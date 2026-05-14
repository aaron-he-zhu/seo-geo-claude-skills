---
name: series
description: "Plan, write, continue, or prepare publish handoff for a content series. Not sure? Use /aaron:auto."
argument-hint: "<topic-or-series-plan> [--plan|--write|--continue|--publish-handoff]"
parameters:
  - name: input
    type: string
    required: true
    description: "Topic, series_plan, prior batch summary, or series reference"
  - name: mode
    type: string
    required: false
    description: "plan, write, continue, or publish-handoff"
---

# Series Command

Plan, write, continue, or prepare publish handoff for a content series.

## Route

- keyword-research
- content-gap-analysis
- seo-content-writer
- geo-content-optimizer
- internal-linking-optimizer
- content-quality-auditor

## Rules

- Default topic input to `--plan`; valid series_plan input to `--write`.
- Default write limit is 3 articles per run; recommend at most 6 unless the user accepts chunking.
- Batch rollups cannot produce `ready` unless every article has full veto-aware audit coverage.
- Return stable `series_plan` or `batch_summary` artifacts with continuation state.

## Output

Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
