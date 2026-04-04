import Foundation
import Mockable
import Testing
@testable import ASCCommand
@testable import Domain

@Suite
struct AppShotsGenerateTests {

    private static let fakePNG: Data = {
        var bytes: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        bytes += [UInt8](repeating: 0, count: 200)
        return Data(bytes)
    }()

    private func makeTempFile() throws -> String {
        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-\(UUID().uuidString).png").path
        try Self.fakePNG.write(to: URL(fileURLWithPath: path))
        return path
    }

    private func makeTempOutputDir() -> String {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("app-shots-test-\(UUID().uuidString)").path
    }

    @Test func `generate enhances file and saves output`() async throws {
        let file = try makeTempFile()
        let outputDir = makeTempOutputDir()
        defer {
            try? FileManager.default.removeItem(atPath: file)
            try? FileManager.default.removeItem(atPath: outputDir)
        }

        let mockRepo = MockScreenshotGenerationRepository()
        given(mockRepo).generateImages(plan: .any, screenshotURLs: .any, styleReferenceURL: .any)
            .willReturn([0: Self.fakePNG])

        let cmd = try AppShotsGenerate.parse(["--file", file, "--output-dir", outputDir])
        let output = try await cmd.execute(repo: mockRepo)

        #expect(output.contains("screen-0.png"))
        #expect(FileManager.default.fileExists(atPath: "\(outputDir)/screen-0.png"))
    }

    @Test func `generate throws when file not found`() async throws {
        let mockRepo = MockScreenshotGenerationRepository()
        let cmd = try AppShotsGenerate.parse(["--file", "/nonexistent.png"])
        do {
            _ = try await cmd.execute(repo: mockRepo)
            Issue.record("Expected error")
        } catch {
            #expect(String(describing: error).contains("not found"))
        }
    }

    @Test func `generate with style reference passes it to repo`() async throws {
        let file = try makeTempFile()
        let styleRef = try makeTempFile()
        let outputDir = makeTempOutputDir()
        defer {
            try? FileManager.default.removeItem(atPath: file)
            try? FileManager.default.removeItem(atPath: styleRef)
            try? FileManager.default.removeItem(atPath: outputDir)
        }

        var capturedRef: URL?
        let mockRepo = MockScreenshotGenerationRepository()
        given(mockRepo).generateImages(plan: .any, screenshotURLs: .any, styleReferenceURL: .any)
            .willProduce { _, _, ref in
                capturedRef = ref
                return [0: Self.fakePNG]
            }

        let cmd = try AppShotsGenerate.parse([
            "--file", file,
            "--output-dir", outputDir,
            "--style-reference", styleRef,
        ])
        _ = try await cmd.execute(repo: mockRepo)

        #expect(capturedRef == URL(fileURLWithPath: styleRef))
    }

    @Test func `generate with custom prompt uses it`() async throws {
        let file = try makeTempFile()
        let outputDir = makeTempOutputDir()
        defer {
            try? FileManager.default.removeItem(atPath: file)
            try? FileManager.default.removeItem(atPath: outputDir)
        }

        var capturedPlan: ScreenshotDesign?
        let mockRepo = MockScreenshotGenerationRepository()
        given(mockRepo).generateImages(plan: .any, screenshotURLs: .any, styleReferenceURL: .any)
            .willProduce { plan, _, _ in
                capturedPlan = plan
                return [0: Self.fakePNG]
            }

        let cmd = try AppShotsGenerate.parse([
            "--file", file,
            "--output-dir", outputDir,
            "--prompt", "add warm glow and shadows",
        ])
        _ = try await cmd.execute(repo: mockRepo)

        #expect(capturedPlan?.screens[0].imagePrompt == "add warm glow and shadows")
    }

    @Test func `generate table output`() async throws {
        let file = try makeTempFile()
        let outputDir = makeTempOutputDir()
        defer {
            try? FileManager.default.removeItem(atPath: file)
            try? FileManager.default.removeItem(atPath: outputDir)
        }

        let mockRepo = MockScreenshotGenerationRepository()
        given(mockRepo).generateImages(plan: .any, screenshotURLs: .any, styleReferenceURL: .any)
            .willReturn([0: Self.fakePNG])

        let cmd = try AppShotsGenerate.parse(["--file", file, "--output-dir", outputDir, "--output", "table"])
        let output = try await cmd.execute(repo: mockRepo)

        #expect(output.contains("| Screen | File |"))
        #expect(output.contains("screen-0.png"))
    }

    @Test func `style reference throws when not found`() async throws {
        let file = try makeTempFile()
        defer { try? FileManager.default.removeItem(atPath: file) }

        let mockRepo = MockScreenshotGenerationRepository()
        let cmd = try AppShotsGenerate.parse([
            "--file", file,
            "--style-reference", "/nonexistent/ref.png",
        ])
        do {
            _ = try await cmd.execute(repo: mockRepo)
            Issue.record("Expected error")
        } catch {
            #expect(String(describing: error).contains("not found"))
        }
    }
}
