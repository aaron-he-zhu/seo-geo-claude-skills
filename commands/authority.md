---
name: authority
description: "Assess domain trust, CITE authority, backlinks, entity credibility, and source authority. Not sure? Use /aaron:auto."
argument-hint: "<domain-or-brand> [--competitors <domains>]"
parameters:
  - name: target
    type: string
    required: true
    description: "Domain, brand, entity, or source set"
  - name: competitors
    type: string
    required: false
    description: "Competitor domains for comparison"
---

# Authority Command

Assess domain trust, CITE authority, backlinks, entity credibility, and source authority.

## Route

- domain-authority-auditor
- backlink-analyzer
- entity-optimizer

## Rules

- Run CITE/domain trust analysis, backlink quality review, and entity credibility checks.
- Flag trust blockers, toxic-link risks, missing entity proof, and authority-building opportunities.

## Output

Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
