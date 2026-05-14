---
name: guard
description: "Run deterministic maintainer validation for evals, contracts, wiki, versions, command inventory, release surfaces, and guardrails. Not sure? Use /aaron:auto."
argument-hint: "--inventory|--evals|--contracts|--wiki [--fix] [--project <name>] [--retire-preview [--bulk-confirmed] [--max-today=<K>]] [--show-deferred]|--versions [--apply]|--release|--all --strict"
allowed-tools: ["Read", "Glob", "Grep"]
parameters:
  - name: mode
    type: string
    required: true
    description: "Validation mode: inventory, evals, contracts, wiki, versions, release, all"
  - name: apply
    type: boolean
    required: false
    description: "Only with --versions; requires explicit confirmation before writes"
  - name: fix
    type: boolean
    required: false
    description: "Only with --wiki. Auto-resolve HIGH-confidence contradictions only (time-series). MEDIUM/LOW require user confirmation via SessionStart prompt."
  - name: project
    type: string
    required: false
    description: "Only with --wiki. Limit lint to a specific project. Defaults to active project from hot-cache."
  - name: retire-preview
    type: boolean
    required: false
    description: "Only with --wiki. Phase 3 dry-run: list WARM files fully covered by compiled wiki pages. Outputs candidates table only, never moves files. Retirement requires explicit memory-management invocation after preview confirmation."
  - name: show-deferred
    type: boolean
    required: false
    description: "Only with --wiki (v9.9.9+). Add a Deferred Contradictions table to the lint output listing snoozed/ignored entries from .unresolved.md with their defer-until dates and resolution-override syntax. Default behavior (without flag) shows deferred entries only as a count line."
  - name: bulk-confirmed
    type: boolean
    required: false
    description: "Only with --wiki --retire-preview (v9.9.9+). Bulk backlog mode: retires ALL safe-marked candidates in one operation with a single summary confirmation. Per-file C1-C5 checks still run at retire time. Day-cap (20/UTC-day) still applies. Useful for users with accumulated WARM backlog where the steady-state 5/call cap is impractical. Default behavior (without flag) requires per-batch confirmation."
  - name: max-today
    type: string
    required: false
    description: "Only with --wiki --retire-preview --bulk-confirmed (v9.9.9+). Caps the bulk retire at K files for today, where K = remaining day budget. Use when --bulk-confirmed would otherwise exceed the 20/UTC-day cap. Example: --max-today=15 retires up to 15 safe candidates today, defers the rest."
---

# Guard Command

Run deterministic maintainer validation for evals, contracts, wiki, versions, command inventory, release surfaces, and guardrails.

## Route

- validation scripts
- governance references

## Rules

- All modes are read-only by default. `--versions` is a dry-run/check mode.
- `--versions --apply` is the only version-sync write path and requires explicit user confirmation plus an edit-enabled runtime.
- Run eval checks, contract checks, wiki lint, version drift checks, command inventory checks, namespace audit, release surface checks, and slimming guardrails as requested.
- Simulated eval passes are regression evidence only; they do not make an EvolutionEvent acceptance-eligible by themselves.
- Emit `validation_results` for eval or release review.

### `--contracts` mode coverage (v10.1.x; Runbook 1.2+)

`--contracts` orchestrates `bash scripts/validate-skill.sh` against both auditor skills plus the auditor-runbook hash manifest. Specifically, it confirms:

- `source_sha256` and `block_sha256` in both auditor SKILL.md files match the live `references/auditor-runbook.md` (drift detection)
- `references/contract-fail-caps.md` Cap Table severity column maps `veto -> P0`, `high -> P1`, `medium`/`low -> P2`
- `references/auditor-runbook.md` Section 6 Lint Coverage Manifest enumerates the same forbidden user-output substrings that this command's prompt advertises (no manifest drift)

## Wiki Mode

Scans `memory/wiki/` compiled pages and `memory/` WARM files for inconsistencies. Sub-flags: `--fix` (auto-resolve HIGH-confidence contradictions), `--project <name>` (scope to one project), `--retire-preview` (Phase 3 retirement candidate dry-run, see Retire-Preview Mode below).

### Workflow

0. **Empty-state check** (v9.9.9+): if `memory/wiki/` directory does not exist OR contains zero compiled pages (only the auto-managed `index.md`), print: `"Wiki layer not initialized. Run 'compile a wiki page on X' (memory-management) once to bootstrap. See cross-cutting/memory-management/references/wiki-runbook.md §1 for triggers and ≥3-WARM-source precondition."` and exit. Do NOT run any of the 7 checks against an empty wiki.
1. Glob `memory/wiki/*.md` (filter by `--project` if set; default to active project from hot-cache, fall back to global)
2. Build WARM index: `find memory -name '*.md' -not -path 'memory/wiki/*' -not -path 'memory/archive/*'`, map entity → path + hash
3. Contradiction scan: compare claim values across pages/WARM for same entity
4. Stale claim scan: recompute `shasum -a 256 <file> | cut -c1-8` vs `sources[].hash` in each wiki page
5. Orphan detection: build inbound-link index, flag pages with zero inlinks
6. Missing page detection: flag entities mentioned 3+ times with no dedicated page
7. Cross-reference gaps: flag page pairs sharing topics without reciprocal links
8. HOT drift: compare `memory/hot-cache.md` values against wiki pages
9. Hash recheck: re-run step 4 to catch mid-scan file changes
10. Report: output structured results (see Output Format below — includes per-entry resolution prompts for unresolved contradictions), append to `memory/wiki/log.md`; clear `memory/wiki/.drift-log` on completion

### Checks Performed

| Check | Description | Auto-fixable |
|-------|-------------|-------------|
| **Contradiction** | Two wiki/WARM files assert conflicting facts about same entity | HIGH only (time-series: use latest + changelog) |
| **Stale claim** | Wiki page cites WARM file whose source hash changed | Yes (re-compile) |
| **Orphan page** | Wiki page with zero inbound links | No (suggest deletion/linking) |
| **Missing page** | Entity mentioned 3+ times but has no page | No (suggest creation) |
| **Missing cross-ref** | Two pages discuss same topic without linking | Yes (add link) |
| **HOT drift** | hot-cache.md references entity whose wiki page changed | No (suggest HOT update) |
| **Hash mismatch** | Compiled page `sources[].hash` differs from current WARM content | Yes (re-compile) |

### Contradiction Resolution

- **HIGH**: Time-series data — auto-use latest value, preserve older values in compiled page changelog section. Auto-applied with `--fix`; otherwise reports "auto-resolved by recency".
- **MEDIUM**: Semantic ambiguity, comparable source weight — insert `[CONTRADICTION-{id}]` marker in compiled page body and append entry to `memory/wiki/.unresolved.md`. Surfaced at next SessionStart with `(a) keep A · (b) keep B · (s) snooze 7d · (i) ignore for 90d` prompt; never auto-resolved.
- **LOW**: Insufficient evidence, fundamental conflict — both values written side-by-side with `[CONTRADICTION-{id}]` marker. Same `.unresolved.md` flow as MEDIUM. Never auto-resolved even with `--fix`.

### Output Format

```markdown
## Wiki Lint Report — [project] (YYYY-MM-DD)

### Unresolved Contradictions
For each entry in `memory/wiki/.unresolved.md` with `snoozed_until` in past (UTC) AND `ignored_until` in past (UTC) OR null:

| ID | Entity | Field | Source A | Source B | Confidence | Created | Action |
|----|--------|-------|----------|----------|------------|---------|--------|
| contradiction-001 | acme-corp | DA | memory/research/competitors/acme.md (=72) | memory/audits/domain/acme-cite.md (=68) | medium | 2026-05-01 | Reply: `resolve contradiction-001 a` (keep A) · `resolve contradiction-001 b` (keep B) · `resolve contradiction-001 s` (snooze 7d) · `resolve contradiction-001 i` (ignore 90d) |

(v9.9.9+) Per-entry resolution syntax: `resolve <id> <a|b|s|i>` — accepted in any conversation turn after this report runs, not just at SessionStart. memory-management routes the resolution per wiki-runbook §5.

**Snoozed/ignored entries** (count only by default): "N entries deferred (snoozed: K, ignored: M). Use `/aaron:guard --wiki --show-deferred` to list explicitly."

**With `--show-deferred`** (v9.9.9+): adds a separate "Deferred Contradictions" table after the active table:

| ID | Entity | Field | Source A | Source B | Defer Type | Defer Until (UTC) | Action |
|----|--------|-------|----------|----------|------------|-------------------|--------|
| contradiction-007 | beta-corp | DA | memory/research/competitors/beta.md (=85) | memory/audits/domain/beta-cite.md (=80) | snoozed | 2026-05-13 | Reply: `resolve contradiction-007 a` (overrides snooze) · `resolve contradiction-007 b` · `resolve contradiction-007 i` (escalate to ignore 90d) |
| contradiction-012 | gamma | name | memory/research/g.md ("Gamma Corp") | memory/entities/gamma.md ("γ Inc.") | ignored | 2026-08-01 | Reply: `resolve contradiction-012 a` · `resolve contradiction-012 b` · `resolve contradiction-012 s` (downgrade to snooze 7d) |

Resolution-override syntax: even when an entry is snoozed/ignored, `resolve <id> <a|b|s|i>` from the user IMMEDIATELY overrides the deferral. Picking `(s)` on a snoozed entry refreshes `snoozed_until` to today+7. Picking `(i)` on a snoozed entry escalates to `ignored_until = today+90` and clears `snoozed_until`. Picking `(a)/(b)` on either deferred state resolves and removes the entry from `.unresolved.md` per §5.3 (overwrite-not-extend semantics).

The flag is read-only — `/aaron:guard --wiki --show-deferred` does NOT modify `.unresolved.md`. Only the user's subsequent `resolve <id> ...` reply (handled by memory-management) changes state.

### Contradictions (N) / Stale Claims (N) / Orphan Pages (N) / Missing Pages (N) / Missing Cross-Refs (N) / HOT Drift (N) / Hash Mismatches (N)
[Each section with relevant table columns]

### Summary
Total checks: N | Issues: N | Auto-fixed: N | Requires user action: N | Unresolved contradictions: N (active) + K (deferred)
```

Results appended to `memory/wiki/log.md` as `## [date] lint <project> issues=N fixed=M unresolved=N`.

## Retire-Preview Mode

Phase 3 dry-run that lists WARM files fully covered by compiled wiki pages. **This command's own execution never moves files** — `allowed-tools` excludes Bash/Write/Edit/Task, so file mutation is structurally impossible from this command. The output may include shell snippets (e.g., recovery script invocation hints); a user copy-pasting those into a separate Claude turn with full tools is responsible for what happens there. Retirement EXECUTION is owned by `memory-management` invocation following preview confirmation.

### Workflow

1. Glob `memory/wiki/<project>/*.md` (project isolation via hot-cache or `--project`). If hot-cache has no active project AND no `--project` flag: exit with "Specify --project or activate one in hot-cache." If empty after glob: print "No compiled pages found. Run compile flow first." and exit.
2. Extract `sources[]` and `covered_warm[]` from each compiled page frontmatter.
3. For each referenced WARM file, run C1-C5 hard checks:
   - **C1 — Frontmatter capture**: WARM has `sources[]` entry AND every non-system frontmatter field appears verbatim in some compiled page's `covered_warm[].fields`. If WARM is referenced by ≥2 compiled pages, ALL must independently satisfy C1.
   - **C2 — Hash match**: WARM current `shasum -a 256 | cut -c1-8` equals every recorded `sources[].hash`.
   - **C3 — Maturity**: WARM mtime older than 90 days.
   - **C4 — Not in hot-cache**: `grep -l "<filename>" memory/hot-cache.md` returns empty.
   - **C5 — Reference count**: WARM is referenced by ≥1 compiled page.
4. Output table:
   ```
   | WARM file | covered_by | mtime | safety |
   |---|---|---|---|
   | memory/research/competitors/acme.md | entity-acme-corp.md | 95d | safe |
   | memory/research/competitors/beta.md | entity-beta.md | 45d | too-fresh (C3) |
   | memory/research/keywords/legacy.md | entity-legacy.md (v10.0.x) | 200d | frontmatter-drift (C1) |
   | memory/research/keywords/seo-tools.md | (none) | 120d | not-covered (C5) |
   ```
   Safety classifications: `safe` (all 5 pass), `too-fresh` (C3 fail), `hash-mismatch` (C2 fail), `frontmatter-drift` (C1 fail — common for compiled pages from v10.0.x lacking `covered_warm[]`; re-compile to opt in), `pinned` (C4 fail), `not-covered` (C5 fail).
5. Footer (mandatory exact text):
   > Found N retire candidates (M safe / K too-fresh / L hash-mismatch / J frontmatter-drift / I pinned / H not-covered).
   > To retire: tell memory-management 'retire <slug>' or 'retire all safe candidates'.
   > This command moved zero files.

## Validation Results

```yaml
validation_results:
  status: mixed
  evidence:
    - "/aaron:guard --evals: simulated cases checked"
  acceptance_eligible: false
  non_validating_reason: "simulated evidence only"
```

## Output

Return inline `validation_results` by default. Read-only modes never write; `--versions --apply` requires explicit confirmation and an edit-enabled runtime.
