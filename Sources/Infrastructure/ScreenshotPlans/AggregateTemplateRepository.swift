import Domain
import Foundation

/// Aggregates templates from all registered `TemplateProvider`s.
///
/// The platform ships with no built-in templates. Plugins register
/// providers to supply their own templates.
public final actor AggregateTemplateRepository: TemplateRepository {
    private var providers: [any TemplateProvider] = []

    public init() {}

    public func register(provider: any TemplateProvider) {
        providers.append(provider)
    }

    public func listTemplates(size: ScreenSize?) async throws -> [ScreenshotTemplate] {
        var all: [ScreenshotTemplate] = []
        for provider in providers {
            let templates = try await provider.templates()
            all.append(contentsOf: templates)
        }

        if let size {
            return all.filter { $0.supportedSizes.contains(size) }
        }
        return all
    }

    public func getTemplate(id: String) async throws -> ScreenshotTemplate? {
        let all = try await listTemplates(size: nil)
        return all.first { $0.id == id }
    }
}
