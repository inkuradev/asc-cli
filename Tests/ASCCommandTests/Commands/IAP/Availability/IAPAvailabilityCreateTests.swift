import Mockable
import Testing
@testable import ASCCommand
@testable import Domain

@Suite
struct IAPAvailabilityCreateTests {

    @Test func `create availability shows created record with territories`() async throws {
        let mockRepo = MockInAppPurchaseAvailabilityRepository()
        given(mockRepo).createAvailability(iapId: .any, isAvailableInNewTerritories: .any, territoryIds: .any)
            .willReturn(InAppPurchaseAvailability(
                id: "avail-new",
                iapId: "iap-42",
                isAvailableInNewTerritories: true,
                territories: ["USA"]
            ))

        let cmd = try IAPAvailabilityCreate.parse([
            "--iap-id", "iap-42",
            "--available-in-new-territories",
            "--territory", "USA",
            "--pretty",
        ])
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
              "id" : "avail-new",
              "isAvailableInNewTerritories" : true,
              "territories" : [
                "USA"
              ]
            }
          ]
        }
        """)
    }
}
