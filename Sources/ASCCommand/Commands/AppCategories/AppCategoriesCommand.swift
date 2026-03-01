import ArgumentParser
import Domain

struct AppCategoriesCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "app-categories",
        abstract: "List App Store categories",
        subcommands: [AppCategoriesList.self]
    )
}

struct AppCategoriesList: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List available App Store categories and subcategories"
    )

    @OptionGroup var globals: GlobalOptions

    @Option(name: .long, help: "Filter by platform: IOS, MAC_OS, TV_OS, VISION_OS")
    var platform: String?

    func run() async throws {
        let repo = try ClientProvider.makeAppCategoryRepository()
        print(try await execute(repo: repo))
    }

    func execute(repo: any AppCategoryRepository) async throws -> String {
        let categories = try await repo.listCategories(platform: platform)
        let formatter = OutputFormatter(format: globals.outputFormat, pretty: globals.pretty)
        return try formatter.formatAgentItems(
            categories,
            headers: ["ID", "Platforms", "Parent ID"],
            rowMapper: { [$0.id, $0.platforms.joined(separator: ","), $0.parentId ?? "-"] }
        )
    }
}
