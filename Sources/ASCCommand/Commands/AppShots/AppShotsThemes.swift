import ArgumentParser
import Domain
import Foundation

struct AppShotsThemesCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "themes",
        abstract: "Browse visual themes for screenshot composition",
        subcommands: [AppShotsThemesList.self, AppShotsThemesGet.self]
    )
}

// MARK: - List

struct AppShotsThemesList: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List available visual themes"
    )

    @OptionGroup var globals: GlobalOptions

    func run() async throws {
        let repo = ClientProvider.makeThemeRepository()
        print(try await execute(repo: repo))
    }

    func execute(repo: any ThemeRepository) async throws -> String {
        let themes = try await repo.listThemes()
        let formatter = OutputFormatter(format: globals.outputFormat, pretty: globals.pretty)
        return try formatter.formatAgentItems(
            themes,
            headers: ["ID", "Name", "Icon", "Description"],
            rowMapper: { [$0.id, $0.name, $0.icon, $0.description] }
        )
    }
}

// MARK: - Get

struct AppShotsThemesGet: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "get",
        abstract: "Get details of a specific theme"
    )

    @OptionGroup var globals: GlobalOptions

    @Option(name: .long, help: "Theme ID")
    var id: String

    @Flag(name: .long, help: "Output the buildContext() prompt string instead of JSON")
    var context: Bool = false

    func run() async throws {
        let repo = ClientProvider.makeThemeRepository()
        print(try await execute(repo: repo))
    }

    func execute(repo: any ThemeRepository) async throws -> String {
        guard let theme = try await repo.getTheme(id: id) else {
            throw ValidationError("Theme '\(id)' not found. Run `asc app-shots themes list` to see available themes.")
        }

        if context {
            return theme.buildContext()
        }

        let formatter = OutputFormatter(format: globals.outputFormat, pretty: globals.pretty)
        return try formatter.formatAgentItems(
            [theme],
            headers: ["ID", "Name", "Icon", "Description"],
            rowMapper: { [$0.id, $0.name, $0.icon, $0.description] }
        )
    }
}
