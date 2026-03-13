import ArgumentParser

struct BetaReviewCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "beta-review",
        abstract: "Manage beta app review submissions and details",
        subcommands: [BetaReviewSubmissionsCommand.self, BetaReviewDetailCommand.self]
    )
}

struct BetaReviewSubmissionsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "submissions",
        abstract: "Manage beta app review submissions",
        subcommands: [BetaReviewSubmissionsList.self, BetaReviewSubmissionsCreate.self, BetaReviewSubmissionsGet.self]
    )
}

struct BetaReviewDetailCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "detail",
        abstract: "Manage beta app review contact details",
        subcommands: [BetaReviewDetailGet.self, BetaReviewDetailUpdate.self]
    )
}
