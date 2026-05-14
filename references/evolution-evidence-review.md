# Controlled Evolution Evidence Review

**Status**: external evidence pack for Hermes+ maintainer workflow
**Scope**: controlled evolution design, validation, and release boundaries
**Decision**: GO for experimental maintainer workflow; no self-authorized edits

This review captures external evidence for continuing controlled evolution without waiting for three project-local signals. External evidence can justify better scaffolding, candidate evals, and dry runs. External evidence is non-validating: it cannot make an EvolutionEvent accepted by itself.

## Decision Frame

The target is not a background self-modifying system. The target is a **Hermes+ controlled maintainer workflow**:

1. Exceed the public Hermes baseline for skill evolution by adding stricter provenance, validation results, rollback, PR review, and executable guardrails.
2. Move close to the claimed self-evolution loop by producing proposals, candidate diffs, eval cases, PR-ready summaries, and review records.
3. Stop before self-authorization: no file edits by `/aaron:evolve`, no automatic memory writes, no automatic PRs, no automatic merges, and no accepted simulated or external-only events.

## External Evidence

| Source | What it supports | Boundary for this repo |
|--------|------------------|------------------------|
| Hermes Agent self-improving guide: https://hermes-agent.ai/blog/self-improving-ai-guide | Memory plus skill updates can improve future agent behavior without model retraining. | Treat skill evolution as maintainer workflow, not proof of production quality. |
| Hermes Agent skills guide: https://hermes-agent.nousresearch.com/docs/guides/work-with-skills | Agents can create and update skill instructions after solving tasks. | `/aaron:evolve` may draft changes, but must not write them. |
| Hermes self-evolution repo: https://github.com/NousResearch/hermes-agent-self-evolution | Public roadmap centers on skill-file optimization first, with later tool, prompt, code, and continuous-loop phases planned. | This repo can exceed skill-file scaffolding with stronger review gates, but should not claim autonomous continuous evolution. |
| EvoMap Evolver: https://github.com/EvoMap/evolver | Evolution assets can be logged as Genes, Capsules, and EvolutionEvents with rollback and review. | Keep Genes and Capsules conceptual until real reuse appears. |
| Reflexion paper: https://arxiv.org/abs/2303.11366 | Verbal feedback and episodic memory can improve later attempts. | Feedback is evidence, not instruction; source provenance and approval are required. |
| Self-Refine paper: https://arxiv.org/abs/2303.17651 | Iterative feedback and refinement can improve outputs without additional training. | Use feedback loops for proposals and eval cases, not automatic acceptance. |

## Hermes+ Maturity Ladder

| Level | Name | Allowed now | Promotion gate |
|-------|------|-------------|----------------|
| L0 | Simulated scaffolding | Seed eval cases and simulated events | Always non-validating |
| L1 | External evidence pack | Source-backed design and candidate evals | Evidence review linked from protocol |
| L2 | Maintainer dry run | One end-to-end proposal from external evidence or maintainer observation | Validation plan plus PR-ready summary |
| L3 | Real signal loop | User feedback, audit failure, GEO drift, contract-lint/validate-library failure, or `maintainer_observation` tied to a project-local artifact | At least three real EvolutionEvents |
| L4 | Accepted improvement | Human-approved change with validation results and rollback | `validation_results.status: passed` |
| L5 | Near-continuous review queue | Recurring reviewed proposals from real signals | Still no self-authorized writes, merges, or releases |

The project should aim for L4 before calling the workflow proven. L5 can exist only as a maintainer review queue, not an autonomous daemon.

## Acceptance Rules

Accepted EvolutionEvents must have all of these:

- `approved_by: user` or `approved_by: maintainer`
- `validation_results.status: passed`
- `validation_results.acceptance_eligible: true`
- concrete `validation_results.evidence`
- no non-empty `validation_results.non_validating_reason`
- `simulation: false`
- `risk.level`
- `rollback.revert_scope`
- no `simulation: true`
- no `source_signal.kind: simulation`
- no `source_signal.kind: external_research`

Events based only on external research remain `proposed`, `rejected`, or `superseded`. To accept an externally inspired change, create a new EvolutionEvent whose `source_signal.kind` is a project-local signal and whose validation results are real, passed, and acceptance-eligible.

## What We Can Exceed

Compared with the public Hermes baseline, this repo can exceed governance maturity for a content-only maintainer workflow in these areas:

1. **Provenance**: every event separates source signal, validation plan, validation results, approval, and rollback.
2. **Safety**: the evolve command has no edit permission and no memory-write path.
3. **Release discipline**: command inventory, manifests, marketplace mirrors, and PR templates are checked by release guardrails.
4. **Audit preservation**: auditor and protocol changes default to protocol risk and cannot lower veto, cap, `BLOCKED`, or artifact gates.
5. **Cross-agent portability**: the workflow stays content-only and Tier 1 compatible.

## What We Must Not Claim

- Do not claim autonomous self-evolution.
- Do not claim simulated evals prove behavior.
- Do not claim external papers validate this repository's results.
- Do not claim the workflow improves SEO/GEO outcomes until real project signals produce accepted changes.

## Dry Run Requirement

Before broadening the workflow, run one dry run with this shape:

1. Source signal: `external_research` or `maintainer_observation`.
2. Target: one non-auditor skill or command description.
3. Output: proposal, candidate diff text, validation plan, rollback scope, PR-ready summary, and proposed EvolutionEvent.
4. Decision: `proposed`, not `accepted`.
5. Validation result: `not_run` unless a real command or reviewer result exists.

After the dry run, promote only the process, not the event outcome.
