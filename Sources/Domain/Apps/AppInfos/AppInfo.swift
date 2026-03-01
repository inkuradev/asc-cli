public struct AppInfo: Sendable, Equatable, Identifiable, Codable {
    public let id: String
    /// Parent app identifier — always present so agents can correlate responses.
    public let appId: String
    public let primaryCategoryId: String?
    public let primarySubcategoryOneId: String?
    public let primarySubcategoryTwoId: String?
    public let secondaryCategoryId: String?
    public let secondarySubcategoryOneId: String?
    public let secondarySubcategoryTwoId: String?

    public init(
        id: String,
        appId: String,
        primaryCategoryId: String? = nil,
        primarySubcategoryOneId: String? = nil,
        primarySubcategoryTwoId: String? = nil,
        secondaryCategoryId: String? = nil,
        secondarySubcategoryOneId: String? = nil,
        secondarySubcategoryTwoId: String? = nil
    ) {
        self.id = id
        self.appId = appId
        self.primaryCategoryId = primaryCategoryId
        self.primarySubcategoryOneId = primarySubcategoryOneId
        self.primarySubcategoryTwoId = primarySubcategoryTwoId
        self.secondaryCategoryId = secondaryCategoryId
        self.secondarySubcategoryOneId = secondarySubcategoryOneId
        self.secondarySubcategoryTwoId = secondarySubcategoryTwoId
    }
}

extension AppInfo: AffordanceProviding {
    public var affordances: [String: String] {
        [
            "listLocalizations": "asc app-info-localizations list --app-info-id \(id)",
            "listAppInfos": "asc app-infos list --app-id \(appId)",
            "getAgeRating": "asc age-rating get --app-info-id \(id)",
            "updateCategories": "asc app-infos update --app-info-id \(id)",
        ]
    }
}
