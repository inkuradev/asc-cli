# App Shots

Create professional App Store marketing screenshots from raw app screenshots. Three approaches — pick the one that fits your workflow:

| | **Enhance** | **Compose + Enhance** | **HTML Export** |
|---|---|---|---|
| **What you do** | Feed a screenshot to Gemini AI | Pick a template, apply it, then enhance with AI | Write a layout plan, export from browser |
| **Command** | `asc app-shots generate` | `templates apply` → `generate` | `asc app-shots html` |
| **AI required** | Yes (Gemini) | Yes (Gemini) | No |
| **Control level** | Low — AI decides layout | Medium — you pick the template | Full — pixel-perfect |

---

## Quick Start

```bash
# 1. Save your Gemini API key (one-time)
asc app-shots config --gemini-api-key AIzaSy...

# 2. Enhance a screenshot
asc app-shots generate --file .asc/app-shots/screen-0.png

# Output: .asc/app-shots/output/screen-0.png
```

That's it. Gemini analyzes your screenshot, wraps it in a photorealistic iPhone mockup, adds marketing text, and outputs a polished App Store image.

---

## CLI Reference

### `asc app-shots generate`

Enhance a single screenshot into a marketing image using Gemini AI.

| Flag | Default | Description |
|------|---------|-------------|
| `--file` | *(required)* | Screenshot file to enhance |
| `--style-reference` | — | Reference image whose visual style Gemini replicates |
| `--prompt` | — | Custom prompt (overrides the built-in auto-enhance prompt) |
| `--gemini-api-key` | — | Gemini API key (falls back to `GEMINI_API_KEY` env, then saved config) |
| `--model` | `gemini-3.1-flash-image-preview` | Gemini model |
| `--output-dir` | `.asc/app-shots/output` | Directory for generated PNGs |

```bash
# Auto-enhance — AI analyzes and designs everything
asc app-shots generate --file screen.png

# Style transfer — match another screenshot's look
asc app-shots generate --file screen.png --style-reference competitor.png

# Custom prompt — tell Gemini exactly what you want
asc app-shots generate --file screen.png \
  --prompt "Add warm glow, deepen shadows, make text pop"
```

**JSON output:**
```json
{
  "generated" : ".asc/app-shots/output/screen-0.png"
}
```

**How the built-in prompt works:**

The default auto-enhance prompt tells Gemini to:
- Analyze the app screenshot (purpose, features, color scheme)
- Replace flat device frames with a photorealistic iPhone 15 Pro mockup
- Find the most compelling UI panel and "break it out" from the device with a drop shadow
- Add a bold 2-4 word ACTION VERB headline (e.g. "TRACK WEATHER") if none exists
- Apply a clean gradient background complementing the app's colors
- Add 1-2 subtle supporting elements (badges, stats)

For better results, use the **`asc-app-shots-prompt` skill** in Claude Code — it reads your screenshot, identifies exact UI panels and colors, and generates a targeted `--prompt` that names specific elements instead of letting Gemini guess.

---

### `asc app-shots translate`

Translate already-generated screenshots into other locales. Gemini reproduces the image exactly, only translating text overlays outside the device mockup.

| Flag | Default | Description |
|------|---------|-------------|
| `--plan` | `.asc/app-shots/app-shots-plan.json` | Source `ScreenshotDesign` JSON |
| `--from` | `en` | Source locale |
| `--to` | *(required, repeatable)* | Target locale(s) |
| `--source-dir` | `.asc/app-shots/output` | Directory with existing generated screenshots |
| `--gemini-api-key` | — | Gemini API key |
| `--model` | `gemini-3.1-flash-image-preview` | Gemini model |
| `--output-dir` | `.asc/app-shots/output` | Base output directory (creates `<locale>/` subdirs) |
| `--device-type` | — | Named device type (overrides width/height) |
| `--style-reference` | — | Style reference for visual consistency |
| `--output-width` | `1320` | Output width in pixels |
| `--output-height` | `2868` | Output height in pixels |

```bash
# Translate to Chinese and Japanese
asc app-shots translate --to zh --to ja

# With style reference for consistency
asc app-shots translate --to zh --style-reference ref.png
```

**JSON output:**
```json
{
  "data": [
    { "locale": "ja", "screens": 3, "outputDir": ".asc/app-shots/output/ja" },
    { "locale": "zh", "screens": 3, "outputDir": ".asc/app-shots/output/zh" }
  ]
}
```

---

### `asc app-shots templates list`

List available screenshot templates. Templates are provided by plugins (e.g. Blitz Screenshots ships 23 built-in templates).

| Flag | Default | Description |
|------|---------|-------------|
| `--size` | — | Filter by size: `portrait`, `landscape`, `portrait43`, `square` |
| `--preview` | — | Include self-contained HTML preview for each template |
| `--output` | `json` | Output format: `json`, `table`, `markdown` |
| `--pretty` | — | Pretty-print JSON |

```bash
asc app-shots templates list
asc app-shots templates list --size portrait --output table
```

**JSON output:**
```json
{
  "data": [
    {
      "id": "top-hero",
      "name": "Top Hero",
      "category": "bold",
      "supportedSizes": ["portrait"],
      "deviceCount": 1,
      "affordances": {
        "preview": "asc app-shots templates get --id top-hero --preview",
        "apply": "asc app-shots templates apply --id top-hero --screenshot screen.png",
        "detail": "asc app-shots templates get --id top-hero",
        "listAll": "asc app-shots templates list"
      }
    }
  ]
}
```

### `asc app-shots templates get`

Get details of a specific template.

| Flag | Default | Description |
|------|---------|-------------|
| `--id` | *(required)* | Template ID |
| `--preview` | — | Output self-contained HTML preview page |

```bash
asc app-shots templates get --id top-hero
asc app-shots templates get --id top-hero --preview > preview.html && open preview.html
```

### `asc app-shots templates apply`

Apply a template to a screenshot. Returns a `ScreenDesign` with affordances for next steps.

| Flag | Default | Description |
|------|---------|-------------|
| `--id` | *(required)* | Template ID |
| `--screenshot` | *(required)* | Path to screenshot file |
| `--headline` | *(required)* | Headline text |
| `--subtitle` | — | Subtitle text |
| `--app-name` | `My App` | App name |
| `--preview` | — | Output self-contained HTML preview |

```bash
# Get design JSON with affordances
asc app-shots templates apply \
  --id top-hero \
  --screenshot screen.png \
  --headline "Ship Faster"

# Preview in browser
asc app-shots templates apply \
  --id top-hero \
  --screenshot screen.png \
  --headline "Ship Faster" \
  --preview > composed.html && open composed.html
```

**JSON output:**
```json
{
  "data": [
    {
      "heading": "Ship Faster",
      "screenshotFile": "screen.png",
      "isComplete": true,
      "affordances": {
        "generate": "asc app-shots generate --design design.json",
        "preview": "asc app-shots templates apply --id top-hero --screenshot screen.png --headline \"Ship Faster\"",
        "changeTemplate": "asc app-shots templates list",
        "templateDetail": "asc app-shots templates get --id top-hero"
      }
    }
  ]
}
```

---

### `asc app-shots html`

Generate a self-contained HTML page from a plan JSON — no AI API key needed. Supports two plan formats:

- **`CompositionPlan`** (has `"canvas"` key) — pixel-perfect control with normalized 0-1 coordinates
- **`ScreenshotDesign`** (legacy) — simpler format, rendered via `LegacyHTMLRenderer`

| Flag | Default | Description |
|------|---------|-------------|
| `--plan` | `.asc/app-shots/app-shots-plan.json` | Path to plan JSON |
| `--output-dir` | `.asc/app-shots/output` | Directory for the HTML file |
| `--output-width` | `1320` | Canvas width in pixels |
| `--output-height` | `2868` | Canvas height in pixels |
| `--device-type` | — | Named device type (overrides width/height) |
| `--mockup` | *(bundled iPhone 17 Pro Max)* | Device mockup: file path, device name, or `"none"` |
| `--screen-inset-x` | — | Screen area X inset (overrides mockups.json) |
| `--screen-inset-y` | — | Screen area Y inset (overrides mockups.json) |
| `<screenshots>` | *(auto-discovered)* | Screenshot files; omit to auto-discover from plan directory |

```bash
# Default — uses .asc/app-shots/app-shots-plan.json
asc app-shots html

# With a specific device type
asc app-shots html --device-type APP_IPHONE_67

# Custom mockup
asc app-shots html --mockup "iPhone 17 Pro Max"

# No device frame
asc app-shots html --mockup none
```

---

### `asc app-shots config`

Manage the stored Gemini API key.

```bash
asc app-shots config --gemini-api-key AIzaSy...   # Save
asc app-shots config                                # Show (masked)
asc app-shots config --remove                       # Delete
```

**Key resolution order:** `--gemini-api-key` flag → `$GEMINI_API_KEY` env var → `~/.asc/app-shots-config.json`

---

## Typical Workflows

### Workflow 1: Quick Enhance (simplest)

```bash
# One command — AI handles everything
asc app-shots generate --file .asc/app-shots/screen-0.png
```

### Workflow 2: Template + Enhance (recommended)

```bash
# 1. Browse templates
asc app-shots templates list --output table

# 2. Preview one
asc app-shots templates get --id top-hero --preview > preview.html
open preview.html

# 3. Apply to your screenshot
asc app-shots templates apply \
  --id top-hero \
  --screenshot .asc/app-shots/screen-0.png \
  --headline "Ship Faster" \
  --preview > composed.html
open composed.html

# 4. Enhance the composed result with AI
asc app-shots generate --file .asc/app-shots/output/screen-0.png

# 5. Translate (optional)
asc app-shots translate --to zh --to ja
```

### Workflow 3: HTML Export (no AI)

```bash
# Write a CompositionPlan JSON (see Domain Models below)
# Then generate HTML
asc app-shots html --plan .asc/app-shots/composition-plan.json

# Open in browser to preview and export
open .asc/app-shots/output/app-shots.html
```

### Workflow 4: Skill-driven (Claude writes the plan)

```bash
# In Claude Code, use the asc-app-shots skill:
# "Plan my App Store screenshots for app 6736834466"
# → Claude fetches metadata, analyzes screenshots, writes app-shots-plan.json

# Then generate HTML or enhance with AI
asc app-shots html
# or
asc app-shots generate --file .asc/app-shots/screen-0.png
```

---

## Architecture

```
ASCCommand                            Domain                              Infrastructure
+-----------------------------------+ +-----------------------------------+ +-----------------------------------+
| AppShotsCommand                   | | ScreenshotDesign                  | | GeminiScreenshotGeneration-       |
|   ├── templates                   | |   appId, appName, tagline, tone   | |   Repository                      |
|   │   ├── list  (TemplateRepo)    | |   colors, screens[]               | |   POST generateContent            |
|   │   ├── get   (TemplateRepo)    | |   affordances: generate, html     | |   (native Gemini REST API)        |
|   │   └── apply (TemplateRepo)    | |                                   | +-----------------------------------+
|   ├── generate  (Gemini direct)   | | ScreenDesign                      | | AggregateTemplateRepository       |
|   ├── translate (GenRepo)         | |   index, heading, subheading      | |   (actor)                         |
|   ├── html      (local render)    | |   template?, screenshotFile       | |   Aggregates TemplateProviders    |
|   └── config    (ConfigStorage)   | |   isComplete, previewHTML         | +-----------------------------------+
+-----------------------------------+ |   affordances: generate, preview  | | FileAppShotsConfigStorage         |
                                      |                                   | |   ~/.asc/app-shots-config.json    |
                                      | ScreenshotTemplate                | +-----------------------------------+
                                      |   id, name, category, background  |
                                      |   textSlots[], deviceSlots[]      |
                                      |   isPortrait, deviceCount         |
                                      |   previewHTML, affordances        |
                                      |                                   |
                                      | CompositionPlan                   |
                                      |   canvas, defaults, screens[]     |
                                      |   (normalized 0-1 coordinates)    |
                                      |                                   |
                                      | TemplateProvider (protocol)       |
                                      | TemplateRepository (protocol)     |
                                      | ScreenshotGenerationRepository    |
                                      | AppShotsConfigStorage (protocol)  |
                                      +-----------------------------------+
```

**Dependency flow:** `ASCCommand → Domain ← Infrastructure`

**Key design note:** `generate` calls the Gemini API directly (no repository) for single-file enhancement. `translate` uses `ScreenshotGenerationRepository` for multi-screen batch generation. `html` renders locally with no network calls.

---

## Domain Models

### `ScreenshotDesign`

The top-level design plan — a collection of screens with shared styling. Used by `translate` and `html` (legacy path).

| Field | Type | Description |
|-------|------|-------------|
| `appId` | `String` | App ID (also the model's `id`) |
| `appName` | `String` | App display name |
| `tagline` | `String` | Marketing tagline |
| `appDescription` | `String?` | Summary for Gemini context (omitted from JSON when nil) |
| `tone` | `ScreenTone` | `bold`, `minimal`, `elegant`, `professional`, `playful` |
| `colors` | `ScreenColors` | `primary`, `accent`, `text`, `subtext` |
| `screens` | `[ScreenDesign]` | Ordered screen designs |

**Affordances:**
| Key | Command |
|-----|---------|
| `generate` | `asc app-shots generate --plan app-shots-plan.json --gemini-api-key $GEMINI_API_KEY` |
| `generateHTML` | `asc app-shots html --plan app-shots-plan.json` |

### `ScreenDesign`

A single screen — knows its template, content, and how to preview itself.

| Field | Type | Description |
|-------|------|-------------|
| `index` | `Int` | Screen order (0-based) |
| `template` | `ScreenshotTemplate?` | Applied template (runtime only, excluded from Codable) |
| `screenshotFile` | `String` | Source screenshot path |
| `heading` | `String` | Main headline |
| `subheading` | `String` | Supporting text |
| `layoutMode` | `LayoutMode` | Layout hint (legacy) |
| `visualDirection` | `String` | Visual description (legacy) |
| `imagePrompt` | `String` | Per-screen Gemini prompt (legacy) |

**Computed properties:**
| Property | Type | Description |
|----------|------|-------------|
| `isComplete` | `Bool` | `template != nil && !heading.isEmpty && !screenshotFile.isEmpty` |
| `previewHTML` | `String` | Self-contained HTML preview (empty if no template) |

**Affordances** (state-aware):
| Key | When | Command |
|-----|------|---------|
| `generate` | `isComplete` | `asc app-shots generate --design design.json` |
| `preview` | `isComplete` | `asc app-shots templates apply --id {id} ...` |
| `changeTemplate` | always | `asc app-shots templates list` |
| `templateDetail` | has template | `asc app-shots templates get --id {id}` |

### `ScreenshotTemplate`

Reusable template for composing screenshots. Registered by plugins via `TemplateProvider`.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique identifier |
| `name` | `String` | Display name |
| `category` | `TemplateCategory` | `bold`, `minimal`, `elegant`, `professional`, `playful`, `showcase`, `custom` |
| `supportedSizes` | `[ScreenSize]` | `portrait`, `landscape`, `portrait43`, `square` |
| `description` | `String` | Human-readable description |
| `background` | `SlideBackground` | `.solid(color)` or `.gradient(from, to, angle)` |
| `textSlots` | `[TemplateTextSlot]` | Text positions with role, preview, style |
| `deviceSlots` | `[TemplateDeviceSlot]` | Device positions with scale, rotation |

**Semantic booleans:** `isPortrait`, `isLandscape`, `deviceCount`

**Affordances:** `preview`, `apply`, `detail`, `listAll`

### `CompositionPlan`

Deterministic layout plan for HTML export. All positions use **normalized 0-1 coordinates** relative to canvas dimensions.

| Field | Type | Description |
|-------|------|-------------|
| `appName` | `String` | App name |
| `canvas` | `CanvasSize` | `width`, `height`, optional `displayType` |
| `defaults` | `SlideDefaults` | `background`, `textColor`, `subtextColor`, `accentColor`, `font` |
| `screens` | `[SlideComposition]` | Each with `texts: [TextOverlay]` and `devices: [DeviceSlot]` |

**Example:**
```json
{
  "appName": "MyApp",
  "canvas": { "width": 1320, "height": 2868 },
  "defaults": {
    "background": { "type": "gradient", "from": "#2A1B5E", "to": "#000000", "angle": 180 },
    "textColor": "#FFFFFF", "subtextColor": "#A8B8D0", "accentColor": "#4A7CFF", "font": "Inter"
  },
  "screens": [{
    "texts": [
      { "content": "ALL YOUR APPS", "x": 0.065, "y": 0.028, "fontSize": 0.028, "fontWeight": 700, "color": "#B8A0FF" }
    ],
    "devices": [
      { "screenshotFile": "screen-1.png", "mockup": "iPhone 17 Pro Max", "x": 0.5, "y": 0.65, "scale": 0.88 }
    ]
  }]
}
```

### Protocols

```swift
@Mockable
public protocol TemplateProvider: Sendable {
    var providerId: String { get }
    func templates() async throws -> [ScreenshotTemplate]
}

@Mockable
public protocol TemplateRepository: Sendable {
    func listTemplates(size: ScreenSize?) async throws -> [ScreenshotTemplate]
    func getTemplate(id: String) async throws -> ScreenshotTemplate?
}

@Mockable
public protocol ScreenshotGenerationRepository: Sendable {
    func generateImages(plan: ScreenshotDesign, screenshotURLs: [URL], styleReferenceURL: URL?) async throws -> [Int: Data]
}

@Mockable
public protocol AppShotsConfigStorage: Sendable {
    func load() throws -> AppShotsConfig?
    func save(_ config: AppShotsConfig) throws
    func delete() throws
}
```

---

## Device Sizes

| Display Type | Device | Width | Height |
|---|---|---|---|
| `APP_IPHONE_69` | iPhone 6.9" | 1320 | 2868 |
| `APP_IPHONE_67` | iPhone 6.7" | 1290 | 2796 |
| `APP_IPHONE_65` | iPhone 6.5" | 1260 | 2736 |
| `APP_IPHONE_61` | iPhone 6.1" | 1179 | 2556 |
| `APP_IPHONE_58` | iPhone 5.8" | 1125 | 2436 |
| `APP_IPHONE_55` | iPhone 5.5" | 1242 | 2208 |
| `APP_IPHONE_47` | iPhone 4.7" | 750 | 1334 |
| `APP_IPAD_PRO_129` | iPad 13" | 2048 | 2732 |
| `APP_IPAD_PRO_3GEN_11` | iPad 11" | 1668 | 2388 |
| `APP_APPLE_TV` | Apple TV | 1920 | 1080 |
| `APP_DESKTOP` | Mac | 2560 | 1600 |
| `APP_APPLE_VISION_PRO` | Vision Pro | 3840 | 2160 |

---

## Device Mockups

Mockup resolution order:
1. `--mockup <file-path>` — use a PNG file directly
2. `--mockup <device-name>` — look up in `~/.asc/mockups/mockups.json`, then bundled `mockups.json`
3. `--mockup` omitted — use the entry marked `"default": true`
4. `--mockup none` — no device frame

Custom mockups go in `~/.asc/mockups/`:
```json
{
  "iPhone 17 Pro Max - Deep Blue": {
    "category": "iPhone",
    "model": "iPhone 17 Pro Max",
    "displayType": "APP_IPHONE_67",
    "outputWidth": 1470,
    "outputHeight": 3000,
    "screenInsetX": 75,
    "screenInsetY": 66,
    "file": "iPhone 17 Pro Max - Deep Blue - Portrait.png",
    "default": true
  }
}
```

---

## File Map

### Sources

```
Sources/
├── Domain/ScreenshotPlans/
│   ├── ScreenshotDesign.swift              # Top-level design (collection of screens)
│   ├── ScreenDesign.swift                  # Single screen (rich domain, carries template)
│   ├── ScreenshotTemplate.swift            # Template model + TemplateCategory, ScreenSize, TextSlot, DeviceSlot
│   ├── TemplateRepository.swift            # TemplateProvider + TemplateRepository protocols
│   ├── ScreenshotGenerationRepository.swift # @Mockable generation protocol
│   ├── CompositionPlan.swift               # Deterministic layout (SlideComposition, TextOverlay, DeviceSlot)
│   ├── TemplateHTMLRenderer.swift          # Renders template previews as HTML
│   ├── TemplateContent.swift               # Content to fill into a template
│   ├── AppShotsConfig.swift                # Gemini API key model
│   ├── AppShotsConfigStorage.swift         # @Mockable config storage protocol
│   ├── ScreenTone.swift                    # bold, minimal, elegant, professional, playful
│   ├── ScreenColors.swift                  # primary, accent, text, subtext
│   └── LayoutMode.swift                    # center, left, right (legacy)
├── Infrastructure/ScreenshotPlans/
│   ├── GeminiScreenshotGenerationRepository.swift  # Implements ScreenshotGenerationRepository
│   ├── AggregateTemplateRepository.swift           # Actor aggregating TemplateProviders
│   └── FileAppShotsConfigStorage.swift             # ~/.asc/app-shots-config.json
└── ASCCommand/Commands/AppShots/
    ├── AppShotsCommand.swift               # Entry point, registers subcommands
    ├── AppShotsGenerate.swift              # Single-file AI enhancement (direct Gemini call)
    ├── AppShotsTranslate.swift             # Multi-locale translation via GenRepo
    ├── AppShotsTemplates.swift             # list, get, apply subcommands
    ├── AppShotsHTML.swift                  # HTML export (CompositionPlan or legacy)
    ├── AppShotsConfig.swift                # Gemini key management
    ├── AppShotsDisplayType.swift           # Device type enum with dimensions
    ├── AppShotsUtils.swift                 # resolveGeminiApiKey(), resizeImageData()
    ├── MockupConfig.swift                  # MockupResolver, MockupEntry
    ├── CompositionHTMLRenderer.swift       # Renders CompositionPlan to HTML
    ├── LegacyHTMLRenderer.swift            # Renders ScreenshotDesign to HTML
    └── RenderAssets.swift                  # Screenshot data URIs + mockup info for renderers
```

### Tests

```
Tests/
├── DomainTests/ScreenshotPlans/
│   └── AppShotsConfigTests.swift
├── InfrastructureTests/ScreenshotPlans/
│   └── FileAppShotsConfigStorageTests.swift
└── ASCCommandTests/Commands/AppShots/
    ├── AppShotsGenerateTests.swift
    ├── AppShotsTranslateTests.swift
    ├── AppShotsTemplatesTests.swift
    ├── AppShotsHTMLTests.swift
    ├── AppShotsConfigTests.swift
    ├── AppShotsDisplayTypeTests.swift
    ├── CompositionHTMLRendererTests.swift
    └── LegacyHTMLRendererTests.swift
```

---

## Testing

```bash
swift test --filter 'AppShotsGenerate'              # Generate command (6)
swift test --filter 'AppShotsTemplates'              # Template commands
swift test --filter 'AppShotsTranslate'              # Translation
swift test --filter 'AppShotsHTML'                   # HTML export
swift test --filter 'CompositionHTMLRenderer'        # Composition renderer
swift test --filter 'LegacyHTMLRenderer'             # Legacy renderer
swift test --filter 'AppShotsDisplayType'            # Device types
swift test --filter 'AppShotsConfig'                 # Config management
swift test --filter 'AppShots'                       # All app-shots tests
```

---

## Available Templates

Templates are provided by plugins. The Blitz Screenshots plugin provides 23 built-in templates:

| Category | Templates |
|----------|-----------|
| **Bold** | Top Hero, Bold CTA, Tilted Hero, Midnight Bold |
| **Minimal** | Minimal Light, Device Only |
| **Elegant** | Dark Premium, Sage Editorial, Cream Serif, Ocean Calm, Blush Editorial |
| **Professional** | Top & Bottom, Left Aligned, Bottom Text |
| **Playful** | Warm Sunset, Sky Soft, Cartoon Peach, Cartoon Mint, Cartoon Lavender |
| **Showcase** | Duo Devices, Triple Fan, Side by Side |
| **Custom** | Custom Blank |