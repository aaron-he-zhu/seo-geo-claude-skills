---
name: skill-evolution-log
description: Append-only records for controlled skill evolution proposals, validations, and decisions.
type: reference
---

# Evolution Memory

This directory stores controlled evolution records for the SEO/GEO skills library. It supports `/aaron:evolve` and the protocol in `references/evolution-protocol.md`.

## Purpose

Use this directory to keep evidence for skill improvements:

- user feedback
- eval failures
- audit failures
- GEO citation drift
- lint findings
- handoff gaps
- stale references
- external research
- accepted or rejected improvement proposals

Evolution records are not approved project facts. They are maintenance evidence.

## File Layout

Use monthly append-only files:

```text
memory/evolution/YYYY-MM.md
```

Each file can contain multiple `EvolutionEvent` entries. Keep raw logs, screenshots, and large exports outside HOT memory; summarize evidence here and link to the source.

## Ownership

- `memory-management` owns lifecycle, archival, and promotion behavior.
- `/aaron:evolve` may produce an `EvolutionEvent` draft.
- Maintainers approve or reject events.
- Candidate events must not be treated as `memory/decisions.md` entries.

## Approval Rules

`approved_by: skill_inferred` means proposed only. It never counts as user or maintainer approval.

Only these approval states can drive durable changes:

- `approved_by: user`
- `approved_by: maintainer`

`decision.status: accepted` requires all of these:

- `approved_by: user` or `approved_by: maintainer`
- `validation_results.status: passed`
- `validation_results` with evidence
- `validation_results.acceptance_eligible: true`
- no non-empty `validation_results.non_validating_reason`
- `simulation: false`
- project-local `source_signal.kind`
- non-empty `source_signal.evidence`
- `risk.level`
- `rollback.revert_scope`

Simulated records must set `simulation: true` and `source_signal.kind: simulation`; they must remain `proposed`, `rejected`, or `superseded`.

Records with `source_signal.kind: external_research` are non-validating and must not be accepted until rewritten from a project-local signal with real validation.

Protocol-layer changes also need an ADR or decision record under `references/decisions/`.

## Event Template

```yaml
id: evo-YYYY-MM-DD-skill-slug-001
type: evolution-event
simulation: false
target:
  kind: skill | command | protocol
  name: geo-content-optimizer
  path: build/geo-content-optimizer/SKILL.md
event_type: trigger_refinement | instruction_refinement | handoff_fix | guardrail_fix | reference_update | eval_addition
source_signal:
  kind: user_feedback | audit_failure | geo_drift | contract_lint | validate_library | eval_failure | handoff_gap | stale_reference | external_research | maintainer_observation | agent_observation | simulation
  evidence:
    - "Short source, URL, file path, eval case id, or audit id"
objective: "What this evolution tries to improve"
proposed_change:
  summary: "One-paragraph candidate change"
  files_touched:
    - "build/geo-content-optimizer/SKILL.md"
  scope: description | when_to_use | handoff | instructions | references | command | protocol
risk:
  level: low | medium | high | protocol
  blast_radius: single_skill | category | protocol_layer | release_surface
validation_plan:
  required:
    - "/aaron:guard --contracts --skill <name>"
    - "/aaron:guard --release --skill <name>"
  eval_cases: []
validation_results:
  status: not_run | passed | failed | mixed
  evidence:
    - "Command output, reviewer note, artifact path, or not_run reason"
  acceptance_eligible: true | false
  non_validating_reason: "simulated cases only, external research only, blocked evidence, or empty string for validating runs"
rollback:
  previous_ref: "commit, release tag, or file path"
  revert_scope: "target files only"
decision:
  status: proposed | accepted | rejected | superseded
  approved_by: user | maintainer | skill_inferred
  rationale: "Why this status was chosen"
```

## Lifecycle

- Proposed events stay in monthly files until accepted, rejected, or superseded.
- Accepted events must include `simulation: false`, project-local `source_signal.kind`, `validation_results.status: passed`, `validation_results.acceptance_eligible: true`, validation result evidence, and user or maintainer approval.
- Rejected events should keep the rejection reason.
- Superseded events should point to the replacement event id.
- Full archival follows the HOT/WARM/COLD rules in `references/state-model.md`.
