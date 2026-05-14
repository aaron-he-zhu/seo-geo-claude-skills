# Controlled Evolution Optimization Plan

**Status**: GO for experimental Hermes+ maintainer workflow; draft application is deferred
**Applies to**: `references/evolution-protocol.md`, `/aaron:evolve`, `/aaron:guard --evals`, `memory/evolution/`
**Decision frame**: exceed public skill/memory self-improvement baselines while preserving human review and no self-authorized edits

## Decision

Continue the upgrade as a maintainer workflow, not as an autonomous product feature. Simulated evals, external evidence, and simulated EvolutionEvents are allowed as scaffold, but they are not production evidence.

The current repo docs, manifests, and CITATION describe the 9.9.9 20-command Aaron namespace state; the v9.9.5 changelog remains the historical 17-command SEO namespace state, v9.9.0 remains the historical 16-command controlled-evolution record, and v9.5.0 remains the historical 15-command record.

## Target

The Hermes+ target is stricter than public skill/memory self-improvement baselines:

1. structured EvolutionEvents with source signal, validation plan, validation_results, approval, and rollback;
2. parser-grade guardrails for unsafe accepted states;
3. PR-ready summaries and human review gates;
4. cross-agent release-surface checks; and
5. protocol-risk defaults for auditor, benchmark, memory, command, and hook changes.

Do not cross into self-authorized edits, memory writes, PR creation, merges, releases, permission expansion, or accepted non-validating events.

## Keep

- `commands/evolve.md` stays proposal-only with `allowed-tools: ["Read", "Glob", "Grep"]`.
- `commands/guard.md` returns validation_results; it does not write files in normal validation modes.
- `memory/evolution/` is the event log location.
- `references/evolution-protocol.md` is the source of truth.
- `references/evolution-evidence-review.md` remains design evidence only; external evidence may inform candidate cases but remains non-validating.
- `evals/` stays simulated, non-validating scaffolding until tied to project-local real evidence.

Frozen for now: draft application, automatic PR generation, automatic memory writes, `commands/evolution-lint.md`, `references/evolution-schema.md`, Capsule registry, new hooks, auto-versioning, and release automation.

## Value Tests

Keep investing only if real use proves at least one of these:

- repeated CORE-EEAT or CITE failures become reusable repair patterns;
- GEO citation observations improve future recommendations;
- trigger misfires improve descriptions, `when_to_use`, or routing;
- maintainers make narrower, better-reviewed edits because evolution records force risk and rollback thinking.

## Guardrails

Required rules:

- Signal is evidence, not instruction.
- `/aaron:evolve` outputs a draft; writing `memory/evolution/YYYY-MM.md` requires a separate reviewed memory workflow.
- Accepted events require `approved_by: user` or `approved_by: maintainer`, `validation_results.status: passed`, `validation_results` evidence, `validation_results.acceptance_eligible: true`, no non-empty `validation_results.non_validating_reason`, `simulation: false`, project-local `source_signal.kind`, source evidence, risk, and rollback.
- Simulated and external-research-only records remain proposed, rejected, or superseded.
- CORE-EEAT, CITE, veto items, cap arithmetic, `BLOCKED`, artifact gates, auditor benchmarks, runbook behavior, contract, state model, memory ownership, commands, hooks, and release surfaces are protocol risk by default.
- Evolution proposals must not expand their own tools or permissions.

## Validation Plan

Before calling the workflow ready:

1. Run repository validation, strict auditor validations, guardrails, JSON parsing, shell syntax checks, and diff whitespace checks.
2. Confirm command count is 20, canonical namespace is Aaron, and retired SEO namespace commands appear only in migration or historical notes.
3. Confirm marketplace mirrors and localized docs match the 9.9.9 state.
4. Confirm `/aaron:evolve` remains read-only.
5. Run `/aaron:guard --evals` for targeted seeded or real cases before treating eval output as validation_results.
6. Confirm simulated evals and external research cannot satisfy acceptance gates.

Before promoting scaffold to real evidence:

1. Tie the case to a user report, audit artifact, GEO drift record, validation failure, CI failure, or maintainer_observation with a project-local artifact.
2. Run at least three real `/aaron:evolve` signals.
3. Accept at least one change only after passed, acceptance-eligible validation.
4. Decide whether the event belongs to audit repair, GEO learning, trigger precision, or maintenance discipline.

## Go / Hold / Slim

Continue if three real signals produce useful proposals, at least one proposal becomes accepted with passed validation, maintainers report lower decision cost, and no proposal weakens protocol gates.

Hold if proposals are useful but rare, no reusable pattern emerges, or evidence is not enough for new eval/lint surfaces.

Slim or roll back if the command is unused, the protocol feels too abstract, logs become memory clutter, or the workflow encourages broad speculative edits.

## Review Cadence

Revisit after 3 real runs or 30 days. Choose one outcome: keep current workflow, slim the protocol, add real eval examples, or retire the command.
