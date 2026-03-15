import Testing
@testable import Domain

@Suite
struct SubscriptionAvailabilityTests {

    @Test func `availability carries subscription id as parent`() {
        let availability = MockRepositoryFactory.makeSubscriptionAvailability(
            id: "avail-1",
            subscriptionId: "sub-42"
        )
        #expect(availability.subscriptionId == "sub-42")
    }

    @Test func `availability tracks whether available in new territories`() {
        let available = MockRepositoryFactory.makeSubscriptionAvailability(isAvailableInNewTerritories: true)
        let notAvailable = MockRepositoryFactory.makeSubscriptionAvailability(isAvailableInNewTerritories: false)
        #expect(available.isAvailableInNewTerritories == true)
        #expect(notAvailable.isAvailableInNewTerritories == false)
    }

    @Test func `availability includes list of territory ids`() {
        let availability = MockRepositoryFactory.makeSubscriptionAvailability(
            territories: ["USA", "GBR", "DEU"]
        )
        #expect(availability.territories == ["USA", "GBR", "DEU"])
    }

    @Test func `affordances include get availability command`() {
        let availability = MockRepositoryFactory.makeSubscriptionAvailability(
            id: "avail-1",
            subscriptionId: "sub-42"
        )
        #expect(availability.affordances["getAvailability"] == "asc subscription-availability get --subscription-id sub-42")
    }

    @Test func `affordances include create availability command`() {
        let availability = MockRepositoryFactory.makeSubscriptionAvailability(
            id: "avail-1",
            subscriptionId: "sub-42"
        )
        #expect(availability.affordances["createAvailability"] == "asc subscription-availability create --subscription-id sub-42 --available-in-new-territories --territory USA --territory CHN")
    }
}
