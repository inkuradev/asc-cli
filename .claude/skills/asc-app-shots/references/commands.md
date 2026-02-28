# asc Commands for Screenshot Planning and Translation

## List apps (get App ID)

```bash
asc apps list [--pretty]
# Returns: id, name, bundleId
```

## Get version ID

```bash
asc versions list --app-id <APP_ID> [--pretty]
# Returns: id, versionString, platform, state
# Filter for prepareForSubmission or readyForSale state
```

## Get app info localizations (name, subtitle)

```bash
# Step 1: Get the app info ID
asc app-infos list --app-id <APP_ID>
# Returns: id, appId

# Step 2: Get localizations for that app info
asc app-info-localizations list --app-info-id <APP_INFO_ID> [--locale en-US]
# Returns: id, locale, name, subtitle, privacyPolicyUrl
```

## Get version localizations (description, keywords)

```bash
asc version-localizations list --version-id <VERSION_ID> [--pretty]
# Returns: id, locale, description, keywords, marketingUrl, supportUrl, versionId
# Note: fields are flat — no .attributes wrapper
```

## Filter by locale with jq

```bash
# Get name for en-US locale
asc app-info-localizations list --app-info-id "$APP_INFO_ID" \
  | jq -r '.data[] | select(.locale == "en-US") | .name'

# Get description for en-US locale
asc version-localizations list --version-id "$VERSION_ID" \
  | jq -r '.data[] | select(.locale == "en-US") | .description'
```

## Full metadata fetch script

```bash
APP_ID="6736834466"
VERSION_ID="abc123def"
LOCALE="en-US"

# App info
APP_INFO_ID=$(asc app-infos list --app-id "$APP_ID" | jq -r '.data[0].id')
APP_NAME=$(asc app-info-localizations list --app-info-id "$APP_INFO_ID" \
  | jq -r --arg locale "$LOCALE" '.data[] | select(.locale == $locale) | .name')
SUBTITLE=$(asc app-info-localizations list --app-info-id "$APP_INFO_ID" \
  | jq -r --arg locale "$LOCALE" '.data[] | select(.locale == $locale) | .subtitle // ""')

# Version localization
VERSION_DATA=$(asc version-localizations list --version-id "$VERSION_ID")
DESCRIPTION=$(echo "$VERSION_DATA" | jq -r --arg locale "$LOCALE" '.data[] | select(.locale == $locale) | .description // ""')
KEYWORDS=$(echo "$VERSION_DATA" | jq -r --arg locale "$LOCALE" '.data[] | select(.locale == $locale) | .keywords // ""')

echo "App: $APP_NAME ($APP_ID)"
echo "Subtitle: $SUBTITLE"
echo "Description: $DESCRIPTION"
echo "Keywords: $KEYWORDS"
```

## Generate screenshots (English)

```bash
# Zero-argument happy path — outputs at 1320×2868 (iPhone 6.9" required) by default
asc app-shots generate

# Different App Store sizes
asc app-shots generate --output-width 1290 --output-height 2796  # iPhone 6.7" required
asc app-shots generate --output-width 1242 --output-height 2688  # iPhone 6.5"
asc app-shots generate --output-width 2048 --output-height 2732  # iPad 13"

# Explicit paths + size
asc app-shots generate \
  --plan .asc/app-shots/app-shots-plan.json \
  --output-dir .asc/app-shots/output \
  --output-width 1320 --output-height 2868 \
  screen1.png screen2.png

# With explicit API key
asc app-shots generate --gemini-api-key AIzaSy...
```

**Output size note:** Gemini returns images at ~704×1520. The CLI automatically upscales to `--output-width` × `--output-height` using CoreGraphics with `.high` interpolation before saving.

## Translate screenshots to other locales

```bash
# Translate to Chinese and Japanese — reads screen-*.png from output dir automatically
asc app-shots translate --to zh --to ja

# Translate with explicit paths
asc app-shots translate \
  --plan .asc/app-shots/app-shots-plan.json \
  --source-dir .asc/app-shots/output \
  --output-dir .asc/app-shots/output \
  --to zh --to ja --to ko

# Single locale
asc app-shots translate --to fr

# Output goes to:
# .asc/app-shots/output/zh/screen-0.png
# .asc/app-shots/output/ja/screen-0.png
```

**Flags:**
| Flag | Default | Description |
|------|---------|-------------|
| `--plan` | `.asc/app-shots/app-shots-plan.json` | Source ScreenPlan JSON |
| `--from` | `en` | Source locale label (informational) |
| `--to` | *(required, repeatable)* | Target locale(s) |
| `--source-dir` | `.asc/app-shots/output` | Dir with existing `screen-*.png` files |
| `--output-dir` | `.asc/app-shots/output` | Base output dir; locale subdirs created automatically |
| `--output-width` | `1320` | Output PNG width in pixels |
| `--output-height` | `2868` | Output PNG height in pixels |
| `--gemini-api-key` | — | API key (flag → env var → config file) |
| `--model` | `gemini-3.1-flash-image-preview` | Gemini model |

## Config (save Gemini API key once)

```bash
asc app-shots config --gemini-api-key AIzaSy...   # save key
asc app-shots config                               # show current key + source
asc app-shots config --remove                      # delete saved key
```