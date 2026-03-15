import Mockable

@Mockable
public protocol SubscriptionAvailabilityRepository: Sendable {
    func getAvailability(subscriptionId: String) async throws -> SubscriptionAvailability
    func createAvailability(subscriptionId: String, isAvailableInNewTerritories: Bool, territoryIds: [String]) async throws -> SubscriptionAvailability
}
