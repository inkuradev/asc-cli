# Auth Login Feature

Persistent credential storage for the `asc` CLI. Saves API key credentials to `~/.asc/credentials.json` so environment variables are not required on every command.

---

## CLI Usage

### `asc auth login`

Save API key credentials to disk.

| Flag | Required | Description |
|------|----------|-------------|
| `--key-id` | Yes | App Store Connect API Key ID |
| `--issuer-id` | Yes | App Store Connect Issuer ID |
| `--private-key-path` | One of two | Path to the `.p8` private key file (supports `~`) |
| `--private-key` | One of two | Raw PEM content of the private key |
| `--output` | No | Output format: `json` (default), `table`, `markdown` |
| `--pretty` | No | Pretty-print JSON output |

**Examples:**

```bash
# Login using a .p8 key file
asc auth login --key-id KEYID123 --issuer-id abc-def-456 --private-key-path ~/.asc/AuthKey_KEYID123.p8

# Login using raw PEM content
asc auth login --key-id KEYID123 --issuer-id abc-def-456 --private-key "$(cat ~/.asc/AuthKey_KEYID123.p8)"
```

**Output (JSON):**

```json
{
  "data": [
    {
      "affordances": {
        "check": "asc auth check",
        "login": "asc auth login --key-id <id> --issuer-id <id> --private-key-path <path>",
        "logout": "asc auth logout"
      },
      "issuerID": "abc-def-456",
      "keyID": "KEYID123",
      "source": "file"
    }
  ]
}
```

---

### `asc auth logout`

Remove saved credentials from `~/.asc/credentials.json`.

```bash
asc auth logout
# → Logged out successfully
```

---

### `asc auth check`

Verify credentials and show their source (`file` or `environment`).

| Flag | Required | Description |
|------|----------|-------------|
| `--output` | No | Output format: `json`, `table`, `markdown` |
| `--pretty` | No | Pretty-print JSON output |

**Examples:**

```bash
asc auth check --pretty
```

**Output (JSON):**

```json
{
  "data": [
    {
      "affordances": {
        "check": "asc auth check",
        "login": "asc auth login --key-id <id> --issuer-id <id> --private-key-path <path>",
        "logout": "asc auth logout"
      },
      "issuerID": "abc-def-456",
      "keyID": "KEYID123",
      "source": "file"
    }
  ]
}
```

**Table output:**

```
Key ID    Issuer ID    Source
-------   -----------  ------
KEYID123  abc-def-456  file
```

---

## Credential Resolution Priority

`CompositeAuthProvider` tries credentials in this order:

1. **`~/.asc/credentials.json`** — written by `asc auth login`
2. **Environment variables** — `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY_PATH` / `ASC_PRIVATE_KEY_B64` / `ASC_PRIVATE_KEY`

All `asc` commands transparently benefit from this priority without any changes.

---

## Typical Workflow

```bash
# One-time setup
asc auth login \
  --key-id KEYID123 \
  --issuer-id abc-def-456 \
  --private-key-path ~/.asc/AuthKey_KEYID123.p8

# Verify it worked
asc auth check --pretty

# Use any command — no env vars needed
asc apps list --pretty

# Remove credentials when done
asc auth logout
```

---

## Architecture

```
ASCCommand
└── Commands/Auth/
    ├── AuthCommand.swift      [auth parent: check + login + logout subcommands]
    ├── AuthLogin.swift        [asc auth login — saves to FileAuthStorage]
    ├── AuthLogout.swift       [asc auth logout — deletes from FileAuthStorage]
    └── AuthCommand.swift      [asc auth check — detects source, emits AuthStatus JSON]
         ↓
Infrastructure/Auth/
├── FileAuthStorage.swift      [reads/writes ~/.asc/credentials.json]
├── FileAuthProvider.swift     [AuthProvider backed by FileAuthStorage]
└── CompositeAuthProvider.swift [file-first, then EnvironmentAuthProvider]
         ↓
Domain/Auth/
├── AuthStorage.swift          [@Mockable protocol: save/load/delete]
├── AuthStatus.swift           [struct: keyID, issuerID, source + AffordanceProviding]
├── CredentialSource.swift     [enum: .file / .environment]
├── AuthCredentials.swift      [Sendable + Equatable + Codable]
├── AuthProvider.swift         [@Mockable protocol: resolve()]
└── AuthError.swift            [enum of all auth failures]
```

---

## Domain Models

### `CredentialSource`

```swift
public enum CredentialSource: String, Sendable, Equatable, Codable {
    case file        // credentials loaded from ~/.asc/credentials.json
    case environment // credentials loaded from environment variables
}
```

### `AuthStatus`

```swift
public struct AuthStatus: Sendable, Equatable, Codable, Identifiable {
    public let keyID: String
    public let issuerID: String
    public let source: CredentialSource
    public var id: String { keyID }   // computed, not encoded
}
```

**Affordances:**

| Key | Command |
|-----|---------|
| `check` | `asc auth check` |
| `login` | `asc auth login --key-id <id> --issuer-id <id> --private-key-path <path>` |
| `logout` | `asc auth logout` |

### `AuthStorage` (protocol)

```swift
@Mockable
public protocol AuthStorage: Sendable {
    func save(_ credentials: AuthCredentials) throws
    func load() throws -> AuthCredentials?
    func delete() throws
}
```

---

## File Map

**Sources:**

```
Sources/
├── Domain/Auth/
│   ├── AuthStorage.swift          [new — @Mockable storage protocol]
│   ├── AuthStatus.swift           [new — domain model + AffordanceProviding]
│   ├── CredentialSource.swift     [new — .file / .environment enum]
│   └── AuthCredentials.swift      [modified — added Codable conformance]
├── Infrastructure/Auth/
│   ├── FileAuthStorage.swift      [new — reads/writes ~/.asc/credentials.json]
│   ├── FileAuthProvider.swift     [new — AuthProvider via FileAuthStorage]
│   └── CompositeAuthProvider.swift [new — file-first composite provider]
└── ASCCommand/
    ├── ClientProvider.swift        [modified — uses CompositeAuthProvider]
    └── Commands/Auth/
        ├── AuthCommand.swift       [modified — added login + logout subcommands, updated AuthCheck]
        ├── AuthLogin.swift         [new — asc auth login command]
        └── AuthLogout.swift        [new — asc auth logout command]
```

**Tests:**

```
Tests/
├── DomainTests/Auth/
│   └── AuthStatusTests.swift                [new]
├── DomainTests/TestHelpers/
│   └── MockRepositoryFactory.swift          [modified — makeAuthStatus()]
├── InfrastructureTests/Auth/
│   ├── FileAuthStorageTests.swift           [new]
│   └── CompositeAuthProviderTests.swift     [new]
└── ASCCommandTests/Commands/Auth/
    ├── AuthLoginTests.swift                 [new]
    ├── AuthLogoutTests.swift                [new]
    └── AuthCheckTests.swift                 [new]
```

---

## API Reference

No new App Store Connect API calls. All new functionality is local file I/O.

| Operation | Implementation |
|-----------|----------------|
| Save credentials | `FileAuthStorage.save()` → `~/.asc/credentials.json` |
| Load credentials | `FileAuthStorage.load()` → `JSONDecoder` |
| Delete credentials | `FileAuthStorage.delete()` → `FileManager.removeItem` |
| Composite resolution | `CompositeAuthProvider.resolve()` → file first, then env |

---

## Testing

```swift
@Test func `auth check shows file source when file credentials exist`() async throws {
    let mockFile = MockAuthProvider()
    let mockEnv = MockAuthProvider()
    let credentials = AuthCredentials(keyID: "KEY123", issuerID: "ISSUER456", privateKeyPEM: "key")
    given(mockFile).resolve().willReturn(credentials)

    let cmd = try AuthCheck.parse(["--pretty"])
    let output = try await cmd.execute(fileProvider: mockFile, envProvider: mockEnv)

    #expect(output == """
    {
      "data" : [
        {
          "affordances" : {
            "check" : "asc auth check",
            "login" : "asc auth login --key-id <id> --issuer-id <id> --private-key-path <path>",
            "logout" : "asc auth logout"
          },
          "issuerID" : "ISSUER456",
          "keyID" : "KEY123",
          "source" : "file"
        }
      ]
    }
    """)
}
```

Run all tests:

```bash
swift test
# Test run with 226 tests in 53 suites passed.
```

---

## Extending

**Named profiles** — support multiple credential sets (e.g., `--profile staging`):

```swift
public protocol AuthStorage: Sendable {
    func save(_ credentials: AuthCredentials, profile: String) throws
    func load(profile: String) throws -> AuthCredentials?
    func delete(profile: String) throws
}
```

**Keychain storage** — store the private key in macOS Keychain instead of a plain JSON file:

```swift
public struct KeychainAuthStorage: AuthStorage { ... }
```
