import Foundation

/// Manages a background screenshot capture loop using AXe for fast cached frame serving.
/// Instead of parsing MJPEG streams (which suffer from pipe buffering), this runs
/// `axe screenshot` in a tight loop and caches the latest frame.
public final class AXeStreamManager: @unchecked Sendable {
    private let lock = NSLock()
    private var latestFrame: Data?
    private var captureTask: Task<Void, Never>?
    private var running = false
    private let axePath: String?

    public init() {
        self.axePath = Self.resolveAxe()
    }

    public var isAvailable: Bool { axePath != nil }

    /// The most recent captured frame (JPEG/PNG data), or nil if no frames yet.
    public var currentFrame: Data? {
        lock.lock()
        defer { lock.unlock() }
        return latestFrame
    }

    /// Start a background capture loop for a simulator.
    public func start(udid: String, fps: Int = 10) {
        guard let axe = axePath else { return }
        stop()
        running = true

        let interval = UInt64(1_000_000_000 / max(fps, 1))
        let tmpFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("axe-stream-\(udid).png")

        captureTask = Task.detached { [weak self] in
            while let self, self.running {
                do {
                    // Use axe screenshot for fast capture
                    let proc = Process()
                    proc.executableURL = URL(fileURLWithPath: axe)
                    proc.arguments = ["screenshot", "--output", tmpFile.path, "--udid", udid]
                    proc.standardInput = FileHandle.nullDevice
                    proc.standardOutput = FileHandle.nullDevice
                    proc.standardError = FileHandle.nullDevice
                    try proc.run()
                    proc.waitUntilExit()

                    if proc.terminationStatus == 0 {
                        let data = try Data(contentsOf: tmpFile)
                        self.updateFrame(data)
                    }
                } catch {
                    // Simulator may have shut down
                    break
                }
                try? await Task.sleep(nanoseconds: interval)
            }
        }
    }

    public func stop() {
        running = false
        captureTask?.cancel()
        captureTask = nil
        updateFrame(nil)
    }

    private func updateFrame(_ data: Data?) {
        lock.lock()
        latestFrame = data
        lock.unlock()
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
