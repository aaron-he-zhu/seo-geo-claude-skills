---
name: visibility
description: "Diagnose AI answer visibility, GEO citation readiness, entity clarity, and trust blockers. Not sure? Use /aaron:auto."
argument-hint: "<brand-page-or-content>"
parameters:
  - name: target
    type: string
    required: true
    description: "Page, brand, entity, query set, or GEO concern"
---

# Visibility Command

Diagnose AI answer visibility, GEO citation readiness, entity clarity, and trust blockers.

## Route

- geo-content-optimizer
- entity-optimizer
- content-quality-auditor
- domain-authority-auditor

## Rules

- Diagnose AI answer inclusion and citation readiness; do not claim observed citation proof.
- Require content-quality-auditor before publish-ready, cite-ready, or GEO Score readiness verdicts.
- Use entity-optimizer for canonical identity gaps and domain-authority-auditor for CITE/trust limits.
- Handoff observed measurement to `/aaron:watch --geo-drift`.

## Output

Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
