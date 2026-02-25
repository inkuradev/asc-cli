@preconcurrency import AppStoreConnect_Swift_SDK
@testable import Infrastructure

final class StubAPIClient: APIClient, @unchecked Sendable {
    private var stubbedResponse: Any?
    private(set) var voidRequestCalled = false

    func willReturn<T>(_ response: T) {
        stubbedResponse = response
    }

    func request<T: Decodable>(_ endpoint: Request<T>) async throws -> T {
        guard let response = stubbedResponse as? T else {
            fatalError("StubAPIClient: no stub configured for \(T.self)")
        }
        return response
    }

    func request(_ endpoint: Request<Void>) async throws {
        voidRequestCalled = true
    }
}
