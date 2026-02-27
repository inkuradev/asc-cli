@preconcurrency import AppStoreConnect_Swift_SDK
import Testing
@testable import Infrastructure
@testable import Domain

@Suite
struct SDKInAppPurchasePriceRepositoryTests {

    // MARK: - listPricePoints

    @Test func `listPricePoints injects iapId into each price point`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(InAppPurchasePricePointsResponse(
            data: [
                InAppPurchasePricePoint(type: .inAppPurchasePricePoints, id: "pp-1"),
                InAppPurchasePricePoint(type: .inAppPurchasePricePoints, id: "pp-2"),
            ],
            links: .init(this: "")
        ))

        let repo = SDKInAppPurchasePriceRepository(client: stub)
        let result = try await repo.listPricePoints(iapId: "iap-99", territory: nil)

        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.iapId == "iap-99" })
    }

    @Test func `listPricePoints maps territory from relationship`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(InAppPurchasePricePointsResponse(
            data: [
                InAppPurchasePricePoint(
                    type: .inAppPurchasePricePoints,
                    id: "pp-1",
                    relationships: .init(territory: .init(data: .init(type: .territories, id: "USA")))
                ),
            ],
            links: .init(this: "")
        ))

        let repo = SDKInAppPurchasePriceRepository(client: stub)
        let result = try await repo.listPricePoints(iapId: "iap-1", territory: nil)

        #expect(result[0].territory == "USA")
    }

    @Test func `listPricePoints maps customerPrice and proceeds from attributes`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(InAppPurchasePricePointsResponse(
            data: [
                InAppPurchasePricePoint(
                    type: .inAppPurchasePricePoints,
                    id: "pp-1",
                    attributes: .init(customerPrice: "0.99", proceeds: "0.70")
                ),
            ],
            links: .init(this: "")
        ))

        let repo = SDKInAppPurchasePriceRepository(client: stub)
        let result = try await repo.listPricePoints(iapId: "iap-1", territory: nil)

        #expect(result[0].customerPrice == "0.99")
        #expect(result[0].proceeds == "0.70")
    }

    // MARK: - setPriceSchedule

    @Test func `setPriceSchedule injects iapId into result`() async throws {
        let stub = StubAPIClient()
        stub.willReturn(InAppPurchasePriceScheduleResponse(
            data: AppStoreConnect_Swift_SDK.InAppPurchasePriceSchedule(type: .inAppPurchasePriceSchedules, id: "sched-1"),
            links: .init(this: "")
        ))

        let repo = SDKInAppPurchasePriceRepository(client: stub)
        let result = try await repo.setPriceSchedule(iapId: "iap-abc", baseTerritory: "USA", pricePointId: "pp-1")

        #expect(result.id == "sched-1")
        #expect(result.iapId == "iap-abc")
    }
}
