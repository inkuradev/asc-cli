import ArgumentParser
import Domain

struct CertificatesCreate: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a signing certificate from a CSR"
    )

    @OptionGroup var globals: GlobalOptions

    @Option(name: .long, help: "Certificate type (e.g. IOS_DISTRIBUTION, MAC_APP_STORE)")
    var type: String

    @Option(name: .long, help: "PEM-encoded Certificate Signing Request content")
    var csrContent: String

    func run() async throws {
        let repo = try ClientProvider.makeCertificateRepository()
        print(try await execute(repo: repo))
    }

    func execute(repo: any CertificateRepository) async throws -> String {
        guard let certType = CertificateType(rawValue: type.uppercased()) else {
            throw ValidationError("Invalid certificate type '\(type)'.")
        }
        let item = try await repo.createCertificate(certificateType: certType, csrContent: csrContent)
        let formatter = OutputFormatter(format: globals.outputFormat, pretty: globals.pretty)
        return try formatter.formatAgentItems(
            [item],
            headers: ["ID", "Name", "Type"],
            rowMapper: { [$0.id, $0.name, $0.certificateType.rawValue] }
        )
    }
}
