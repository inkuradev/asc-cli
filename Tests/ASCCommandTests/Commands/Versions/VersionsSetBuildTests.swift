import Mockable
import Testing
@testable import ASCCommand
@testable import Domain

@Suite
struct VersionsSetBuildTests {

    @Test func `execute links build to version`() async throws {
        let mockRepo = MockVersionRepository()
        given(mockRepo).setBuild(versionId: .any, buildId: .any).willReturn()

        let cmd = try VersionsSetBuild.parse(["--version-id", "v-1", "--build-id", "build-42"])
        try await cmd.execute(repo: mockRepo)

        verify(mockRepo).setBuild(versionId: .value("v-1"), buildId: .value("build-42")).called(.once)
    }
}
