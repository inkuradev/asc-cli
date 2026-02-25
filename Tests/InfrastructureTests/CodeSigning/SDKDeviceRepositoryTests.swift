@preconcurrency import AppStoreConnect_Swift_SDK
import Testing
@testable import Infrastructure
@testable import Domain

@Suite
struct SDKDeviceRepositoryTests {

    @Test func `listDevices maps name udid and deviceClass`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(DevicesResponse(
            data: [
                AppStoreConnect_Swift_SDK.Device(
                    type: .devices,
                    id: "dev-1",
                    attributes: .init(
                        name: "My iPhone",
                        platform: .ios,
                        udid: "ABC-123",
                        deviceClass: .iphone,
                        status: .enabled,
                        model: "iPhone 16 Pro"
                    )
                ),
            ],
            links: .init(this: "")
        ))

        let repo = SDKDeviceRepository(client: stub)
        let result = try await repo.listDevices(platform: nil)

        #expect(result[0].id == "dev-1")
        #expect(result[0].name == "My iPhone")
        #expect(result[0].udid == "ABC-123")
        #expect(result[0].deviceClass == .iPhone)
        #expect(result[0].platform == .iOS)
        #expect(result[0].model == "iPhone 16 Pro")
        #expect(result[0].isEnabled == true)
    }

    @Test func `listDevices maps disabled status`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(DevicesResponse(
            data: [
                AppStoreConnect_Swift_SDK.Device(
                    type: .devices,
                    id: "dev-1",
                    attributes: .init(name: "Old iPhone", platform: .ios, udid: "XYZ", deviceClass: .iphone, status: .disabled)
                ),
            ],
            links: .init(this: "")
        ))

        let repo = SDKDeviceRepository(client: stub)
        let result = try await repo.listDevices(platform: nil)

        #expect(result[0].isEnabled == false)
    }
}
