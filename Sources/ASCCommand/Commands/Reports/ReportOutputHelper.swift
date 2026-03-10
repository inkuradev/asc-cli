import Foundation

enum ReportOutputHelper {
    static func format(rows: [[String: String]], formatter: OutputFormatter) throws -> String {
        switch formatter.format {
        case .json:
            return try formatJSON(rows: rows, pretty: formatter.pretty)
        case .table, .markdown:
            return formatTable(rows: rows, formatter: formatter)
        }
    }

    private static func formatJSON(rows: [[String: String]], pretty: Bool) throws -> String {
        struct DataWrapper: Encodable {
            let data: [[String: String]]
        }
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        } else {
            encoder.outputFormatting = [.sortedKeys]
        }
        let data = try encoder.encode(DataWrapper(data: rows))
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    private static func formatTable(rows: [[String: String]], formatter: OutputFormatter) -> String {
        guard let firstRow = rows.first else { return "" }
        let headers = firstRow.keys.sorted()
        let tableRows = rows.map { row in
            headers.map { row[$0] ?? "" }
        }

        var widths = headers.map(\.count)
        for row in tableRows {
            for (i, cell) in row.enumerated() where i < widths.count {
                widths[i] = max(widths[i], cell.count)
            }
        }

        var lines: [String] = []
        let headerLine = headers.enumerated().map { i, h in
            h.padding(toLength: widths[i], withPad: " ", startingAt: 0)
        }.joined(separator: "  ")
        lines.append(headerLine)

        let separator = widths.map { String(repeating: "-", count: $0) }.joined(separator: "  ")
        lines.append(separator)

        for row in tableRows {
            let line = row.enumerated().map { i, cell in
                cell.padding(toLength: widths[i], withPad: " ", startingAt: 0)
            }.joined(separator: "  ")
            lines.append(line)
        }

        return lines.joined(separator: "\n")
    }
}
