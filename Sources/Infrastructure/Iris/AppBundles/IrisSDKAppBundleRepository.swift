import Domain
import Foundation

/// Implements `IrisAppBundleRepository` via the iris private API.
public struct IrisSDKAppBundleRepository: IrisAppBundleRepository, @unchecked Sendable {
    private let client: IrisClient

    public init(client: IrisClient = IrisClient()) {
        self.client = client
    }

    public func listAppBundles(session: IrisSession) async throws -> [AppBundle] {
        let (data, _) = try await client.get(
            path: "appBundles",
            queryItems: [
                URLQueryItem(name: "include", value: "appBundleVersions"),
                URLQueryItem(name: "limit", value: "300"),
            ],
            cookies: session.cookies
        )
        let response = try JSONDecoder().decode(IrisAppBundlesResponse.self, from: data)
        return response.data.map { mapToAppBundle($0) }
    }

    public func createApp(
        session: IrisSession,
        name: String,
        bundleId: String,
        sku: String,
        primaryLocale: String,
        platforms: [String],
        versionString: String
    ) async throws -> AppBundle {
        // Build the JSON:API compound document matching the real iris API.
        // Uses placeholder IDs for related resources (iris resolves them server-side).
        let versionIds = platforms.map { "store-version-\($0.lowercased())" }
        let appInfoId = "new-appInfo-id"
        let appInfoLocId = "new-appInfoLocalization-id"

        // Build appStoreVersions relationship data
        let versionRelData = platforms.enumerated().map { i, _ in
            RelationshipData(type: "appStoreVersions", id: versionIds[i])
        }

        // Build included resources
        var included: [IrisIncludedResource] = []

        // Add appStoreVersion + localization for each platform
        for (i, platform) in platforms.enumerated() {
            let versionLocId = "new-\(platform.lowercased())VersionLocalization-id"

            included.append(.appStoreVersion(
                id: versionIds[i],
                platform: platform,
                versionString: versionString,
                localizationId: versionLocId
            ))
            included.append(.appStoreVersionLocalization(
                id: versionLocId,
                locale: primaryLocale
            ))
        }

        // Add appInfo + localization
        included.append(.appInfo(id: appInfoId, localizationId: appInfoLocId))
        included.append(.appInfoLocalization(
            id: appInfoLocId,
            locale: primaryLocale,
            name: name
        ))

        let requestBody = IrisCreateAppRequest(
            data: IrisCreateAppData(
                type: "apps",
                attributes: IrisCreateAppAttributes(
                    sku: sku,
                    primaryLocale: primaryLocale,
                    bundleId: bundleId
                ),
                relationships: IrisCreateAppRelationships(
                    appStoreVersions: RelationshipWrapper(data: versionRelData),
                    appInfos: RelationshipWrapper(data: [
                        RelationshipData(type: "appInfos", id: appInfoId),
                    ])
                )
            ),
            included: included.map { $0.toEncodable() }
        )

        let body = try JSONEncoder().encode(requestBody)
        let (data, _) = try await client.post(
            path: "apps",
            body: body,
            cookies: session.cookies
        )
        let response = try JSONDecoder().decode(IrisSingleAppBundleResponse.self, from: data)
        return mapToAppBundle(response.data, fallbackName: name)
    }

    private func mapToAppBundle(_ resource: IrisAppBundleResource, fallbackName: String? = nil) -> AppBundle {
        AppBundle(
            id: resource.id,
            name: resource.attributes.name ?? fallbackName ?? "",
            bundleId: resource.attributes.bundleId ?? "",
            sku: resource.attributes.sku ?? "",
            primaryLocale: resource.attributes.primaryLocale ?? "en-US",
            platforms: resource.attributes.platformNames ?? []
        )
    }
}

// MARK: - Iris JSON:API Response Models

struct IrisAppBundlesResponse: Decodable {
    let data: [IrisAppBundleResource]
}

struct IrisSingleAppBundleResponse: Decodable {
    let data: IrisAppBundleResource
}

struct IrisAppBundleResource: Decodable {
    let id: String
    let type: String
    let attributes: IrisAppBundleAttributes
}

struct IrisAppBundleAttributes: Decodable {
    let name: String?
    let bundleId: String?
    let sku: String?
    let primaryLocale: String?
    let platformNames: [String]?
}

// MARK: - Create App Request (JSON:API compound document)

struct IrisCreateAppRequest: Encodable {
    let data: IrisCreateAppData
    let included: [IrisIncludedEncodable]
}

struct IrisCreateAppData: Encodable {
    let type: String
    let attributes: IrisCreateAppAttributes
    let relationships: IrisCreateAppRelationships
}

struct IrisCreateAppAttributes: Encodable {
    let sku: String
    let primaryLocale: String
    let bundleId: String
}

struct IrisCreateAppRelationships: Encodable {
    let appStoreVersions: RelationshipWrapper
    let appInfos: RelationshipWrapper
}

struct RelationshipWrapper: Encodable {
    let data: [RelationshipData]
}

struct RelationshipData: Encodable {
    let type: String
    let id: String
}

// MARK: - Included resources

/// Type-safe enum for building the `included` array.
enum IrisIncludedResource {
    case appStoreVersion(id: String, platform: String, versionString: String, localizationId: String)
    case appStoreVersionLocalization(id: String, locale: String)
    case appInfo(id: String, localizationId: String)
    case appInfoLocalization(id: String, locale: String, name: String)

    func toEncodable() -> IrisIncludedEncodable {
        switch self {
        case .appStoreVersion(let id, let platform, let versionString, let localizationId):
            IrisIncludedEncodable(
                type: "appStoreVersions",
                id: id,
                attributes: [
                    "platform": platform,
                    "versionString": versionString,
                ],
                relationships: [
                    "appStoreVersionLocalizations": RelationshipWrapper(data: [
                        RelationshipData(type: "appStoreVersionLocalizations", id: localizationId),
                    ]),
                ]
            )
        case .appStoreVersionLocalization(let id, let locale):
            IrisIncludedEncodable(
                type: "appStoreVersionLocalizations",
                id: id,
                attributes: ["locale": locale],
                relationships: nil
            )
        case .appInfo(let id, let localizationId):
            IrisIncludedEncodable(
                type: "appInfos",
                id: id,
                attributes: nil,
                relationships: [
                    "appInfoLocalizations": RelationshipWrapper(data: [
                        RelationshipData(type: "appInfoLocalizations", id: localizationId),
                    ]),
                ]
            )
        case .appInfoLocalization(let id, let locale, let name):
            IrisIncludedEncodable(
                type: "appInfoLocalizations",
                id: id,
                attributes: [
                    "locale": locale,
                    "name": name,
                ],
                relationships: nil
            )
        }
    }
}

/// Generic encodable for the `included` array items.
struct IrisIncludedEncodable: Encodable {
    let type: String
    let id: String
    let attributes: [String: String]?
    let relationships: [String: RelationshipWrapper]?
}
