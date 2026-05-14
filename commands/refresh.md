---
name: refresh
description: "Update stale, declining, outdated, or decayed content. Not sure? Use /aaron:auto."
argument-hint: "<url-or-content>"
parameters:
  - name: target
    type: string
    required: true
    description: "URL, content, or performance summary"
---

# Refresh Command

Update stale, declining, outdated, or decayed content.

## Route

- content-refresher
- on-page-seo-auditor
- content-quality-auditor

## Rules

- Diagnose freshness, decay, outdated facts, ranking loss, and quality risks.
- Return refresh plan, evidence gaps, update scope, quality gate status, and next monitoring step.

## Output

Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
