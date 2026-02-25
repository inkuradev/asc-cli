import ArgumentParser

struct CertificatesCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "certificates",
        abstract: "Manage signing certificates",
        subcommands: [
            CertificatesList.self,
            CertificatesCreate.self,
            CertificatesRevoke.self,
        ]
    )
}
