---
name: evolution-failure-probes
description: Failure-probe catalog for 9.9.0 controlled evolution guardrail validation.
type: reference
---

# Evolution Failure Probes

These probes define the simulated failure cases expected to fail release validation. They are not production records and should be executed only against temporary repo copies.

| Probe | Expected Failure |
|-------|------------------|
| `nonvalidating-accepted-quoted` | `source_signal.kind: "simulation"` plus `decision.status: "accepted"` must fail. |
| `nonvalidating-accepted-flow` | Flow-style `source_signal: {kind: external_research}` plus accepted status must fail. |
| `eventlike-missing-type` | Event-shaped blocks with `source_signal`, `validation_results`, or `decision` but no `type: evolution-event` must fail. |
| `malformed-indented-event` | Malformed YAML fences with indented EvolutionEvent keys must fail parser-grade validation. |
| `accepted-missing-source-evidence` | Accepted events must require non-empty `source_signal.evidence`. |
| `accepted-missing-schema-field` | Accepted event fixtures must include required schema fields such as `id`, `event_type`, `objective`, `proposed_change`, and validation plan. |
| `accepted-without-evidence-key` | Accepted events must require a non-empty `validation_results.evidence` list. |
| `accepted-evidence-object` | Evidence arrays must contain non-empty strings, not objects or empty placeholders. |
| `optional-false-schema-value` | Optional schema fields such as `validation_plan.eval_cases` and `validation_results.non_validating_reason` must fail when present with falsey non-string/list values. |
| `run-evals-passed-noneligible` | `/aaron:guard --evals` templates must never pair `status: passed` with `acceptance_eligible: false/no/off`. |
| `run-evals-passed-nonvalidating-reason` | `/aaron:guard --evals` templates must never pair `status: passed` with a non-empty `non_validating_reason`. |
| `memory-write-path-case` | `/aaron:evolve` must reject uppercase or mixed-case write paths such as `SAVE to memory/evolution/...`. |
| `memory-write-path-split` | `/aaron:evolve` must reject split write paths such as ``memory/`` plus ``evolution/YYYY-MM.md``. |
| `command-frontmatter-name-drift` | Command frontmatter `name` must match the filename stem. |
| `command-section-drift` | README, Chinese README, and CLAUDE command sections must keep the 10 user / 6 maintenance split exactly. |
| `retired-p2-reference` | Active docs, hooks, refs, or skills must not refer to the retired P2 review slash command literal. |
| `auditor-runbook-hash-drift` | Auditor inline runbook hashes must fail when source or inline blocks drift. |

## Execution Contract

Run probes in temporary copies only:

```text
copy repo to a temp directory
mutate one probe condition
run bash scripts/validate-slimming-guardrails.sh
expect non-zero exit
discard temp directory
```

Passing a mutated probe is a release blocker for 9.9.0 and later.
