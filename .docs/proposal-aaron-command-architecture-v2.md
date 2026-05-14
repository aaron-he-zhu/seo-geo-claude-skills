# Aaron Command Architecture v2 Proposal

**Status**: working-tree implementation complete; release acceptance pending
**Date**: 2026-04-30
**Source**: fork review, Aaron/user feedback, and agent-team review
**Scope**: redesign the command layer while keeping all 20 skills and all skill URLs stable

## Executive Summary

The command layer should become the product API: `/aaron:auto` for default end-to-end operation, `/aaron:max` for explicit maximum-depth or exhaustive orchestration, and a compact set of expert shortcuts for repeatable jobs. The 20 underlying skills stay stable; commands route across them.

This is a direct breaking rename from `/seo:` to `/aaron:`. There is no alias
layer. The working tree now includes local recovery copy, routing eval coverage,
release-surface updates, rollback notes, and guardrails. Accepted release
decision evidence and host callable-name smoke checks remain release gates.

## Product Decision

Proceed only if Aaron is intentionally moving from an SEO command bundle to a
broader SEO/GEO operating system. The value case: `/seo:*` under-sells GEO,
memory, governance, monitoring, and authority work; the old command set grew
incrementally; most new users should learn only `/aaron:auto` and `/aaron:max`;
expert shortcuts become stable task APIs without exposing raw skills.

The accepted decision record must include migration impact, old-command support signals, target-user benefit hypotheses, success metrics, rollback thresholds, and explicit Aaron/maintainer approval. Do not proceed if maintainers require
backward compatibility, release channels cannot mark a breaking rename, runtime skill docs cannot be fully migrated, or accepted decision evidence is missing.

## Non-Negotiables

- Keep exactly 20 skills.
- Do not add, rename, move, or delete skill directories.
- Do not change existing skill GitHub URLs.
- End state has exactly 20 command specs.
- Do not create duplicate `/seo:*` shim command files.
- Do not preserve `/seo:` as runtime aliases, transition files, or current documentation.
- Default command output is inline. Files are written only when the user explicitly asks and the runtime can write.
- Do not weaken CORE-EEAT, CITE, memory ownership, controlled evolution, eval, routing, version, or release guardrails.
- Treat line-budget recovery as a later slimming phase, not a precondition for this architecture decision.

## Proposed 20 Commands

| Group | Command | Job | Primary routes |
|-------|---------|-----|----------------|
| Universal | `/aaron:auto` | Infer intent, choose the smallest useful workflow, ask only for blocking inputs. | resolver across all skills |
| Universal | `/aaron:max` | Explicit maximum-depth, exhaustive, or stress-test orchestration with phase gates. | multi-skill orchestration |
| Strategy | `/aaron:discover` | Keyword demand, SERP intent, market demand, cluster discovery. | `keyword-research`, `serp-analysis`, `content-gap-analysis` |
| Strategy | `/aaron:compete` | Competitor SEO/GEO, content gaps, backlinks, share-of-voice. | `competitor-analysis`, `backlink-analyzer`, `content-gap-analysis` |
| Strategy | `/aaron:map` | Site/topic/entity map, editorial roadmap, internal-link architecture. | `content-gap-analysis`, `internal-linking-optimizer`, `entity-optimizer` |
| Strategy | `/aaron:brief` | Convert research into one executable content brief. | research skills, `seo-content-writer` |
| Content | `/aaron:write` | Single article, landing page, guide, comparison, FAQ, or product copy. | `seo-content-writer`, `geo-content-optimizer`, `meta-tags-optimizer` |
| Content | `/aaron:series` | Plan, write, continue, and hand off a content series. | research skills, `seo-content-writer`, `geo-content-optimizer`, `internal-linking-optimizer` |
| Content | `/aaron:refresh` | Update stale, declining, or outdated content. | `content-refresher`, `on-page-seo-auditor`, `content-quality-auditor` |
| Publish | `/aaron:publish` | Prepare a CMS-neutral publish package; do not publish by default. | `content-quality-auditor`, `meta-tags-optimizer`, `schema-markup-generator`, `internal-linking-optimizer` |
| Optimize | `/aaron:audit` | Page/content SEO plus CORE-EEAT publish-readiness audit. | `on-page-seo-auditor`, `content-quality-auditor` |
| GEO | `/aaron:visibility` | AI answer visibility and GEO citation readiness. | `geo-content-optimizer`, `entity-optimizer`, `content-quality-auditor`, `domain-authority-auditor` |
| Technical | `/aaron:tech` | Crawlability, indexing, Core Web Vitals, robots, sitemap, canonicals, migration risk. | `technical-seo-checker` |
| Trust | `/aaron:authority` | CITE, domain trust, backlinks, entity credibility, source authority. | `domain-authority-auditor`, `backlink-analyzer`, `entity-optimizer` |
| Monitor | `/aaron:watch` | Rankings, alerts, GEO drift, AI citation checks, anomaly monitoring. | `rank-tracker`, `alert-manager`, `geo-content-optimizer`, `memory-management` |
| Report | `/aaron:report` | SEO/GEO report for a domain, campaign, project, or period. | `performance-reporter`, monitor skills |
| Memory | `/aaron:remember` | Project memory lifecycle: initialize, query, update, promote, archive, and entity/feedback state. | `memory-management`, `entity-optimizer` |
| Governance | `/aaron:skillify` | Read-only proposal/review surface for skill, command, routing, and eval changes. | resolver, skill contract |
| Governance | `/aaron:evolve` | Controlled evolution from a signal through risk classification, validation plan, and EvolutionEvent draft. | evolution protocol, resolver, affected skills |
| Governance | `/aaron:guard` | Deterministic validation bundle: evals, contracts, wiki, versions, release surfaces. | validation scripts and governance refs |

### Physical Command File Inventory

Implementation replaces the current 17 files with exactly 20 files under
`commands/`: `audit.md`, `authority.md`, `auto.md`, `brief.md`, `compete.md`,
`discover.md`, `evolve.md`, `guard.md`, `map.md`, `max.md`, `publish.md`,
`refresh.md`, `remember.md`, `report.md`, `series.md`, `skillify.md`,
`tech.md`, `visibility.md`, `watch.md`, `write.md`. Documented sections are
17 user commands (`auto`, `max`, `discover`, `compete`, `map`, `brief`, `write`,
`series`, `refresh`, `publish`, `audit`, `visibility`, `tech`, `authority`,
`watch`, `report`, `remember`) and 3 maintainer/governance commands
(`skillify`, `evolve`, `guard`). Guardrails must assert filenames, slash names,
and documented section counts.

## User Chooser

Docs must teach the two universal commands first and put the 20-command list in
an expert/reference section. README, marketplace copy, and first-run examples
show only the two beginner entries above the fold:

### Beginner Contract

New users should not be asked to memorize 20 commands. README, marketplace copy,
and first-run examples should present only:

```text
/aaron:auto  default end-to-end operator
/aaron:max   explicit maximum-depth mode
```

Expert shortcuts are for repeatable jobs, saved workflows, and maintainers. Each
expert command description should include: "Not sure? Use `/aaron:auto`."

```text
Not sure / ordinary task        /aaron:auto
Maximum-depth / exhaustive      /aaron:max
Find opportunities              /aaron:discover
Beat a competitor               /aaron:compete
Build a content/site map        /aaron:map
Turn research into a brief      /aaron:brief
Write one asset                 /aaron:write
Build a content series          /aaron:series
Refresh old content             /aaron:refresh
Check quality                   /aaron:audit
Prepare a publish package       /aaron:publish
Improve AI answer visibility    /aaron:visibility
Fix technical SEO               /aaron:tech
Assess trust/authority          /aaron:authority
Monitor rankings or GEO drift   /aaron:watch
Report performance              /aaron:report
Use project memory              /aaron:remember
Review a proposed change        /aaron:skillify
Evolve behavior from a signal   /aaron:evolve
Run maintainer validation       /aaron:guard
```

## Boundary Rules

- `discover` finds demand, SERP intent, and topic clusters; `map` turns known opportunities into architecture.
- `brief` produces one execution brief; `write` produces the asset.
- `publish` packages a ready asset; it is not a CMS writer.
- `visibility` owns AI answer inclusion, AI citation readiness, and GEO visibility diagnosis; `watch` monitors drift over time.
- `authority` audits trust, backlinks, and CITE; `visibility` focuses on answer inclusion and entity clarity.
- Internal links are owned by `map` for architecture and `publish` for final package checks.
- Meta, schema, and snippet polish are owned by `write`, `audit`, and `publish`; no separate `polish` shortcut is needed.

## Core Command Contracts

### `/aaron:auto`

Required behavior:

- detect user intent and scenario family;
- execute the smallest safe end-to-end command chain implied by the user's goal;
- keep ordinary user-facing output concise;
- list plausible alternatives only when confidence is low or the user asks for routing detail;
- ask only for missing blocking inputs;
- continue until the natural stopping point;
- if the user gives an object but no outcome, run lightweight triage and choose the safest useful starting chain;
- if the user gives neither object nor outcome, ask one concise blocking question;
- stop at evidence gaps, write/permission gates, external side effects, publish/readiness gates, oversized batches, repo governance, or memory/entity writes;
- never redirect ordinary broad work to `/aaron:max`;
- use `/aaron:max` only when the user explicitly asks for maximum-depth, exhaustive, or stress-test mode;
- never write files, publish, or claim readiness unless the specialist gate and user permission allow it.

Internal/debug fields for route traces:

```yaml
detected_intent: string
selected_command: /aaron:<command>
selection_confidence: high | medium | low
why_this_command: string
other_possible_commands: [/aaron:<command>]
skill_chain: [skill]
missing_inputs: [string]
assumptions: [string]
result: string
next_command: /aaron:<command> | none
```

### `/aaron:max`

Required behavior:

- run only for explicit maximum-depth, exhaustive, or stress-test work;
- run a preflight before deep work;
- infer depth internally from the natural-language goal; no `quick`, `deep`, or `full` command parameters are exposed;
- state phases, stop condition, evidence mode, and permission checkpoints;
- run safe read-only analysis phases immediately by default;
- pause only for filesystem writes, external side effects, paid/tool-costly operations, or explicit time/cost checkpoints;
- chunk work when token, evidence, or time limits require it;
- preserve auditor, memory, publish, and evolution gates;
- write files only after explicit user confirmation.

Required fields:

```yaml
max_scope: page | domain | content_plan | series | publish | recovery | campaign | repo
depth_inferred: light | standard | complete
phases_planned: [string]
phases_completed: [string]
blocked_phases: [string]
evidence_mode: tool_backed | user_provided | no_tool_estimate
permission_checkpoints: [string]
stop_condition: string
priority_actions: [string]
continuation_plan: [string]
files_written: [string]
```

### `/aaron:series`

Modes:

```text
/aaron:series <topic> --plan
/aaron:series <series-plan> --write
/aaron:series <series-dir-or-summary> --continue
/aaron:series <series-dir-or-summary> --publish-handoff
```

Defaults:

- topic input defaults to `--plan`;
- valid `series_plan` input defaults to `--write`;
- default write limit is 3 articles per run;
- maximum recommended write limit is 6 unless the user accepts chunked output;
- batch rollups cannot create a `ready` publish verdict unless every article has full veto-aware audit coverage.

### `/aaron:publish`

Required behavior:

- prepare a publish package, not direct publication;
- include metadata, schema, media map, internal-link checks, and CMS-neutral fields;
- route through `internal-linking-optimizer` when internal links are promised;
- return `ready`, `ready_with_concerns`, or `blocked`;
- allow `ready` only with full veto-aware audit coverage for the relevant page or every article in a series;
- use provider mapping as advisory unless a separate CMS integration exists and the user confirms write access.

### `/aaron:visibility`

Required behavior:

- diagnose AI answer inclusion and GEO citation readiness;
- use `geo-content-optimizer` for answer-ready structure and citation-readiness work;
- route through `entity-optimizer` when canonical identity or sameAs evidence is missing;
- require `content-quality-auditor` before any publish-ready, cite-ready, or GEO Score readiness verdict;
- use `domain-authority-auditor` when CITE/domain trust limits citation readiness;
- never treat GEO readiness as observed citation proof; hand off to `/aaron:watch` for measurement.

### `/aaron:watch`

Required GEO drift behavior:

- load due records from `memory/geo-feedback/` when the user asks for GEO drift checks;
- preserve the T+14, T+45, and T+90 measurement model;
- compare observed AI citation behavior against predicted GEO Score;
- record engines checked, evidence source, observed citation count/rate, and confidence;
- update `next_measurement_date` only when the user permits memory writes;
- create a governance signal for `/aaron:evolve` only when cohort-level drift evidence meets the fixed gate;
- treat per-record drift as evidence or an open loop until cohort thresholds are met;
- distinguish ranking/alert monitoring from GEO feedback-loop monitoring in output.

Fixed governance-signal gate: `cohort_sample_size >= 10`, `cohort_mae > 15`,
and `evidence_mode != no_tool_estimate`. `aggregate_threshold_met` may appear in
artifacts only as a derived value from those fields, never as a free assertion.
Any weaker evidence can only produce evidence/open loops, not `draft_evolution_signal`.

Required GEO drift artifact:

```yaml
artifact_type: geo_drift_record
source_ref: string
cohort_id: string | null
cohort_sample_size: integer
cohort_min_n: integer
cohort_mae: number | null
drift_threshold: number
aggregate_threshold_met: boolean  # derived from cohort_sample_size, cohort_mae, and evidence_mode
measurement_window: T+14 | T+45 | T+90 | ad_hoc
engines_checked: [string]
predicted_geo_score: number | null
observed_citation_rate: number | null
drift_delta: number | null
evidence_mode: tool_backed | user_provided | no_tool_estimate
next_measurement_date: string | null
memory_write_requested: boolean
governance_signal: none | draft_evolution_signal
open_loops: [string]
```

### `/aaron:remember`

Required behavior:

- support initialize, query, review, update, promote, demote, archive, cleanup, purge, and feedback-state operations;
- preserve memory-management as the sole writer for memory lifecycle, project wiki, archive, purge, cleanup, and protocol aggregation;
- preserve existing skill-owned writes for user-confirmed WARM artifacts, `memory/audits/content/`, `memory/audits/domain/`, and entity candidates;
- route canonical `memory/entities/<name>.md` profile writes through `entity-optimizer`, not memory-management;
- preserve canonical entity schema and lawful-basis prompts for profile writes;
- distinguish read-only recall from write/update requests;
- require explicit user intent before writing memory artifacts, except protocol-owned auditor veto hot-cache writes;
- allow only `content-quality-auditor` and `domain-authority-auditor` to append one veto marker to `memory/hot-cache.md` without extra confirmation;
- require explicit confirmation and scoped targets for cleanup, purge, GDPR, or CCPA erasure requests;
- preserve deletion audit notes without retaining erased sensitive content;
- preserve GEO feedback records during ordinary cleanup unless they are out of scope;
- for purge, GDPR, or CCPA erasure, delete or anonymize matching `memory/geo-feedback/`, `memory/wiki/log.md`, `memory/wiki/log-archive/`, and auditor archive records while keeping only non-sensitive audit notes.

Required erasure manifest:

```yaml
artifact_type: memory_erasure_manifest
redacted_matches: [string]
subject_fingerprints: [string]
canonical_paths: [string]
derived_paths: [string]
actions: [delete | anonymize | rebuild | tombstone]
tombstone_path: memory/privacy/tombstones.md
non_sensitive_tombstone: string
reingest_blocked: boolean
```

### `/aaron:evolve`

Required behavior:

- require an explicit `--signal` or equivalent source evidence;
- isolate the signal from proposed implementation;
- classify risk as low, medium, high, or protocol;
- draft affected skills, command routes, evals, and release surfaces;
- produce an EvolutionEvent draft;
- require ADR/decision record for protocol-risk changes;
- remain read-only and proposal-only;
- do not edit files, write memory, change permissions, bump versions, commit, persist state, or accept its own proposal;
- never mark evolution accepted by itself.

### `/aaron:guard`

Modes:

```text
/aaron:guard --evals
/aaron:guard --contracts
/aaron:guard --wiki
/aaron:guard --versions
/aaron:guard --versions --apply
/aaron:guard --release
/aaron:guard --all --strict
```

Rules:

- all modes are read-only by default;
- `--versions` is a dry-run/check mode;
- `--versions --apply` is the only version-sync write path and needs explicit user confirmation;
- guard frontmatter must not preapprove broad write/edit tools for read-only modes;
- guardrail tests must mechanically check allowed tools, non-apply write language, and the narrow apply allowlist;
- `--all --strict` is the maintainer release gate;
- guard must preserve current eval, contract, wiki, version, library, and bash guardrail coverage.

## Artifact Contracts

Commands may render artifacts as Markdown, but downstream commands need stable keys.

### `series_plan`

```yaml
artifact_type: series_plan
status: ready | ready_with_concerns | needs_input
topic: string
audience: string | null
market: string | null
goal: string | null
article_count: integer
articles:
  - order: integer
    slug: string
    title_working: string
    target_keyword: string
    intent: informational | commercial | transactional | navigational | mixed
    content_type: string
    funnel_stage: top | middle | bottom | retention
evidence:
  source_mode: tool_backed | user_provided | no_tool_estimate
  notes: [string]
open_loops: [string]
next_command: /aaron:series
```

### `batch_summary`

```yaml
artifact_type: batch_summary
status: complete | partial | blocked
series_plan_ref: string
run_scope:
  start: integer
  limit: integer
  mode: plan | write | continue | publish_handoff
articles:
  - slug: string
    output_ref: string
    draft_status: drafted | skipped | blocked
    geo_status: done | needs_review | not_run
    internal_links_status: proposed | done | not_run
    audit_status: full_passed | full_failed | rollup_only | not_run
continuation:
  remaining_slugs: [string]
  next_start: integer | null
open_loops: [string]
next_command: /aaron:publish
```

### `publish_package`

```yaml
artifact_type: publish_package
status: ready | ready_with_concerns | blocked
source_ref: string
quality_gate:
  audit_ref: string | null
  audit_scope: per_article_full | page_full | rollup_only | not_run
  gate_verdict: SHIP | FIX | BLOCK | not_run
  veto_state: none | capped | blocked | unknown
  final_score: number | null
  cap_applied: boolean | null
  blockers: [string]
  ready_verdict_allowed: boolean  # publish-package derived from audit fields, not auditor-produced
metadata:
  title: string
  meta_description: string
  canonical: string | null
schema:
  type: string
  status: ready | needs_visible_content | blocked
internal_links:
  status: ready | needs_review | blocked
  notes: [string]
media_map:
  required: [string]
  optional: [string]
cms_mapping:
  platform: generic | advisory
  fields: [string]
  unsupported_fields: [string]
open_loops: [string]
```

## Migration Map

This breaking rename map is for recovery copy and release notes, not aliases.
No `/seo:` command remains callable after implementation.

| Old command | Recommended new call | Behavior difference / old-output mode |
|-------------|----------------------|---------------------------------------|
| `/seo:keyword-research` | `/aaron:discover` | demand/SERP/topic discovery only |
| `/seo:write-content` | `/aaron:write` | one asset; use `/aaron:series` for batches |
| `/seo:audit-page` | `/aaron:audit` | page SEO plus CORE-EEAT gate |
| `/seo:audit-domain` | `/aaron:authority` | CITE/trust/domain authority surface |
| `/seo:check-technical` | `/aaron:tech` | technical-only route |
| `/seo:optimize-meta` | `/aaron:publish --meta` | meta-only mode; full `/aaron:publish` returns a package |
| `/seo:generate-schema` | `/aaron:publish --schema` | schema-only mode; package mode adds quality/internal-link checks |
| `/seo:geo-drift-check` | `/aaron:watch --geo-drift` | preserves due records, T+14/T+45/T+90, evidence, next-measurement semantics |
| `/seo:setup-alert` | `/aaron:watch --alert` | alert setup mode |
| `/seo:report` | `/aaron:report` | report route unchanged in intent |
| `/seo:wiki-lint` | `/aaron:guard --wiki` | deterministic validation mode |
| `/seo:skillify` | `/aaron:skillify` | proposal/review surface |
| `/seo:evolve-skill` | `/aaron:evolve --signal <source>` | keeps signal isolation, risk, validation plan, EvolutionEvent draft |
| `/seo:run-evals` | `/aaron:guard --evals` | validation bundle mode |
| `/seo:contract-lint` | `/aaron:guard --contracts` | contract validation mode |
| `/seo:sync-versions` | `/aaron:guard --versions --apply` | write path only with explicit apply and confirmation |
| `/seo:validate-library` | `/aaron:guard --release` | release gate mode |

New command concepts: `/aaron:auto`, `/aaron:max`, `/aaron:compete`, `/aaron:map`, `/aaron:brief`, `/aaron:series`, `/aaron:refresh`, `/aaron:publish`, `/aaron:visibility`, `/aaron:remember`.

### Breaking Release Requirements

Because no `/seo:` compatibility layer is kept, implementation must ship as a
breaking release:

- release notes, version surfaces, README, Chinese README, marketplace top copy, and host docs must call out "breaking command rename";
- every old command gets a copyable replacement example from the table above;
- old `/seo:*` invocations fail as unavailable/removed commands, with no silent fallback;
- if a host supports an unavailable-command message, it must point users to the migration table and `/aaron:auto`;
- if a host lacks command-not-found copy, provide an `UPGRADE` page and release-top recovery note;
- fallback path: paste the old command and arguments into `/aaron:auto` and ask for the new route;
- external docs and examples pass a repo-wide namespace audit before release;
- rollback instructions list every removed `/seo:*` command file.

### Host Namespace Proof

Implementation cannot start until each host has callable-name evidence:

| Host surface | Required proof |
|--------------|----------------|
| Claude Code / Claude command files | command picker exposes `/aaron:auto`; `/aaron:auto <prompt>` executes; optional `/aaron` alias result recorded |
| ClawHub/OpenClaw | bundle manifest exposes `/aaron:auto`; command inventory displays 20 commands; optional `/aaron` alias result recorded |
| Gemini extension | slash commands not claimed unless host evidence is added; natural-language/context install only |
| Qwen extension | slash commands not claimed unless host evidence is added; natural-language/context install only |
| CodeBuddy | marketplace/command discovery exposes `/aaron:auto`; command inventory display checked; optional `/aaron` alias result recorded |
| Generic Markdown install | README instructions show `/aaron:auto`, optional `/aaron` alias policy, and old-command recovery |

The release gate must include an installed-smoke-check artifact with host,
namespace source, `/aaron:auto` discoverability where slash commands are claimed,
optional `/aaron` alias result, command inventory display, old `/seo:*` recovery
wording, manifest/path touched, upgrade path, and evidence status. Missing root
alias support is not a failure; claiming `/aaron:auto` without command inventory
evidence is release-blocking unless waived.

## Namespace Change

Implementation uses a direct breaking rename:

- `/aaron:` is the only current command namespace.
- `/aaron` root alias is optional host capability and must not be modeled as a `commands/*.md` file or normal eval case.
- `/seo:` commands are removed, not aliased.
- no host-level alias metadata is added.
- no `seo-*` shim files are allowed.
- command inventory remains exactly 20 physical command specs.
- `/seo:` may appear only in migration tables, changelogs, historical release notes, or explicit breaking-change notices.
- current docs, marketplace copy, command specs, and examples must use `/aaron:`.

Natural-language auto-invocation is best-effort and host-dependent. This repo
may optimize command descriptions, manifests, marketplace copy, and routing
policy, but it can only guarantee behavior for explicit `/aaron:auto` calls or
hosts with verified natural-language routing evidence.

## Governance Gates

Every command or route change must be risk-classified before implementation.

| Change | Default risk | Required gate |
|--------|--------------|---------------|
| command description or argument change | medium | proposal review and targeted eval |
| command route across skills | high | `/aaron:skillify`, `/aaron:evolve`, EvolutionEvent draft |
| namespace change | high | migration plan, release notes, guardrail updates |
| auditor verdicts, memory ownership, shared contracts, hooks, guardrails | protocol | ADR or decision record plus protocol validation |

Proposal PR gate:

- include `/aaron:skillify` analysis for command inventory and route ownership;
- include `/aaron:evolve --signal <source>` output or equivalent signal isolation;
- include risk classification, validation plan, and EvolutionEvent/ADR draft.

Implementation PR gate:

- resolver rows, docs, command specs, and release surfaces cannot land from a draft alone;
- high/protocol changes require accepted maintainer or user decision evidence;
- protocol-risk changes require accepted ADR/decision record and cannot use waiver substitution;
- non-protocol namespace/route evidence gaps may use a named waiver with owner, scope, expiry, and validation impact;
- waivers cannot cover auditor verdicts, memory ownership, purge/erasure, publish/audit gates, hooks, guardrails outside line-budget mode, or evolution acceptance;
- no command may self-accept its own evolution proposal.

## Eval Plan

Command routing evals must use the existing `type: eval-case` shape and the current routing guard pattern.

Required placement and fields:

- file: `evals/<target_skill>/cases.md`;
- `id: routing-command-<command>-<scenario>`;
- `status: simulated` or `status: real`;
- `target_skill`;
- expected command route inside `expected_behavior`;
- expected primary skill behavior;
- acceptable handoffs;
- `failure_modes`.

Required command-route coverage:

| Command | Minimum eval target |
|---------|---------------------|
| `/aaron:auto` | resolver-adjacent target skill chosen by scenario |
| `/aaron:max` | resolver-adjacent target skill chosen by scenario |
| `/aaron:discover` | `keyword-research` |
| `/aaron:compete` | `competitor-analysis` |
| `/aaron:map` | `content-gap-analysis` or `internal-linking-optimizer` |
| `/aaron:brief` | `seo-content-writer` |
| `/aaron:write` | `seo-content-writer` |
| `/aaron:series` | `seo-content-writer` |
| `/aaron:refresh` | `content-refresher` |
| `/aaron:publish` | `content-quality-auditor` |
| `/aaron:audit` | `content-quality-auditor` |
| `/aaron:visibility` | `geo-content-optimizer` plus `content-quality-auditor` readiness gate |
| `/aaron:tech` | `technical-seo-checker` |
| `/aaron:authority` | `domain-authority-auditor` |
| `/aaron:watch` | `rank-tracker` or `geo-content-optimizer` |
| `/aaron:report` | `performance-reporter` |
| `/aaron:remember` | `memory-management` |
| `/aaron:skillify` | `memory-management` or governance target chosen by scenario |
| `/aaron:evolve` | `memory-management` |
| `/aaron:guard` | `content-quality-auditor` or governance target chosen by scenario |

Every proposed command needs at least one `routing-command-*` eval unless the
implementation PR includes a documented exemption and a guardrail allowlist.
The guardrail must derive command names from the 20-command inventory and fail
when no `routing-command-<command>-*` eval exists; exemptions require owner,
expiry, and reason.

Any new eval field for command routes is a separate protocol change that must update `evals/README.md`, `/aaron:guard`, `commands/guard.md`, and guardrails together.

## Release Surface And Namespace Audit

Synchronized implementation must update these surfaces: `commands/*.md`;
root/localized docs (`README.md`, `docs/README.zh.md`, `CLAUDE.md`,
`AGENTS.md`, `CONTRIBUTING.md`, `CITATION.cff`, `VERSIONS.md`);
GitHub surfaces (`.github/PULL_REQUEST_TEMPLATE.md`,
`.github/ISSUE_TEMPLATE/*.yml`, `.github/workflows/*.yml`,
`.github/scripts/sync-skills.js`); runtime/marketplace surfaces
(`marketplaces/README.md`, `.mcp.json`, `hooks/hooks.json`,
`.claude-plugin/plugin.json`, `marketplace.json`,
`.claude-plugin/marketplace.json`, `.codebuddy-plugin/marketplace.json`,
`gemini-extension.json`, `openclaw.plugin.json`, `qwen-extension.json`);
runtime docs (`research/**/SKILL.md`, `research/**/references/*.md`,
`build/**/SKILL.md`, `build/**/references/*.md`, `optimize/**/SKILL.md`,
`optimize/**/references/*.md`, `monitor/**/SKILL.md`,
`monitor/**/references/*.md`, `cross-cutting/**/SKILL.md`,
`cross-cutting/**/references/*.md`); governance docs (`evals/README.md`,
`references/skill-resolver.md`, `memory/evolution/README.md`,
`commands/guard.md`, `scripts/validate-slimming-guardrails.sh`,
`.gitignore`, `.docs/README.md`); and any protocol/reference doc containing
live `/seo:` instructions.

Guardrail updates must become authoritative for command inventory. `sync-skills.js --check` may remain in validation, but it is not sufficient for command names, aliases, namespace adoption, or command-count prose.

Required namespace audit:

- scan the repo for `/seo:` before and after migration;
- allowlist only historical changelog, migration table, or explicit deprecation sections;
- fail if live instructions still point at retired `/seo:` commands;
- fail if runtime `SKILL.md` files or skill-local references point at retired `/seo:` commands;
- verify `/aaron:` is canonical in current docs and marketplace copy.
Workflow and script layers must both enforce namespace audit, command inventory,
20-command routing eval coverage, line-budget waiver handling, and skill-route
coverage.

## Line Budget Plan

Line budget is not a design precondition, but current release tooling is a hard
gate. Architecture PRs may treat `validate-slimming-guardrails.sh` as
informational only when the proposal itself still passes or a parser-checkable
temporary waiver exists. Command implementation should either reserve margin
(target counted lines <= 19500 before adding commands/evals/docs) or implement
the waiver path below.

Temporary waiver implementation contract:

```yaml
line_budget_waiver:
  file: references/decisions/command-line-budget-waiver.md
  owner: Aaron or named maintainer
  scope: command architecture implementation only
  expires_on: first command-implementation release or 14 days after merge
  release_behavior: forbidden for final release unless renewed by accepted decision
  validation_mode: AARON_COMMAND_LINE_BUDGET_WAIVER=1 ./scripts/validate-slimming-guardrails.sh
  required_output: waiver id, owner, expiry, counted-line baseline
  required_code_path: require_line_budget_or_waiver
  forbidden_scope:
    - CORE-EEAT protocol changes
    - CITE protocol changes
    - auditor runbook slimming
    - memory ownership changes
    - evolution protocol changes
    - guardrail weakening outside the line-budget check
```

Implementation must add `require_line_budget_or_waiver` to the guardrail or CI
wrapper. It must parse the decision file, owner, expiry, and baseline; require
the explicit environment flag; convert only the line-budget failure to
informational; and keep every other guardrail failure blocking. Release workflow
use is forbidden unless a renewed accepted decision explicitly permits it.

## Implementation Plan

### Phase 0: Preflight

1. Confirm the direct breaking rename to `/aaron:`.
2. Record current command inventory, release surfaces, and line count.
3. Confirm the exact 20 physical command filenames.
4. Complete the host namespace matrix and installed-smoke-check evidence.
5. Do not design or test `/seo:` aliases.

### Phase 1: Command Specs

1. Replace the old command inventory with the 20 commands in this proposal.
2. Keep specs compact, route-focused, and output-first.
3. Make `/aaron:guard` read-only by default.
4. Preserve `/aaron:evolve` as the controlled evolution workflow.
5. Add `/aaron:remember` as the memory lifecycle workflow.
6. Delete old `/seo:` command files rather than adding compatibility shims.

### Phase 2: Resolver, Evals, Release Surfaces

1. Update resolver guidance for command-aware routing.
2. Add routing eval cases using `routing-command-*` IDs.
3. Update docs, manifests, localized README, PR template, and protocol/reference docs.
4. Update guardrails with exact 20-command inventory and namespace assertions.

### Phase 3: Review And Acceptance

1. Run agent-team review focused on command UX, namespace migration, memory/evolution governance, and validation preservation.
2. Fix findings.
3. Run required validations.
4. Prepare PR with migration path, validation evidence, and rollback scope.

## Validation Plan

Required before merging this architecture proposal:

```bash
git diff --check
./scripts/validate-skill.sh --status
```

Informational for this architecture proposal, required again before release
unless maintainers approve a separate waiver:

```bash
./scripts/validate-slimming-guardrails.sh
node .github/scripts/sync-skills.js --check
```

Additional architecture acceptance checks:

- exactly 20 command files exist;
- exactly 20 discovered `SKILL.md` files exist;
- skill paths and skill URLs are unchanged;
- command inventory matches this proposal exactly;
- `/aaron:` is canonical in current docs;
- `/seo:` appears only in allowlisted migration, changelog, historical release note, or breaking-change context;
- no duplicate alias command files exist;
- `/aaron:publish` does not claim direct CMS writes;
- `/aaron:watch` preserves GEO drift feedback persistence semantics;
- `/aaron:guard --versions` is read-only unless `--apply` is explicit;
- `/aaron:guard` read-only modes are protected by parser-checkable allowed-tool and write-language guardrails;
- command-aware evals use `routing-command-*` IDs and current eval-case fields;
- `/aaron` root alias is represented only in host smoke evidence, not command-routing evals;
- guardrails derive the 20 command names and require at least one `routing-command-<command>-*` eval per command, unless an owner/expiry/reason allowlist exists;
- every discovered skill appears in at least one current `/aaron:` command route;
- `publish_package.status: ready` is allowed only when `audit_scope` is `page_full` or `per_article_full`, `gate_verdict: SHIP`, `veto_state: none`, `cap_applied: false`, `ready_verdict_allowed: true`, and `blockers` is empty;
- issue templates and OpenClaw/ClawHub surfaces are audited for retired `/seo:` command examples;
- runtime skill docs and skill-local references are audited for retired `/seo:` command examples;
- breaking release notes explain old-command failure behavior and point to `/aaron:auto`;
- host namespace smoke checks prove `/aaron:*` discoverability before implementation;
- implementation PR includes accepted decision evidence for high/protocol changes; protocol changes cannot use waiver substitution;
- line-budget exemption, when used, is backed by the parser-checkable waiver contract above;
- tracked `.docs` proposals and counted reference pointers are present in `git ls-files` before PR review.

## Rollback Plan

Rollback must be parser-checkable:

1. Record the previous commit or tag before migration.
2. Restore the previous command inventory from that ref.
3. Restore command-count and namespace text in release surfaces.
4. Revert command-aware resolver rows and eval cases.
5. Re-run the same required validations.
6. Do not touch skill directories or historical changelog entries.

Implementation PRs must include this rollback manifest:

```yaml
rollback_manifest:
  previous_ref: string
  old_command_files: [string]
  new_command_files: [string]
  removed_seo_command_files: [string]
  release_surfaces: [string]
  issue_template_files: [string]
  openclaw_surfaces: [string]
  resolver_rows: [string]
  eval_case_ids: [string]
  namespace_audit_allowlist: [string]
  validation_commands: [string]
  guardrail_files: [string]
  ci_workflow_files: [string]
  host_manifest_files: [string]
  line_budget_waiver_file: string | null
  published_artifacts: [string]
  marketplace_rollback_notes: [string]
```

## Recommendation

Proceed after accepting the direct breaking rename to `/aaron:` and the exact
20-file command inventory. The revised architecture is stronger than the
current ad hoc set because it gives users two reliable entrypoints, preserves
expert shortcuts, keeps memory and evolution explicit, and treats SEO, GEO,
content operations, monitoring, reporting, and governance as one Aaron-branded
system. Line-budget slimming should be handled later as its own cleanup phase.
