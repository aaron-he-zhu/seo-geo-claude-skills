# Evolution Evals
**Status**: lightweight simulated seed set
**Scope**: controlled evolution regression examples
This directory stores small review cases for `/aaron:evolve`, `/aaron:guard --evals`, controlled evolution, and the `/aaron:auto`/`/aaron:max` Product API. They are not automated benchmarks and do not prove production behavior.
## Layout
```text
evals/<skill-name>/cases.md
evals/product-api-scenarios.md
```
Each YAML case uses:
```yaml
id: geo-content-optimizer-sim-001
type: eval-case
status: simulated | real
target_skill: geo-content-optimizer
scenario: "Short situation"
input_summary: "Request or failure signal"
expected_behavior: ["Expected behavior"]
failure_modes: ["Regression"]
evolution_use: "How the case informs evolution"
```
Routing cases use the same schema and live in the target skill's `cases.md`; do not create a separate `evals/routing/` pseudo-skill unless `/aaron:guard --evals` and this contract are extended first. Use `id: routing-...`, keep `target_skill` as a real skill slug, and encode route order, required gates, handoffs, `NEEDS_INPUT`, or `BLOCKED` behavior in `expected_behavior`.
Product API scenarios live in `evals/product-api-scenarios.md` as a YAML `eval-case` bundle with real `target_skill` values plus `scenario_family`, `risk_gates`, `expected_route`, `blocking_inputs`, and `must_not`. For command-only governance scenarios, `target_skill` is the risk/state owner and `expected_route` is command truth. Use that library before adding scenario wording to `commands/auto.md` or `commands/max.md`.
## Evidence Rule
Seed cases may be simulated, but simulated cases are non-validating and cannot support an accepted EvolutionEvent. Promote a case to `status: real` only after it is tied to a real user report, audit artifact, GEO drift record, contract-lint/validate-library failure, CI failure, or another project-local signal.
External research can create candidate cases, but external research is non-validating. A case based only on external research stays `status: simulated` until tied to a project-local artifact or real project signal. Maintainer review may approve the process or proposal, but it does not promote external-only evidence to real validation.
## Running Cases
Use `/aaron:guard --evals --skill <skill-name>` or `/aaron:guard --evals --case <case-id>`. The command returns a `validation_results` block for PR review or an EvolutionEvent draft. Passing simulated cases is useful regression evidence, but acceptance still requires project-local real evidence and maintainer or user approval under the evolution protocol.
