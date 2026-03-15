public struct InAppPurchaseAvailability: Sendable, Equatable, Identifiable, Codable {
    public let id: String
    /// Parent IAP identifier — injected by Infrastructure since ASC API omits it from response
    public let iapId: String
    public let isAvailableInNewTerritories: Bool
    public let territories: [String]

    public init(
        id: String,
        iapId: String,
        isAvailableInNewTerritories: Bool,
        territories: [String]
    ) {
        self.id = id
        self.iapId = iapId
        self.isAvailableInNewTerritories = isAvailableInNewTerritories
        self.territories = territories
    }
}

extension InAppPurchaseAvailability: AffordanceProviding {
    public var affordances: [String: String] {
        [
            "getAvailability": "asc iap-availability get --iap-id \(iapId)",
            "createAvailability": "asc iap-availability create --iap-id \(iapId) --available-in-new-territories --territory USA --territory CHN",
        ]
    }
}
