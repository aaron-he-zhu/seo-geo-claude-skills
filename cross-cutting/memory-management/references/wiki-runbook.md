---
name: wiki-runbook
description: Execution runbook for the wiki layer (Phase 2 compile + reconciliation, Phase 3 retirement). Owned by memory-management as sole semantic writer.
type: reference
---

# Wiki Layer Runbook

This runbook is the execution detail for `memory/wiki/` operations. The schema lives in [state-model.md](../../../references/state-model.md) §WIKI Compilation View. Skill description and ownership live in [SKILL.md](../SKILL.md) §Wiki Layer.

`memory-management` is the sole semantic writer of all wiki content. The PostToolUse hook may perform a narrowly-scoped index refresh; everything else (compile / contradiction reconciliation / retire / restore) is explicit `memory-management` invocation following the procedures here.

---

## §1 When to Compile

Compile produces a derived wiki page synthesizing ≥3 source WARM files about the same entity, keyword, or topic. Triggers:

- **User explicit**: phrases like "compile a wiki page on X" / "synthesize what we know about X" / "build entity page for X" / Chinese equivalents in [commands/auto.md](../../../commands/auto.md) routing rules
- **Threshold suggestion**: same entity appears in ≥3 WARM files AND not in `memory/hot-cache.md` → `memory-management` proactively suggests compile (does not execute without confirmation)
- **Lint surface**: `/aaron:guard --wiki` reports "Missing page" → list in report only; never auto-compile

### §1.1 Pre-compile guardrails (v9.9.9+)

Two safety prompts MUST fire before compile execution. Both addressed 6-persona simulation findings (Marcus + Priya).

**N5 — Multi-project disambiguation**: if hot-cache history mentions ≥2 distinct `project:` slugs AND the current hot-cache has no active `project:` field, memory-management MUST prompt before compiling:
```
You have multiple project contexts in recent history:
  - <project-slug-1> (last seen: <date>)
  - <project-slug-2> (last seen: <date>)
  - <project-slug-3> (last seen: <date>)
Which project owns this compile? Pick one (1/2/3) or set hot-cache project= first.
```
Never default-route to global silently. The agency case (Pranayama Pro vs Pranayama Pro Studios) demonstrated silent-cross-contamination risk for related sub-brands.

**N6 — Personal-data entity guardrail**: if the entity name being compiled is identifiable as a natural person (heuristic: title-case `First Last` name OR matches LinkedIn/biography surface in source WARM OR explicitly tagged `entity_type: person` in source frontmatter), memory-management MUST prompt:
```
"<entity-name>" appears to be a natural person. Compiling will duplicate personal
data into covered_warm[] AND (if contradiction surfaces) into .unresolved.md
value fields. Under GDPR Art 5(1)(c) data minimization, this is questionable.

Recommended: compile at company-level instead and reference the person in body
text without verbatim frontmatter duplication.

Override with "yes compile this person" if you have a documented lawful basis
(consent / legitimate interest / contract — see memory-management SKILL.md
GDPR section). Override is logged.
```
Demonstrated by the fintech persona testing (FINRA-adjacent regulatory environment): compiling spreads PII to 3 surfaces (WARM + `covered_warm[]` + `.unresolved.md`), counter to documented "containment" framing.

Both guardrails are advisory prompts, not hard blocks. User can override either; override logged as: `## [date] compile-override entity=<X> reason=<multi-project|natural-person> override_phrase=<exact-text>`.

Compile is always user-confirmed. The scenario `auto-wiki-compile-001` in [evals/product-api-scenarios.md](../../../evals/product-api-scenarios.md) lists `explicit compile permission` as a blocking input.

---

## §2 Compile Steps

Atomic procedure, 7 steps. Failure at any step before step 5 leaves WARM untouched.

1. **Confirm with user**: "Will create `memory/wiki/<project>/<type>-<slug>.md` from N sources. Proceed?"
2. **Collect sources**:
   ```bash
   find memory -name '*.md' -not -path 'memory/wiki/*' -not -path 'memory/archive/*' -exec grep -l "<entity>" {} +
   ```
   Avoids globstar dependency on macOS bash 3.2.
3. **Compute hashes**: `shasum -a 256 <file> | cut -c1-8` per source.
   - **Tool availability check**: if `/usr/bin/shasum` not present (Windows / minimal containers), abort compile with error: "Compile requires shasum. Install or use Git Bash on Windows." Never fall back to silent skip.
4. **Extract + reconcile** (see §4). For each source WARM file, also capture its non-system frontmatter fields verbatim into `covered_warm[]` (see step 5 schema). System fields excluded from capture: `project`, `mtime` derivatives.
5. **Write file** with required frontmatter to `memory/wiki/<project>/<type>-<slug>.md`:
   ```yaml
   ---
   name: entity-acme-corp
   type: entity                     # entity | keyword | topic | comparison | synthesis
   project: acme-q2
   sources:
     - path: memory/research/competitors/acme.md
       hash: a1b2c3d4
     - path: memory/audits/domain/acme-cite.md
       hash: e5f6a7b8
   covered_warm:                    # Verbatim snapshot of source WARM frontmatter — used by C1 retirement check (§7 / state-model.md)
     - path: memory/research/competitors/acme.md
       fields:
         name: research-acme-2026q1
         description: Q1 competitor research
         type: research
         score: 78
         status: active
         next_action: re-audit-q3
     - path: memory/audits/domain/acme-cite.md
       fields:
         name: audit-acme-cite
         description: CITE domain rating snapshot
         type: audit
         score: 72
         status: active
         next_action: refresh-q4
   last_compiled: 2026-05-01
   ---
   ```
   - `covered_warm[].fields` MUST capture all non-system frontmatter fields from the source WARM. Empty/absent fields stored as null.
   - Body ≤200 lines. **If body would exceed 200 lines**: split into `<type>-<slug>-part1.md` / `-part2.md` etc. Procedure (mechanically verifiable, v9.9.9+):
     1. Before write, count generated body lines: `wc -l < <generated-body>`.
     2. If ≤200, single-file write per step 5 schema. Done.
     3. If >200, split body into chunks of ≤200 lines at paragraph boundaries (never mid-list, never mid-code-block). Compute N = number of parts.
     4. For each part `i` in 1..N:
        - Filename: `memory/wiki/<project>/<type>-<slug>-part<i>.md`
        - Frontmatter: full schema from step 5 PLUS `part: i/N` field
        - `sources[]` and `covered_warm[]` replicated identically across all parts (so any part alone has the full lineage for retire/restore)
        - Body chunk for part `i`
     5. After all parts written, log a single compile entry per §3: `## [date] compile <type>/<slug> sources=N contradictions=M auto_resolved=K parts=N` (note `parts=N` — v9.9.9+).
     6. `/aaron:guard --wiki` lint counts a split-page as ONE compiled page for orphan/missing-page detection (uses `<type>-<slug>` slug, ignores `-part<i>` suffix).
     7. Phase 3 retire treats the split as atomic: all parts retire together OR none. The C1 check looks at the union of `covered_warm[]` across all parts (which are identical anyway).

   Skip-split escape hatch: if the user explicitly says "compile as single page even if long" (rare; e.g., a single coherent body that should not be chunked), `memory-management` may write a single >200-line page and emit a warning: "Compiled page exceeds 200-line cap; lint may flag." User accepts the lint flag.
6. **Append to `memory/wiki/log.md`**:
   ```
   ## [2026-05-01 14:23] compile entity/acme-corp sources=2 contradictions=0 auto_resolved=0
   ```
   Include `auto_resolved=N` count when HIGH-confidence contradictions were auto-resolved during reconciliation.
7. **Trigger PostToolUse index refresh** — automatic via hook on file write. No manual action needed.

---

## §3 log.md Write Rules

| Operation | Trigger | Format |
|-----------|---------|--------|
| `compile` | New compiled page written | `## [date] compile <type>/<slug> sources=N contradictions=M auto_resolved=K` |
| `query` | User explicitly says "log this lookup" | `## [date] query <entity> hits=N` |
| `lint` | `/aaron:guard --wiki` completes | `## [date] lint <project> issues=N fixed=M` |
| `retire` | Phase 3 retire executes (see §7) | `## [date] retire <warm-path> → <archive-path>` |
| `restore` | Phase 3 restore executes (see §7.6) | `## [date] restore <archive-path> → <originally_at>` |
| `resolve` | User picks (a)/(b)/(s)/(i) or `resolve <id> ...` (v9.9.9+) | `## [date] resolve <id> <a\|b\|s\|i> entity=<X> field=<F> chosen_value=<V> chosen_source=<path>` |

500-line cap; on overflow, `memory-management` rotates oldest 50% to `memory/wiki/log-archive/YYYY.md`. Hook never rotates.

Parseable: `grep "^## \[" memory/wiki/log.md | tail -5`

### §3.1 Audit-log post-condition (v9.9.9+)

EVERY wiki write performed by `memory-management` in response to a user resolve/snooze/ignore/restore action MUST emit a log entry per the table above PLUS surface a one-line confirmation to the user echoing what changed. This addresses the v9.9.9 user-perspective review finding: "every wiki write is an LLM speech-act, not an enforced action — no audit trail when the LLM forgets or partially writes."

Required confirmation format (v9.9.9+):
```
✓ <action> for contradiction-<id>: <terse summary>
  Edited: <compiled-page-path> (line <N>: replaced [CONTRADICTION-<id>] with <chosen-value>)
  Updated: memory/wiki/.unresolved.md (removed entry <id>)
  Logged: memory/wiki/log.md (1 line appended)
```

Examples:
- `(a) keep A`: `✓ Resolved contradiction-001: kept value 72 from memory/research/competitors/acme.md. Edited acme-corp.md, removed entry from .unresolved.md, logged 1 line.`
- `(s) snooze`: `✓ Snoozed contradiction-001 until 2026-05-13 UTC. Updated .unresolved.md (snoozed_until set), logged 1 line.`
- `(i) ignore`: `✓ Ignored contradiction-001 until 2026-08-04 UTC. Updated .unresolved.md (ignored_until set), logged 1 line.`
- restore: `✓ Restored memory/research/competitors/acme.md from archive. Body byte-identical (excluding stripped retire-only fields). Logged 1 line.`

If memory-management cannot complete the write (e.g., file permissions, missing destination), it MUST surface the failure explicitly: `✗ Failed to <action>: <reason>. No changes made.` Never claim "done" without the receipt.

Verification: user can `grep "^## \[.*resolve contradiction-001" memory/wiki/log.md` to confirm the action landed. The log entry is the durable receipt; the inline confirmation is the immediate UX signal.

---

## §4 Contradiction Reconciliation

Confidence determines handling. All non-HIGH cases use `memory/wiki/.unresolved.md` + SessionStart prompt (§5), never the deprecated `[待确认]` file-edit pattern.

| Confidence | Trigger condition | Handling | User interaction |
|------------|-------------------|----------|------------------|
| **HIGH** | Time-series data; same metric, different dates | Use latest value. Older values moved to compiled page body changelog section. | Auto-applied with `--fix`; otherwise reports "auto-resolved by recency". Logged as `auto_resolved=N` per §3. |
| **MEDIUM** | Semantic ambiguity; comparable source weight | Insert `[CONTRADICTION-{id}]` marker in compiled page body. Append entry to `memory/wiki/.unresolved.md` (id, value-A, value-B, source-A, source-B, confidence, created_at). | Surface in next SessionStart conversational prompt (§5). |
| **LOW** | Insufficient evidence; fundamental conflict | Both values written side-by-side with `[CONTRADICTION-{id}]` marker. Same `.unresolved.md` entry shape as MEDIUM. | Same as MEDIUM; never auto-resolved even with `--fix`. |

`.unresolved.md` schema (YAML list, one entry per contradiction):

```yaml
- id: contradiction-001
  entity: acme-corp
  project: acme-q2                 # v9.9.9+: scopes first-time banner per §5.6; null OK (banner falls back to global)
  field: DA
  value_a: 72
  source_a: memory/research/competitors/acme.md
  value_b: 68
  source_b: memory/audits/domain/acme-cite.md
  confidence: medium               # high | medium | low
  created_at: 2026-05-01           # UTC date the contradiction was detected (not "value recency")
  snoozed_until: null              # or YYYY-MM-DD UTC; strictly-less-than predicate per §5.2
  ignored_until: null              # or YYYY-MM-DD UTC; today+90 when (i) picked; overwrite-not-extend on re-(i)
```

200-line cap; `memory-management` archives oldest 50% on overflow.

---

## §5 User Interaction Template

SessionStart hook checks `memory/wiki/.unresolved.md`. If non-empty AND not all entries are snoozed/ignored, surface **once per session**, max 3 entries shown.

### §5.1 Prompt rendering

The prompt MUST render the `field` name (not just the bare value), the SOURCE PATH (always, never positional words like "first/second"), and the `entity` from the `.unresolved.md` schema:

```
Wiki has 1 unresolved contradiction:
  Entity: acme-corp
  Field:  DA
  Source A (memory/research/competitors/acme.md): 72
  Source B (memory/audits/domain/acme-cite.md):   68
Pick: (a) keep A · (b) keep B · (s) snooze 7d · (i) ignore for 90d
```

**Multi-project scoping**: if `.unresolved.md` entry has a `project:` field, that scopes the first-time banner per §5.6. If absent, derive project from the compiled page path (`memory/wiki/<project>/...`). If neither resolvable, banner is global.

### §5.2 Date semantics (UTC, exclusive)

All `snoozed_until` and `ignored_until` dates are **UTC dates** (no timezone offsets). The hook skip predicate is **strictly less-than**:

- `snoozed_until: 2026-05-10` → entry skipped while UTC date < 2026-05-10. Resurfaces ON 2026-05-10 itself.
- Equivalent bash check: `[ "$(date -u +%Y-%m-%d)" \< "$snoozed_until" ]` returns true → skip.
- A user who picks `(s)` on 2026-05-03 gets `snoozed_until: 2026-05-10` (today+7); resurface on day 8 (May 10), matching natural "snooze for a week" semantics.

### §5.3 Response handling

- **`(a)` / `(b)`** → `memory-management` rewrites compiled page (replace `[CONTRADICTION-{id}]` marker with chosen value), removes entry from `.unresolved.md`. **Mandatory audit-log post-condition** (v9.9.9+): emit `## [date] resolve <id> a|b ...` to `log.md` AND surface inline confirmation per §3.1. No "done" without receipt.
- **`(s)`** → entry gains `snoozed_until: YYYY-MM-DD` (today+7 UTC); hook skips until that date per §5.2. Snooze applies only to the SessionStart prompt; `/aaron:guard --wiki` lint output also respects snooze (see commands/guard.md §Output Format).
- **`(i)`** → entry gains `ignored_until: YYYY-MM-DD` (today+90 UTC); hook skips until that date, then resurfaces. **Self-expiring; no permanent one-way doors.** Re-applying `(i)` after resurface OVERWRITES `ignored_until` to today+90 (does not extend additively).
- **Per-entry resolution syntax** (v9.9.9+, supports `/aaron:guard --wiki` resolution path): `resolve <id> <a|b|s|i>` accepted in any conversation turn. Example: `resolve contradiction-001 a`. Behaves identically to picking the option at SessionStart prompt.
- **Freeform mapping to (a)/(b)** → `memory-management` interprets in context, but MUST always quote both VALUE AND SOURCE PATH in confirmation, never positional words. Examples:
  - User: "the higher one" → `memory-management` checks if `value_a` and `value_b` are numeric AND comparable. If yes: "Did you mean keep A (DA=72, from memory/research/competitors/acme.md)?" If non-numeric (e.g., "CEO is Alice" vs "CEO is Bob"): asks the user to disambiguate, never resolves silently.
  - User: "the more recent" → `memory-management` does NOT have access to the source files' content recency (the `.unresolved.md` schema only has `created_at` of the contradiction record). Replies: "I can't see which value is more recent from the contradiction record. Want me to read both source files? Or just pick one (a) or (b)?"
  - User: "first one" / "second one" / "the top" → REJECTED with "Positional words are ambiguous. Reply with (a), (b), or quote the actual value or source path."
- **Clarifying questions** (v9.9.9+, third response class) — examples: "show me the source", "what's in acme.md?", "when were these recorded?", "which one is from the audit?". These are NOT freeform attempts at resolution and NOT topic changes. `memory-management` answers the question (reads source files / shows `.unresolved.md` entry detail / etc.), keeps the prompt active, does not defer. Wait for the next user turn for an actual `(a)/(b)/(s)/(i)` or `resolve <id> ...` response.
- **No response / user changes topic** → entry stays in `.unresolved.md`; not re-shown this session; appears at next SessionStart unless snoozed/ignored.

### §5.4 Condensed >3 mode + deferred visibility

When >3 unresolved entries exist, show condensed: `"N unresolved contradictions. Run /aaron:guard --wiki for full list with per-entry resolution syntax."`

`/aaron:guard --wiki` Output Format includes the `resolve <id> <a|b|s|i>` syntax for each unresolved entry — so the >3 case is no longer a dead-end (v9.9.9+). User can resolve from any turn after running guard, not just SessionStart.

**Deferred entries visibility** (v9.9.9+): snoozed and ignored entries (those with `snoozed_until` or `ignored_until` in future per §5.2) appear by default only as a count line in the lint output. To see explicit detail, run `/aaron:guard --wiki --show-deferred` — adds a "Deferred Contradictions" table with per-entry resolution-override syntax. The override semantics:
- `resolve <id> a` / `resolve <id> b` on a deferred entry → resolves immediately, removes entry from `.unresolved.md` (deferral discarded)
- `resolve <id> s` on an ignored entry → downgrades to snooze (clears `ignored_until`, sets `snoozed_until = today+7 UTC`)
- `resolve <id> i` on a snoozed entry → escalates to ignore (clears `snoozed_until`, sets `ignored_until = today+90 UTC`)
- `resolve <id> s` on already-snoozed entry → refreshes `snoozed_until = today+7 UTC` (overwrite, not extend)
- `resolve <id> i` on already-ignored entry → refreshes `ignored_until = today+90 UTC` (overwrite per §5.3)

The lint command itself remains read-only; only memory-management responding to the `resolve <id> ...` reply mutates `.unresolved.md`.

### §5.5 Resurface UX (v9.9.9+)

When an entry's `ignored_until` expires and resurfaces, the prompt MUST prefix the entry with `"[Previously deferred YYYY-MM-DD]"` so the user knows this isn't new — preventing accidental re-`(i)` loops:

```
Wiki has 1 unresolved contradiction:
  [Previously deferred 2026-02-02]
  Entity: acme-corp
  Field:  DA
  ...
```

Same prefix applies if `snoozed_until` expired (less likely to confuse since snooze is shorter, but consistent UX).

### §5.6 First-time banner

When a contradiction surfaces in a session that has never seen the wiki layer prompt before (heuristic: no prior `(a)/(b)/(s)/(i)` or `resolve <id>` response in session log for this project), prepend a one-shot banner: `"Wiki layer found a contradiction in your project records. Below: pick which value to keep, or defer. (You can also reply 'resolve <id> a' from any later turn — see commands/guard.md.)"`. Banner shown once per project, not per session.

---

## §6 First-run migration (existing v10.0.x users)

- Existing `memory/wiki/index.md` valid as-is — no rebuild needed
- `memory/wiki/log.md`, `memory/wiki/.unresolved.md`, `memory/wiki/.drift-log` auto-created empty on first wiki operation
- Existing v10.0.x compiled pages without `covered_warm[]` remain valid for query and lint, but cannot pass C1 in `/aaron:guard --wiki --retire-preview` until re-compiled
- Existing WARM files NOT auto-compiled — system never proactively prompts to compile on upgrade
- The `memory/wiki/.retire-day-log` (Phase 3) is created on first retire attempt; absence is treated as "0 retires today"

---

## §7 Retirement Workflow (Phase 3)

WARM files fully covered by compiled wiki pages may be retired to `memory/archive/` on user request. Retirement is never automatic. The recovery invariant is enforced by `originally_at` + `retired_on` + `retired_because_compiled` fields written into COLD frontmatter (NOT wiki/), so `rm -rf memory/wiki/` does NOT destroy retirement history. Validated by `scripts/validate-phase3-rollback.sh` (4-fixture matrix: plain LF, no-trailing-NL, CRLF, multi-line YAML).

### §7.1 Triggers

- User explicitly invokes `/aaron:guard --wiki --retire-preview` to enumerate candidates
- User says "retire <slug>" or "retire all safe candidates" (or Chinese equivalents from `commands/auto.md` routing rules)
- `memory-management` **never** proactively suggests retirement (deliberate UX choice — addresses cumulative-noise concern)

### §7.2 Safety Caps

- **Per call**: maximum 5 files. Larger requests split into batches with per-batch confirmation.
- **Per day**: maximum 20 files. Day boundary is **UTC midnight** (not local time, not project switch). Tracked in `memory/wiki/.retire-day-log` (30-day rolling window).
- **Per file**: must pass C1-C5 (§7.3) before retirement.

#### §7.2.1 Bulk Backlog Mode (v9.9.9+)

Users coming with accumulated WARM backlog (e.g., 100+ files after months of research) hit the steady-state caps painfully. Real complaint from 6-persona simulation (David, e-commerce SEO, 214 WARM files): "5/call + 20/day caps assume you're producing notes, not catching up on a backlog. At my pace this would take 2 weeks of cleanup." Mitigation: `--bulk-confirmed` flag.

Trigger: user invokes `/aaron:guard --wiki --retire-preview --bulk-confirmed` after first reviewing a normal `--retire-preview` table. The `--bulk-confirmed` mode:

1. Re-runs the full preview (same C1-C5 checks per file).
2. Surfaces a SINGLE summary prompt covering ALL `safe`-marked candidates: `"Retire ALL N safe candidates in one batch (C1-C5 verified per file)? This is a one-time operation. y/n."`
3. On `y`, retires the entire `safe` list. Day-cap check still applies — if N > 20 - day-so-far, abort with `"Bulk retire would exceed 20-file daily cap. Try --bulk-confirmed --max-today=K (where K is the remaining day budget)."`
4. Per-file C1-C5 check still runs at retire time (not just preview time) — any file that has changed between preview and execute is skipped with diagnostic.
5. log.md gets ONE entry per file plus a summary line: `## [date] retire-bulk count=N project=<P> initiated_by=<user>`.

`--bulk-confirmed` is opt-in only. Default behavior (5/call) unchanged. Power users with a verified preview output can clean a backlog in one operation; cautious users still get per-batch confirmation.

#### §7.2.2 Force-retire for not-covered files (v9.9.9+)

C5 ("WARM is referenced by ≥1 compiled page") is a hard precondition for normal retire. But real users (Maya from 6-persona simulation, solo consultant) have legitimate reasons to retire WARM that no compiled page references: stale entity profiles, deprecated content briefs, abandoned project notes. Without a force path, users `mv` manually around the safety rail, which then triggers `wiki-manual-archive-detect` lint warnings — a frustrating loop where the safety mechanism punishes the legitimate use case.

Trigger: `retire <path> --force` OR `force-retire <path>` (English) / `强制退役 <path>` (Chinese). Behavior:

1. C1, C2, C3, C4 STILL apply (frontmatter capture, hash match, maturity, not-pinned). Only C5 is bypassed.
2. memory-management surfaces an explicit confirmation: `"Force-retire <path>? This file is not referenced by any compiled wiki page (C5 fail). Recovery via /aaron:remember recover wiki will still work because originally_at is added to the archive frontmatter. Confirm with 'yes force'."`
3. On confirm, run §7.4 procedure normally. Archive gets `originally_at` + `retired_on` + `retired_because_compiled: <none-no-coverage>` fields.
4. log.md entry: `## [date] retire-force <path> → <archive-path> (C5 bypassed by user)`. The `-force` suffix on the operation is greppable for audit.
5. The resulting archive ALSO has `force_retired: true` field in frontmatter so `wiki-manual-archive-detect` knows this was deliberate (not a manual `mv`) and does NOT warn.

This closes the Maya-class friction: stale-but-uncovered files can be retired through the documented flow, recovery still works, and the lint doesn't accuse the user of bypassing the system.
- **Day-log format**: one line per completed batch, fixed schema. Single space separator, no key=value form. Format: `YYYY-MM-DDTHH:MM:SSZ count`. Example:
  ```
  2026-05-01T03:14:22Z 5
  2026-05-01T08:22:01Z 3
  2026-05-02T12:00:00Z 2
  ```
- **Day-cap check**: `awk -v today="$(date -u +%Y-%m-%d)" '$1 ~ "^"today {sum += $2} END {exit (sum >= 20)}' memory/wiki/.retire-day-log`. Exit 0 = under cap, exit 1 = at/over cap (refuse new retire).
- **Rolling cleanup**: `memory-management` removes lines >30 days old at append time.

When user requests >5 files, prompt: `"Retire batch 1/3 (5 files): a, b, c, d, e. Proceed?"`. After batch 1 confirms, repeat for batch 2/3.

### §7.3 "Fully Covered" Hard Checks

All five must pass:

- **C1 — Frontmatter capture**: WARM file is referenced by some compiled page's `sources[]` AND that compiled page's `covered_warm[]` contains an entry with matching `path` whose `fields` map captures every non-system frontmatter field present in the current WARM file. System fields excluded from capture: `project`, `mtime`. All other fields (`name`, `description`, `type`, `score`, `status`, `next_action`, plus any custom fields) must be present in `covered_warm[].fields` with values matching the WARM exactly. **Multi-page edge case**: if WARM is referenced by ≥2 compiled pages, **all** referencing pages must independently satisfy C1. Mechanically verifiable via `yq` or hand-rolled YAML diff between WARM frontmatter and `covered_warm[].fields`.
- **C2 — Hash match**: WARM current `shasum -a 256 | cut -c1-8` equals the hash recorded in every compiled page's `sources[]` entry that references it (no drift).
- **C3 — Maturity**: WARM file mtime is older than 90 days (aligns with existing WARM→COLD natural demotion threshold from `state-model.md`).
- **C4 — Not in hot-cache**: `grep -l "<filename>" memory/hot-cache.md` returns empty.
- **C5 — Reference count**: WARM is referenced by ≥1 compiled page (basic precondition).

`/aaron:guard --wiki --retire-preview` output safety classifications: `safe` (all 5 pass), `too-fresh` (C3 fails), `hash-mismatch` (C2 fails), `frontmatter-drift` (C1 fails), `pinned` (C4 fails), `not-covered` (C5 fails).

> **Migration note for existing v10.0.x compiled pages without `covered_warm[]`**: such pages cannot pass C1. `--retire-preview` reports them as `frontmatter-drift` with hint "compile produced before v9.9.9; re-compile to enable retirement". User explicitly re-compiles to opt in. No automatic backfill.

### §7.4 Atomic Retire Procedure (per file)

Steps must execute in order. Failure handling in §7.5.

1. **Pre-check**: re-run C1-C5 AND re-shasum the source file. If hash advanced since last check (mtime moved during the user-confirmation window), abort this file with "source modified during preview; re-run --retire-preview". Any C1-C5 fail → abort this file, continue to next. Per-file user confirmation (or once-per-batch in batch mode).
2. **Compute archive path with collision handling**:
   ```bash
   DATE=$(date -u +%Y-%m-%d)
   archive="memory/archive/$DATE-acme.md"
   # Collision: same dated filename already exists (two retires same day, same slug,
   # OR a previously-retired file with same slug from earlier session)
   if [ -e "$archive" ]; then
     archive="memory/archive/$DATE-acme-$(date -u +%H%M%S).md"
   fi
   # Second collision (sub-second rate, near-impossible single-user) → abort with error
   [ -e "$archive" ] && { echo "ERROR: archive path collision unresolvable"; exit 1; }
   ```
3. **Copy source to archive**:
   ```bash
   cp memory/research/competitors/acme.md "$archive"
   ```
4. **In-place edit archive frontmatter** (insert before closing `---`; the `scripts/validate-phase3-rollback.sh` validator enforces this exact procedure with 4 fixture variants):
   ```yaml
   originally_at: memory/research/competitors/acme.md
   retired_on: 2026-05-01
   retired_because_compiled: memory/wiki/acme-q2/entity-acme-corp.md
   ```
   Insert these three lines immediately before the closing `---` of the frontmatter, leaving original fields and body untouched. CRLF source files: insert plain LF lines; recovery strip pattern catches them regardless of source line ending.
5. **Verify byte-identity** (the documented integrity check, command included so implementer doesn't reinvent it):
   ```bash
   diff <(awk 'BEGIN{fm=0} /^---\r?$/{fm++; print; next} {print}' memory/research/competitors/acme.md) \
        <(awk 'BEGIN{fm=0}
               /^---\r?$/{fm++; print; next}
               fm==1 && /^(originally_at|retired_on|retired_because_compiled):/ {next}
               {print}' "$archive")
   ```
   Expected: empty (zero diff). If diff non-empty → fail handler (§7.5 step 2-5 row): `rm "$archive"`, leave WARM untouched, report.
6. **Delete original WARM**:
   ```bash
   rm memory/research/competitors/acme.md
   ```
7. **Update compiled page** (audit only): append one line to compiled page body:
   ```
   Source files retired to archive on 2026-05-01.
   ```
   **Do not modify** `sources[].hash` — that hash is a historical snapshot; modifying breaks lint drift detection. **If body+append would exceed 200-line cap**: auto-trigger split per §2 step 5 spill rule.
8. **Append log**:
   ```
   ## [2026-05-01 14:23] retire memory/research/competitors/acme.md
   - to: memory/archive/2026-05-01-acme.md
   - compiled_in: memory/wiki/acme-q2/entity-acme-corp.md
   - reason: covered (C1+C2+C3+C4+C5 passed)
   ```
9. **Append day-log**: write one line `YYYY-MM-DDTHH:MM:SSZ count` to `memory/wiki/.retire-day-log` (per §7.2 format). Roll cleanup: drop lines >30 days old.
10. **Touch index for refresh**: `touch memory/wiki/index.md`. PostToolUse hook only matches `Write|Edit`, not `rm` from step 6, so explicit touch is required to ensure index rebuild reflects the retire.

### §7.5 Failure Handling (Partial Retire)

Step numbers reference §7.4 (10-step procedure). The integrity gate is at step 5 (byte-identity verify); after that, partial state is recoverable but not auto-rolled-back.

| Failed step | State | Recovery |
|-------------|-------|----------|
| 1 (pre-check) | Nothing changed | Report C1-C5 fail OR "source modified during preview" → user re-runs preview |
| 2-5 | Archive file may exist or be incomplete; WARM untouched | Delete archive file (`rm "$archive"`); WARM intact; report error to user |
| 6 | Archive complete, WARM still exists (both copies present) | **Do not auto-rollback** — possible user edit interleaved between step 5 verify and step 6 rm. Report: `"Both files exist. Keep archive (mv archive/X.md research/X.md && rm \"$archive\") or keep original (rm \"$archive\")?"` |
| 7-10 | Retire technically successful; only audit/index fields incomplete | Next `/aaron:guard --wiki` detects "WARM file referenced by sources but missing" and prompts for self-heal (re-runs steps 7-10) |

Never auto-rollback step 6+. Possible user edits between steps mean automated revert risks data loss.

### §7.6 Recovery Workflow

**User-initiated undo (single file)** — user says "restore <archive-filename>" or "undo last retire":

1. Read `memory/archive/<file>.md` frontmatter, extract `originally_at`
2. Check destination clear: `[ ! -e "$originally_at" ]` — if exists, abort with: `"<originally_at> already exists. Restore would overwrite. Move existing file first or pick different target."`
3. Copy back: `cp memory/archive/<file>.md "$originally_at"`
4. Strip retire-only fields from restored file: remove `originally_at`, `retired_on`, `retired_because_compiled` (preserve trailing-newline state of source)
5. Delete archive: `rm memory/archive/<file>.md`
6. Append log: `## [date] restore <archive> → <originally_at>`

**Recovery after `rm -rf memory/wiki/`** (the rollback invariant): all retired WARM files survive — they sit in `memory/archive/` with `originally_at` frontmatter. Two equivalent paths to restore:

**Path A — `/aaron:remember` (recommended for non-technical users, v9.9.9+)**:
Just say one of these phrases — `memory-management` will run the recovery script on your behalf and surface the audit-log receipt:
- `recover wiki`
- `recover retired files`
- `restore my wiki`
- `undo last retire`
- `恢复wiki` / `恢复退役`

memory-management checks Bash tool availability first. If available, it runs `bash scripts/recover-retired-warm.sh` and reports the result. If unavailable (e.g., read-only Claude session), it explains the manual path with the exact command line you can copy-paste.

**Path B — direct shell invocation (for power users / CI)**:
```bash
bash scripts/recover-retired-warm.sh
```

Exit codes: `0` clean recovery, `2` partial (some destinations occupied or path-injection / symlink-pivot rejected — review skip-* messages), `1` hard error.

The script reads each `memory/archive/*.md` frontmatter, restores files referenced by `originally_at` to their pre-retire paths (stripping the three retire-only fields), skips files where the destination already exists, and rejects adversarial archives (absolute paths, `..` escapes, non-`memory/` prefixes, symlink-pivot ancestors). Validated against 5 fixture variants (plain LF, no-trailing-NL, CRLF, multi-line YAML, body-with-HR) plus path-injection and symlink-pivot negative tests by `scripts/validate-phase3-rollback.sh`, which is the rollback merge gate for the wiki Phase 3 surface.
