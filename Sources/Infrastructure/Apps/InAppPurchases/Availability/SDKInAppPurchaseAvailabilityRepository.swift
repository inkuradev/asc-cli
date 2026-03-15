@preconcurrency import AppStoreConnect_Swift_SDK
import Domain

public struct SDKInAppPurchaseAvailabilityRepository: InAppPurchaseAvailabilityRepository, @unchecked Sendable {
    private let client: any APIClient

    public init(client: any APIClient) {
        self.client = client
    }

    public func getAvailability(iapId: String) async throws -> Domain.InAppPurchaseAvailability {
        let request = APIEndpoint.v2.inAppPurchases.id(iapId).inAppPurchaseAvailability.get(parameters: .init(
            include: [.availableTerritories]
        ))
        let response = try await client.request(request)
        return mapAvailability(response.data, iapId: iapId)
    }

    public func createAvailability(
        iapId: String,
        isAvailableInNewTerritories: Bool,
        territoryIds: [String]
    ) async throws -> Domain.InAppPurchaseAvailability {
        let body = InAppPurchaseAvailabilityCreateRequest(data: .init(
            type: .inAppPurchaseAvailabilities,
            attributes: .init(isAvailableInNewTerritories: isAvailableInNewTerritories),
            relationships: .init(
                inAppPurchase: .init(data: .init(type: .inAppPurchases, id: iapId)),
                availableTerritories: .init(data: territoryIds.map { .init(type: .territories, id: $0) })
            )
        ))
        let response = try await client.request(APIEndpoint.v1.inAppPurchaseAvailabilities.post(body))
        return mapAvailability(response.data, iapId: iapId)
    }

    private func mapAvailability(
        _ sdk: AppStoreConnect_Swift_SDK.InAppPurchaseAvailability,
        iapId: String
    ) -> Domain.InAppPurchaseAvailability {
        let territories = sdk.relationships?.availableTerritories?.data?.map(\.id) ?? []
        return Domain.InAppPurchaseAvailability(
            id: sdk.id,
            iapId: iapId,
            isAvailableInNewTerritories: sdk.attributes?.isAvailableInNewTerritories ?? false,
            territories: territories
        )
    }
}
