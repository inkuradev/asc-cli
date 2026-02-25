import Mockable
import Testing
@testable import ASCCommand
@testable import Domain

@Suite
struct DevicesListTests {

    @Test func `listed devices include udid class status and affordances`() async throws {
        let mockRepo = MockDeviceRepository()
        given(mockRepo).listDevices(platform: .any).willReturn([
            Device(
                id: "dev-1",
                name: "My iPhone",
                udid: "ABC-123",
                deviceClass: .iPhone,
                platform: .iOS,
                status: .enabled
            ),
        ])

        let cmd = try DevicesList.parse(["--pretty"])
        let output = try await cmd.execute(repo: mockRepo)

        #expect(output == """
        {
          "data" : [
            {
              "affordances" : {
                "listDevices" : "asc devices list"
              },
              "deviceClass" : "IPHONE",
              "id" : "dev-1",
              "name" : "My iPhone",
              "platform" : "IOS",
              "status" : "ENABLED",
              "udid" : "ABC-123"
            }
          ]
        }
        """)
    }
}
