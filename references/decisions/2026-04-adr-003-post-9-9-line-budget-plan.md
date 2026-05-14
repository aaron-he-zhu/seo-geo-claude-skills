# ADR-003: Post-9.9 Line Budget Plan

- **Date**: 2026-04-27
- **Status**: Proposed
- **Target release**: v9.9.x
- **Baseline**: 20,438 counted lines after the 9.9.0 controlled evolution upgrade
- **Target**: below 20,000 counted lines, with a working target of 19,850 lines

## Context

The 9.9.0 upgrade added controlled evolution docs, eval cases, PR-grade mock events, failure probes, and parser-grade guardrails. The result is safer, but it pushed the repository above the 20,000-line operating budget.

This plan narrows ADR-002 to the immediate post-9.9 task: recover at least 589 lines of margin without weakening discovery, auditor standards, release gates, or controlled evolution safety.

## Decision

Use a documentation-compression pass, not a guardrail or benchmark reduction.

Do not slim:

- `scripts/validate-slimming-guardrails.sh`
- `scripts/validate-skill.sh`
- `references/core-eeat-benchmark.md`
- `references/cite-domain-rating.md`
- `references/auditor-runbook.md`
- auditor-class `SKILL.md` runbook-sync blocks
- `references/skill-contract.md`
- `references/state-model.md`
- command files required for the 16-command inventory

## Reduction Budget

| Area | Current lines | Treatment | Target savings |
|------|---------------|-----------|----------------|
| `references/evolution-optimization-plan.md` | 244 | Convert long rationale into outcome, scope, and open-loop checklist | 120-150 |
| `references/evolution-protocol.md` | 407 | Keep schema, rules, commands, risk gates; remove repeated explanatory sections | 100-140 |
| `memory/evolution/2026-04.md` | 195 | Keep one compact simulated event plus dry-run summary; move repeated cases to eval IDs | 60-80 |
| `references/evolution-pr-grade-mock.md` | 160 | Keep one accepted, one rejected, one superseded fixture with minimal prose | 35-50 |
| `evals/*/cases.md` | 339 | Compact YAML wording, not case count; retain all 16 cases | 80-110 |
| `references/evolution-evidence-review.md` and failure probes | 129 | Remove repeated Hermes explanation; keep acceptance boundaries and probe catalog | 30-50 |

Expected net reduction: 425-580 lines before validation overhead. If final count remains above 20,000, compress non-protocol examples in ordinary skill reference packs before touching evolution guardrails.

## Execution Order

1. Compress `evolution-optimization-plan.md` first because it is the least runtime-critical.
2. Compress `evolution-pr-grade-mock.md` and `memory/evolution/2026-04.md` while keeping parser-grade fixtures valid.
3. Compact eval case prose but keep all 16 case IDs and expected behavior/failure mode fields.
4. Compress `evolution-protocol.md` last, only after guardrails still pass against the existing fixtures.
5. Recount lines and stop once the repository is below 19,850.

## Required Validation

Run all of these after each batch:

```bash
bash -n scripts/validate-slimming-guardrails.sh
git diff --check
bash scripts/validate-slimming-guardrails.sh
bash scripts/validate-skill.sh --status
bash scripts/validate-skill.sh cross-cutting/content-quality-auditor
bash scripts/validate-skill.sh cross-cutting/domain-authority-auditor
node .github/scripts/sync-skills.js --check
```

Also rerun negative probes for:

- malformed indented EvolutionEvent YAML
- missing `source_signal.kind`
- missing `source_signal.evidence`
- missing `validation_results.evidence`
- falsey optional schema values
- split `memory/` + `evolution/` write path
- `/aaron:guard --evals` `passed` plus non-eligible or non-validating output

## Acceptance Criteria

- Counted lines are below 20,000; preferred final count is 19,850 or lower.
- `validate-slimming-guardrails.sh` remains green.
- All 16 eval cases remain present.
- Accepted, rejected, and superseded PR-grade sample events remain parser-valid.
- `v9.5.0` remains a historical 15-command record; 9.9.x remains the current 16-command surface.
- No CORE-EEAT, CITE, auditor, memory ownership, hook, command inventory, or controlled evolution acceptance rule is weakened.

## Rejected Options

- Deleting eval cases to save lines.
- Removing failure probes after they caught real parser gaps.
- Compressing auditor runbook-sync blocks.
- Reducing the guardrail script before controlled evolution stabilizes.
- Moving safety rules into prose that is not machine-checked.
