import Mockable
import Testing
@testable import ASCCommand
@testable import Domain

@Suite
struct CertificatesListTests {

    @Test func `listed certificates include type and affordances`() async throws {
        let mockRepo = MockCertificateRepository()
        given(mockRepo).listCertificates(certificateType: .any).willReturn([
            Certificate(id: "cert-1", name: "iOS Distribution", certificateType: .iosDistribution),
        ])

        let cmd = try CertificatesList.parse(["--pretty"])
        let output = try await cmd.execute(repo: mockRepo)

        #expect(output == """
        {
          "data" : [
            {
              "affordances" : {
                "revoke" : "asc certificates revoke --certificate-id cert-1"
              },
              "certificateType" : "IOS_DISTRIBUTION",
              "id" : "cert-1",
              "name" : "iOS Distribution"
            }
          ]
        }
        """)
    }

    @Test func `table output includes all row fields`() async throws {
        let mockRepo = MockCertificateRepository()
        given(mockRepo).listCertificates(certificateType: .any).willReturn([
            Certificate(id: "cert-1", name: "iOS Dist", certificateType: .iosDistribution),
        ])

        let cmd = try CertificatesList.parse(["--output", "table"])
        let output = try await cmd.execute(repo: mockRepo)

        #expect(output.contains("cert-1"))
        #expect(output.contains("IOS_DISTRIBUTION"))
        #expect(output.contains("No"))
    }

    @Test func `optional certificate fields are omitted when nil`() async throws {
        let mockRepo = MockCertificateRepository()
        given(mockRepo).listCertificates(certificateType: .any).willReturn([
            Certificate(
                id: "cert-1",
                name: "Mac Distribution",
                certificateType: .macAppDistribution,
                displayName: "Mac App Distribution",
                serialNumber: "SN-001"
            ),
        ])

        let cmd = try CertificatesList.parse(["--pretty"])
        let output = try await cmd.execute(repo: mockRepo)

        #expect(output == """
        {
          "data" : [
            {
              "affordances" : {
                "revoke" : "asc certificates revoke --certificate-id cert-1"
              },
              "certificateType" : "MAC_APP_DISTRIBUTION",
              "displayName" : "Mac App Distribution",
              "id" : "cert-1",
              "name" : "Mac Distribution",
              "serialNumber" : "SN-001"
            }
          ]
        }
        """)
    }
}
