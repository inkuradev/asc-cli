import Testing
@testable import Domain

@Suite
struct AppCategoryTests {

    @Test func `category carries id and platforms`() {
        let cat = MockRepositoryFactory.makeAppCategory(id: "6014", platforms: ["IOS"])
        #expect(cat.id == "6014")
        #expect(cat.platforms == ["IOS"])
    }

    @Test func `top level category has no parent id`() {
        let cat = MockRepositoryFactory.makeAppCategory(parentId: nil)
        #expect(cat.parentId == nil)
    }

    @Test func `subcategory carries parent id`() {
        let cat = MockRepositoryFactory.makeAppCategory(id: "6014-action", parentId: "6014")
        #expect(cat.parentId == "6014")
    }

    @Test func `category affordances include listCategories`() {
        let cat = MockRepositoryFactory.makeAppCategory(id: "6014")
        #expect(cat.affordances["listCategories"] == "asc app-categories list")
    }
}
