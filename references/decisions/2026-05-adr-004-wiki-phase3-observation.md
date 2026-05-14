# ADR-004: Ship Wiki Phase 2/3 + Observe Adoption (v9.9.9 → 3-Month Review)

- **Date**: 2026-05-06
- **Status**: Accepted
- **Ships at**: v9.9.9 (29 commits ahead of main, branch `claude/ecstatic-turing-6bd25c`)
- **Reviewer**: aaron-he-zhu + 7 multi-agent rounds (rev2 architect / rev3 upstream / rev4 architect / user-perspective / 6-agent team / 6-persona simulation / strategy review)

## Context

The wiki Phase 2/3 work shipped across v9.9.9 → v9.9.9 (5 patch releases over 4 days, 29 commits, 44 cumulative fixes). After 7 rounds of internal review and the 6-persona simulation, the data signaled diminishing returns:

- Round 1-3 (architecture): 2 RED + 8 YELLOW → 0 RED + 8 YELLOW → 3 RED + 8 YELLOW
- Round 4-5 (user-perspective): 5 RED + 10 YELLOW
- Round 6 (6-agent team): 5 RED + 16 YELLOW
- Round 7 (6-persona): **0 RED** + 6 YELLOW

The persona simulation also surfaced an adoption signal: **5 of 6 personas either skipped or worked around Phase 3** (Maya bypassed via manual `mv`; David skipped entirely due to caps; Lisa never discovered it; Marcus used with reservations; Priya used only for forensic verification; only Aaron the maintainer used the full feature).

Strategy reviewer (round 6) recommended: "Phase 3 should not have shipped — the entire C1-C5 hard-check apparatus exists to safely automate a `mv` operation users do themselves at ≤5 files/call. The asymmetry is staggering."

## Decision

**Ship v9.9.9 locally + observe production adoption for 3 months before deciding Phase 3's long-term fate.**

This is path A from the post-simulation analysis, chosen over:
- Path B (slim-now per Strategy reviewer): too premature without production data
- Path C (demote-but-keep): more conservative but introduces marketing/discoverability complexity

Rationale:
1. Internal simulation has hit diminishing returns (round 7 found 0 RED).
2. Strategy reviewer's pushback is plausible but **unfalsifiable from simulation alone** — only real users decide this.
3. The simulated 5/6 non-adoption could mean (a) over-engineered, (b) premature for day-1 users, (c) niche audience missing from personas, or (d) entire wiki abstraction over-built. Production data discriminates.
4. 44 fixes across 5 patches have made Phase 3 **safe + accessible** even if it turns out to be unnecessary. The cost of leaving it in is bounded; the cost of slimming prematurely is irreversibility for a real-but-niche audience.

## Observation Criteria (3-Month Review at 2026-08-06)

The decision to slim, retain, or expand Phase 3 depends on these signals:

### Strong signal — slim Phase 3 to "stable, no investment"
- Zero or near-zero `memory/wiki/.retire-day-log` activity across all installations
- No GitHub issues filed about Phase 3 retire/restore
- ClawHub install count includes <5% who run `/aaron:guard --wiki --retire-preview`
- Recovery script (`scripts/recover-retired-warm.sh`) never invoked in production
- Strategy reviewer's pushback validated by data

### Mixed signal — keep as-is, defer next decision
- Some retire activity but no recovery invocations
- 1-2 GitHub issues about Phase 3 (UX polish, not bugs)
- Niche power-user adoption (5-15% of installs)
- Phase 1+2 dominate; Phase 3 is the long tail

### Strong signal — expand Phase 3 (unlikely)
- ≥20% of installs trigger Phase 3
- Multiple feature requests for retire-flow extensions
- Production-level recovery invocations succeed without fixes
- Phase 3 surfaces as a discriminating factor in plugin-comparison reviews

### Failure signal — emergency slim or rollback
- Any reported data loss (recovery failures in real use)
- Any reported security incident (path injection / symlink pivot in the wild)
- Compliance complaint involving GDPR purge gaps

## Telemetry Approach

The plugin is content-only (no `.py`, no embedded analytics). Observation comes from:

1. **`memory/wiki/log.md` audit trail** (already mandated by wiki-runbook §3.1, v9.9.9+) — users who care about local audit can grep their own data; reproducibility patterns can be aggregated voluntarily.
2. **GitHub Issues + Discussions** — qualitative signal from real users.
3. **ClawHub install + skill-invocation counts** — if ClawHub exposes per-skill telemetry, surface Phase 3 invocation rate.
4. **Maintainer-led check at 2026-08-06**: announce a brief survey (3 questions, optional) in Discord/Slack/wherever the user community gathers:
   - "Have you used `/aaron:guard --wiki --retire-preview`?"
   - "Did you compile a wiki page in the last 30 days?"
   - "Did you ever run `/aaron:remember recover wiki`?"

No automated collection. No personal data. The signal is coarse but honest.

## Sunken Costs Acknowledgment

29 commits, 5 patch releases, 7 review rounds, 44 fixes.

This is non-trivial investment. The ADR formally acknowledges:
- Strategy reviewer's pushback was valid input that we **did not act on** in v10.1.x.
- v9.9.9 is the production-ready version, not a step toward v10.2.0+.
- If 2026-08-06 review confirms slim is needed, the acknowledged cost is the proposal doc (1268 lines), the runbook §7 retirement workflow (~200 lines), the validator script + symlink-pivot fixture (~250 lines), and 11 of the 31 eval cases.
- The Phase 1+2 work (auto-refresh + compile + reconciliation + audit log) carries forward unchanged regardless of the Phase 3 decision.

## What Ships at v9.9.9

- 8 commits of v9.9.9 wiki Phase 2/3 ship
- 5 commits of v9.9.9 user-perspective security/UX patch
- 2 commits of v9.9.9 restore + --show-deferred
- 6 commits of v9.9.9 6-agent-team review fixes
- 5 commits of v9.9.9 6-persona simulation fixes
- 1 commit (this ADR)
- v9.9.9 git tag at the post-ADR HEAD

CI workflows have `AARON_COMMAND_LINE_BUDGET_WAIVER=1` and `fetch-depth: 2`. Validators GREEN. 31 memory-management eval cases + 53 Product API scenarios.

## Cross-references

- [proposal-wiki-phase-2-3-completion.md](../proposal-wiki-phase-2-3-completion.md) — canonical implementation spec
- [wiki-runbook.md](../../cross-cutting/memory-management/references/wiki-runbook.md) — execution detail
- [command-line-budget-waiver.md](command-line-budget-waiver.md) — WLB-2026-05-001, expires 2026-08-04 (one day before this ADR's review date)
- [VERSIONS.md](../../VERSIONS.md) — full changelog v9.9.9 → v9.9.9

## Reversal Conditions

This ADR's decision (ship + observe) is reversed if:
- Pre-2026-08-06 emergency: any in-the-wild security incident or data loss → immediate slim/rollback per "Failure signal" above
- 2026-08-06 review: data falls in "Strong signal — slim" range → execute slim per Strategy reviewer's plan (proposal 1268 → 150, drop waiver, mark Phase 3 stable, refocus on external onramp)
- Otherwise: ADR remains accepted, decision reviewed at v10.2.0 cycle.

## History

- **2026-05-06**: ADR accepted. v9.9.9 tag created at branch HEAD. Push to remote and external announcement deferred to maintainer's discretion.
