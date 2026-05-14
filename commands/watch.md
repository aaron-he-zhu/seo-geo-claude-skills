---
name: watch
description: "Monitor rankings, alerts, AI citation checks, and GEO drift feedback loops. Not sure? Use /aaron:auto."
argument-hint: "<domain-or-records> [--alert|--geo-drift]"
parameters:
  - name: target
    type: string
    required: true
    description: "Domain, keyword set, alert need, or GEO feedback records"
  - name: mode
    type: string
    required: false
    description: "alert, rank, or geo-drift"
---

# Watch Command

Monitor rankings, alerts, AI citation checks, and GEO drift feedback loops.

## Route

- rank-tracker
- alert-manager
- geo-content-optimizer
- memory-management

## Rules

- For GEO drift, load due memory/geo-feedback records, preserve T+14/T+45/T+90 measurement windows, compare observed citation behavior to predicted GEO Score, and update next_measurement_date only when user permits memory writes.
- Only generate evolution signals when the derived cohort gate passes: `cohort_sample_size >= 10`, `cohort_mae > 15`, and `evidence_mode` is not `no_tool_estimate`.
- Separate ranking/alert monitoring from GEO feedback-loop monitoring.

## Output

Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
