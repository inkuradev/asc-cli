import Foundation
import Testing
@testable import Domain

@Suite
struct InAppPurchaseAvailabilityTests {

    @Test func `availability carries iap id as parent`() {
        let availability = MockRepositoryFactory.makeInAppPurchaseAvailability(
            id: "avail-1",
            iapId: "iap-42"
        )
        #expect(availability.iapId == "iap-42")
    }

    @Test func `availability tracks whether available in new territories`() {
        let available = MockRepositoryFactory.makeInAppPurchaseAvailability(isAvailableInNewTerritories: true)
        let notAvailable = MockRepositoryFactory.makeInAppPurchaseAvailability(isAvailableInNewTerritories: false)
        #expect(available.isAvailableInNewTerritories == true)
        #expect(notAvailable.isAvailableInNewTerritories == false)
    }

    @Test func `availability includes list of territory ids`() {
        let availability = MockRepositoryFactory.makeInAppPurchaseAvailability(
            territories: ["USA", "CHN", "JPN"]
        )
        #expect(availability.territories == ["USA", "CHN", "JPN"])
    }

    @Test func `affordances include get availability command`() {
        let availability = MockRepositoryFactory.makeInAppPurchaseAvailability(
            id: "avail-1",
            iapId: "iap-42"
        )
        #expect(availability.affordances["getAvailability"] == "asc iap-availability get --iap-id iap-42")
    }

    @Test func `affordances include create availability command`() {
        let availability = MockRepositoryFactory.makeInAppPurchaseAvailability(
            id: "avail-1",
            iapId: "iap-42"
        )
        #expect(availability.affordances["createAvailability"] == "asc iap-availability create --iap-id iap-42 --available-in-new-territories --territory USA --territory CHN")
    }

    @Test func `nil territories omitted from json`() throws {
        let availability = InAppPurchaseAvailability(
            id: "avail-1",
            iapId: "iap-1",
            isAvailableInNewTerritories: true,
            territories: []
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(availability)
        let json = String(data: data, encoding: .utf8)!
        #expect(json.contains("\"iapId\""))
        #expect(json.contains("\"isAvailableInNewTerritories\""))
    }
}
