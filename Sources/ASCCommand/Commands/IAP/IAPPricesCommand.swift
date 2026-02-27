import ArgumentParser

struct IAPPricesCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "prices",
        abstract: "Manage in-app purchase price schedules",
        subcommands: [IAPPricesSet.self]
    )
}
