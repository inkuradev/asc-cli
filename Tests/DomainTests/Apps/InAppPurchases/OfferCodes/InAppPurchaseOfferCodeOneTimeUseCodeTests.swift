import Foundation
import Testing
@testable import Domain

@Suite
struct InAppPurchaseOfferCodeOneTimeUseCodeTests {

    @Test func `one-time code carries offerCodeId`() {
        let code = MockRepositoryFactory.makeIAPOfferCodeOneTimeUseCode(offerCodeId: "oc-99")
        #expect(code.offerCodeId == "oc-99")
    }

    @Test func `one-time code has count and dates`() {
        let code = MockRepositoryFactory.makeIAPOfferCodeOneTimeUseCode(
            numberOfCodes: 3000,
            expirationDate: "2026-06-30"
        )
        #expect(code.numberOfCodes == 3000)
        #expect(code.expirationDate == "2026-06-30")
    }

    @Test func `affordances include listOneTimeCodes`() {
        let code = MockRepositoryFactory.makeIAPOfferCodeOneTimeUseCode(offerCodeId: "oc-1")
        #expect(code.affordances["listOneTimeCodes"] == "asc iap-offer-code-one-time-codes list --offer-code-id oc-1")
    }

    @Test func `deactivate affordance only when active`() {
        let active = MockRepositoryFactory.makeIAPOfferCodeOneTimeUseCode(id: "otc-1", isActive: true)
        #expect(active.affordances["deactivate"] == "asc iap-offer-code-one-time-codes update --one-time-code-id otc-1 --active false")

        let inactive = MockRepositoryFactory.makeIAPOfferCodeOneTimeUseCode(id: "otc-1", isActive: false)
        #expect(inactive.affordances["deactivate"] == nil)
    }
}
