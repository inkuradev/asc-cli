@preconcurrency import AppStoreConnect_Swift_SDK
import Domain

public struct SDKSubscriptionAvailabilityRepository: SubscriptionAvailabilityRepository, @unchecked Sendable {
    private let client: any APIClient

    public init(client: any APIClient) {
        self.client = client
    }

    public func getAvailability(subscriptionId: String) async throws -> Domain.SubscriptionAvailability {
        let request = APIEndpoint.v1.subscriptions.id(subscriptionId).subscriptionAvailability.get(parameters: .init(
            include: [.availableTerritories]
        ))
        let response = try await client.request(request)
        return mapAvailability(response.data, subscriptionId: subscriptionId)
    }

    public func createAvailability(
        subscriptionId: String,
        isAvailableInNewTerritories: Bool,
        territoryIds: [String]
    ) async throws -> Domain.SubscriptionAvailability {
        let body = SubscriptionAvailabilityCreateRequest(data: .init(
            type: .subscriptionAvailabilities,
            attributes: .init(isAvailableInNewTerritories: isAvailableInNewTerritories),
            relationships: .init(
                subscription: .init(data: .init(type: .subscriptions, id: subscriptionId)),
                availableTerritories: .init(data: territoryIds.map { .init(type: .territories, id: $0) })
            )
        ))
        let response = try await client.request(APIEndpoint.v1.subscriptionAvailabilities.post(body))
        return mapAvailability(response.data, subscriptionId: subscriptionId)
    }

    private func mapAvailability(
        _ sdk: AppStoreConnect_Swift_SDK.SubscriptionAvailability,
        subscriptionId: String
    ) -> Domain.SubscriptionAvailability {
        let territories = sdk.relationships?.availableTerritories?.data?.map(\.id) ?? []
        return Domain.SubscriptionAvailability(
            id: sdk.id,
            subscriptionId: subscriptionId,
            isAvailableInNewTerritories: sdk.attributes?.isAvailableInNewTerritories ?? false,
            territories: territories
        )
    }
}
