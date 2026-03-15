import Mockable

@Mockable
public protocol InAppPurchaseAvailabilityRepository: Sendable {
    func getAvailability(iapId: String) async throws -> InAppPurchaseAvailability
    func createAvailability(iapId: String, isAvailableInNewTerritories: Bool, territoryIds: [String]) async throws -> InAppPurchaseAvailability
}
