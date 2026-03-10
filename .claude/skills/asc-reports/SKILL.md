---
name: asc-reports
description: |
  Download sales, trends, and financial reports from App Store Connect using the `asc` CLI tool.
  Use this skill when:
  (1) Downloading sales reports: "asc sales-reports download --vendor-number ... --report-type SALES ..."
  (2) Downloading finance reports: "asc finance-reports download --vendor-number ... --report-type FINANCIAL ..."
  (3) Checking app sales, revenue, downloads, subscriptions, or proceeds
  (4) User says "download my sales report", "show sales data", "get financial report", "check my app revenue", "how many downloads", "subscription metrics"
---

# asc Sales & Finance Reports

Download sales and trends data and financial reports from App Store Connect. See [commands.md](references/commands.md) for detailed flag reference and valid enum values.

## Commands

### Download a sales report

```bash
asc sales-reports download \
  --vendor-number <VENDOR_NUMBER> \
  --report-type SALES \
  --sub-type SUMMARY \
  --frequency DAILY \
  [--report-date 2024-01-15] \
  [--output json|table] \
  [--pretty]
```

All four required flags (`--vendor-number`, `--report-type`, `--sub-type`, `--frequency`) must be provided. `--report-date` is optional — omit to get the latest available report.

### Download a finance report

```bash
asc finance-reports download \
  --vendor-number <VENDOR_NUMBER> \
  --report-type FINANCIAL \
  --region-code US \
  --report-date 2024-01 \
  [--output json|table] \
  [--pretty]
```

All four flags are required for finance reports (including `--report-date`).

## Report Types Quick Reference

| Sales Report Type | Description |
|-------------------|-------------|
| `SALES` | App and in-app purchase sales |
| `PRE_ORDER` | Pre-order data |
| `SUBSCRIPTION` | Auto-renewable subscription activity |
| `SUBSCRIPTION_EVENT` | Subscription lifecycle events |
| `SUBSCRIBER` | Active subscriber counts |
| `INSTALLS` | First-time downloads |
| `FIRST_ANNUAL` | First annual subscription renewals |
| `WIN_BACK_ELIGIBILITY` | Win-back offer eligible users |

| Finance Report Type | Description |
|---------------------|-------------|
| `FINANCIAL` | Financial summary with proceeds |
| `FINANCE_DETAIL` | Detailed financial breakdown |

## Output Format

Reports return dynamic TSV data from Apple, parsed into JSON arrays. Column names vary by report type.

```json
{
  "data" : [
    {
      "Provider" : "APPLE",
      "SKU" : "com.example.app",
      "Title" : "My App",
      "Units" : "10",
      "Developer Proceeds" : "6.99",
      "Currency of Proceeds" : "USD"
    }
  ]
}
```

Use `--output table` for a tabular view of the same data.

## Typical Workflow

```bash
# 1. Get daily sales summary
asc sales-reports download \
  --vendor-number 123456 \
  --report-type SALES \
  --sub-type SUMMARY \
  --frequency DAILY \
  --report-date 2024-01-15 \
  --pretty

# 2. Check monthly subscription metrics
asc sales-reports download \
  --vendor-number 123456 \
  --report-type SUBSCRIPTION \
  --sub-type SUMMARY \
  --frequency MONTHLY \
  --report-date 2024-01 \
  --pretty

# 3. Download financial report for US proceeds
asc finance-reports download \
  --vendor-number 123456 \
  --report-type FINANCIAL \
  --region-code US \
  --report-date 2024-01 \
  --pretty
```

## Important Notes

- The vendor number can be found in App Store Connect under "Sales and Trends" → "Payments and Financial Reports"
- Reports are gzip-compressed TSV from Apple's API — the CLI handles decompression and parsing automatically
- Not all report type + sub-type + frequency combinations are valid; Apple returns an error for unsupported combinations
- Finance reports require `--region-code` (e.g. `US`, `EU`, `JP`, `AU`) and `--report-date`
- Daily reports are typically available after a 1-day delay; monthly reports after the month ends

## Reference

See [commands.md](references/commands.md) for the full list of valid enum values for each flag.