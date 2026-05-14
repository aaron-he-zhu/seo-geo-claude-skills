---
waiver_id: WLB-2026-05-002
owner: aaron-he-zhu
expiry: 2026-08-12
counted_line_baseline: 24000
---

# Repository Line Budget Waiver — v9.9.9 Consolidated 9.x Final

- **Date**: 2026-05-14
- **Status**: Active
- **Expiry**: 2026-08-12 (90 days from issue)
- **Owner**: aaron-he-zhu
- **Baseline**: 24000 counted lines (current ~23555)
- **Ships in**: v9.9.9 (consolidates the entire v10.x development line back into the 9.x stream as the final 9.x release)

## Context

The 20000-line repository budget enforced by `scripts/validate-slimming-guardrails.sh` was set at the v9.5.0 architecture migration. At that time the repo measured ~19500 counted lines.

The v9.9.9 consolidation absorbs the following content streams into a single squashed release:

- Anchor-pack repositioning: `evals/product-api-scenarios.md`, 3 `.docs/` proposals (excluded from count), `references/aaron-product-api-contract.md`, `references/contract-fail-caps.md`, `distribution/platforms.json` (pre-consolidation baseline: ~21833 counted lines)
- Wiki Phase 2/3 implementation:
  - `references/proposal-wiki-phase-2-3-completion.md` (~1268 lines) — design spec required for future maintenance per ADR pattern
  - `cross-cutting/memory-management/references/wiki-runbook.md` (~332 lines after §5 hardening) — execution runbook for memory-management; cannot be inlined into SKILL.md without breaking the 350-line SKILL cap
  - 13 new eval cases in `evals/memory-management/cases.md` (~60 lines)
  - 2 new Product API scenarios in `evals/product-api-scenarios.md` (~10 lines)
- Series command workflow recovery: `references/proposal-series-command-workflow.md` (~637 lines, recovered from a detached worktree, now marked superseded — see header note)
- Severity-tier routing for auditor outputs (B3) + Star History + multiple security/UX fixes

Current count: ~23555 counted lines (post-consolidation, 2026-05-14).

The previous waiver (WLB-2026-05-001, baseline 22500) was insufficient because the actual measurement after recovery merges drifted to ~23555. This waiver replaces it with a 24000 baseline to provide ~445 lines of headroom before the next renewal.

## Decision

Grant a 90-day waiver allowing the repository to operate at up to 24000 counted lines while the v9.9.9 release establishes itself as the long-term 9.x line. During the waiver period:

1. **No new spec docs** in `references/` without explicit approval (proposals can land in `.docs/` which is excluded from the count).
2. **No new SKILL.md content** beyond what existing skills already document (existing 350-line cap continues to apply per skill).
3. **Slim opportunities** to evaluate before waiver expiry:
   - `references/proposal-wiki-phase-2-3-completion.md`: candidate for compression to archive-style summary. Estimated savings: ~1000 lines.
   - `references/proposal-series-command-workflow.md`: now superseded — candidate for compression once the landed `/aaron:series` contract is fully stable. Estimated savings: ~500 lines.
   - `cross-cutting/memory-management/references/wiki-runbook.md` §5: candidate for splitting into runbook + UX-template files. Estimated savings: ~50 lines.
4. **Re-evaluate at expiry** (2026-08-12): either (a) renew waiver if v9.9.10/v9.10.0 is in flight, (b) execute slimming pass, or (c) bump base budget to 24000 in `validate-slimming-guardrails.sh` with a new ADR justifying the change.

## Activation

To activate the waiver, set the env var:
```bash
export AARON_COMMAND_LINE_BUDGET_WAIVER=1
bash scripts/validate-slimming-guardrails.sh   # passes "repository line budget waiver active (WLB-2026-05-002, ...)"
```

Without the env var, the validator FAILS the budget check — preserving the slimming pressure for routine PRs that don't legitimately need more lines. CI for the v9.9.x release pipeline must export this variable until expiry.

## Consequences

- Pro: ships v9.9.9 as a single coherent 9.x final release without forcing a same-cycle slim.
- Pro: 90-day clock forces a real slimming decision before the waiver becomes a permanent overshoot.
- Pro: existing slimming guardrail still fires for routine PRs (no waiver env var = budget enforced).
- Con: opens a 90-day window where contributors might push more content into `references/` without resistance.
- Con: requires CI configuration update to export `AARON_COMMAND_LINE_BUDGET_WAIVER=1` until expiry.

## Cross-references

- [scripts/validate-slimming-guardrails.sh](../../scripts/validate-slimming-guardrails.sh) (waiver validation logic)
- [references/proposal-wiki-phase-2-3-completion.md](../proposal-wiki-phase-2-3-completion.md) (largest contributor)
- [references/proposal-series-command-workflow.md](../proposal-series-command-workflow.md) (second-largest — superseded by commands/series.md)
- [cross-cutting/memory-management/references/wiki-runbook.md](../../cross-cutting/memory-management/references/wiki-runbook.md) (third-largest)
- ADR-002 [systematic-slimming-plan.md](2026-04-adr-002-systematic-slimming-plan.md) (prior slimming context)
- ADR-003 [post-9-9-line-budget-plan.md](2026-04-adr-003-post-9-9-line-budget-plan.md) (prior budget context)
- Superseded waiver: WLB-2026-05-001 (baseline 22500, replaced 2026-05-14 by this waiver)
