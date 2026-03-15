@preconcurrency import AppStoreConnect_Swift_SDK
import Testing
@testable import Infrastructure
@testable import Domain

@Suite
struct SDKInAppPurchaseAvailabilityRepositoryTests {

    @Test func `getAvailability injects iapId into response`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(InAppPurchaseAvailabilityResponse(
            data: InAppPurchaseAvailability(
                type: .inAppPurchaseAvailabilities,
                id: "avail-1",
                attributes: .init(isAvailableInNewTerritories: true),
                relationships: .init(availableTerritories: .init(data: [
                    .init(type: .territories, id: "USA"),
                    .init(type: .territories, id: "CHN"),
                ]))
            ),
            links: .init(this: "")
        ))

        let repo = SDKInAppPurchaseAvailabilityRepository(client: stub)
        let result = try await repo.getAvailability(iapId: "iap-99")

        #expect(result.id == "avail-1")
        #expect(result.iapId == "iap-99")
        #expect(result.isAvailableInNewTerritories == true)
        #expect(result.territories == ["USA", "CHN"])
    }

    @Test func `getAvailability maps empty territories when relationship data is nil`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(InAppPurchaseAvailabilityResponse(
            data: InAppPurchaseAvailability(
                type: .inAppPurchaseAvailabilities,
                id: "avail-2",
                attributes: .init(isAvailableInNewTerritories: false)
            ),
            links: .init(this: "")
        ))

        let repo = SDKInAppPurchaseAvailabilityRepository(client: stub)
        let result = try await repo.getAvailability(iapId: "iap-1")

        #expect(result.territories == [])
        #expect(result.isAvailableInNewTerritories == false)
    }

    @Test func `createAvailability injects iapId into response`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(InAppPurchaseAvailabilityResponse(
            data: InAppPurchaseAvailability(
                type: .inAppPurchaseAvailabilities,
                id: "avail-new",
                attributes: .init(isAvailableInNewTerritories: true),
                relationships: .init(availableTerritories: .init(data: [
                    .init(type: .territories, id: "USA"),
                ]))
            ),
            links: .init(this: "")
        ))

        let repo = SDKInAppPurchaseAvailabilityRepository(client: stub)
        let result = try await repo.createAvailability(
            iapId: "iap-42",
            isAvailableInNewTerritories: true,
            territoryIds: ["USA"]
        )

        #expect(result.id == "avail-new")
        #expect(result.iapId == "iap-42")
        #expect(result.territories == ["USA"])
    }
}
