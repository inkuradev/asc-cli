import Foundation
import Mockable
import Testing
@testable import ASCCommand
@testable import Domain

@Suite
struct ScreenshotsImportTests {

    // MARK: - Helpers

    private func makeManifest(
        locale: String = "en-US",
        displayType: ScreenshotDisplayType = .iphone67,
        files: [String] = ["en-US/1.png"]
    ) -> ScreenshotManifest {
        ScreenshotManifest(
            version: "1.0",
            exportedAt: nil,
            localizations: [
                locale: ScreenshotManifest.LocalizationManifest(
                    displayType: displayType,
                    screenshots: files.enumerated().map { i, file in
                        ScreenshotManifest.ScreenshotEntry(order: i + 1, file: file)
                    }
                )
            ]
        )
    }

    private func makeImageURLs(_ files: [String]) -> [String: URL] {
        Dictionary(uniqueKeysWithValues: files.map { ($0, URL(fileURLWithPath: "/fake/\($0)")) })
    }

    private func makeLocalization(id: String = "loc-1", locale: String = "en-US") -> AppStoreVersionLocalization {
        AppStoreVersionLocalization(id: id, versionId: "v1", locale: locale)
    }

    private func makeSet(id: String = "set-1", displayType: ScreenshotDisplayType = .iphone67, repo: any ScreenshotRepository) -> AppScreenshotSet {
        AppScreenshotSet(id: id, localizationId: "loc-1", screenshotDisplayType: displayType, repo: repo)
    }

    private func makeScreenshot(id: String = "img-1", fileName: String = "1.png") -> AppScreenshot {
        AppScreenshot(id: id, setId: "set-1", fileName: fileName, fileSize: 1_048_576)
    }

    // MARK: - Output format

    @Test func `execute formats uploaded screenshots as JSON`() async throws {
        let mockRepo = MockScreenshotRepository()
        given(mockRepo).listLocalizations(versionId: .any).willReturn([makeLocalization()])
        given(mockRepo).listScreenshotSets(localizationId: .any).willReturn([makeSet(repo: mockRepo)])
        given(mockRepo).uploadScreenshot(setId: .any, fileURL: .any).willReturn(makeScreenshot(id: "img-1", fileName: "1.png"))

        let cmd = try ScreenshotsImport.parse(["--version-id", "v1", "--from", "/fake.zip", "--pretty"])
        let output = try await cmd.execute(
            repo: mockRepo,
            manifest: makeManifest(),
            imageURLs: makeImageURLs(["en-US/1.png"])
        )

        #expect(output.contains("img-1"))
        #expect(output.contains("1.png"))
    }

    // MARK: - Find-or-create localization

    @Test func `execute reuses existing localization when locale matches`() async throws {
        let mockRepo = MockScreenshotRepository()
        given(mockRepo).listLocalizations(versionId: .any).willReturn([makeLocalization(id: "loc-existing", locale: "en-US")])
        given(mockRepo).listScreenshotSets(localizationId: .value("loc-existing")).willReturn([makeSet(repo: mockRepo)])
        given(mockRepo).uploadScreenshot(setId: .any, fileURL: .any).willReturn(makeScreenshot())

        let cmd = try ScreenshotsImport.parse(["--version-id", "v1", "--from", "/fake.zip"])
        _ = try await cmd.execute(
            repo: mockRepo,
            manifest: makeManifest(locale: "en-US"),
            imageURLs: makeImageURLs(["en-US/1.png"])
        )
        verify(mockRepo).createLocalization(versionId: .any, locale: .any).called(.never)
    }

    @Test func `execute creates localization when locale is not found`() async throws {
        let mockRepo = MockScreenshotRepository()
        given(mockRepo).listLocalizations(versionId: .any).willReturn([])
        given(mockRepo).createLocalization(versionId: .any, locale: .any)
            .willReturn(AppStoreVersionLocalization(id: "loc-new", versionId: "v1", locale: "ja"))
        given(mockRepo).listScreenshotSets(localizationId: .any).willReturn([makeSet(repo: mockRepo)])
        given(mockRepo).uploadScreenshot(setId: .any, fileURL: .any).willReturn(makeScreenshot())

        let cmd = try ScreenshotsImport.parse(["--version-id", "v1", "--from", "/fake.zip"])
        _ = try await cmd.execute(
            repo: mockRepo,
            manifest: makeManifest(locale: "ja", files: ["ja/1.png"]),
            imageURLs: makeImageURLs(["ja/1.png"])
        )
        verify(mockRepo).createLocalization(versionId: .value("v1"), locale: .value("ja")).called(.once)
    }

    // MARK: - Find-or-create screenshot set

    @Test func `execute reuses existing screenshot set when display type matches`() async throws {
        let mockRepo = MockScreenshotRepository()
        given(mockRepo).listLocalizations(versionId: .any).willReturn([makeLocalization()])
        given(mockRepo).listScreenshotSets(localizationId: .any)
            .willReturn([makeSet(id: "set-existing", displayType: .iphone67, repo: mockRepo)])
        given(mockRepo).uploadScreenshot(setId: .any, fileURL: .any).willReturn(makeScreenshot())

        let cmd = try ScreenshotsImport.parse(["--version-id", "v1", "--from", "/fake.zip"])
        _ = try await cmd.execute(
            repo: mockRepo,
            manifest: makeManifest(displayType: .iphone67),
            imageURLs: makeImageURLs(["en-US/1.png"])
        )
        verify(mockRepo).createScreenshotSet(localizationId: .any, displayType: .any).called(.never)
    }

    @Test func `execute creates screenshot set when display type is not found`() async throws {
        let mockRepo = MockScreenshotRepository()
        given(mockRepo).listLocalizations(versionId: .any).willReturn([makeLocalization()])
        given(mockRepo).listScreenshotSets(localizationId: .any).willReturn([])
        given(mockRepo).createScreenshotSet(localizationId: .any, displayType: .any)
            .willReturn(makeSet(id: "set-new", displayType: .iphone67, repo: mockRepo))
        given(mockRepo).uploadScreenshot(setId: .any, fileURL: .any).willReturn(makeScreenshot())

        let cmd = try ScreenshotsImport.parse(["--version-id", "v1", "--from", "/fake.zip"])
        _ = try await cmd.execute(
            repo: mockRepo,
            manifest: makeManifest(displayType: .iphone67),
            imageURLs: makeImageURLs(["en-US/1.png"])
        )
        verify(mockRepo).createScreenshotSet(localizationId: .value("loc-1"), displayType: .value(.iphone67)).called(.once)
    }
}
