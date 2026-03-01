import Mockable
import Testing
@testable import ASCCommand
@testable import Domain

@Suite
struct AgeRatingUpdateTests {

    @Test func `age-rating update returns updated declaration`() async throws {
        let mockRepo = MockAgeRatingDeclarationRepository()
        given(mockRepo).updateDeclaration(id: .any, update: .any)
            .willReturn(AgeRatingDeclaration(
                id: "decl-1",
                appInfoId: "",
                isAdvertising: false,
                violenceRealistic: ContentIntensity.none
            ))

        let cmd = try AgeRatingUpdate.parse([
            "--declaration-id", "decl-1",
            "--advertising", "false",
            "--violence-realistic", "NONE",
            "--pretty",
        ])
        let output = try await cmd.execute(repo: mockRepo)

        #expect(output.contains("\"id\" : \"decl-1\""))
        #expect(output.contains("\"isAdvertising\" : false"))
        #expect(output.contains("\"NONE\""))
    }

    @Test func `age-rating update passes only specified flags`() async throws {
        let mockRepo = MockAgeRatingDeclarationRepository()

        var capturedUpdate: AgeRatingDeclarationUpdate?
        given(mockRepo).updateDeclaration(id: .any, update: .any)
            .willProduce { _, update in
                capturedUpdate = update
                return AgeRatingDeclaration(id: "decl-1", appInfoId: "")
            }

        let cmd = try AgeRatingUpdate.parse([
            "--declaration-id", "decl-1",
            "--gambling", "true",
            "--violence-cartoon", "INFREQUENT_OR_MILD",
            "--age-rating-override", "THIRTEEN_PLUS",
        ])
        _ = try await cmd.execute(repo: mockRepo)

        let update = try #require(capturedUpdate)
        #expect(update.isGambling == true)
        #expect(update.violenceCartoonOrFantasy == .infrequentOrMild)
        #expect(update.ageRatingOverride == .thirteenPlus)
        #expect(update.isAdvertising == nil)
        #expect(update.violenceRealistic == nil)
    }
}
