import ArgumentParser

struct IAPAvailabilityCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "iap-availability",
        abstract: "Manage in-app purchase territory availability",
        subcommands: [
            IAPAvailabilityGet.self,
            IAPAvailabilityCreate.self,
        ]
    )
}
