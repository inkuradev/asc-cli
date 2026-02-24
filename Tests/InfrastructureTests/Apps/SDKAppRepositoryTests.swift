@preconcurrency import AppStoreConnect_Swift_SDK
import Testing
@testable import Infrastructure
@testable import Domain

@Suite
struct SDKAppRepositoryTests {

    @Test func `getApp maps single app from SDK response`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(AppResponse(
            data: App(
                type: .apps,
                id: "app-99",
                attributes: .init(name: "Single App", bundleID: "com.single", sku: "S1")
            ),
            links: .init(this: "")
        ))

        let repo = SDKAppRepository(client: stub)
        let result = try await repo.getApp(id: "app-99")

        #expect(result.id == "app-99")
        #expect(result.displayName == "Single App")
        #expect(result.bundleId == "com.single")
    }

    @Test func `listApps maps name bundleId and sku from SDK attributes`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(AppsResponse(
            data: [
                App(
                    type: .apps,
                    id: "app-1",
                    attributes: .init(name: "My App", bundleID: "com.example.app", sku: "APP001")
                ),
            ],
            links: .init(this: "")
        ))

        let repo = SDKAppRepository(client: stub)
        let result = try await repo.listApps(limit: nil)

        #expect(result.data[0].id == "app-1")
        #expect(result.data[0].displayName == "My App")
        #expect(result.data[0].bundleId == "com.example.app")
        #expect(result.data[0].sku == "APP001")
    }
}
