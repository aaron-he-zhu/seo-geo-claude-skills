---
name: audit
description: "Audit page SEO and CORE-EEAT publish readiness. Use for page quality, on-page SEO, claim risk, and publish blockers. Not sure? Use /aaron:auto."
argument-hint: "<url-or-content> [--full]"
parameters:
  - name: target
    type: string
    required: true
    description: "URL, pasted content, or page summary to audit"
  - name: full
    type: boolean
    required: false
    description: "Run full publish-readiness gate when evidence is available"
---

# Audit Command

Audit page SEO and CORE-EEAT publish readiness. Use for page quality, on-page SEO, claim risk, and publish blockers.

## Route

- on-page-seo-auditor
- content-quality-auditor

## Rules

- Check on-page SEO, metadata, headings, images, links, and CORE-EEAT risk.
- Return `ready`, `ready_with_concerns`, `blocked`, or `needs_input` with evidence and next fixes.
- Do not produce a publish-ready verdict without full veto-aware audit coverage.

## Output

Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
