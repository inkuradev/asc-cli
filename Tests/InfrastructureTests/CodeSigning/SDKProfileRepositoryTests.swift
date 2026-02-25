@preconcurrency import AppStoreConnect_Swift_SDK
import Testing
@testable import Infrastructure
@testable import Domain

@Suite
struct SDKProfileRepositoryTests {

    @Test func `listProfiles injects bundleIdId from request when filtering by bundle id`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(ProfilesWithoutIncludesResponse(
            data: [
                AppStoreConnect_Swift_SDK.Profile(
                    type: .profiles,
                    id: "prof-1",
                    attributes: .init(name: "My Profile", profileType: .iosAppStore, profileState: .active)
                ),
            ],
            links: .init(this: "")
        ))

        let repo = SDKProfileRepository(client: stub)
        let result = try await repo.listProfiles(bundleIdId: "bid-99", profileType: nil)

        #expect(result[0].id == "prof-1")
        #expect(result[0].bundleIdId == "bid-99")
        #expect(result[0].profileType == .iosAppStore)
        #expect(result[0].isActive == true)
    }

    @Test func `listProfiles extracts bundleIdId from relationship when no filter`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(ProfilesResponse(
            data: [
                AppStoreConnect_Swift_SDK.Profile(
                    type: .profiles,
                    id: "prof-1",
                    attributes: .init(name: "My Profile", profileType: .macAppStore, profileState: .active),
                    relationships: .init(
                        bundleID: .init(data: .init(type: .bundleIDs, id: "bid-from-relationship"))
                    )
                ),
            ],
            links: .init(this: "")
        ))

        let repo = SDKProfileRepository(client: stub)
        let result = try await repo.listProfiles(bundleIdId: nil, profileType: nil)

        #expect(result[0].bundleIdId == "bid-from-relationship")
        #expect(result[0].profileType == .macAppStore)
    }

    @Test func `deleteProfile calls void endpoint`() async throws {
        let stub = StubAPIClient()
        let repo = SDKProfileRepository(client: stub)

        try await repo.deleteProfile(id: "prof-1")

        #expect(stub.voidRequestCalled == true)
    }
}
