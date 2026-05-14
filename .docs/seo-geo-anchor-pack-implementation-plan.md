# SEO/GEO Anchor Pack Implementation Plan

**Status**: draft implementation plan
**Date**: 2026-05-01
**Scope**: current repository only
**Target repo**: `seo-geo-claude-skills`

## 1. Decision

This repository should become the **SEO/GEO anchor capability pack** for
`slash-aaron`.

It should not become the whole `slash-aaron` product layer. It should not own
global capability routing, the website, future-pack examples, unsupported-case
evals, or product-level registries.

The current repo keeps its professional identity:

```text
20 SEO/GEO skills
20 /aaron:* pack-local commands
SEO/GEO references, evals, quality gates, and platform evidence
```

The only product relationship this repo should expose is:

```text
This repository is the candidate SEO/GEO anchor capability pack for slash-aaron.
```

## 2. Goals

- Position this project as the first candidate anchor `slash-aaron` capability
  pack until the product repo schema and verifier exist.
- Preserve all existing SEO/GEO skill behavior, command inventory, release
  surfaces, and platform evidence.
- Keep `/aaron:auto` and `/aaron:max` pack-local, not global capability
  selectors.
- Prepare for a future `distribution/capability-pack.json` without adding it
  before schema, CI, package-surface, and line-budget prerequisites exist.
- Avoid any counted-line growth unless it is offset in the same PR.

## 3. Non-Goals

Do not add any of these to the current repo:

- `slash-aaron` website files;
- product-level `capability resolver`;
- product-level `registry/capabilities.json`;
- a second platform registry;
- `registry/platforms.json`;
- future dev/writing/ops/research pack examples;
- unsupported/future-pack eval cases;
- `docs/slash-aaron-examples.md`;
- non-SEO/GEO pack runbooks, validators, manifests, or examples.

## 4. Hard Constraints

### 4.1 Line Budget

The current repo is already near the release guardrail ceiling. Any
release-bearing PR for this plan must be net counted lines `<= 0`, unless a
separate slimming PR first creates budget.

Practical rule:

```text
No new counted files in docs/, evals/, distribution/, references/, commands/,
README, or manifest surfaces unless the same PR deletes/compresses more counted
lines than it adds.
```

`.docs/` may carry planning documents, but `.docs/` is not a substitute for
release-bearing manifests or validation.

### 4.2 Routing Boundary

Global capability selection belongs to the future `slash-aaron` repo.

This repo owns only:

```text
natural language SEO/GEO request -> SEO/GEO pack-local resolver -> SEO/GEO skill/command chain
```

It must not own:

```text
natural language request -> any future pack -> global route selection
```

### 4.3 Platform Truth

Platform and host support claims remain authoritative in:

```text
distribution/platforms.json
```

No new file in this repo should restate per-host support as a second source of
truth. Future `slash-aaron` registries should derive or link to this file.

## 5. Immediate Current-Repo Changes

These are the only changes that should happen before the new `slash-aaron`
schema exists.

### 5.1 README Copy

Files:

```text
README.md
docs/README.zh.md
```

Change type: in-place wording, no new section unless offset.

English copy:

```text
This repository is the candidate SEO/GEO anchor capability pack for slash-aaron.
```

Chinese copy:

```text
本仓库是 slash-aaron 的候选 SEO/GEO anchor 能力包。
```

Do not add public links to `slashaaron.com` or
`github.com/aaron-he-zhu/slash-aaron` until those surfaces exist.

### 5.2 Product API Contract Boundary

File:

```text
references/aaron-product-api-contract.md
```

Change the contract from global language to pack-local language:

```text
/aaron:auto runs the SEO/GEO pack-local workflow.
Cross-pack capability selection belongs to the slash-aaron product repo.
If a request is clearly outside SEO/GEO, this pack should decline rather than
route into a fake SEO/GEO workflow. It may point to slash-aaron only after the
product repo exists.
```

Do not say `/aaron:auto` first selects a capability pack inside this repo.

### 5.3 Auto / Max Command Copy

Files:

```text
commands/auto.md
commands/max.md
```

Keep both commands SEO/GEO pack-local.

Recommended replacement for current SEO/GEO-only phrasing:

```text
Run the end-to-end SEO/GEO capability-pack workflow implied by a
natural-language goal, using the smallest safe depth.
```

For out-of-pack requests, add a concise decline rule only if it can replace
existing prose without increasing counted lines:

```text
If the request is clearly outside SEO/GEO, stop and say this pack cannot claim
execution support for that work. Do not name another pack unless slash-aaron has
a verified product-registry entry for it.
```

Do not make these files global selectors for dev, writing, ops, research, or
future packs.

## 6. Deferred Manifest Track

Do not add this file yet:

```text
distribution/capability-pack.json
```

Add it only after all prerequisites below are true.

### 6.1 Prerequisites

- `slash-aaron` repo exists.
- `slash-aaron/schemas/capability-pack.schema.json` exists.
- The schema has a pinned version.
- This repo has line budget or a same-PR offset.
- The manifest package-surface decision is explicit: shipped intentionally or
  explicitly excluded.
- Current repo validation checks parse and validate the manifest.
- CI watches the manifest and validation script.

### 6.2 Required Manifest Fields

The manifest must be schema-validated and include at least:

- `schemaVersion`;
- `packVersion`;
- `id`;
- `name`;
- `product`;
- `repo`;
- `manifestPath`;
- `resolver`;
- `entrypoints`;
- `commands`;
- `skills`;
- `scope`;
- `artifacts`;
- `qualityGates`;
- `approvalGates`;
- `unsupportedClaims`;
- `validation`;
- `distribution`;
- `evidence`.

Counts such as `"skills": 20` or `"commands": 20` are not enough. The manifest
must provide stable IDs and paths so the product layer can validate and render
the pack safely.

Canonical values and shapes for this repo:

- `id`: `seo-geo`;
- `product`: `slash-aaron`;
- `repo`: `https://github.com/aaron-he-zhu/seo-geo-claude-skills`;
- `resolver.type`: `pack-local`;
- `resolver.path`: `references/skill-resolver.md`;
- `entrypoints.default.slash`: `/aaron:auto`;
- `entrypoints.maxDepth.slash`: `/aaron:max`;
- command IDs use the `seo-geo.<command>` namespace;
- skill IDs match current skill directory names;
- version source is existing release metadata, not a new version authority;
- `distribution.platformsSource` points to `distribution/platforms.json`;
- `distribution` and `evidence` may reference platform IDs and evidence paths,
  but must not embed copied per-host support claims.

The manifest is an export, not a new source of truth. Commands, skills,
versions, platform claims, and quality references must be generated from or
checked against the existing repo-local sources they summarize.

### 6.3 Approval Gates

Approval gates must be objects, not strings. Each gate needs:

- `id`;
- trigger conditions;
- default dry-run behavior;
- required confirmation shape;
- approved scope;
- affected surface;
- non-grant words such as `apply`, `publish`, `fix`, `send`, `launch`;
- logging rule;
- rollback or recovery plan.

Positive approval must be scoped. A valid approval names the action, surface,
target scope, and time-bounded permission. Vague words such as `apply`,
`publish`, `fix`, `send`, or `launch` remain non-approval unless paired with the
required scoped confirmation.

## 7. Eval Boundaries

Do not put non-SEO/GEO future-pack cases into:

```text
evals/product-api-scenarios.md
```

That file currently expects real current `target_skill` values and existing
`/aaron:*` routes.

Future unsupported/future-pack routing cases belong in the new product repo:

```text
slash-aaron/evals/capability-routing-scenarios.md
```

Only add pack-local unsupported behavior here after this repo has an explicit
unsupported-case schema and guardrail support.

## 8. Package And Platform Surface

If `distribution/capability-pack.json` is later added, decide whether it ships
with public bundles.

If shipped:

- validate it in guardrails;
- keep private or operational data out of it;
- include it intentionally in ClawHub/package expectations;
- assert it is included by the public bundle check;
- derive host support from `distribution/platforms.json`.

If excluded:

- add the exclusion explicitly to package config;
- assert the exclusion in the public bundle check;
- document how `slash-aaron` retrieves the manifest by immutable source;
- avoid stale local-only data.

Private or operational data is forbidden in both shipped and excluded manifest
paths. Live outreach prospects, contact data, CRM exports, analytics
identifiers, private evidence, and operational notes stay behind private
boundaries such as `.docs/outreach/` and must not appear in a manifest consumed
by `slash-aaron`.

The retrieval contract for an excluded manifest must be immutable and versioned:

- source type, such as release asset, package artifact, or tagged repository
  blob;
- release tag or package version;
- manifest path;
- schemaVersion;
- checksum or equivalent integrity check;
- validation owner.

## 9. Implementation Phases

### Phase A: Copy Boundary Patch

Current repo only.

1. Update `README.md` and `docs/README.zh.md` with anchor-pack relationship.
2. Update `references/aaron-product-api-contract.md` to say global routing
   belongs to `slash-aaron`.
3. Update `commands/auto.md` and `commands/max.md` to stay SEO/GEO pack-local.
4. Sweep `CLAUDE.md`, `AGENTS.md`, marketplace copy, plugin descriptions, and
   manifests for stale product-level routing language; update only if needed
   and with a same-PR line offset.
5. Keep net counted lines `<= 0`.
6. Run validation and attach net-line evidence.

### Phase B: New Product Repo Prerequisite

Not in this repo.

Creating or publishing `slash-aaron` is an external product action. It requires
explicit user approval before repo creation, website publication, registry
publication, or any public support claim. Default to dry-run planning until that
approval exists.

1. Create `slash-aaron`.
2. Add `schemas/capability-pack.schema.json`.
3. Add `registry/capabilities.json`.
4. Add `product/routing-contract.md`.
5. Add `product/approval-gates.md`.
6. Add `evals/capability-routing-scenarios.md`.
7. Add `examples/seo-geo.md`.

Phase B is accepted before Phase C only when:

- registry entries reference this pack; they do not duplicate its commands,
  skills, platform support, or quality gates;
- no per-host support state is restated outside `distribution/platforms.json`;
- SEO/GEO requests route into this pack-local resolver;
- non-SEO/GEO requests do not route into this pack;
- unsupported/future-pack examples stay in `slash-aaron`;
- if `distribution/capability-pack.json` does not exist yet, the registry entry
  is explicitly provisional and does not claim manifest-backed verification.

### Phase C: Manifest PR

Current repo, only after Phase B.

1. Add `distribution/capability-pack.json`.
2. Add schema validation.
3. Update guardrails.
4. Update CI watch paths.
5. Decide and validate package surface.
6. Keep net counted lines within budget.
7. Run full validation.

Phase C must name concrete hooks, not prose-only intent:

- `scripts/validate-slimming-guardrails.sh` parses JSON, validates the pinned
  schema, checks source-of-truth consistency, and verifies package behavior;
- `.github/workflows/validate-skill.yml` watches `distribution/**`, schema lock
  files, validation scripts, `.clawhubignore`, and package workflow changes;
- `.github/workflows/clawhub-publish.yml` or its preflight validates whether the
  manifest is intentionally included or excluded from the public bundle;
- the schema source is pinned by version and checksum, or vendored with an
  explicit update procedure.

## 10. Validation

Phase A must run:

```bash
git diff --check
node .github/scripts/sync-skills.js --check
bash scripts/validate-skill.sh --status
bash scripts/validate-slimming-guardrails.sh
```

Phase A must also attach line-budget delta evidence:

```text
base_count: counted lines on target branch
current_count: counted lines after this PR
requirement: current_count <= base_count
```

The existing absolute guardrail is not enough for Phase A because it permits a
small positive delta while the repo remains below 20000.

Phase C must also run:

```bash
jq -e . distribution/capability-pack.json
# schema validation using the pinned slash-aaron schema version/checksum
# guardrail validation for source-of-truth consistency and package behavior
# package-surface validation for ClawHub/public bundle inclusion or exclusion
```

## 11. Acceptance Criteria

Phase A is accepted when:

- the repo is described as the candidate SEO/GEO anchor capability pack until
  slash-aaron verification exists;
- `/aaron:auto` and `/aaron:max` remain pack-local;
- global capability routing is not assigned to this repo;
- no future-pack examples or unsupported evals are added here;
- platform support remains in `distribution/platforms.json`;
- counted lines stay below the guardrail and do not increase versus the target
  branch;
- validation passes.

Phase C is accepted only when:

- `distribution/capability-pack.json` validates against schema;
- manifest fields are machine-readable, not prose-only;
- approval gates are enforceable objects;
- host support claims are derived from `distribution/platforms.json`;
- CI watches the manifest;
- package behavior is explicit;
- validation passes.

## 12. Final Boundary

This repo should answer:

```text
How does /aaron execute SEO/GEO work safely and well?
```

It should not answer:

```text
How does /aaron route every possible professional task?
```

That second question belongs to the new `slash-aaron` product repo.
