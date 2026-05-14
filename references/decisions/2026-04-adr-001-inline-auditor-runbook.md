# ADR-001: Inline Auditor Runbook instead of Contract Inheritance

- **Date**: 2026-04-11
- **Status**: Accepted
- **Ships in**: v7.1.0
- **Authors**: aaron-he-zhu + 10-reviewer agent panel (Rounds 1 and 2)

## Context

v1 of the plan proposed adding approximately 150 lines to `references/skill-contract.md` covering 7 new mechanisms borrowed from JeffLi1993/seo-audit-skill and xue160709/Skill-Distiller:

- Evidence Layering (Mechanical vs Semantic split)
- Guardrail Negatives
- Gap Typology (missing/misunderstanding/shallow)
- Artifact Gate
- Critical Fail Cap
- Blind Pass / Coverage Gap
- Failure Modes Catalog

The assumption was that updating the contract would propagate behavior to all 20 skills via the existing markdown links in each SKILL.md.

### Round 1 review (5 agents: Skeptic / UX Advocate / Impl Verifier / Prompt Engineer / Sustainability)

The panel rejected several v1 assumptions:

1. **Contract inheritance is a polite fiction.** Markdown links from SKILL.md to `references/skill-contract.md` are inert text at skill activation. Claude Code's skill loader reads the SKILL.md body into context but does not auto-fetch linked reference files. Effective compliance for linked rules: ~25%. For inlined rules: ~95%.
2. **Blind Pass is theater.** Claude cannot truly "ignore" a framework that is already in its context window. A second scoring pass costs 2x tokens for weakly decorrelated output.
3. **Gap Typology has no consumer.** Categories collapse to "missing" ~85% of the time. Boundaries are fuzzy enough for ~40% miscategorization rate.
4. **60/40 cap numbers are eyeballed.** The plan offered 70/50 and 65/45 as alternatives, revealing no principled basis.
5. **Failure Modes Catalog is likely to become a tombstone.** Manual curation with no named owner, no cadence, predictable drift by month 3.

Round 1 produced v2. v2 kept Critical Fail Cap, Guardrail Negatives, and the inline strategy; deferred Gap Typology and Failure Modes to observation; killed Blind Pass and Evidence Layering entirely.

### Round 2 review (5 agents: Continuity / Red Team / DevEx / Migration / Doc Quality)

The second panel found 14 additional issues in v2, including:

- **Cap arithmetic under-specified.** v2's single worked example covered only one of several real scenarios. Sub-cap dimensions, 2+ veto fails, and veto + non-veto combinations were ambiguous.
- **350-line rule violation.** Inlining ~260 lines into ~400-line auditor skills violated an existing CLAUDE.md rule. Without a formal amendment, a future contributor would revert the inlining as "bloat."
- **`memory/hot-cache.md` overwrite hazard.** v2's "create file" step could silently destroy existing user campaign state.
- **Guardrail year rule created a false negative.** Unconditional "year = freshness positive" would suppress legitimate R10 veto fires on pages like "SEO Checklist for 2020."
- **Handoff backward compatibility was undefined.** Pre-upgrade audits consumed by post-upgrade skills would break.
- **Source-of-truth drift risk.** Cap numbers defined in 5 places would predictably disagree in 3-6 months.
- **Decision provenance would be lost.** All v1 → v2 → v3 reasoning lived in an ephemeral `/tmp/` plan file.

v3 addresses all 14 findings. This ADR is one of the permanent assets created by v3.

## Decision

Ship v7.1.0 as the auditor-runbook inline strategy with the following elements:

1. **Amend `CLAUDE.md:63`** to formally exempt protocol-layer auditors from the 350-line rule, with a ceiling of approximately 670 lines for affected skills.
2. **Create `references/auditor-runbook.md`** as the single source of truth for auditor handoff schema, cap arithmetic (decision table + 3 worked examples), guardrail rules, Artifact Gate checklist, User-Facing Translation layer, and Lint Coverage Manifest.
3. **Inline §1-5 of the Runbook** (the execution-critical sections) into both `content-quality-auditor/SKILL.md` and `domain-authority-auditor/SKILL.md`, between `<!-- runbook-sync start: sha256=... -->` markers. The sha256 enables machine-verifiable drift detection via `/aaron:guard --contracts`. §6 Lint Coverage Manifest stays only in the source file because it is consumed by the lint tool, not by the auditor at execution time.
4. **Ship only the 60-point cap.** The 2+ veto case returns `status: BLOCKED` rather than applying an unvalidated 40-point cap. Numeric calibration deferred to v7.3, gated on 30+ real multi-veto audits.
5. **Declare handoff extension fields optional during a v7.1.0 → v7.2.0 deprecation window** to prevent breakage when pre-upgrade audits are consumed by post-upgrade skills.
6. **Ship v7.1.0 as a single PR with two sequential commits**: infrastructure first (reference files, ADR, AUDITOR-AUTHORS, CLAUDE.md amendment) then behavior (both auditor SKILL.md inlines as an atomic pair, plus tracking files). Enables clean partial rollback and a reviewable diff.
7. **Commit P0 and P1-1 (`/aaron:guard --contracts`) in the same sprint.** The biggest rot risk in the P0-to-P1 gap is inline copy drift, and contract checks are the only detection mechanism.

## Consequences

### Positive

- Rules execute at approximately 95% compliance instead of approximately 25%.
- Single source of truth per concern (item definitions, cap numbers, arithmetic, general handoff format).
- Drift detectable via sha256 and `/aaron:guard --contracts`.
- User trust preserved by the Translation Layer (plain language instead of raw T04 failures).
- Decision provenance captured in this ADR and survives in git history.
- Backward compatibility defined explicitly with a dated sunset.

### Negative

- Two auditor SKILL.md files grow from ~400 lines to ~670 lines. Required a formal CLAUDE.md amendment.
- Runbook edits require propagation to both inlined copies. Drift detection ships in v7.2.0, not v7.1.0; there is a rot window between P0 and P1-1 ship, mitigated by committing them in the same sprint.
- New contributors face more files to learn than v1 would have had. Mitigated by the `references/AUDITOR-AUTHORS.md` onboarding document that ships alongside this ADR.
- 18 non-auditor skills continue using the existing contract format; cap-extension fields apply only to auditors. Explicitly scoped in `skill-contract.md §Auditor-class Extension`.

## Rejected alternatives

- **Contract-only update (v1).** Rejected because compliance rate was approximately 25% via markdown links. Internal rules that must execute cannot live in a linked file.
- **Python-based deterministic layer (from JeffLi inspiration).** Rejected because it violates Tier 1 zero-dependency and ClawHub per-skill distribution assumptions.
- **Blind Pass / Coverage Gap (from Skill-Distiller inspiration).** Rejected because Claude cannot genuinely ignore in-context frameworks; produces weakly decorrelated output at 2x token cost.
- **Gap Typology as required handoff field.** Rejected for v7.1.0 because no consumer skill currently routes on type. Deferred to P2 with trigger condition (3+ real handoffs where writer produced a suboptimal fix due to missing type).
- **Failure Modes Catalog at launch.** Rejected for v7.1.0 because of fan-fiction risk (writing failure modes for bugs not yet observed). Deferred to P2 with trigger condition (5+ real false positives manually labeled).
- **2+ veto cap at 40.** Rejected for v7.1.0 because the number was eyeballed. BLOCKED path used instead. Calibration deferred to v7.3.
- **Inlining all 6 Runbook sections.** Rejected because §6 Lint Coverage Manifest is consumed by the lint tool, not by the auditor at execution time. Including it would inflate SKILL.md files by another ~30 lines without execution benefit.

## Review triggers

- **Auditor calibration trigger**: `/aaron:guard --evals` plus maintainer review evaluates deferred observation items when real audit evidence exists. Items with unmet triggers stay closed; items with met triggers are proposed for a future release.
- **First `/aaron:guard --contracts` drift report**: audit the inlined copies, update the sync procedure if drift was preventable.
- **Any edit to `references/auditor-runbook.md`**: re-run the sync procedure, recompute sha256 in both inlined copies, and verify `commands/guard.md` still matches §6 Lint Coverage Manifest.
- **If the 350-line exception proves abusive**: revisit the inlining strategy and consider whether an alternative (e.g., a build-time preprocessor that assembles SKILL.md at publish time) would preserve execution fidelity without the bloat. As of v7.1.0, no preprocessor infrastructure exists in ClawHub or Claude Code.

## Related

- [references/auditor-runbook.md](../auditor-runbook.md) — the authoritative source created by this decision
- [references/AUDITOR-AUTHORS.md](../AUDITOR-AUTHORS.md) — onboarding doc for new auditor-class skill authors
- [references/skill-contract.md](../skill-contract.md) — the general contract (modified with an Auditor-class Extension clause)
- [CLAUDE.md](../../CLAUDE.md) — 350-line rule amended in this release

## Status Update — 2026-05

Status review at v10.0.x. Decisions 1, 2, 3, 5, 6, 7 shipped as planned. Decision 4 partial: 60-point cap and BLOCKED path ship; numeric calibration for the 2+ veto case remains deferred — the 30+ multi-veto evidence trigger has not fired (single-user corpus has not reached threshold; no audit-archival mechanism is built into the repo).

The three deferred items (cap calibration, Failure Modes Catalog, Gap Typology as a required auditor handoff field) all gate on the same evidence trigger and remain pending. Re-evaluate when 30+ multi-veto auditor outputs have been observed in practice.

Note on `gap_type`: appears in [entity-geo-handoff-schema.md](../entity-geo-handoff-schema.md) as a structured handoff field for the entity-geo subdomain — unrelated to the original ADR-001 deferral, which scoped Gap Typology as a generalized auditor-handoff field.

The 350-line exception is sourced only by the two existing auditors; both still under the ~750 ceiling (716 / 707 lines as of v10.0.x post-severity-routing).
