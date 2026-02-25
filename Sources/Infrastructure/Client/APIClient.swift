@preconcurrency import AppStoreConnect_Swift_SDK

public protocol APIClient {
    func request<T: Decodable>(_ endpoint: Request<T>) async throws -> T
    func request(_ endpoint: Request<Void>) async throws
}

extension APIProvider: APIClient {}
