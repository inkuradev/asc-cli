import ArgumentParser

struct DevicesCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "devices",
        abstract: "Manage registered test devices",
        subcommands: [
            DevicesList.self,
            DevicesRegister.self,
        ]
    )
}
