## What does this PR do?

<!-- Brief description of changes -->

## Type of change

- [ ] New skill
- [ ] Skill update
- [ ] Documentation
- [ ] Bug fix
- [ ] Controlled evolution proposal
- [ ] Other

## Controlled Evolution

<!-- Required when this PR is based on /aaron:evolve or changes controlled evolution surfaces. -->

- EvolutionEvent id:
- Target:
- Risk level: low / medium / high / protocol
- Source signal: user_feedback / audit_failure / geo_drift / contract_lint / validate_library / eval_failure / handoff_gap / stale_reference / external_research / maintainer_observation / agent_observation / simulation
- Eval cases:
- Validation run:
- Validation results:
- Acceptance eligible: yes / no
- Rollback previous_ref:
- Rollback removed command files:
- Rollback release surfaces:
- Rollback host manifests:
- Rollback validation commands:
- Rollback published artifacts:
- Host namespace smoke evidence:
- Approved by: user / maintainer / skill_inferred
- Decision status: proposed / accepted / rejected / superseded

## Checklist

### For new skills:
- [ ] `name` field matches directory name exactly
- [ ] `description` includes trigger phrases AND scope boundaries
- [ ] Placed in the correct category directory (research/build/optimize/monitor/cross-cutting)
- [ ] SKILL.md is under 350 lines
- [ ] Uses `~~placeholder` pattern for tool references
- [ ] Includes validation checkpoints
- [ ] Includes at least one concrete example
- [ ] Related skills are linked correctly

### For all changes:
- [ ] Follows the [Agent Skills specification](https://agentskills.io/specification.md)
- [ ] `VERSIONS.md` updated with new version and date
- [ ] `marketplace.json` (repo root) skills array updated (if adding a new skill)
- [ ] `.claude-plugin/marketplace.json` byte-identical to root (`cp marketplace.json .claude-plugin/marketplace.json` — or let CI do it on main)
- [ ] `.claude-plugin/plugin.json` skills array updated (if adding a new skill)
- [ ] `README.md` skills table updated (if adding a new skill)

### For controlled evolution changes:
- [ ] EvolutionEvent summary included above
- [ ] Simulated evidence is labeled `simulation: true`
- [ ] Simulated evidence is not marked `decision.status: accepted`
- [ ] External-research-only evidence is not marked `decision.status: accepted`
- [ ] Accepted events use `approved_by: user` or `approved_by: maintainer`
- [ ] Accepted events include `validation_results` evidence
- [ ] Accepted events use `validation_results.status: passed`
- [ ] Accepted events use `validation_results.acceptance_eligible: true`
- [ ] Accepted events have no non-empty `validation_results.non_validating_reason`
- [ ] Accepted events set `simulation: false` and project-local `source_signal.kind`
- [ ] Accepted events include non-empty `source_signal.evidence`
- [ ] No CORE-EEAT, CITE, veto, cap, BLOCKED, or artifact-gate standard was weakened
- [ ] `/aaron:evolve` remains proposal-only; any edits were applied through normal reviewed workflow
- [ ] Human maintainer review completed before merge
