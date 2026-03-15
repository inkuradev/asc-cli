@preconcurrency import AppStoreConnect_Swift_SDK
import Testing
@testable import Infrastructure
@testable import Domain

@Suite
struct SDKSubscriptionAvailabilityRepositoryTests {

    @Test func `getAvailability injects subscriptionId into response`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(SubscriptionAvailabilityResponse(
            data: SubscriptionAvailability(
                type: .subscriptionAvailabilities,
                id: "avail-1",
                attributes: .init(isAvailableInNewTerritories: true),
                relationships: .init(availableTerritories: .init(data: [
                    .init(type: .territories, id: "USA"),
                    .init(type: .territories, id: "GBR"),
                ]))
            ),
            links: .init(this: "")
        ))

        let repo = SDKSubscriptionAvailabilityRepository(client: stub)
        let result = try await repo.getAvailability(subscriptionId: "sub-99")

        #expect(result.id == "avail-1")
        #expect(result.subscriptionId == "sub-99")
        #expect(result.isAvailableInNewTerritories == true)
        #expect(result.territories == ["USA", "GBR"])
    }

    @Test func `getAvailability maps empty territories when relationship data is nil`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(SubscriptionAvailabilityResponse(
            data: SubscriptionAvailability(
                type: .subscriptionAvailabilities,
                id: "avail-2",
                attributes: .init(isAvailableInNewTerritories: false)
            ),
            links: .init(this: "")
        ))

        let repo = SDKSubscriptionAvailabilityRepository(client: stub)
        let result = try await repo.getAvailability(subscriptionId: "sub-1")

        #expect(result.territories == [])
        #expect(result.isAvailableInNewTerritories == false)
    }

    @Test func `createAvailability injects subscriptionId into response`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(SubscriptionAvailabilityResponse(
            data: SubscriptionAvailability(
                type: .subscriptionAvailabilities,
                id: "avail-new",
                attributes: .init(isAvailableInNewTerritories: false),
                relationships: .init(availableTerritories: .init(data: [
                    .init(type: .territories, id: "JPN"),
                ]))
            ),
            links: .init(this: "")
        ))

        let repo = SDKSubscriptionAvailabilityRepository(client: stub)
        let result = try await repo.createAvailability(
            subscriptionId: "sub-42",
            isAvailableInNewTerritories: false,
            territoryIds: ["JPN"]
        )

        #expect(result.id == "avail-new")
        #expect(result.subscriptionId == "sub-42")
        #expect(result.territories == ["JPN"])
    }
}
