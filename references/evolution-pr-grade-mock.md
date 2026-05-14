---
name: evolution-pr-grade-mock
description: PR-grade controlled evolution mock for 9.9.0 simulation-complete release validation.
type: reference
---

# Evolution PR-Grade Mock

This fixture shows how a PR should summarize controlled evolution: source signal, target, risk, validation_results, rollback, and decision. It is not production evidence.

## Mock PR Summary

```markdown
## Controlled Evolution
- Source signal: maintainer_observation from agent-team review.
- Target: `commands/guard.md` and `scripts/validate-slimming-guardrails.sh`.
- Risk: high release-surface guardrail change.
- Validation: `/aaron:guard --evals`, `/aaron:guard --release --strict`, `/aaron:guard --contracts --strict`, failure probes.
- Rollback: revert the guardrail parser block and command-template changes.
```

## Accepted Event Sample

```yaml
id: evo-sample-accepted-parser-guard-001
type: evolution-event
simulation: false
target: {kind: command, name: guard, path: commands/guard.md}
event_type: guardrail_fix
source_signal: {kind: maintainer_observation, evidence: ["Mock PR review found run-evals acceptance eligibility needed parser-grade guard coverage."]}
objective: "Demonstrate an accepted, project-local, PR-grade controlled evolution event."
proposed_change: {summary: "Require parser-grade EvolutionEvent validation and failure-probe coverage before accepting evolution records.", files_touched: ["scripts/validate-slimming-guardrails.sh", "commands/guard.md"], scope: command}
risk: {level: high, blast_radius: release_surface}
validation_plan: {required: ["/aaron:guard --evals --strict", "/aaron:guard --release --strict", "/aaron:guard --contracts --strict"], eval_cases: ["guardrail-probe-nonvalidating-accepted", "guardrail-probe-run-evals-noneligible-passed"]}
validation_results: {status: passed, evidence: ["Mock PR: parser-grade guard accepted fixture passed.", "Mock PR: failure probes rejected non-validating accepted events."], acceptance_eligible: true, non_validating_reason: ""}
rollback: {previous_ref: "mock-pr-base", revert_scope: "parser-grade parser and guard command template only"}
decision: {status: accepted, approved_by: maintainer, rationale: "Mock sample meets project-local provenance, validation, evidence, approval, and rollback requirements."}
```

## Rejected Event Sample

```yaml
id: evo-sample-rejected-external-001
type: evolution-event
simulation: false
target: {kind: skill, name: geo-content-optimizer, path: build/geo-content-optimizer/SKILL.md}
event_type: instruction_refinement
source_signal: {kind: external_research, evidence: ["External research suggests stronger AI citation formatting."]}
objective: "Show that external-only signals can inform proposals but cannot approve changes."
proposed_change: {summary: "Change GEO citation recommendations based only on external research.", files_touched: ["build/geo-content-optimizer/SKILL.md"], scope: instructions}
risk: {level: medium, blast_radius: single_skill}
validation_plan: {required: ["/aaron:guard --evals --skill geo-content-optimizer"], eval_cases: ["geo-content-optimizer-sim-001"]}
validation_results: {status: mixed, evidence: ["Mock PR: external-only evidence remains non-validating."], acceptance_eligible: false, non_validating_reason: "external research only"}
rollback: {previous_ref: "mock-pr-base", revert_scope: "geo-content-optimizer instruction proposal only"}
decision: {status: rejected, approved_by: skill_inferred, rationale: "Rejected until rewritten from a project-local signal."}
```

## Superseded Event Sample

```yaml
id: evo-sample-superseded-eval-001
type: evolution-event
simulation: true
target: {kind: skill, name: content-quality-auditor, path: cross-cutting/content-quality-auditor/SKILL.md}
event_type: eval_addition
source_signal: {kind: simulation, evidence: ["Initial simulated eval lacked C01 and R10 coverage."]}
objective: "Show how an older simulated eval proposal is superseded by a broader eval set."
proposed_change: {summary: "Add a single simulated veto eval.", files_touched: ["evals/content-quality-auditor/cases.md"], scope: references}
risk: {level: protocol, blast_radius: protocol_layer}
validation_plan: {required: ["/aaron:guard --contracts --strict", "/aaron:guard --release --strict"], eval_cases: ["content-quality-auditor-sim-005"]}
validation_results: {status: mixed, evidence: ["Mock PR: superseded by the 9.9.0 simulated eval expansion."], acceptance_eligible: false, non_validating_reason: "simulated case only"}
rollback: {previous_ref: "mock-pr-base", revert_scope: "simulated eval fixture only"}
decision: {status: superseded, approved_by: skill_inferred, rationale: "Superseded by expanded C01, R10, multi-veto, and artifact-gate eval coverage."}
```
