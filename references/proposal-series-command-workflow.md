# Series Command Workflow Proposal

**Status**: superseded — implementation landed as `commands/series.md` in v9.9.9
**Date**: 2026-04-30 (proposal); landed 2026-05-14
**Source**: review of `arawlin/seo-geo-claude-skills-x`
**Scope**: add series planning, batch writing, and publish-package workflows without adding skills or changing existing skill URLs

> **Landed shape (different from this proposal)**: instead of two separate commands `/seo:plan-series` and `/seo:write-series`, the implementation consolidates into **one** command `/aaron:series` with mode flags: `--plan | --write | --continue | --publish-handoff`. See [commands/series.md](../commands/series.md) for the actual landed contract. The two-command split described below is historical context only.

## Executive Summary

The fork adds useful workflow ideas: content-series planning, batch article
generation, image placeholder planning, series finalization, and Strapi-oriented
CMS publishing. The main repository should adopt the workflow value, but not the
fork's skill shape.

This proposal keeps the public skill surface stable:

- Keep exactly 20 skills.
- Do not add, rename, move, or delete skill directories.
- Do not change existing skill GitHub URLs.
- Allow the command inventory to grow from 17 to 20 commands.
- Implement the new workflow as command orchestration over existing skills.

The recommended command additions are:

1. `/seo:plan-series` for topic-to-series research planning.
2. `/seo:write-series` for batch article production from a series plan.
3. `/seo:prepare-publish` for platform-neutral publish-package preparation.

This gives maintainers explicit workflow entrypoints while preserving the
library's 20-skill compatibility contract.

## Goals

1. Absorb the fork's high-value content-series workflow without increasing the
   number of skills.
2. Preserve all existing skill paths and URLs used by marketplace manifests,
   agents, external docs, and users.
3. Add three user-facing commands so the series workflow is discoverable and
   does not overload `/seo:write-content`.
4. Keep publishing platform-neutral; do not make Strapi a required runtime or
   first-class public skill.
5. Extend resolver, eval, docs, and release-surface checks so the new commands
   are reviewable and releasable.
6. Stay within the repository line-budget discipline by extracting only the
   reusable workflow contract, not copying the fork's long docs verbatim.

## Non-Goals

- Do not add `series-research-planner`, `article-batch-generator`,
  `series-content-orchestrator`, `series-finalizer`,
  `seo-image-placeholder`, or `strapi-cms-publisher` as new skills.
- Do not add new skill paths to `.claude-plugin/plugin.json`,
  `marketplace.json`, `.codebuddy-plugin/marketplace.json`, Gemini, Qwen, or
  any marketplace mirror.
- Do not create a Strapi-specific command in the first implementation.
- Do not make Tier 1 behavior depend on Strapi, a CMS API, MCP tools, browser
  capture, crawlers, or network access.
- Do not weaken CORE-EEAT, CITE, auditor runbook, memory, evolution, routing,
  or release-surface guardrails.
- Do not use the new commands to write durable project memory directly; existing
  memory ownership rules still apply.

## Current State

The main repository currently exposes:

- 20 skills across `research/`, `build/`, `optimize/`, `monitor/`, and
  `cross-cutting/`.
- 17 commands under `commands/`.
- A derived routing index in `references/skill-resolver.md`.
- Proposal-only controlled evolution surfaces: `/seo:skillify`,
  `/seo:evolve-skill`, and `/seo:run-evals`.
- Release and slimming checks in `scripts/validate-skill.sh` and
  `scripts/validate-slimming-guardrails.sh`.

The current command set supports single-topic research and single-asset writing,
but it does not provide a clear command-level workflow for:

- turning one topic into a planned multi-article series;
- generating a batch of related articles from one normalized plan;
- producing a final publish package across multiple articles.

The fork explores those workflows by adding new skills. This proposal maps those
capabilities onto the existing main-repo skill set.

## Source Lessons From The Fork

The fork's useful ideas are workflow-level, not necessarily skill-level:

| Fork capability | Useful lesson | Main-repo landing surface |
|-----------------|---------------|---------------------------|
| `series-research-planner` | A series needs a normalized plan before writing starts. | `/seo:plan-series` using existing research skills |
| `article-batch-generator` | Batch writing should use a shared plan, shared links, shared audits, and stable output paths. | `/seo:write-series` using existing build and link skills |
| `series-content-orchestrator` | Users need one entrypoint for a full series workflow. | command chain, not a new skill |
| `series-finalizer` | Delivery artifacts should summarize status, blockers, and publish readiness. | `/seo:prepare-publish` plus content-quality audit output |
| `seo-image-placeholder` | Drafts benefit from explicit visual evidence slots. | `seo-content-writer` and `geo-content-optimizer` instructions |
| `strapi-cms-publisher` | Publish packages need frontmatter, schema, media, taxonomy, and hash discipline. | platform-neutral publish contract, not Strapi-specific skill |

The fork also exposes integration risks:

- new skills were not registered across release surfaces;
- some versions did not align with the plugin version;
- resolver coverage did not include the new skills;
- line count exceeded the main repo budget.

The main repo should therefore adopt the workflow pattern through commands and
small reference updates, not by copying the fork's directory layout.

## Design Principles

1. **Commands orchestrate; skills own capability.**
   Commands route multi-step user workflows. Skills remain the reusable
   capability modules.

2. **No skill URL churn.**
   Existing skill URLs remain stable because external users, marketplaces, and
   agents may reference them directly.

3. **Platform-neutral publishing first.**
   The first implementation prepares publish-ready data. Provider-specific CMS
   writes remain examples or future integrations.

4. **Artifacts over prose.**
   The workflow should define concrete intermediate and final artifacts, even
   when the user does not write files.

5. **Tier 1 remains useful.**
   With no external tools, commands should still produce directional series
   plans, drafts, checklists, and handoff summaries from user-provided inputs.

6. **Line budget is a release constraint.**
   Add compact command specs and focused references. Do not copy large fork docs.

## Proposed Command Inventory Change

Increase command count from 17 to 20 by adding:

```text
commands/plan-series.md
commands/write-series.md
commands/prepare-publish.md
```

No existing command is removed. `/seo:write-content` remains the single-asset
entrypoint. `/seo:write-series` becomes the batch entrypoint.

## Command 1: `/seo:plan-series`

### Purpose

Plan a multi-article content series from one seed topic, audience, market, and
business goal.

### Draft Frontmatter

```yaml
---
name: plan-series
description: Plan a multi-article SEO/GEO content series from one topic, with keyword clusters, SERP intent, competitor gaps, article order, and a normalized series plan.
argument-hint: "<topic> [articles=6] [audience] [market] [goal] [competitors]"
parameters:
  - name: topic
    type: string
    required: true
    description: Seed topic or theme for the content series.
  - name: articles
    type: string
    required: false
    description: Target article count, default 6.
  - name: audience
    type: string
    required: false
    description: Target reader or buyer segment.
  - name: market
    type: string
    required: false
    description: Country, language, city, or service area.
  - name: goal
    type: string
    required: false
    description: Business goal such as traffic, leads, sales, or awareness.
  - name: competitors
    type: string
    required: false
    description: Competitor domains or examples, comma-separated.
---
```

### Route

Primary route:

```text
keyword-research -> serp-analysis -> content-gap-analysis
```

Conditional handoffs:

- Use `competitor-analysis` when competitor domains or competitive share
  questions are present.
- Use `entity-optimizer` when the series depends on unclear brand, product, or
  expert identity.
- Use `memory-management` only through the existing memory handoff when the
  user explicitly asks to persist project context.

### Required Output

Return a normalized series plan with:

- topic, audience, market, goal, assumptions;
- keyword clusters and primary intent per cluster;
- recommended article list with order, slug, target keyword, intent, content
  type, and funnel stage;
- SERP or no-tool evidence notes;
- competitor/content-gap notes;
- internal-linking expectations for the future batch;
- risks and missing inputs;
- next command: `/seo:write-series`.

### Optional File Artifact

When the user asks for files, write or recommend:

```text
<topic_dir>/research/00-series-research.md
<topic_dir>/research/00-series-plan.json
```

The JSON schema should be documented compactly in a reference section or inside
the command file. It should not require a new skill.

## Command 2: `/seo:write-series`

### Purpose

Generate a batch of related SEO/GEO articles from a normalized series plan,
then produce shared internal-linking and quality handoff data.

### Draft Frontmatter

```yaml
---
name: write-series
description: Write a batch of SEO/GEO articles from a series plan, with per-article drafts, GEO blocks, visual evidence slots, internal-link recommendations, and audit handoffs.
argument-hint: "<series plan or topic_dir> [start=1] [limit] [style] [engine]"
parameters:
  - name: plan
    type: string
    required: true
    description: Series plan JSON, topic directory, or pasted plan.
  - name: start
    type: string
    required: false
    description: Optional starting article number.
  - name: limit
    type: string
    required: false
    description: Optional maximum number of articles to generate in this run.
  - name: style
    type: string
    required: false
    description: Tone, format, or editorial style.
  - name: engine
    type: string
    required: false
    description: Target AI/search surface such as AI Overviews, ChatGPT, Perplexity, Gemini, or Google.
---
```

### Route

Primary route:

```text
seo-content-writer -> geo-content-optimizer -> internal-linking-optimizer
```

Required quality gate:

```text
content-quality-auditor
```

The auditor may run per article or as a batch rollup, depending on requested
depth and token budget.

### Existing Skill Extensions

Update existing skill instructions, not skill paths:

- `seo-content-writer`: add "series batch mode" and a compact output contract
  for multiple articles.
- `geo-content-optimizer`: add batch-aware GEO checks and visual proof checks.
- `internal-linking-optimizer`: add "series cross-link matrix" mode.
- `content-quality-auditor`: add "batch audit rollup" mode.

### Required Output

Return:

- article drafts or file paths for each requested article;
- each article's title, meta description, H1, outline, FAQ, and CTA;
- GEO citation blocks and source/evidence gaps;
- visual evidence slots with placement, capture target, and purpose;
- internal-link matrix with source, target, anchor, and priority;
- per-article quality status;
- batch summary and unresolved blockers;
- next command: `/seo:prepare-publish`.

### Optional File Artifact

When the user asks for files, write or recommend:

```text
<topic_dir>/articles/NN-slug.md
<topic_dir>/delivery/internal-links/NN-slug.links.md
<topic_dir>/delivery/audits/NN-slug.audit.json
<topic_dir>/delivery/50-batch-summary.md
```

The command should not assume the files exist unless it has read or written
them in the current workflow.

## Command 3: `/seo:prepare-publish`

### Purpose

Prepare a platform-neutral publish package for one article or a series. This
command should produce the data a human or external integration needs before
CMS upload, without directly writing to a CMS.

### Draft Frontmatter

```yaml
---
name: prepare-publish
description: Prepare a publish-ready SEO/GEO package with quality verdict, metadata, schema, frontmatter, media map, internal-link checklist, and CMS-neutral field mapping.
argument-hint: "<article, series dir, or batch summary> [platform] [strict]"
parameters:
  - name: source
    type: string
    required: true
    description: Article, content bundle, series directory, or batch summary.
  - name: platform
    type: string
    required: false
    description: Optional target platform name for advisory field mapping only.
  - name: strict
    type: boolean
    required: false
    description: Treat missing required publish data as blocking.
---
```

### Route

Primary route:

```text
content-quality-auditor -> meta-tags-optimizer -> schema-markup-generator
```

Conditional handoffs:

- Use `technical-seo-checker` when crawlability, rendering, canonical,
  sitemap, or structured-data deployment risks are present.
- Use `internal-linking-optimizer` when links are missing or unresolved.
- Use `geo-content-optimizer` when AI citation readiness is still weak.
- Use `performance-reporter` only after publication or when reporting context
  already exists.

### Required Output

Return:

- publish readiness verdict: ready, ready with concerns, blocked;
- blocking issues and non-blocking improvements;
- title, meta description, canonical guidance, Open Graph/Twitter fields;
- JSON-LD or schema requirements;
- frontmatter recommendation;
- media map and visual evidence capture list;
- internal-link checklist;
- category/tag suggestions;
- source/evidence freshness notes;
- optional content hash recommendation;
- CMS-neutral field mapping;
- rollback or update notes for existing content.

### Provider-Specific Boundary

If the user asks for Strapi, WordPress, Webflow, Sanity, or another CMS, the
command may provide an advisory field map. It must not claim direct write
support unless the connected runtime, credentials, and user confirmation are
available outside the command spec.

Do not add `/seo:strapi-publish` in this phase. Strapi can be documented later
as an example provider if real user evidence shows repeated need.

## Existing Skill Changes

No skill directories are added. Existing skills receive compact mode additions:

| Existing skill | New responsibility | Change type |
|----------------|--------------------|-------------|
| `keyword-research` | cluster seed terms for series planning | instructions and triggers |
| `serp-analysis` | validate article-level SERP intent within a series | instructions |
| `competitor-analysis` | detect competitor series and coverage depth | instructions |
| `content-gap-analysis` | produce article backlog and gap-priority map | instructions |
| `seo-content-writer` | batch draft from series plan | instructions and reference |
| `geo-content-optimizer` | batch GEO checks and visual proof slots | instructions |
| `internal-linking-optimizer` | series cross-link matrix | instructions and reference |
| `content-quality-auditor` | batch audit rollup and publish verdict | instructions |
| `meta-tags-optimizer` | batch metadata review for publish packages | instructions |
| `schema-markup-generator` | visible-content-matched schema package | instructions |
| `technical-seo-checker` | optional deployment-readiness checks | handoff note |

Descriptions and triggers should change only when they improve discovery for
existing skill responsibilities. Do not add trigger language that implies a new
skill URL.

## Resolver Updates

Update `references/skill-resolver.md` with command-aware rows or notes for:

| User intent | Command route | Primary skill route |
|-------------|---------------|---------------------|
| Plan a content series | `/seo:plan-series` | `keyword-research` and `content-gap-analysis` |
| Generate a batch of articles | `/seo:write-series` | `seo-content-writer` |
| Build a series internal-link plan | `/seo:write-series` or direct skill use | `internal-linking-optimizer` |
| Prepare publish package | `/seo:prepare-publish` | `content-quality-auditor` |
| Publish to a CMS | `/seo:prepare-publish` advisory only | no direct CMS skill |

Resolver language should explicitly state that the new commands are workflow
entrypoints, not new skill routes.

## Eval Plan

Add simulated eval cases using the existing `type: eval-case` contract. Do not
create a new eval framework.

Recommended initial cases:

1. `keyword-research`: user asks for "plan a 6 article topic cluster".
2. `content-gap-analysis`: user asks for "what articles are missing compared
   with competitors".
3. `seo-content-writer`: user provides a series plan and asks for batch drafts.
4. `geo-content-optimizer`: user asks to make the batch more likely to be cited
   by AI systems.
5. `internal-linking-optimizer`: user asks for links between all articles in a
   generated series.
6. `content-quality-auditor`: user asks whether a batch is ready to publish.
7. `schema-markup-generator`: user asks for schema across a batch.
8. `meta-tags-optimizer`: user asks for metadata for every article.

Each case should include:

- `target_skill`;
- expected command route when relevant;
- expected primary skill behavior;
- acceptable handoffs;
- failure modes such as routing to a nonexistent skill or claiming direct CMS
  write support.

## Release Surface Updates

Adding three commands requires synchronized updates to:

- `README.md`;
- `docs/README.zh.md`;
- `CLAUDE.md`;
- `AGENTS.md`;
- `CITATION.cff`;
- `VERSIONS.md`;
- `.claude-plugin/plugin.json`;
- `marketplace.json`;
- `.claude-plugin/marketplace.json`;
- `.codebuddy-plugin/marketplace.json`;
- `gemini-extension.json`;
- `qwen-extension.json`;
- `commands/validate-library.md`;
- `scripts/validate-slimming-guardrails.sh`;
- any command inventory tests or command-count text.

The public description should change from "20 SEO/GEO skills and 17 commands"
to "20 SEO/GEO skills and 20 commands" only after all command files and
inventory surfaces are synchronized.

Historical changelog entries must remain historical. Do not rewrite older
release records except where a guardrail explicitly expects current-state text.

## Line Budget Plan

This proposal adds command capability and reference text, so implementation
must preserve line-budget discipline.

Recommended controls:

1. Keep each new command file compact: target 80 lines or fewer.
2. Prefer shared output contracts over repeated examples in each command.
3. Add one compact reference section only if command files become too long.
4. Do not copy fork reference files wholesale.
5. After implementation, run the line-budget guardrail and slim ordinary
   examples before touching protocol, auditor, or guardrail logic.

Target: keep counted lines below the repository guardrail threshold after the
full change lands.

## Implementation Plan

### Phase 1: Proposal Review

1. Review this proposal.
2. Decide whether the three-command shape is acceptable.
3. Confirm that Strapi remains provider-specific advisory output, not a public
   command or skill.

### Phase 2: Command Specs

1. Add `commands/plan-series.md`.
2. Add `commands/write-series.md`.
3. Add `commands/prepare-publish.md`.
4. Keep command specs read-oriented and workflow-oriented; no extra
   `allowed-tools` unless a command truly requires them.

### Phase 3: Existing Skill Mode Updates

1. Add compact series planning language to research skills.
2. Add batch drafting and visual evidence slots to `seo-content-writer`.
3. Add batch GEO and visual proof checks to `geo-content-optimizer`.
4. Add series cross-link matrix language to `internal-linking-optimizer`.
5. Add batch audit and publish-package verdict language to
   `content-quality-auditor`.

### Phase 4: Resolver And Evals

1. Update `references/skill-resolver.md`.
2. Add simulated routing and workflow eval cases to existing target skill eval
   files.
3. Update `/seo:run-evals` or `/seo:validate-library` docs only as needed to
   describe the new command-aware cases.

### Phase 5: Release Surface Sync

1. Update all command inventory surfaces from 17 to 20.
2. Update version and release notes only when the implementation is ready for a
   release candidate.
3. Run synchronization checks for plugin and marketplace files.

### Phase 6: Review, Fix, And Acceptance

1. Run targeted review on command routing and no-new-skill constraints.
2. Fix review findings.
3. Run required validations.
4. Prepare a PR with the proposal, implementation summary, validation evidence,
   and rollback scope.

## Validation Plan

Required validation before merge:

```bash
git diff --check
./scripts/validate-skill.sh --status
./scripts/validate-slimming-guardrails.sh
node .github/scripts/sync-skills.js --check
```

Additional checks:

- Confirm the discovered skill count remains 20.
- Confirm `.claude-plugin/plugin.json` skill paths are unchanged.
- Confirm all existing skill URLs still resolve to the same paths.
- Confirm command count is 20 in README, localized README, CLAUDE, AGENTS,
  CITATION, manifests, marketplaces, and guardrails.
- Confirm no new skill directory exists for the six fork-only skills.
- Confirm no command claims direct CMS write support without explicit runtime
  integration and user confirmation.
- Confirm `/seo:skillify` remains proposal-only and read-only.

## Acceptance Criteria

The implementation is acceptable when:

- the repository still has exactly 20 discovered `SKILL.md` files;
- no existing skill directory has been renamed, moved, or removed;
- no manifest skill path has been added or changed;
- exactly three command files were added, bringing the command inventory to 20;
- the new commands route only to existing skills;
- release surfaces consistently describe 20 skills and 20 commands;
- resolver rows distinguish command workflows from skill ownership;
- simulated eval cases cover planning, writing, linking, quality, metadata,
  schema, and publish-package preparation;
- validation passes;
- line-budget guardrails pass.

## Risks And Mitigations

| Risk | Mitigation |
|------|------------|
| Commands duplicate skill instructions | Keep commands as routers and put capability detail in existing skills. |
| `write-series` becomes too broad | Use `plan-series` and `prepare-publish` as boundaries; keep `write-series` focused on batch draft production and handoff. |
| Publishing becomes CMS-specific | Keep `/seo:prepare-publish` platform-neutral; document provider maps as advisory only. |
| Line count exceeds budget | Compact command specs, avoid copied fork docs, slim ordinary examples if needed. |
| Routing ambiguity increases | Update resolver and add command-aware eval cases. |
| Release surfaces drift | Update guardrails to assert 20-command inventory consistently. |

## Rollback Plan

If the workflow causes routing drift, line-budget failure, or release-surface
instability:

1. Revert the three command files.
2. Revert command-count updates in release surfaces.
3. Revert resolver rows and command-aware eval cases.
4. Keep any independently useful wording improvements to existing skills only
   if they pass validation and do not imply the removed commands.

Rollback should not touch existing skill paths or historical changelog entries.

## Open Questions

1. Should `series_plan` be documented as a JSON schema in a compact reference,
   or only as a command output template?
2. Should `/seo:prepare-publish` support a `platform` parameter from day one, or
   should provider mapping remain prose-only until real demand appears?
3. Should batch quality auditing require full CORE-EEAT on every article, or
   allow a quick rollup plus targeted full audits for high-risk pages?
4. Should visual evidence slots be required for all generated articles, or only
   when the topic involves trust, UI proof, comparisons, procedures, or claims?

## Recommendation

Proceed with the three-command design after review. It captures the fork's
highest-value workflow ideas while preserving the main repository's stable
20-skill surface. The first implementation should be conservative: command
specs, compact skill-mode updates, resolver rows, simulated eval cases, and
strict release-surface synchronization.
