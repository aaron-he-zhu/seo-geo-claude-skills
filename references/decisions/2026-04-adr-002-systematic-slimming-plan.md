# ADR-002: Guardrailed Systematic Slimming Plan

- **Date**: 2026-04-24
- **Status**: Accepted
- **Target release**: v9.5.0+
- **Authors**: aaron-he-zhu + Codex + agent review panel

## Context

The repository is a content-based SEO/GEO skill operating system. `SKILL.md` files control discovery, activation, handoff, and runtime behavior; `references/` carry templates, rubrics, contracts, and examples; `commands/` expose slash workflows and maintenance gates; manifests, README files, `VERSIONS.md`, and `CITATION.cff` are release surfaces.

Prior slimming reviews found that markdown validity is not enough. Regressions included stale citation metadata, missing discovery aliases, under-specified robots/sitemap/HSTS/image/schema/report templates, conflicting score denominators, and missing release checks.

## Decision

Adopt guardrail-first slimming. No large slimming phase should run until machine-checkable regression guards and release gates exist.

Safe target: net reduction to about `18.5k-19.3k` tracked lines. Stretch near `18.0k` is acceptable only with clean agent review and regression checks after each phase. Targets below `18.0k` are not recommended unless the project accepts higher behavioral risk or moves to a generated/external packaging model.

## Protected Zones

| Protected area | Reason |
|----------------|--------|
| `references/core-eeat-benchmark.md` | CORE-EEAT scoring source |
| `references/cite-domain-rating.md` | CITE scoring source |
| `references/auditor-runbook.md` | Auditor execution source |
| Auditor inline runbook blocks | Required because links do not reliably load at activation |
| `references/skill-contract.md` | Handoff, status, promotion, protocol rules |
| `references/state-model.md` | Memory/wiki lifecycle and ownership |
| `hooks/hooks.json` | Runtime behavior |
| `memory-management/SKILL.md` | Sole writer, hooks delegation, HOT/WARM/COLD |
| `entity-optimizer/SKILL.md` | Canonical profile contract |
| High-value discovery aliases | Discovery recall is product behavior |

## Phase 0 Requirements

| Gate | Required assertion |
|------|--------------------|
| Canonical sections | `skill-contract.md`, `CONTRIBUTING.md`, `CLAUDE.md`, `AGENTS.md`, and validators agree |
| Auditor exception | Auditor skills with `runbook-sync` may use the documented ~750-line ceiling |
| Citation metadata | `CITATION.cff` version/date matches public release |
| Discovery aliases | robots.txt, sitemap, canonical, HSTS, schema.org, AI SEO, Semrush, Keyword Planner, Ubersuggest, Ahrefs alternative, memory/wiki triggers retained |
| Template regressions | robots/sitemap/HSTS/image/schema/report/KPI/disavow/linking/freshness fields retained |
| Runtime contracts | memory sole writer, entity profile, hooks, Stop guard, auditor archive contract retained |
| Release matrix | plugin, marketplace mirrors, Gemini/Qwen/CodeBuddy, CITATION, README badges, CLAUDE, VERSIONS agree |
| CI | Guardrails, all skill validators, status check, JSON parse, marketplace mirror, whitespace check run before publish |

## Implementation Status in v9.5.0

- Compact section contract is aligned across docs and `scripts/validate-skill.sh`.
- `validate-skill.sh` checks shared headings and auditor runbook hash drift.
- `validate-slimming-guardrails.sh` encodes historical regression checks, alias allowlist, release-surface checks, and protected runtime-contract checks.
- `.github/workflows/clawhub-publish.yml` runs guardrails before publishing.
- `commands/validate-library.md`, `CLAUDE.md`, README, localized README, manifests, `VERSIONS.md`, and `CITATION.cff` expose the release gate.

## Future Slimming Phases

| Phase | Pool | Treatment | Expected safe net |
|-------|------|-----------|-------------------|
| 1 | Reference packs | Classify protocol/benchmark/generation/rubric/template/example; compress only safe classes | 900-1,500 |
| 2 | Examples/report bodies | Keep one complete example where useful; convert repeats to calibration cards | 400-700 |
| 3 | Ordinary skill skeletons | Standardize non-auditor shells while preserving triggers, handoff, data sources, and reference links | 300-600 |
| 4 | Docs/commands | Compress repeated docs and command bodies without deleting command files | 200-500 |

## File Classes

| Class | Treatment |
|-------|-----------|
| Protocol / benchmark | Do not slim |
| Realtime technical matrix | Compact only after required fields and update cadence are locked |
| Generation contract | Preserve required-vs-optional fields, validation rules, policy violations, preflight checks |
| Rubric / threshold | Compact tables; retain thresholds, counterexamples, safety guards |
| Template pack | Replace long examples with placeholders and starter blocks |
| Worked examples | Keep one complete example or short calibration cards |

## Phase Ledger

Every phase must record starting tracked line count, ending tracked line count, gross deletion, review/fix/release overhead, net reduction, validation commands, and open risk. Use current `git ls-files | xargs wc -l`, not historical baselines.

## Rejected Options

- Compress protected protocol/benchmark sources as ordinary examples.
- Remove high-value discovery aliases.
- Treat release manifests and guardrails as documentation bloat.
- Force every command into the same shape when governance commands need extra logic.

## Reopen Conditions

Revisit this ADR if a future slimming phase creates a P1 regression, a marketplace changes packaging constraints, or the project deliberately chooses a generated/external reference model.
