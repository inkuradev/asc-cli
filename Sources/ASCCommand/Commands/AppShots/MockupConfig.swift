import CoreGraphics
import Foundation
import ImageIO

/// A device mockup entry describing a frame PNG and its screen inset coordinates.
///
/// Users can add their own mockups by placing a `mockups.json` and PNG files in `~/.asc/mockups/`.
/// The format mirrors the bundled default config:
///
/// ```json
/// {
///   "iPhone 17 Pro Max - Deep Blue": {
///     "category": "iPhone",
///     "model": "iPhone 17 Pro Max",
///     "displayType": "APP_IPHONE_67",
///     "outputWidth": 1470,
///     "outputHeight": 3000,
///     "screenInsetX": 75,
///     "screenInsetY": 66,
///     "file": "iPhone 17 Pro Max - Deep Blue - Portrait.png",
///     "default": true
///   }
/// }
/// ```
struct MockupEntry: Codable, Sendable {
    let category: String?
    let model: String?
    let displayType: String?
    let outputWidth: Int
    let outputHeight: Int
    let screenInsetX: Int
    let screenInsetY: Int
    let file: String
    let `default`: Bool?
}

/// Resolves a device mockup frame from bundled resources or `~/.asc/mockups/`.
///
/// Resolution order:
/// 1. If `--mockup` is a file path → use directly (with optional `--screen-inset-x/y` or devices.json lookup)
/// 2. If `--mockup` is a device name → look up in `~/.asc/mockups/mockups.json`, then bundled `mockups.json`
/// 3. If `--mockup` is omitted → use the entry marked `"default": true`
enum MockupResolver {

    /// The user-level mockups directory.
    static let userMockupsDir: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".asc/mockups")
    }()

    struct ResolvedMockup {
        let fileURL: URL
        let frameWidth: Int
        let frameHeight: Int
        let screenInsetX: Int
        let screenInsetY: Int
    }

    /// Resolves a mockup from the given CLI argument (name, path, or nil for default).
    /// - Parameters:
    ///   - argument: The `--mockup` value — a file path, device name, or nil.
    ///   - insetXOverride: Explicit `--screen-inset-x` from CLI.
    ///   - insetYOverride: Explicit `--screen-inset-y` from CLI.
    /// - Returns: A resolved mockup with file URL and screen coordinates, or nil if `--mockup none`.
    static func resolve(
        argument: String?,
        insetXOverride: Int?,
        insetYOverride: Int?
    ) throws -> ResolvedMockup? {
        // Explicit opt-out
        if argument == "none" { return nil }

        // Case 1: argument is a file path
        if let arg = argument, FileManager.default.fileExists(atPath: arg) {
            return try resolveFromPath(
                URL(fileURLWithPath: arg),
                insetXOverride: insetXOverride,
                insetYOverride: insetYOverride
            )
        }

        // Case 2: argument is a device name — search configs
        // Case 3: argument is nil — find the default entry
        let (entry, baseDir) = try findEntry(name: argument)

        let fileURL = baseDir.appendingPathComponent(entry.file)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw MockupError.fileNotFound(entry.file, baseDir.path)
        }

        return ResolvedMockup(
            fileURL: fileURL,
            frameWidth: entry.outputWidth,
            frameHeight: entry.outputHeight,
            screenInsetX: insetXOverride ?? entry.screenInsetX,
            screenInsetY: insetYOverride ?? entry.screenInsetY
        )
    }

    // MARK: - Private

    private static func resolveFromPath(
        _ url: URL,
        insetXOverride: Int?,
        insetYOverride: Int?
    ) throws -> ResolvedMockup {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw MockupError.mockupNotFound(url.path)
        }

        // Try to find insets from a nearby devices.json / mockups.json
        let filename = url.lastPathComponent
        if let entry = lookupInNearbyConfigs(filename: filename, startDir: url.deletingLastPathComponent()) {
            return ResolvedMockup(
                fileURL: url,
                frameWidth: entry.outputWidth,
                frameHeight: entry.outputHeight,
                screenInsetX: insetXOverride ?? entry.screenInsetX,
                screenInsetY: insetYOverride ?? entry.screenInsetY
            )
        }

        // Fallback: read image dimensions, use percentage-based insets
        let (w, h) = imageDimensions(url: url)
        return ResolvedMockup(
            fileURL: url,
            frameWidth: w,
            frameHeight: h,
            screenInsetX: insetXOverride ?? Int(Double(w) * 0.052),
            screenInsetY: insetYOverride ?? Int(Double(h) * 0.022)
        )
    }

    /// Finds a mockup entry by name (or the default if name is nil).
    /// Searches user dir first, then bundled resources.
    private static func findEntry(name: String?) throws -> (MockupEntry, URL) {
        // Search order: user dir → bundled
        let searchDirs: [(URL, URL)] = {
            var dirs: [(configURL: URL, baseDir: URL)] = []

            // User mockups
            let userConfig = userMockupsDir.appendingPathComponent("mockups.json")
            if FileManager.default.fileExists(atPath: userConfig.path) {
                dirs.append((userConfig, userMockupsDir))
            }

            // Bundled mockups
            if let bundleDir = Bundle.module.url(forResource: "mockups", withExtension: nil) {
                let bundleConfig = bundleDir.appendingPathComponent("mockups.json")
                if FileManager.default.fileExists(atPath: bundleConfig.path) {
                    dirs.append((bundleConfig, bundleDir))
                }
            }

            return dirs
        }()

        for (configURL, baseDir) in searchDirs {
            guard let data = try? Data(contentsOf: configURL),
                  let entries = try? JSONDecoder().decode([String: MockupEntry].self, from: data) else {
                continue
            }

            if let name = name {
                // Search by name (case-insensitive partial match)
                if let (_, entry) = entries.first(where: { $0.key.localizedCaseInsensitiveContains(name) }) {
                    return (entry, baseDir)
                }
            } else {
                // Find the default entry
                if let (_, entry) = entries.first(where: { $0.value.default == true }) {
                    return (entry, baseDir)
                }
            }
        }

        if let name = name {
            throw MockupError.deviceNotFound(name)
        } else {
            throw MockupError.noDefaultMockup
        }
    }

    /// Searches for mockup entry in nearby config files (mockups.json or devices.json).
    private static func lookupInNearbyConfigs(filename: String, startDir: URL) -> MockupEntry? {
        let stem = filename.replacingOccurrences(of: ".png", with: "")
        var dir = startDir

        for _ in 0..<4 {
            for configName in ["mockups.json", "devices.json"] {
                let configURL = dir.appendingPathComponent(configName)
                guard let data = try? Data(contentsOf: configURL),
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    continue
                }

                for (_, value) in json {
                    guard let info = value as? [String: Any] else { continue }
                    // Match by "file" field or "path" field containing the filename stem
                    let matchesFile = (info["file"] as? String)?.contains(stem) == true
                    let matchesPath = (info["path"] as? String)?.contains(stem) == true
                    if matchesFile || matchesPath,
                       let w = info["outputWidth"] as? Int,
                       let h = info["outputHeight"] as? Int,
                       let ix = info["screenInsetX"] as? Int,
                       let iy = info["screenInsetY"] as? Int {
                        return MockupEntry(
                            category: info["category"] as? String,
                            model: info["model"] as? String,
                            displayType: info["displayType"] as? String,
                            outputWidth: w, outputHeight: h,
                            screenInsetX: ix, screenInsetY: iy,
                            file: filename,
                            default: nil
                        )
                    }
                }
            }
            dir = dir.deletingLastPathComponent()
        }
        return nil
    }

    private static func imageDimensions(url: URL) -> (width: Int, height: Int) {
        guard let fileData = try? Data(contentsOf: url),
              let source = CGImageSourceCreateWithData(fileData as CFData, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let w = props[kCGImagePropertyPixelWidth] as? Int,
              let h = props[kCGImagePropertyPixelHeight] as? Int else {
            return (0, 0)
        }
        return (w, h)
    }
}

enum MockupError: Error, CustomStringConvertible {
    case mockupNotFound(String)
    case fileNotFound(String, String)
    case deviceNotFound(String)
    case noDefaultMockup

    var description: String {
        switch self {
        case .mockupNotFound(let path):
            return "Mockup file not found: \(path)"
        case .fileNotFound(let file, let dir):
            return "Mockup frame file '\(file)' not found in \(dir)"
        case .deviceNotFound(let name):
            return "No mockup device matching '\(name)'. Add your own to ~/.asc/mockups/mockups.json"
        case .noDefaultMockup:
            return "No default mockup found. Check bundled resources or ~/.asc/mockups/mockups.json"
        }
    }
}
