import ArgumentParser

struct TerritoriesCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "territories",
        abstract: "List available App Store territories",
        subcommands: [
            TerritoriesList.self,
        ],
        defaultSubcommand: TerritoriesList.self
    )
}
