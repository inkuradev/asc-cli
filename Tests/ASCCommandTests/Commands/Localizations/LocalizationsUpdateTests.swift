import Mockable
import Testing
@testable import ASCCommand
@testable import Domain

@Suite
struct LocalizationsUpdateTests {

    @Test func `execute json output`() async throws {
        let mockRepo = MockVersionLocalizationRepository()
        given(mockRepo).updateLocalization(
            localizationId: .any,
            whatsNew: .any,
            description: .any,
            keywords: .any,
            marketingUrl: .any,
            supportUrl: .any,
            promotionalText: .any
        ).willReturn(
            AppStoreVersionLocalization(
                id: "loc-1",
                versionId: "v-1",
                locale: "en-US",
                whatsNew: "Bug fixes and performance improvements"
            )
        )

        let cmd = try LocalizationsUpdate.parse([
            "--localization-id", "loc-1",
            "--whats-new", "Bug fixes and performance improvements",
            "--pretty",
        ])
        let output = try await cmd.execute(repo: mockRepo)

        #expect(output == """
        {
          "data" : [
            {
              "affordances" : {
                "listLocalizations" : "asc localizations list --version-id v-1",
                "listScreenshotSets" : "asc screenshot-sets list --localization-id loc-1",
                "updateLocalization" : "asc localizations update --localization-id loc-1"
              },
              "id" : "loc-1",
              "locale" : "en-US",
              "versionId" : "v-1",
              "whatsNew" : "Bug fixes and performance improvements"
            }
          ]
        }
        """)
    }

    @Test func `execute passes whatsNew to repository`() async throws {
        let mockRepo = MockVersionLocalizationRepository()
        given(mockRepo).updateLocalization(
            localizationId: .value("loc-42"),
            whatsNew: .value("New features"),
            description: .value(nil),
            keywords: .value(nil),
            marketingUrl: .value(nil),
            supportUrl: .value(nil),
            promotionalText: .value(nil)
        ).willReturn(
            AppStoreVersionLocalization(id: "loc-42", versionId: "v-1", locale: "en-US", whatsNew: "New features")
        )

        let cmd = try LocalizationsUpdate.parse(["--localization-id", "loc-42", "--whats-new", "New features"])
        _ = try await cmd.execute(repo: mockRepo)
    }

    @Test func `execute passes all text fields to repository`() async throws {
        let mockRepo = MockVersionLocalizationRepository()
        given(mockRepo).updateLocalization(
            localizationId: .any,
            whatsNew: .any,
            description: .any,
            keywords: .any,
            marketingUrl: .any,
            supportUrl: .any,
            promotionalText: .any
        ).willReturn(
            AppStoreVersionLocalization(id: "loc-1", versionId: "v-1", locale: "zh-Hans")
        )

        let cmd = try LocalizationsUpdate.parse([
            "--localization-id", "loc-1",
            "--whats-new", "新功能",
            "--description", "应用描述",
            "--keywords", "关键词",
            "--marketing-url", "https://example.com",
            "--support-url", "https://support.example.com",
            "--promotional-text", "促销文本",
        ])
        _ = try await cmd.execute(repo: mockRepo)
    }
}
