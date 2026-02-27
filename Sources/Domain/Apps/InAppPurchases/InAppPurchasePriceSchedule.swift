public struct InAppPurchasePriceSchedule: Sendable, Equatable, Identifiable, Codable {
    public let id: String
    /// Parent IAP identifier — injected by Infrastructure
    public let iapId: String

    public init(id: String, iapId: String) {
        self.id = id
        self.iapId = iapId
    }
}

extension InAppPurchasePriceSchedule: AffordanceProviding {
    public var affordances: [String: String] {
        ["listPricePoints": "asc iap price-points list --iap-id \(iapId)"]
    }
}
