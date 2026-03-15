# IAP & Subscription Availability

Manage territory availability for in-app purchases and auto-renewable subscriptions.

## CLI Usage

### IAP Availability

#### Get IAP Availability

```bash
asc iap-availability get --iap-id <id>
```

| Flag | Required | Description |
|------|----------|-------------|
| `--iap-id` | Yes | IAP ID to get availability for |
| `--output` | No | Output format: json (default), table, markdown |
| `--pretty` | No | Pretty-print JSON output |

#### Create IAP Availability

```bash
asc iap-availability create --iap-id <id> \
  --available-in-new-territories \
  --territory USA --territory CHN --territory JPN
```

| Flag | Required | Description |
|------|----------|-------------|
| `--iap-id` | Yes | IAP ID to set availability for |
| `--available-in-new-territories` | No | Auto-include new territories Apple adds |
| `--territory` | No | Territory ID (repeatable, e.g. USA, CHN, JPN) |

### Subscription Availability

#### Get Subscription Availability

```bash
asc subscription-availability get --subscription-id <id>
```

| Flag | Required | Description |
|------|----------|-------------|
| `--subscription-id` | Yes | Subscription ID to get availability for |

#### Create Subscription Availability

```bash
asc subscription-availability create --subscription-id <id> \
  --available-in-new-territories \
  --territory USA --territory GBR
```

| Flag | Required | Description |
|------|----------|-------------|
| `--subscription-id` | Yes | Subscription ID to set availability for |
| `--available-in-new-territories` | No | Auto-include new territories Apple adds |
| `--territory` | No | Territory ID (repeatable) |

### Example Output (JSON)

```json
{
  "data": [
    {
      "id": "avail-1",
      "iapId": "iap-42",
      "isAvailableInNewTerritories": true,
      "territories": ["USA", "CHN", "JPN"],
      "affordances": {
        "getAvailability": "asc iap-availability get --iap-id iap-42",
        "createAvailability": "asc iap-availability create --iap-id iap-42 --available-in-new-territories --territory USA --territory CHN"
      }
    }
  ]
}
```

## Typical Workflow

```bash
# 1. List IAPs for an app
asc iap list --app-id $APP_ID

# 2. Check availability for a specific IAP
asc iap-availability get --iap-id $IAP_ID

# 3. Set availability to specific territories
asc iap-availability create --iap-id $IAP_ID \
  --available-in-new-territories \
  --territory USA --territory GBR --territory DEU

# Same flow for subscriptions:
asc subscriptions list --group-id $GROUP_ID
asc subscription-availability get --subscription-id $SUB_ID
asc subscription-availability create --subscription-id $SUB_ID \
  --territory USA --territory JPN
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ ASCCommand                                                   │
│  IAPAvailabilityCommand (get, create)                       │
│  SubscriptionAvailabilityCommand (get, create)              │
├─────────────────────────────────────────────────────────────┤
│ Infrastructure                                               │
│  SDKInAppPurchaseAvailabilityRepository                     │
│  SDKSubscriptionAvailabilityRepository                      │
├─────────────────────────────────────────────────────────────┤
│ Domain                                                       │
│  InAppPurchaseAvailability + AffordanceProviding             │
│  SubscriptionAvailability + AffordanceProviding              │
│  InAppPurchaseAvailabilityRepository (@Mockable)            │
│  SubscriptionAvailabilityRepository (@Mockable)             │
└─────────────────────────────────────────────────────────────┘
```

## Domain Models

### InAppPurchaseAvailability

```swift
public struct InAppPurchaseAvailability: Sendable, Equatable, Identifiable, Codable {
    public let id: String
    public let iapId: String                      // parent ID, injected by Infrastructure
    public let isAvailableInNewTerritories: Bool
    public let territories: [String]              // territory IDs (e.g. "USA", "CHN")
}
```

**Affordances:**
- `getAvailability` — refresh this availability record
- `createAvailability` — create/update availability with territories

### SubscriptionAvailability

```swift
public struct SubscriptionAvailability: Sendable, Equatable, Identifiable, Codable {
    public let id: String
    public let subscriptionId: String             // parent ID, injected by Infrastructure
    public let isAvailableInNewTerritories: Bool
    public let territories: [String]
}
```

**Affordances:** Same pattern as IAP availability.

## File Map

```
Sources/
├── Domain/Apps/InAppPurchases/Availability/
│   ├── InAppPurchaseAvailability.swift
│   └── InAppPurchaseAvailabilityRepository.swift
├── Domain/Apps/Subscriptions/Availability/
│   ├── SubscriptionAvailability.swift
│   └── SubscriptionAvailabilityRepository.swift
├── Infrastructure/Apps/InAppPurchases/Availability/
│   └── SDKInAppPurchaseAvailabilityRepository.swift
├── Infrastructure/Apps/Subscriptions/Availability/
│   └── SDKSubscriptionAvailabilityRepository.swift
└── ASCCommand/Commands/
    ├── IAP/Availability/
    │   ├── IAPAvailabilityCommand.swift
    │   ├── IAPAvailabilityGet.swift
    │   └── IAPAvailabilityCreate.swift
    └── Subscriptions/Availability/
        ├── SubscriptionAvailabilityCommand.swift
        ├── SubscriptionAvailabilityGet.swift
        └── SubscriptionAvailabilityCreate.swift

Tests/
├── DomainTests/Apps/InAppPurchases/Availability/
│   └── InAppPurchaseAvailabilityTests.swift
├── DomainTests/Apps/Subscriptions/Availability/
│   └── SubscriptionAvailabilityTests.swift
├── InfrastructureTests/Apps/InAppPurchases/Availability/
│   └── SDKInAppPurchaseAvailabilityRepositoryTests.swift
├── InfrastructureTests/Apps/Subscriptions/Availability/
│   └── SDKSubscriptionAvailabilityRepositoryTests.swift
└── ASCCommandTests/Commands/
    ├── IAP/Availability/
    │   ├── IAPAvailabilityGetTests.swift
    │   └── IAPAvailabilityCreateTests.swift
    └── Subscriptions/Availability/
        ├── SubscriptionAvailabilityGetTests.swift
        └── SubscriptionAvailabilityCreateTests.swift
```

| Wiring File | Change |
|-------------|--------|
| `ClientFactory.swift` | `makeInAppPurchaseAvailabilityRepository`, `makeSubscriptionAvailabilityRepository` |
| `ClientProvider.swift` | Static factory methods for both repositories |
| `ASC.swift` | Register `IAPAvailabilityCommand`, `SubscriptionAvailabilityCommand` |
| `InAppPurchase.swift` | Added `getAvailability` affordance |
| `Subscription.swift` | Added `getAvailability` affordance |

## API Reference

| Endpoint | SDK Call | Repository Method |
|----------|---------|-------------------|
| GET /v2/inAppPurchases/{id}/inAppPurchaseAvailability | `APIEndpoint.v2.inAppPurchases.id().inAppPurchaseAvailability.get()` | `getAvailability(iapId:)` |
| POST /v1/inAppPurchaseAvailabilities | `APIEndpoint.v1.inAppPurchaseAvailabilities.post()` | `createAvailability(iapId:isAvailableInNewTerritories:territoryIds:)` |
| GET /v1/subscriptions/{id}/subscriptionAvailability | `APIEndpoint.v1.subscriptions.id().subscriptionAvailability.get()` | `getAvailability(subscriptionId:)` |
| POST /v1/subscriptionAvailabilities | `APIEndpoint.v1.subscriptionAvailabilities.post()` | `createAvailability(subscriptionId:isAvailableInNewTerritories:territoryIds:)` |

## Testing

```bash
swift test --filter 'InAppPurchaseAvailabilityTests|SubscriptionAvailabilityTests|SDKInAppPurchaseAvailabilityRepositoryTests|SDKSubscriptionAvailabilityRepositoryTests|IAPAvailabilityGetTests|IAPAvailabilityCreateTests|SubscriptionAvailabilityGetTests|SubscriptionAvailabilityCreateTests'
```

## Extending

- **Update availability** — Add PATCH support if the API supports modifying existing availability records
- **List territories** — Add `asc territories list` to discover available territory IDs
- **App-level availability** — Use `/v2/appAvailabilities` for app-level territory control
