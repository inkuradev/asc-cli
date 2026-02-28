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

## Step 1 — Detect CLI command

Before running any `asc` commands, determine which command to use:

```bash
which asc
```

- **If found** → use `asc` directly (installed via Homebrew or binary)
- **If not found** → use `swift run asc` (running from the asc-swift source repo)

Use whichever works for all subsequent commands. In examples below, `asc` represents whichever form is correct.

---

## Step 2 — Gather inputs

Ask the user for (skip if already provided):
- **App ID** — e.g. `6736834466`; if unknown, run `asc apps list` and let user pick
- **Version ID** — if unknown, run `asc versions list --app-id <APP_ID>` and use the first result
- **Locale** — default: `en-US`
- **Screenshot files** — check `.asc/app-shots/` in the current directory first; if `*.png` or `*.jpg` files are present there, use them automatically without asking. Only ask the user if no files are found there.

---

## Step 3 — Fetch App Store metadata

Run each command as a single direct pipe — never `cat` intermediate files.

Our `asc` CLI **flattens all fields to the top level** (no `.attributes` wrapper).

```bash
# 1. List apps — fields: id, name, bundleId, primaryLocale, sku
asc apps list | jq '.data[] | {id, name}'

# 2. App info ID + localization — fields: id, locale, name, subtitle, privacyPolicyUrl, appInfoId
APP_INFO_ID=$(asc app-infos list --app-id <APP_ID> | jq -r '.data[0].id')
asc app-info-localizations list --app-info-id "$APP_INFO_ID" \
  | jq '.data[] | select(.locale == "<LOCALE>") | {name, subtitle}'

# 3. Version ID (if not already known) — use first result
VERSION_ID=$(asc versions list --app-id <APP_ID> | jq -r '.data[0].id')

# 4. Version localization — fields: id, locale, description, keywords, marketingUrl, supportUrl, versionId
asc version-localizations list --version-id "$VERSION_ID" \
  | jq '.data[] | select(.locale == "<LOCALE>") | {description, keywords}'
```

Extract:
- `appName` ← `.name`; `tagline` ← `.subtitle` (use empty string if null)
- `appDescription` ← summarize `.description` to 2-3 sentences (see below)
- `keywords` for reference only (not written to the plan)

**Summarize `appDescription`** from the full `.description`:
- Write 2-3 focused sentences capturing the app's **purpose** and **target audience**
- Keep it under 200 characters — this context is prepended to every Gemini imagePrompt
- Example: "AppNexus manages iOS/macOS apps on App Store Connect. A unified dashboard for versions, metadata, screenshots, and AI-powered store optimization. Built for indie developers who want full control without opening a browser."
- If description is unavailable, leave `appDescription` out of the plan

---

## Step 4 — Analyze screenshots with vision

Read each screenshot file. For each one, determine:

### Colors (from the first/hero screenshot)
Extract the app's dominant color palette to populate `colors`:
- `primary` — dominant background color (usually dark: navy, black, deep gray)
- `accent` — brand/highlight color (button tints, active states, logo color)
- `text` — heading text color (usually white or near-white)
- `subtext` — secondary text color (gray, muted)

**Fallbacks if colors are ambiguous:** `#0D1B2A` / `#4A7CFF` / `#FFFFFF` / `#A8B8D0`

### Hero vs Standard — App Store design convention (CRITICAL)

**Only `index: 0` is the hero screenshot.** All others (`index: 1, 2, 3...`) are standard screenshots.

| | Hero (index 0) | Standard (index 1+) |
|---|---|---|
| Device angle | Tilted ~8-10° | Upright, straight (0-2°) |
| Device size | ~70% canvas | ~80% canvas, fills frame |
| Effects | Radial glow, floating dots, light streaks | Subtle gradient or flat background only |
| Text placement | Heading above, subheading below | Heading above device, subheading below |
| Purpose | Grab attention in search results | Show features clearly |
| layoutMode | `center` or `tilted` | `center` |

### Per-screen config
For each screenshot:
1. **heading** — 2-5 word benefit headline (what does the user gain?)
2. **subheading** — 6-12 word supporting text (how? for whom?)
3. **layoutMode** — always `center` for standard; `center` or `tilted` for hero
4. **visualDirection** — 1-2 sentence factual description of what the UI shows
5. **imagePrompt** — Gemini generation prompt (see formula below)

### imagePrompt Formula (CRITICAL — sent directly to Gemini for image generation)

Always quote **exact heading and subheading text** — Gemini renders them in the image.

**Hero (index 0) — cinematic, tilted, atmospheric:**
```
"Generate a premium App Store hero screenshot. The uploaded iPhone UI is displayed in a
sleek tilted device mockup (~8 degrees) centered on a [dark] canvas ([hex]). Bold white
heading '[EXACT heading]' above the device, with [color] subtext '[EXACT subheading]' below.
[Accent color] radial glow behind the device. [Floating dots / light streaks]. Premium quality."
```

> Example: "Generate a premium App Store hero screenshot. The uploaded iPhone UI is displayed in a sleek tilted device mockup (~10 degrees) centered on a deep navy canvas (#0A0F1E). Bold white heading 'All Your Apps' above the device, with soft blue-gray subtext 'Manage your entire App Store portfolio in one place' below. Brilliant electric blue radial glow (#4A90E2) pulses behind the device. Floating micro-dots add cinematic depth. Professional, editorial, premium quality."

**Standard (index 1+) — clean, upright, UI-focused:**
```
"Generate a clean App Store feature screenshot. The uploaded iPhone UI is displayed upright
and centered, filling most of the canvas on a [dark] background ([hex]). Bold white heading
'[EXACT heading]' above the device, with [color] subtext '[EXACT subheading]' below.
Subtle background vignette. Clean, minimal, editorial quality."
```

> Example: "Generate a clean App Store feature screenshot. The uploaded iPhone UI is displayed upright and centered, filling most of the canvas on a deep navy background (#0A0F1E). Bold white heading 'Ship With Confidence' above the device, with muted blue-gray subtext 'App Info, Screenshots, and AI tools in one tap' below. Subtle background vignette. Clean, minimal, editorial quality."

### Tone (for the whole plan)
Choose based on app category + metadata:
- `minimal` — tools, utilities, productivity
- `playful` — games, kids, lifestyle
- `professional` — business, finance, enterprise
- `bold` — sports, media, entertainment
- `elegant` — fashion, luxury, wellness

---

## Step 5 — Write plan file

Combine metadata + vision analysis into `app-shots-plan.json`.

**CRITICAL: The root JSON key is `appId` (not `id`).** See `references/plan-schema.md` for the full schema.

Use the Write tool to save the plan to **`.asc/app-shots/app-shots-plan.json`** (create the directory if needed). This is the default location that `asc app-shots generate` reads automatically.

---

## Step 6 — Auto-run generate (do NOT stop and wait)

After writing the plan, **immediately run `asc app-shots generate`** — do not print instructions and wait for the user to say "continue".

Resolve the Gemini API key (in order):
1. Check `$GEMINI_API_KEY` env var — if set, use it
2. The CLI will automatically fall back to `~/.asc/app-shots-config.json` (set via `asc app-shots config`)
3. If neither is set, ask the user once: "Please provide your Gemini API key (or save it with: `asc app-shots config --gemini-api-key KEY`)"

If the plan was written to `.asc/app-shots/app-shots-plan.json` (the default), run with **no arguments** — everything is discovered automatically:

```bash
asc app-shots generate
```

This reads `.asc/app-shots/app-shots-plan.json`, discovers `*.png/*.jpg` from `.asc/app-shots/`, and writes output to `.asc/app-shots/output/`.

Only pass explicit paths if files are in non-default locations:
```bash
asc app-shots generate \
  --plan path/to/plan.json \
  --output-dir path/to/output \
  path/to/screen1.png path/to/screen2.png
```

(Use `swift run asc` if `asc` is not installed globally, as detected in Step 1.)

After generation completes, show the paths of the generated PNG files.

---

## Gemini API key management

Users can save their key once so they never need to pass `--gemini-api-key` again:

```bash
asc app-shots config --gemini-api-key AIzaSy...    # save key
asc app-shots config                                # show current key (masked) + source
asc app-shots config --remove                       # delete saved key
```

Key is stored at `~/.asc/app-shots-config.json`. Resolution order in `generate`:
`--gemini-api-key` flag → `$GEMINI_API_KEY` env var → saved config file → error

---

## Example invocation

User: "Plan App Store screenshots for app 6736834466. Screenshots: screen1.png screen2.png"

Claude:
1. `which asc` → not found → uses `swift run asc`
2. `swift run asc app-infos list --app-id 6736834466` → appInfoId
3. `swift run asc app-info-localizations list ...` → appName, tagline
4. `swift run asc version-localizations list ...` → description
5. Summarizes description → appDescription
6. Checks `.asc/app-shots/` → finds screen1.png, screen2.png automatically
7. Reads them with vision → colors + per-screen configs
8. Writes `.asc/app-shots/app-shots-plan.json` with `appId` key
9. Checks `$GEMINI_API_KEY` → set → runs `asc app-shots generate` (no args needed)
10. Shows generated PNG paths in `.asc/app-shots/output/`
