@preconcurrency import AppStoreConnect_Swift_SDK
import Domain

public struct SDKAppRepository: AppRepository, @unchecked Sendable {
    private let client: any APIClient

    public init(client: any APIClient) {
        self.client = client
    }

    public func listApps(limit: Int?) async throws -> PaginatedResponse<Domain.App> {
        let request = APIEndpoint.v1.apps.get(parameters: .init(
            limit: limit
        ))
        let response = try await client.request(request)
        let apps = response.data.map { mapApp($0) }
        let nextCursor = response.links.next
        return PaginatedResponse(data: apps, nextCursor: nextCursor)
    }

    public func getApp(id: String) async throws -> Domain.App {
        let request = APIEndpoint.v1.apps.id(id).get()
        let response = try await client.request(request)
        return mapApp(response.data)
    }

    private func mapApp(_ sdkApp: AppStoreConnect_Swift_SDK.App) -> Domain.App {
        Domain.App(
            id: sdkApp.id,
            name: sdkApp.attributes?.name ?? "",
            bundleId: sdkApp.attributes?.bundleID ?? "",
            sku: sdkApp.attributes?.sku,
            primaryLocale: sdkApp.attributes?.primaryLocale
        )
    }
}
