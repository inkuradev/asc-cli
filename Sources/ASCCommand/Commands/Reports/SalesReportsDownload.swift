import ArgumentParser
import Domain

struct SalesReportsDownload: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "download",
        abstract: "Download a sales report"
    )

    @OptionGroup var globals: GlobalOptions

    @Option(name: .long, help: "Vendor number")
    var vendorNumber: String

    @Option(name: .long, help: "Report type: SALES, PRE_ORDER, SUBSCRIPTION, etc.")
    var reportType: String

    @Option(name: .long, help: "Report sub-type: SUMMARY, DETAILED, etc.")
    var subType: String

    @Option(name: .long, help: "Frequency: DAILY, WEEKLY, MONTHLY, YEARLY")
    var frequency: String

    @Option(name: .long, help: "Report date (e.g. 2024-01-15)")
    var reportDate: String?

    func run() async throws {
        let repo = try ClientProvider.makeReportRepository()
        print(try await execute(repo: repo))
    }

    func execute(repo: any ReportRepository) async throws -> String {
        guard let parsedReportType = SalesReportType(cliArgument: reportType) else {
            throw ValidationError("Invalid report type: \(reportType)")
        }
        guard let parsedSubType = SalesReportSubType(cliArgument: subType) else {
            throw ValidationError("Invalid sub-type: \(subType)")
        }
        guard let parsedFrequency = ReportFrequency(cliArgument: frequency) else {
            throw ValidationError("Invalid frequency: \(frequency)")
        }

        let rows = try await repo.downloadSalesReport(
            vendorNumber: vendorNumber,
            reportType: parsedReportType,
            subType: parsedSubType,
            frequency: parsedFrequency,
            reportDate: reportDate
        )

        let formatter = OutputFormatter(format: globals.outputFormat, pretty: globals.pretty)
        return try ReportOutputHelper.format(rows: rows, formatter: formatter)
    }
}
