import Mockable

@Mockable
public protocol InAppPurchasePriceRepository: Sendable {
    func listPricePoints(iapId: String, territory: String?) async throws -> [InAppPurchasePricePoint]
    func setPriceSchedule(iapId: String, baseTerritory: String, pricePointId: String) async throws -> InAppPurchasePriceSchedule
}
