import Testing
@testable import Domain

@Suite
struct InAppPurchaseSubmissionTests {

    @Test func `submission carries iapId`() {
        let submission = MockRepositoryFactory.makeInAppPurchaseSubmission(id: "sub-1", iapId: "iap-abc")
        #expect(submission.iapId == "iap-abc")
        #expect(submission.id == "sub-1")
    }

    @Test func `submission affordances include listLocalizations`() {
        let submission = MockRepositoryFactory.makeInAppPurchaseSubmission(id: "sub-1", iapId: "iap-abc")
        #expect(submission.affordances["listLocalizations"] == "asc iap-localizations list --iap-id iap-abc")
    }
}
