import ArgumentParser

struct BundleIDsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "bundle-ids",
        abstract: "Manage bundle identifiers",
        subcommands: [
            BundleIDsList.self,
            BundleIDsCreate.self,
            BundleIDsDelete.self,
        ]
    )
}
