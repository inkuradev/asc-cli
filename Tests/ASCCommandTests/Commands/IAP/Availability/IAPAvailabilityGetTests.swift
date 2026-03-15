import Mockable
import Testing
@testable import ASCCommand
@testable import Domain

@Suite
struct IAPAvailabilityGetTests {

    @Test func `get availability shows iapId, territories and affordances`() async throws {
        let mockRepo = MockInAppPurchaseAvailabilityRepository()
        given(mockRepo).getAvailability(iapId: .any)
            .willReturn(InAppPurchaseAvailability(
                id: "avail-1",
                iapId: "iap-42",
                isAvailableInNewTerritories: true,
                territories: ["USA", "CHN"]
            ))

        let cmd = try IAPAvailabilityGet.parse(["--iap-id", "iap-42", "--pretty"])
        let output = try await cmd.execute(repo: mockRepo)

        #expect(output == """
        {
          "data" : [
            {
              "affordances" : {
                "createAvailability" : "asc iap-availability create --iap-id iap-42 --available-in-new-territories --territory USA --territory CHN",
                "getAvailability" : "asc iap-availability get --iap-id iap-42"
              },
              "iapId" : "iap-42",
              "id" : "avail-1",
              "isAvailableInNewTerritories" : true,
              "territories" : [
                "USA",
                "CHN"
              ]
            }
          ]
        }
        """)
    }
}
