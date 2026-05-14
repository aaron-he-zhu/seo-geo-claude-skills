# Contract Fail Caps (single source of truth)

> **This file owns cap policy.** The auditor runbook may restate active numbers inside its hash-synced executable block; all other files link here. Drift is flagged by `/aaron:guard --contracts`.

**Scope**: numbers only. Arithmetic rules and worked examples live in [auditor-runbook.md §2](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/auditor-runbook.md). Item definitions (which items are vetos) live in the framework files.

---

## Cap Table

| Condition | Dimension cap | Overall cap | Status | Severity |
|---|---|---|---|---|
| 1 veto item failed | **60/100** | **60/100** | active (v7.1.0) | **P0** |
| 2+ veto items failed | `[calibration pending v7.3]` — use BLOCKED path per auditor-runbook §2 Worked Example 3 | `[calibration pending v7.3]` | deferred | **P0** (each veto) |

## Severity Tiers (v10.0.x)

Internal routing label for finding prioritization. Never rendered to users — user-facing translation lives in [auditor-runbook.md §5](auditor-runbook.md). Caps in the table above still apply only to veto failures; P-tiers govern fix ordering, not score gating.

| Tier | Internal | Mapping | User-facing |
|---|---|---|---|
| **P0** | `severity: veto` | Veto item failure (T03/T04/T05/T09/C01/R10) | "critical issue" |
| **P1** | `severity: high` | Non-veto Fail with item weight ≥ 8 | "should-fix" |
| **P2** | `severity: medium`/`low` | Partial, or Fail with weight < 8 | "nice-to-have" |

---

## Applied when

A veto item failure activates the cap for the affected dimension AND the overall score. The veto item is determined by the framework:

- **CORE-EEAT** veto items: T04 (Trust — affiliate disclosure), C01 (Contextual Clarity — clickbait), R10 (Referenceability — data consistency) — defined in [core-eeat-benchmark.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/core-eeat-benchmark.md)
- **CITE** veto items: T03 (Trust — link farm), T05 (Trust — profile duplication), T09 (Trust — manual action) — defined in [cite-domain-rating.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/cite-domain-rating.md)

---

## Worked example — how the number 60 is consumed

For a page with raw T dimension = 85 and raw overall = 78, with T04 failing:

```
T dimension: 85 → 60    (capped down because raw > 60)
Overall:     78 → 60    (capped at 60 because any veto forces overall cap)
```

### Second example — raw dim already below cap

For a page with raw C dimension = 55 and raw overall = 77, with C01 (clickbait) failing:

```
C dimension: 55 → 55    (unchanged; 55 < 60, cap is a ceiling only, not a floor)
Overall:     77 → 60    (capped at 60 because any veto forces overall cap)
```

The cap is a **ceiling only**. If raw dim is already below 60, it stays at its natural value — the cap does not raise it. See [auditor-runbook.md §2](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/auditor-runbook.md) for the full decision table and all three worked examples.

---

## Rationale

- **60/100 = Medium floor**: signals a real problem without appearing broken. Above Low rating band (40-59), below Good band (75-89). Chosen so a content author reading the score knows "this is a real issue, but not catastrophic."
- **2+ veto fail capped as BLOCKED pending calibration**: the 40-tier number in earlier drafts (v1, v2) was eyeballed. Shipping an uncalibrated number would erode trust when users hit the 2-veto case. BLOCKED forces manual review until real calibration data exists.

---

## Who consumes this file

These files consume cap policy defined here. Only hash-synced auditor execution surfaces may restate active numbers:

- [references/auditor-runbook.md §2](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/auditor-runbook.md) — arithmetic and worked examples
- [references/core-eeat-benchmark.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/core-eeat-benchmark.md) — veto item definitions, links here for caps
- [references/cite-domain-rating.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/cite-domain-rating.md) — veto item definitions, links here for caps
- [cross-cutting/content-quality-auditor/SKILL.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/cross-cutting/content-quality-auditor/SKILL.md) — consumes via inlined Runbook
- [cross-cutting/domain-authority-auditor/SKILL.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/cross-cutting/domain-authority-auditor/SKILL.md) — consumes via inlined Runbook

---

## Sunset — calibration trigger

The 40-tier cap for 2+ veto fails is deferred until real data exists.

- **Trigger condition**: 30+ audits in `memory/audits/` with multi-veto fail scenarios
- **Review trigger**: when 30+ real multi-veto audits exist, or during the next maintainer calibration review
- **Runner**: `/aaron:guard --evals` plus maintainer review of `memory/audits/` evidence
- **Owner**: project maintainer (aaron-he-zhu)
- **Action on trigger met**: propose numeric 40-tier cap for v7.3, back-calibrated against the 30+ observed multi-veto cases
- **Action on trigger unmet**: keep the deferred item closed for release; no 40-tier cap ships; BLOCKED path remains authoritative for multi-veto cases

---

## Changing the cap number

If you need to change 60 or the deferred 40:

1. Edit THIS file
2. Re-run `/aaron:guard --contracts` to verify no other file still restates the old number (none should — it's a lint rule)
3. Re-sync [auditor-runbook.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/auditor-runbook.md) worked examples if the new number changes their arithmetic
4. Propagate the updated Runbook to both auditor SKILL.md inline copies (per [AUDITOR-AUTHORS.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/AUDITOR-AUTHORS.md) runbook update procedure)
5. Write an ADR in `references/decisions/` explaining why the number changed

**Do not** change the cap number in more than one place. That is drift by construction. Edit here first, propagate from here.
