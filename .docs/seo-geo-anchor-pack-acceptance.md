# SEO/GEO Anchor Pack Acceptance

Date: 2026-05-01

Scope: implement, review, repair, and accept the current-repo-only
`slash-aaron` anchor-pack plan in `.docs/seo-geo-anchor-pack-implementation-plan.md`.

## Accepted Decision

This repository is accepted as the candidate SEO/GEO anchor capability pack for
`slash-aaron`.

It is not the global `slash-aaron` product repo. It does not own the first-layer
capability resolver, `slashaaron.com`, product-level registry, future-pack
unsupported evals, or capability-pack manifest schema.

## Implemented Changes

- `README.md` and `docs/README.zh.md` now state that this repository is the
  candidate SEO/GEO anchor capability pack for `slash-aaron`.
- `references/aaron-product-api-contract.md` now defines `/aaron:auto` and
  `/aaron:max` as SEO/GEO pack-local Product API entries.
- `commands/auto.md` now declines clearly non-SEO/GEO work with a pack-boundary
  note unless a verified `slash-aaron` product registry provides another route.
- `commands/max.md` is explicitly limited to SEO/GEO pack-local maximum-depth
  orchestration.
- `CLAUDE.md` and marketplace descriptions now use pack-local / capability-pack
  language instead of broad product-layer language.
- `scripts/validate-slimming-guardrails.sh` now validates
  `distribution/platforms.json` as a constrained support-claim registry:
  platform IDs must be unique, required fields must exist, claim and command
  values must use controlled vocabularies, and `lastVerified` must be a date.

## Review Loop

Three read-only agent reviews were run.

- Boundary review: passed; no P1/P2 findings.
- Phase A acceptance review: initially failed on relative counted-line budget.
  The patch was repaired by compressing README command-section whitespace.
- Validation risk review: found that the platform registry guard was too
  shallow. The guardrail was repaired with constrained registry validation.

## Validation Evidence

Final validation results:

```text
git diff --check
PASS

node .github/scripts/sync-skills.js --check
PASS

bash scripts/validate-skill.sh --status
PASS - all 20 skill versions internally consistent

for each skill directory: bash scripts/validate-skill.sh <dir>
PASS - validated all 20 skills

bash scripts/validate-slimming-guardrails.sh
PASS - 443 passed, 0 failed
Current counted lines: 19993

jq constrained platform registry check
PASS - platform-registry-ok
```

## Acceptance Conditions

Accepted for the working tree.

For PR or release acceptance, the commit must include the required new files
that current validation depends on, especially `distribution/platforms.json` and
the new `evals/*/cases.md` files. A tracked-only PR that omits those files will
not reproduce the local validation result.

## Explicit Non-Scope

The following remain out of scope for this repository:

- creating `slash-aaron`;
- publishing `slashaaron.com`;
- adding `distribution/capability-pack.json`;
- adding `docs/slash-aaron-examples.md`;
- adding unsupported or future-pack eval cases to this repo;
- implementing a cross-pack resolver inside `/aaron:auto`.
