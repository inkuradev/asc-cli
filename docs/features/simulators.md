# Simulators

Manage local iOS simulators from the CLI — list, boot, shutdown, and stream the device screen to an interactive browser UI with touch, swipe, text input, and accessibility inspection via [AXe](https://github.com/cameroncooke/AXe).

## CLI Usage

### List Simulators

```bash
asc simulators list [--booted] [--output json|table|markdown] [--pretty]
```

**Options:**

| Flag | Default | Description |
|------|---------|-------------|
| `--booted` | `false` | Show only booted simulators |
| `--output` | `json` | Output format: json, table, markdown |
| `--pretty` | `false` | Pretty-print JSON output |

**Examples:**

```bash
# List all available iOS simulators
asc simulators list --output table

# List only booted simulators
asc simulators list --booted --pretty
```

**Table output:**

```
UDID                                  Name                State     Runtime
----                                  ----                -----     -------
CF65871E-B600-40CB-8B18-B6B7101D38E1  iPhone 16 Pro Max   Booted    iOS 18.2
8A35796A-5F41-4933-BBD7-307089EDD509  iPad (10th gen)     Shutdown  iOS 18.2
```

**JSON output (with affordances):**

```json
{
  "data" : [
    {
      "id" : "CF65871E-B600-40CB-8B18-B6B7101D38E1",
      "name" : "iPhone 16 Pro Max",
      "state" : "Booted",
      "runtime" : "com.apple.CoreSimulator.SimRuntime.iOS-18-2",
      "displayRuntime" : "iOS 18.2",
      "isBooted" : true,
      "affordances" : {
        "shutdown" : "asc simulators shutdown --udid CF65871E-...",
        "stream" : "asc simulators stream --udid CF65871E-...",
        "listSimulators" : "asc simulators list"
      }
    }
  ]
}
```

---

### Boot Simulator

```bash
asc simulators boot --udid <udid>
```

---

### Shutdown Simulator

```bash
asc simulators shutdown --udid <udid>
```

---

### Stream Simulator (Interactive)

Stream the simulator screen to the browser with tap, swipe, type, gesture, and accessibility inspection.

```bash
asc simulators stream [--udid <udid>] [--port <port>] [--fps <fps>]
```

**Options:**

| Flag | Default | Description |
|------|---------|-------------|
| `--udid` | _(none)_ | Simulator UDID; omit to pick from browser UI |
| `--port` | `8425` | HTTP server port |
| `--fps` | `5` | Target frames per second |

**Examples:**

```bash
# Open the interactive stream UI (pick device in browser)
asc simulators stream

# Stream a specific device at 10 fps
asc simulators stream --udid CF65871E-B600-40CB-8B18-B6B7101D38E1 --fps 10
```

Opens `http://localhost:8425` in the browser with:

- **Live device screen** inside a realistic device frame bezel
- **Click to tap** — coordinates auto-mapped to device UIKit points
- **Drag to swipe** — gesture direction and duration detected
- **Hardware buttons** — Home, Lock, Siri
- **Gesture presets** — scroll up/down/left/right, edge swipes
- **Text input** — type text, send Return/Backspace/Tab/Escape
- **Tap by accessibility** — tap by ID or label
- **Describe UI** — dump the accessibility tree for AI agent inspection
- **Activity log** — real-time log of all actions

Requires [AXe](https://github.com/cameroncooke/AXe) for interaction: `brew install cameroncooke/axe/axe`

---

## Typical Workflow

```bash
# 1. List simulators and pick one
asc simulators list --output table

# 2. Boot if needed
asc simulators boot --udid CF65871E-B600-40CB-8B18-B6B7101D38E1

# 3. Start interactive stream
asc simulators stream --udid CF65871E-B600-40CB-8B18-B6B7101D38E1

# 4. Interact in the browser: click, type, swipe, inspect
# 5. Ctrl+C to stop
```

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  ASCCommand                      │
│  SimulatorsCommand                               │
│  ├── SimulatorsList    (list [--booted])         │
│  ├── SimulatorsBoot    (boot --udid X)           │
│  ├── SimulatorsShutdown (shutdown --udid X)      │
│  └── SimulatorsStream  (stream [--udid X])       │
│         │                                        │
│         ▼                                        │
│  DeviceStreamServer (HTTP on :8425)              │
│  ├── GET  /               → Interactive HTML     │
│  ├── GET  /api/devices    → Simulator list       │
│  ├── GET  /api/screenshot → Cached frame (PNG)   │
│  ├── GET  /api/frame      → Device bezel PNG     │
│  ├── POST /api/tap        → AXe tap              │
│  ├── POST /api/swipe      → AXe swipe            │
│  ├── POST /api/type       → AXe type             │
│  ├── POST /api/button     → AXe button           │
│  └── GET  /api/describe   → AXe describe-ui      │
└──────────────┬──────────────────────────────────┘
               │ uses
               ▼
┌─────────────────────────────────────────────────┐
│              Infrastructure                      │
│  SimctlSimulatorRepository (xcrun simctl)        │
│  AXeInteractionRepository  (axe CLI)             │
│  AXeStreamManager          (background capture)  │
│  DeviceStreamServer        (NWListener HTTP)      │
└──────────────┬──────────────────────────────────┘
               │ implements
               ▼
┌─────────────────────────────────────────────────┐
│              Domain                              │
│  Simulator, SimulatorState, SimulatorFilter       │
│  SimulatorRepository (@Mockable)                  │
│  SimulatorInteractionRepository (@Mockable)       │
│  SimulatorButton, SimulatorGesture                │
└─────────────────────────────────────────────────┘
```

---

## Domain Models

### Simulator

```swift
public struct Simulator: Sendable, Equatable, Identifiable, Codable {
    public let id: String       // UDID
    public let name: String     // "iPhone 16 Pro Max"
    public let state: SimulatorState
    public let runtime: String  // "com.apple.CoreSimulator.SimRuntime.iOS-18-2"

    public var isBooted: Bool       // state == .booted
    public var displayRuntime: String  // "iOS 18.2"
}
```

### SimulatorState

```swift
public enum SimulatorState: String, Codable {
    case booted = "Booted"
    case shutdown = "Shutdown"
    case shuttingDown = "Shutting Down"
    case creating = "Creating"

    public var isBooted: Bool
    public var isAvailable: Bool  // booted or shutdown
}
```

### Affordances (state-aware)

| State | Affordances |
|-------|-------------|
| `shutdown` | `boot`, `listSimulators` |
| `booted` | `shutdown`, `stream`, `listSimulators` |

---

## File Map

### Sources

```
Sources/
├── Domain/Simulators/
│   ├── Simulator.swift
│   ├── SimulatorState.swift
│   ├── SimulatorRepository.swift
│   ├── SimulatorInteraction.swift
│   └── SimulatorInteractionRepository.swift
├── Infrastructure/Simulators/
│   ├── SimctlSimulatorRepository.swift
│   ├── AXeInteractionRepository.swift
│   ├── AXeStreamManager.swift
│   └── DeviceStreamServer.swift
└── ASCCommand/Commands/Simulators/
    ├── SimulatorsCommand.swift
    ├── SimulatorsList.swift
    ├── SimulatorsBoot.swift
    ├── SimulatorsShutdown.swift
    └── SimulatorsStream.swift
```

### Tests

```
Tests/
├── DomainTests/Simulators/
│   └── SimulatorTests.swift              (12 tests)
└── ASCCommandTests/Commands/Simulators/
    ├── SimulatorsListTests.swift          (4 tests)
    ├── SimulatorsBootTests.swift          (1 test)
    ├── SimulatorsShutdownTests.swift      (1 test)
    └── SimulatorsStreamTests.swift        (5 tests)
```

### Wiring

| File | Change |
|------|--------|
| `ClientFactory.swift` | `makeSimulatorRepository()`, `makeSimulatorInteractionRepository()` |
| `ClientProvider.swift` | Static factory methods |
| `ASC.swift` | Registered `SimulatorsCommand` |
| `MockRepositoryFactory.swift` | `makeSimulator()` factory |

### Web UI Assets

```
apps/remote-device-stream/
├── index.html                    # Interactive stream UI
├── frames/                       # Device bezel PNGs
│   ├── iPhone 16 Pro Max.png
│   ├── iPhone 17 Pro Max.png
│   ├── ...
│   └── insets.json               # Screen inset data from devices.json
└── simulator-config.json         # (deprecated, replaced by frames/)
```

---

## Testing

```bash
# Run all simulator tests
swift test --filter 'Simulator'

# Run specific suite
swift test --filter 'SimulatorTests'
swift test --filter 'SimulatorsListTests'
```

---

## Prerequisites

- **Xcode** — provides `xcrun simctl` for simulator management
- **AXe** _(optional, recommended)_ — enables tap, swipe, type, and UI inspection in the stream

```bash
brew install cameroncooke/axe/axe
```
