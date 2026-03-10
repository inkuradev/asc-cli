import ArgumentParser

struct FinanceReportsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "finance-reports",
        abstract: "Download financial reports",
        subcommands: [FinanceReportsDownload.self]
    )
}
