@preconcurrency import AppStoreConnect_Swift_SDK
import Domain

public struct SDKTerritoryRepository: TerritoryRepository, @unchecked Sendable {
    private let client: any APIClient

    public init(client: any APIClient) {
        self.client = client
    }

    public func listTerritories() async throws -> [Domain.Territory] {
        let request = APIEndpoint.v1.territories.get(
            fieldsTerritories: [.currency],
            limit: 200
        )
        let response = try await client.request(request)
        return response.data.map { sdk in
            Domain.Territory(id: sdk.id, currency: sdk.attributes?.currency)
        }
    }
}
