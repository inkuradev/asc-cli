import ArgumentParser

struct SubscriptionAvailabilityCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "subscription-availability",
        abstract: "Manage subscription territory availability",
        subcommands: [
            SubscriptionAvailabilityGet.self,
            SubscriptionAvailabilityCreate.self,
        ]
    )
}
