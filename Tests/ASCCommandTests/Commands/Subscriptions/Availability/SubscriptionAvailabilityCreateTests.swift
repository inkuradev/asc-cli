import Mockable
import Testing
@testable import ASCCommand
@testable import Domain

@Suite
struct SubscriptionAvailabilityCreateTests {

    @Test func `create availability shows created record with territories`() async throws {
        let mockRepo = MockSubscriptionAvailabilityRepository()
        given(mockRepo).createAvailability(subscriptionId: .any, isAvailableInNewTerritories: .any, territoryIds: .any)
            .willReturn(SubscriptionAvailability(
                id: "avail-new",
                subscriptionId: "sub-42",
                isAvailableInNewTerritories: true,
                territories: ["JPN"]
            ))

        let cmd = try SubscriptionAvailabilityCreate.parse([
            "--subscription-id", "sub-42",
            "--available-in-new-territories",
            "--territory", "JPN",
            "--pretty",
        ])
        let output = try await cmd.execute(repo: mockRepo)

        #expect(output == """
        {
          "data" : [
            {
              "affordances" : {
                "createAvailability" : "asc subscription-availability create --subscription-id sub-42 --available-in-new-territories --territory USA --territory CHN",
                "getAvailability" : "asc subscription-availability get --subscription-id sub-42"
              },
              "id" : "avail-new",
              "isAvailableInNewTerritories" : true,
              "subscriptionId" : "sub-42",
              "territories" : [
                "JPN"
              ]
            }
          ]
        }
        """)
    }
}
