import ArgumentParser

struct IAPPricePointsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "price-points",
        abstract: "List available price points for an in-app purchase",
        subcommands: [IAPPricePointsList.self]
    )
}
