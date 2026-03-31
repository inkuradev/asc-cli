import Foundation

/// Manages AXe stream-video subprocesses and distributes frames to connected clients.
/// AXe outputs MJPEG with HTTP multipart headers; we strip the HTTP header and re-serve
/// frames ourselves to support multiple clients.
public final class AXeStreamManager: @unchecked Sendable {
    private var process: Process?
    private var pipe: Pipe?
    private let lock = NSLock()
    private var latestFrame: Data?
    private var parseBuffer = Data()
    private var httpHeaderSkipped = false
    private let axePath: String?

    public init() {
        self.axePath = Self.resolveAxe()
    }

    public var isAvailable: Bool { axePath != nil }

    /// The most recent captured frame (JPEG data), or nil if no frames yet.
    public var currentFrame: Data? {
        lock.lock()
        defer { lock.unlock() }
        return latestFrame
    }

    /// Start streaming from a simulator.
    public func start(udid: String, fps: Int = 10, quality: Int = 75, scale: Double = 0.5) {
        guard let axe = axePath else { return }
        stop()

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: axe)
        proc.arguments = [
            "stream-video",
            "--udid", udid,
            "--format", "mjpeg",
            "--fps", "\(fps)",
            "--quality", "\(quality)",
            "--scale", "\(scale)",
        ]
        proc.standardError = FileHandle.nullDevice

        let stdout = Pipe()
        proc.standardOutput = stdout
        self.pipe = stdout
        self.process = proc
        self.parseBuffer = Data()
        self.httpHeaderSkipped = false

        stdout.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let chunk = handle.availableData
            guard !chunk.isEmpty, let self else { return }

            self.parseBuffer.append(chunk)

            // Skip the initial HTTP header (ends with \r\n\r\n)
            if !self.httpHeaderSkipped {
                if let range = self.parseBuffer.range(of: Data("\r\n\r\n".utf8)) {
                    self.parseBuffer = Data(self.parseBuffer[range.upperBound...])
                    self.httpHeaderSkipped = true
                } else {
                    return
                }
            }

            self.extractFrames(from: &self.parseBuffer)
        }

        do {
            try proc.run()
        } catch {
            self.process = nil
            self.pipe = nil
        }
    }

    public func stop() {
        pipe?.fileHandleForReading.readabilityHandler = nil
        if let proc = process, proc.isRunning {
            proc.terminate()
        }
        process = nil
        pipe = nil
    }

    // MARK: - Frame Parsing

    private let boundary = Data("--mjpegstream".utf8)
    private let headerEnd = Data("\r\n\r\n".utf8)

    private func extractFrames(from buffer: inout Data) {
        while true {
            // Find boundary
            guard let boundaryRange = buffer.range(of: boundary) else { break }

            // Find end of frame headers (after boundary)
            let afterBoundary = boundaryRange.upperBound
            guard afterBoundary < buffer.count else { break }

            let remaining = Data(buffer[afterBoundary...])
            guard let headerEndRange = remaining.range(of: headerEnd) else { break }

            // Extract Content-Length from headers
            let headerData = Data(remaining[remaining.startIndex..<headerEndRange.lowerBound])
            let headerStr = String(data: headerData, encoding: .utf8) ?? ""

            var contentLength: Int?
            for line in headerStr.split(separator: "\r\n") {
                if line.lowercased().hasPrefix("content-length:") {
                    let value = line.dropFirst("content-length:".count).trimmingCharacters(in: .whitespaces)
                    contentLength = Int(value)
                }
            }

            guard let length = contentLength else {
                // Can't determine frame size; skip this boundary and try next
                buffer = Data(buffer[boundaryRange.upperBound...])
                continue
            }

            let frameStart = buffer.startIndex + (afterBoundary - buffer.startIndex) + (headerEndRange.upperBound - remaining.startIndex)
            let frameEnd = frameStart + length

            guard frameEnd <= buffer.count else {
                // Incomplete frame — wait for more data
                break
            }

            let frame = Data(buffer[frameStart..<frameEnd])

            // Validate it's a JPEG (starts with FFD8)
            if frame.count > 2, frame[frame.startIndex] == 0xFF, frame[frame.startIndex + 1] == 0xD8 {
                lock.lock()
                latestFrame = frame
                lock.unlock()
            }

            // Consume processed data
            buffer = Data(buffer[frameEnd...])
        }
    }

    private static func resolveAxe() -> String? {
        for path in ["/opt/homebrew/bin/axe", "/usr/local/bin/axe"] {
            if FileManager.default.fileExists(atPath: path) { return path }
        }
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        proc.arguments = ["axe"]
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = FileHandle.nullDevice
        try? proc.run()
        proc.waitUntilExit()
        if proc.terminationStatus == 0 {
            let out = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let out, !out.isEmpty { return out }
        }
        return nil
    }
}
