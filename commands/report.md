---
name: report
description: "Generate SEO/GEO reports for a domain, campaign, project, or period. Not sure? Use /aaron:auto."
argument-hint: "<domain-or-campaign> [--period <range>]"
parameters:
  - name: scope
    type: string
    required: true
    description: "Domain, campaign, project, or report scope"
  - name: period
    type: string
    required: false
    description: "Reporting period"
---

# Report Command

Generate SEO/GEO reports for a domain, campaign, project, or period.

## Route

- performance-reporter
- rank-tracker
- alert-manager
- geo-content-optimizer

## Rules

- Require exactly one scope before reporting: domain, campaign, project, or period.
- Report traffic, rankings, AI citations/readiness, authority, technical health, content progress, and open loops.
- Keep source/date freshness visible and separate observed data from estimates.

## Output

Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
