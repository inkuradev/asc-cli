---
name: asc-app-shots
description: |
  AI-powered App Store screenshot planning skill. Fetches app metadata from App Store Connect
  via `asc` CLI, analyzes screenshots using Claude's vision to extract colors and layout,
  summarizes the app description, and writes a ScreenPlan JSON file ready for
  `asc app-shots generate` to produce final marketing screenshots via Gemini.
  Use this skill when:
  (1) User asks to "analyze my screenshots for App Store"
  (2) User asks to "create an app shots plan" or "generate screenshot plan"
  (3) User says "plan my App Store screenshots for app ID"
  (4) User mentions "asc-app-shots" or asks for screenshot marketing copy planning
---

# asc-app-shots: Screenshot Plan Generator

Two-step workflow:
1. **This skill** — fetch metadata + analyze screenshots → write `app-shots-plan.json`
2. **`asc app-shots generate`** — read plan + call Gemini image generation → output PNG files

---

## Step 1 — Gather inputs

Ask the user for (skip if already provided):
- **App ID** — e.g. `6736834466`
- **Version ID** — from `asc versions list --app-id <id>`
- **Locale** — default: `en-US`
- **Screenshot files** — paths to PNG/JPG files to plan

---

## Step 2 — Fetch App Store metadata

Run these commands and extract the fields:

```bash
# 1. App name + tagline (subtitle)
APP_INFO_ID=$(asc app-infos list --app-id <APP_ID> | jq -r '.data[0].id')
asc app-info-localizations list --app-info-id "$APP_INFO_ID"
# → appName from .name, tagline from .subtitle (fallback: empty string)

# 2. Full description + keywords
asc version-localizations list --version-id <VERSION_ID>
# → description from .description (for locale), keywords from .keywords
```

**Summarize `appDescription`** from the full `.description`:
- Write 2-3 focused sentences capturing the app's **purpose** and **target audience**
- Keep it under 200 characters — this context is prepended to every Gemini imagePrompt
- Example: "AppNexus manages iOS/macOS apps on App Store Connect. A unified dashboard for versions, metadata, screenshots, and AI-powered store optimization. Built for indie developers who want full control without opening a browser."
- If description is unavailable, leave `appDescription` out of the plan

---

## Step 3 — Analyze screenshots with vision

Read each screenshot file. For each one, determine:

### Colors (from the first/hero screenshot)
Extract the app's dominant color palette to populate `colors`:
- `primary` — dominant background color (usually dark: navy, black, deep gray)
- `accent` — brand/highlight color (button tints, active states, logo color)
- `text` — heading text color (usually white or near-white)
- `subtext` — secondary text color (gray, muted)

**Fallbacks if colors are ambiguous:** `#0D1B2A` / `#4A7CFF` / `#FFFFFF` / `#A8B8D0`

### Per-screen config
For each screenshot:
1. **heading** — 2-5 word benefit headline (what does the user gain?)
2. **subheading** — 6-12 word supporting text (how? for whom?)
3. **layoutMode** — `center` (hero, large device), `left` (feature, text on right), `tilted` (dynamic angle)
4. **visualDirection** — 1-2 sentence factual description of what the UI shows
5. **imagePrompt** — Gemini generation prompt (see formula below)

### imagePrompt Formula (CRITICAL — sent directly to Gemini for image generation)

Use this 1-3 sentence structure:

```
"Generate a [premium/cinematic/modern] App Store [hero/feature/showcase] screenshot.
The uploaded iPhone UI is displayed in a [style] device mockup [angle/position].
Bold [color] heading '[EXACT heading text]' [placement], with [color] subtext '[EXACT subheading]' [placement].
[Background hex color], [glow/gradient/lighting effect]. [Quality/style descriptors]."
```

**Rules:**
- Always start: "Generate a [adjective] App Store screenshot"
- Always quote **exact heading and subheading text** — Gemini renders them in the image
- Specify device angle: "tilted ~8 degrees", "centered on canvas", "positioned to the left"
- Include background hex + lighting: "deep electric blue radial glow (#4A7CFF)", "soft bokeh depth"
- End with quality: "Minimal, editorial, premium quality" / "Cinematic depth, professional quality"
- 1-3 sentences max — be concise, let Gemini be creative

**Hero screen (tilted, centered):**
> "Generate a premium App Store hero screenshot. The uploaded iPhone UI is displayed in a sleek tilted device mockup (~8 degrees) centered on a near-black canvas (#0D1B2A). Bold white heading 'Manage All Your Apps' sits above the device, with soft blue-gray subtext 'One dashboard for every release' below. A deep electric blue radial glow (#4A7CFF) pulses behind the device. Floating micro-dots add cinematic depth. Minimal, editorial, premium quality."

**Feature screen (left-positioned):**
> "Generate a modern App Store feature screenshot. The uploaded iPhone UI is positioned to the left on a deep navy background (#0D1B2A), tilted slightly right. Bold white heading 'Ship With Confidence' on the right side, with muted blue subtext 'Metadata, screenshots, and AI in one tap' below. Soft blue accent glow radiates from behind the device. Professional depth-of-field atmosphere, editorial quality."

### Tone (for the whole plan)
Choose based on app category + metadata:
- `minimal` — tools, utilities, productivity
- `playful` — games, kids, lifestyle
- `professional` — business, finance, enterprise
- `bold` — sports, media, entertainment
- `elegant` — fashion, luxury, wellness

---

## Step 4 — Write plan file

Combine metadata + vision analysis into `app-shots-plan.json` (see `references/plan-schema.md` for schema).

Use the Write tool to save the file in the current directory (or alongside the screenshots if in a subdirectory).

---

## Step 5 — Print next step

```
✅ Plan written to app-shots-plan.json

Next step — generate marketing screenshots with Gemini:
  asc app-shots generate \
    --plan app-shots-plan.json \
    --gemini-api-key $GEMINI_API_KEY \
    --output-dir app-shots-output \
    <screenshot files...>

Generated PNGs → app-shots-output/screen-0.png, screen-1.png, ...
```

---

## Example invocation

User: "Plan App Store screenshots for app 6736834466, version v123. Screenshots: screen1.png screen2.png"

Claude:
1. Runs `asc app-infos list --app-id 6736834466` → gets `appInfoId`
2. Runs `asc app-info-localizations list --app-info-id <id>` → `appName`, `tagline`
3. Runs `asc version-localizations list --version-id v123` → full `description`
4. Summarizes description → `appDescription` (2-3 sentences, ≤200 chars)
5. Reads `screen1.png`, `screen2.png` with vision → extracts `colors`, builds per-screen configs
6. Generates `ScreenPlan` JSON with 2 screens
7. Writes `app-shots-plan.json`
8. Prints generate command
