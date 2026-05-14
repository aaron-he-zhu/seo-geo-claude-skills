---
name: max
description: "Run explicit maximum-depth, exhaustive, or stress-test SEO/GEO pack-local orchestration with phase gates."
---
# Max Command
Run explicit maximum-depth, exhaustive, or stress-test SEO/GEO pack-local orchestration with phase gates.
## Route
- multi-skill orchestration
## Rules
- Follow the Product API Contract in `references/aaron-product-api-contract.md`; use `evals/product-api-scenarios.md` for scenario and risk-gate coverage instead of embedding industry cases here.
- Run only when the user explicitly asks for maximum-depth, exhaustive, or stress-test work.
- Infer depth from the natural-language goal, but expose no command parameters or depth flags.
- Before deep work, output phase plan, success criteria, evidence inventory, risk gates, permission checkpoints, and stop condition.
- Full-sprint phase order: preflight -> `/aaron:discover` and `/aaron:compete` -> `/aaron:map` -> `/aaron:tech`, `/aaron:audit`, `/aaron:visibility`, `/aaron:authority` -> optional `/aaron:remember` only for explicit memory lifecycle -> `/aaron:brief`, `/aaron:write`, or `/aaron:series` -> `/aaron:publish` gate -> `/aaron:watch` -> `/aaron:report`.
- Apply risk gates from the scenario library: publish readiness, YMYL, schema factuality, batch scale, external side effects, memory/entity writes, reputation ethics, GEO visibility claims, insufficient data, and technical indexation.
- Respect specialist boundaries: batch content stays chunked, audit and publish readiness require full veto-aware evidence, GEO visibility cannot promise citations, memory cleanup stays with memory-management, and canonical entity profile writes stay with entity-optimizer.
- Start safe read-only analysis by default; pause for filesystem writes, external side effects, paid/tool-costly operations, or explicit time/cost checkpoints.
- Words such as apply, commit, release, publish, or fix are not automatic permission grants. Content publish-package and readiness work routes through `/aaron:publish`; actual CMS/external publication, version bumps, commits, releases, permission changes, and repo edits require explicit confirmation and the appropriate guard, governance, or host workflow.
- Do not publish, mark content ready, or claim ship-ready status from a max summary. Ready requires `/aaron:audit` or `/aaron:publish` evidence with full veto-aware coverage, SHIP gate verdict, no veto state, no caps, no blockers, and `ready_verdict_allowed: true`.
## Output
Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
