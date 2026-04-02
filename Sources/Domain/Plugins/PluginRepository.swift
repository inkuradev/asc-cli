import Mockable

/// Manages installed dylib plugins and the plugin marketplace.
@Mockable
public protocol PluginRepository: Sendable {
    func listInstalled() async throws -> [Plugin]
    func listAvailable() async throws -> [Plugin]
    func searchAvailable(query: String) async throws -> [Plugin]
    func install(name: String) async throws -> Plugin
    func uninstall(name: String) async throws
}
