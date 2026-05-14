---
name: publish
description: "Prepare a CMS-neutral publish package with quality gate, metadata, schema, media, and internal-link checks. Not sure? Use /aaron:auto."
argument-hint: "<draft-or-url> [--meta|--schema]"
parameters:
  - name: source
    type: string
    required: true
    description: "Draft, URL, series summary, or content reference"
  - name: mode
    type: string
    required: false
    description: "Optional meta-only or schema-only mode"
---

# Publish Command

Prepare a CMS-neutral publish package with quality gate, metadata, schema, media, and internal-link checks.

## Route

- content-quality-auditor
- meta-tags-optimizer
- schema-markup-generator
- internal-linking-optimizer

## Rules

- Prepare a publish package; do not publish directly by default.
- Allow `ready` only when full veto-aware audit coverage passes with SHIP, `cap_applied: false`, no BLOCKED status, no veto/blocker open loops, and no unresolved required evidence gaps.
- Every publish package must include `ready_verdict_allowed`, derived from those existing audit fields; do not expect the auditor to invent a separate boolean.
- `--meta` returns title/meta/Open Graph variants only. `--schema` returns JSON-LD only and must not invent unsupported rich-result facts.

## Output

Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
