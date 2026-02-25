@preconcurrency import AppStoreConnect_Swift_SDK
import Testing
@testable import Infrastructure
@testable import Domain

@Suite
struct SDKBundleIDRepositoryTests {

    @Test func `listBundleIDs maps identifier and platform`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(BundleIDsResponse(
            data: [
                AppStoreConnect_Swift_SDK.BundleID(
                    type: .bundleIDs,
                    id: "bid-1",
                    attributes: .init(name: "My App", platform: .ios, identifier: "com.example.app")
                ),
            ],
            links: .init(this: "")
        ))

        let repo = SDKBundleIDRepository(client: stub)
        let result = try await repo.listBundleIDs(platform: nil, identifier: nil)

        #expect(result[0].id == "bid-1")
        #expect(result[0].name == "My App")
        #expect(result[0].identifier == "com.example.app")
        #expect(result[0].platform == .iOS)
    }

    @Test func `listBundleIDs maps macOS platform`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(BundleIDsResponse(
            data: [
                AppStoreConnect_Swift_SDK.BundleID(
                    type: .bundleIDs,
                    id: "bid-2",
                    attributes: .init(name: "Mac App", platform: .macOs, identifier: "com.example.mac")
                ),
            ],
            links: .init(this: "")
        ))

        let repo = SDKBundleIDRepository(client: stub)
        let result = try await repo.listBundleIDs(platform: nil, identifier: nil)

        #expect(result[0].platform == .macOS)
    }

    @Test func `deleteBundleID calls void endpoint`() async throws {
        let stub = StubAPIClient()
        let repo = SDKBundleIDRepository(client: stub)

        try await repo.deleteBundleID(id: "bid-1")

        #expect(stub.voidRequestCalled == true)
    }
}
