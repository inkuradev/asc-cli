import Mockable
import Testing
@testable import ASCCommand
@testable import Domain

@Suite
struct BuildsAddBetaGroupTests {

    @Test func `execute adds beta group to build`() async throws {
        let mockRepo = MockBuildRepository()
        given(mockRepo).addBetaGroups(buildId: .any, betaGroupIds: .any).willReturn()

        let cmd = try BuildsAddBetaGroup.parse(["--build-id", "build-1", "--beta-group-id", "bg-42"])
        try await cmd.execute(repo: mockRepo)

        verify(mockRepo).addBetaGroups(buildId: .value("build-1"), betaGroupIds: .value(["bg-42"])).called(.once)
    }
}
