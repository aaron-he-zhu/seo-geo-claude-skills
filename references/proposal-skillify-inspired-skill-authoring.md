---
name: proposal-skillify-inspired-skill-authoring
description: Historical archive of the skillify authoring proposal that shipped in v9.9.5.
type: reference
---

# Archive Note — Skillify-Inspired Skill Authoring

**Status**: archived historical proposal
**Original implementation**: v9.9.5
**Current command**: `/aaron:skillify`

This proposal introduced the repository-local skill authoring review workflow.
The durable outcome is now the read-only `/aaron:skillify` command plus routing
coverage in `references/skill-resolver.md`, command inventory checks in
`scripts/validate-slimming-guardrails.sh`, and simulated eval cases under
`evals/`.

## Current Source of Truth

- [commands/skillify.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/commands/skillify.md) — current read-only authoring review command
- [commands/evolve.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/commands/evolve.md) — controlled evolution from evidence
- [commands/guard.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/commands/guard.md) — eval, contract, release, and inventory validation
- [references/skill-resolver.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/skill-resolver.md) — current routing map

## Durable Decisions

- Skill authoring review stays **read-only** and proposal-only.
- New or heavily changed skills need routing, handoff, eval, command, release,
  and guardrail impact review before implementation.
- Cross-skill routing or protocol-adjacent changes require `/aaron:evolve`
  output and accepted decision evidence before landing.
- Command inventory changes must update docs, manifests, eval coverage, and
  guardrails in the same release.
