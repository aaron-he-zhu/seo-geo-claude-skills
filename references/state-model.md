# State Model

Plan C standardizes where reusable project state belongs. All state follows a three-tier temperature model with automatic lifecycle management.

## Temperature Tiers

### HOT — `memory/hot-cache.md`

- Capacity: 80 lines max
- Loaded automatically by SessionStart hook every session
- Content: project goals, hero keywords (max 10), primary competitors (max 5), active veto items, unresolved open loops from `memory/open-loops.md`
- Promotion: **explicit** — the user or a skill pins a finding to HOT ("promote X" / auto-promote of veto items and blockers). No hook counts references, so promotion is never frequency-based.
- Demotion: when the HOT entry's `last_updated` date is older than 30 days — move it out of hot-cache.md; the content remains in its WARM file

### WARM — `memory/<category>/<skill>/`

- Capacity: 200 lines per file
- Loaded on demand when a skill matches the topic
- Paths follow the Durable State definitions below
- Promotion: when the user/skill decides a conclusion is durable, extract it (max 3 lines) to HOT — an explicit action, not a reference counter
- Demotion: when the file's `last_updated` date is older than 90 days — move it to `memory/archive/` with date prefix `YYYY-MM-DD-`

### COLD — `memory/archive/`

- No capacity limit
- Queried only when `memory-management` is explicitly invoked
- Never auto-deleted, only archived
- Filename format: `YYYY-MM-DD-original-filename.md`

### Lifecycle Rules (observable only)

Nothing in the hooks records read/reference counts, so the lifecycle uses only what an agent can
check on disk: an **explicit pin** or a **`last_updated` date**.

```
explicit "promote X" / pin           → WARM promotes to HOT (extract ≤3 lines)
HOT entry last_updated > 30 days      → HOT demotes to WARM
WARM file last_updated > 90 days      → WARM demotes to COLD (archive with YYYY-MM-DD- prefix)
```

### Dual Truncation Rule

HOT tier is limited to 80 lines AND 25KB (whichever triggers first). Truncation occurs at newline boundaries — no mid-line cuts. If exceeded after Claude Write/Edit, the PostToolUse hook warns the user.

### Staleness Protocol

| Age | Treatment |
|-----|-----------|
| ≤7 days | Current — use without caveat |
| 8–30 days | Point-in-time — verify against current state before asserting as fact |
| 31–90 days | Stale — surfaced for review when `memory-management` runs its staleness scan (by `last_updated` date) |
| >90 days | Archive candidate — recommend archival via memory-management |

## Memory File Frontmatter

Every file in `memory/` SHOULD include YAML frontmatter. Two shapes are valid:

**WARM files** — subject matter state (audits, research, decisions, entities, etc.):

```yaml
---
name: campaign-q2-seo
description: Q2 SEO campaign targeting 50 keywords across 3 verticals
type: project
last_updated: 2026-06-10
---
```

Valid `type` values: `project`, `reference`, `decision`, `entity`, `glossary`, `open-loops`, `entity-candidates`

The `description` field enables future semantic search across memory files. **`last_updated`** (a date) is what the demotion/archival rules and `memory-management`'s staleness scan read — write it whenever you create or modify a WARM file. Absent it, fall back to the file's mtime.

**HOT file** (`memory/hot-cache.md`) — session scope declaration:

```yaml
---
tier: hot
project: acme-q2     # null for global scope; set to a project slug to scope memory reads
---
```

When `project` is non-null, the SessionStart hook and `memory-management` preferentially load memory scoped to that project. Switching projects between sessions = swap this field.

## Durable State

### `memory/decisions.md`

Store:

- major strategic choices
- accepted tradeoffs
- abandoned directions worth remembering

### `memory/open-loops.md`

Store:

- unresolved blockers
- missing evidence
- follow-up tasks
- risks that should not be forgotten

### `memory/glossary.md`

Store:

- project terminology
- internal acronyms
- shorthand labels
- segment definitions
- historical naming context

### `memory/entities/`

Store:

- canonical names
- sameAs and profile links
- entity type
- topic associations
- disambiguation notes
- knowledge-base status

Only `entity-optimizer` should write canonical records here. Other skills should keep raw entity leads in their own category notes until canonicalization is needed.

### `memory/research/`

Common subfolders:

- `keywords/`
- `competitors/`
- `serp/`
- `content-gaps/`

Store:

- keyword opportunities
- competitor findings
- SERP notes
- content gap summaries

### `memory/content/`

Common subfolders:

- `briefs/`
- `calendar/`
- `published/`

Store:

- content briefs
- approved angles
- meta tag decisions
- schema notes
- refresh plans

### `memory/audits/`

Common subfolders:

- `content/`
- `domain/`
- `technical/`
- `internal-linking/`

Store:

- audit summaries
- veto items
- prioritized fixes
- pass/fail gate decisions

### `memory/monitoring/`

Common subfolders:

- `rank-history/`
- `reports/`
- `alerts/`
- `snapshots/`

Store:

- ranking deltas
- alert history
- backlink changes
- stakeholder reporting summaries
- dated supporting CSV or export files when helpful

## Writing Guidance

When a skill describes state updates, it should:

- prefer summaries over raw dumps
- distinguish facts from assumptions
- note missing data explicitly
- avoid inventing data when tools are unavailable
- keep raw exports beside the dated summary they support

## Ownership

- `memory-management` is the sole executor of WARM → COLD archival operations
- `entity-optimizer` is the sole writer of canonical records in `memory/entities/<name>.md`
- Other skills write entity candidates to `memory/entities/candidates.md` only
- `content-quality-auditor` owns publish-readiness state in `memory/audits/content/`
- `domain-authority-auditor` owns citation-trust state in `memory/audits/domain/`

See [skill-contract.md](skill-contract.md) for the full protocol-layer vs execution-layer behavior matrix.
