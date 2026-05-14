---
name: proposal-wiki-phase-2-3-completion
description: Complete implementation spec for Wiki Knowledge Layer Phase 2 (compiled pages + reconciliation) and Phase 3 (user-initiated retirement) shipping in v9.9.9. Supersedes v3 deferral; incorporates multi-agent review feedback (architecture / fact-check / UX).
type: reference
---

# Wiki Knowledge Layer Phase 2/3 Completion — v9.9.9

**Status**: ✅ implemented across v9.9.9 → v9.9.9 (2026-05-03 → 2026-05-06). v9.9.9 shipped wiki Phase 2/3 (8 commits a357f3f → 7bae954). v9.9.9 patched 5 RED + 10 YELLOW from user-perspective testing (5 commits 664b239 → d178594). v9.9.9 closed restore-scenario + --show-deferred gaps (2 commits 50e3547 + a85185c). v9.9.9 fixed 6-agent-team review findings: symlink-pivot security, hook prompt-injection, set -e in run_fixture, awk-pattern-drift docs, ERR-trap CI debuggability, GDPR robustness, audit-log UX, CI waiver env, §6→§7 cross-references, eval-count drift. All 7 tests of `scripts/validate-phase3-rollback.sh` pass live (5 round-trip + 2 negative tests). PR-scoped language and §12.2 Open Questions in this document are HISTORICAL — left intact for design provenance. Future wiki layer changes: reference for design history; amend (not replace) the runbook / state-model / SKILL.md surfaces.
**Author**: Aaron Zhu
**Reviewers**: 4 multi-agent passes (Plan / Explore / general-purpose) — rev2 architecture, rev3 upstream-adaptation, rev4 follow-up, post-implementation acceptance
**Shipped version**: v9.9.9 (target met)
**Supersedes**: deferral guidance in [proposal-wiki-layer-v3.md](proposal-wiki-layer-v3.md) §3

## What changed since rev3 (rev4 diff summary — read this first)

For implementers who already read rev3, these are the only deltas. Everything else is unchanged.

| # | Section | Change | Why |
|---|---|---|---|
| 1 | §1.1 | Added self-reference exemption clause | Doc body uses bare "Phase N" ~30 times by design; mandate scoped to outbound prose only |
| 2 | **§1.2 A2** (rewritten) | Pack-boundary rule now exempts memory-management lifecycle ops | rev3 paper-over with engineered "SEO" tokens rejected; safety belongs at scenario gates, not keyword grep |
| 3 | **§4.2.5** (rewritten) | Trigger phrasing back to natural language; commit ordering A→B→C explicit; inter-PR fallback added | Aligns with §1.2 A2 fix; users actually say "what do we know about X", not "compile our SEO research findings on X" |
| 4 | **§4.2.6** (new) | `commands/remember.md` scope expansion moved from PR #4 to PR #2 | Fixed forward-reference: scenarios route via `/aaron:remember`, scope must be in place when scenarios land |
| 5 | §4.4.5b | Fixed citation: `evals/product-api-scenarios.md` is from `f5d5f0f`, not `965acac` | Factual correction (Explore #10) |
| 6 | §4.4.6 | Removed `commands/remember.md` row (now in PR #2 §4.2.6) | Consequence of fix #4; cross-ref count 7 → 6 |
| 7 | §6.2 + §4.4.7 | Added `changed_paths_match` helper definition | Helper doesn't exist on main; rev3 hand-waved a fallback that wasn't actually a fallback |
| 8 | Scenario blocks (§4.2.5) | Added "explicit permission" to `blocking_inputs`; retire `expected_route` is now the chain `/aaron:guard --wiki --retire-preview -> /aaron:remember` | Aligns with sibling scenario pattern (`auto-entity-knowledge-graph-001` etc.); reflects two-step actual flow |

PR scope updates: PR #2 ~220 → ~260 lines (gained `remember.md` + auto.md exemption rule + inter-PR fallback). PR #4 unchanged. Total proposal ~1068 → ~1190 lines.

---

## 1. Background

The Wiki Knowledge Layer was designed in v3 (2026-04-05) as three phases over WARM memory files in `memory/wiki/`:

- **Phase 1** — `memory/wiki/index.md` auto-refreshed by PostToolUse hook; SessionStart auto-loads
- **Phase 2** — compiled pages with source SHA-256 hashes, `memory/wiki/log.md` timeline, contradiction reconciliation
- **Phase 3** — terminal HOT/WIKI/COLD architecture; WARM files retired into COLD once compiled pages cover them

As of v9.9.9, only Phase 1 is fully shipped. Phase 2 has schema in `references/state-model.md` but no execution runbook. Phase 3 is mentioned in `state-model.md:73` as a single line; the `--retire-preview` flag is not registered in `commands/guard.md`.

The previous review pass recommended deferring Phase 3 due to (a) a `retired_path` frontmatter design that broke the "delete `memory/wiki/` for zero-cost rollback" invariant, and (b) absence of demonstrated user demand. This proposal fixes (a) with a redesigned data model and explicitly accepts (b) as a deliberate "build for completeness" choice.

### 1.1 Naming Clarification — "Phase 2/3" Disambiguation

**This proposal's Phase 2/3 refers exclusively to wiki layer phases** as defined in [references/state-model.md](state-model.md) §WIKI Compilation View. They describe the maturity of the wiki knowledge layer:
- Phase 1 = index auto-refresh (shipped in v7.0.0)
- Phase 2 = compiled pages with reconciliation (this proposal)
- Phase 3 = user-initiated WARM retirement (this proposal)

**This is distinct from "Phase 2/3" in [.docs/slashaaron-product-proposal.md](../.docs/slashaaron-product-proposal.md)** (commit `965acac`), which describes anchor-pack rollout phases (anchor-pack PR sequencing / manifest integration / cross-pack registry). The two namespaces are unrelated; do not conflate.

**Disambiguation rule** (rev4 scope-corrected): the "wiki Phase N" / "anchor-pack Phase N" prefix is mandatory in:
- PR titles
- commit messages (subject line and body)
- `commands/auto.md` routing entries
- changelog entries (VERSIONS.md, CHANGELOG.md)
- any prose written outside this proposal that refers to phase concepts

**Self-reference exemption**: within the body of THIS proposal (`proposal-wiki-phase-2-3-completion.md`), bare "Phase N" refers to wiki phases by surrounding context (the document title, frontmatter, and §1 introductory bullets establish the namespace). The doc body uses bare "Phase N" ~30 times; rewriting all of them would damage readability for zero clarity gain. The mandate above governs anything that escapes this proposal's scope.

**Enforcement**: not currently mechanized. A future `/aaron:guard --contracts` extension could grep PR titles via `gh pr view --json title` for bare "Phase N" without "wiki" or "anchor-pack" prefix, but that's out of scope for v9.9.9.

### 1.2 Upstream Adaptation — Commit `965acac` Anchor Pack Repositioning

This proposal was drafted against `main` at commit `451bfca`. Commit `965acac docs: position seo-geo as slash-aaron anchor pack` (68 files, +1467/-138) landed on main between draft and implementation. Conflict analysis: **no breaking conflicts**. Three adaptations folded into this revision:

- **A1** — `commands/auto.md` now references the [Product API Contract](aaron-product-api-contract.md) and the [Product API Scenario Library](../evals/product-api-scenarios.md) (the scenario file already existed since commit `f5d5f0f` Aaron migration; `965acac` formalized the contract that governs it). New high-frequency routing must land as a scenario first. **Adaptation**: §4.2.5 routing additions are split — scenario registration in `evals/product-api-scenarios.md` lands as a separate commit BEFORE the natural-language routing entries in `commands/auto.md`, both within PR #2. See §4.2.5 below.
- **A2 (revised)** — Pack-boundary scope correction: `commands/auto.md` now declines clearly non-SEO/GEO work. The first attempt at adaptation (rev3) tried to engineer "SEO" / "SEO/GEO" tokens into wiki trigger phrasing to satisfy this rule. **Review feedback rejected this approach** as paper-over: wiki/memory operations are not outbound workflow selection (the thing the pack-boundary check guards) — they are **maintenance on user-owned project memory**, regardless of memory's topical scope. A user with a board-meeting note in `memory/research/` is owed memory operations on it, even though "Q3 board meeting" is not SEO content.

   **Correct adaptation**: amend `commands/auto.md` rules paragraph to **explicitly exempt memory-management compile/retire/restore** from the pack-boundary check. Then trigger phrasing in §4.2.5 returns to natural language (no engineered "SEO" inserts). Safety remains gated by scenario-level checks (`memory_or_entity_write`, ≥3 WARM source precondition for compile, C1-C5 hard checks for retire) — not by keyword grep on user phrasing.

   Concrete `commands/auto.md` edit (PR #2 scope, separate commit from §4.2.5 trigger additions): append to the Rules section line about "clearly non-SEO/GEO work":
   > "Memory-management lifecycle operations (compile, retire, restore, query, archive, purge) operate on user-owned project memory regardless of the memory's topical scope and are NOT subject to the pack-boundary check; safety for these operations is enforced by scenario-level gates and per-operation user confirmation."
- **A3** — `scripts/validate-slimming-guardrails.sh` now contains OpenClaw bundle and platform registry validation (verified at lines 956-965 on main per Explore #1). The phase 3 rollback validator hook in PR #3 must insert AFTER the platform registry block, not before. See §4.4.7 below.

A1 and A3 affect file insertion points / commit ordering only. A2 is a one-line carve-out to the pack-boundary rule, scoped narrowly to memory-management lifecycle ops. None of these is a design change to wiki itself.

**Pre-implementation requirement**: rebase the implementation branch onto `main` (post-`965acac`) before starting PR #1. All line-number anchors in this proposal were re-verified against `main` post-`965acac` and remain accurate (SKILL.md §Wiki Layer at line 166-168, GDPR purge step 3 at line 238-239, SKILL.md total 257 lines).

---

## 2. Scope

This release ships wiki Phase 2 + wiki Phase 3 simultaneously as v9.9.9. Wiki Phase 1 unchanged.

**In scope**:
- Restoration of the `wiki-lint` 7-check workflow (lost in v9.9.0 → v9.9.5 command migration)
- Phase 2 compile workflow with conversational contradiction reconciliation
- Phase 3 user-initiated WARM retirement with full recovery path
- 11 new eval cases covering compile, drift, project isolation, retirement, rollback, GDPR, routing, manual-archive detection
- 2 new Product API scenarios (`wiki_entity_synthesis`, `wiki_warm_retirement`) registered in `evals/product-api-scenarios.md`
- Sync across 9 manifest files + 6 cross-reference docs

**Out of scope**:
- Automatic compile / automatic retire (everything stays user-initiated)
- Cross-project entity merging
- Wiki page export / sharing
- Performance optimization for >500-WARM-file projects

---

## 3. Design Principles (Reinforced)

These six principles are non-negotiable. Any change that violates one must update this document first.

1. **WARM is immutable** — wiki is a derived layer; WARM files are not rewritten by wiki maintenance flows
2. **`memory-management` is the sole semantic writer** of all wiki content; hooks only perform narrow delegated index refreshes
3. **`rm -rf memory/wiki/` is a zero-cost rollback** — no mechanism in this proposal places reverse pointers outside `memory/wiki/` that would survive its deletion **except** Phase 3's `originally_at` field in COLD frontmatter (see §5.3 for why this is OK)
4. **All compile / contradiction confirmation / retire operations are conversational** — users never edit derived markdown files to confirm or trigger anything
5. **`cross-cutting/memory-management/SKILL.md` §Wiki Layer is hard-capped at 30 lines** — full runbook detail lives in `cross-cutting/memory-management/references/wiki-runbook.md`
6. **Hooks log silently and never prompt directly** — user notifications happen via SessionStart prompts after threshold accumulation

---

## 4. Change Set

Four PRs, merged in order. Each PR must pass `/aaron:guard --release`, `/aaron:guard --contracts`, and `bash scripts/validate-slimming-guardrails.sh` before merge.

### PR #1 — Restore wiki-lint 7-check + register retire-preview (~110 lines, low risk)

**Source**: git commit `9967b3d` `commands/wiki-lint.md` (78 lines, deleted in `f5d5f0f` Aaron migration)

**Target**: `commands/guard.md` `--wiki` mode (covering full lint AND retire-preview dry-run mode — both are read-only and can ship together)

**4.1.1 Modify [commands/guard.md](../commands/guard.md) line 4** — register `--retire-preview` as a sub-flag of `--wiki` (mirrors the existing `[--apply]` sub-flag of `--versions`):

```yaml
argument-hint: "--inventory|--evals|--contracts|--wiki [--fix] [--project <name>] [--retire-preview]|--versions [--apply]|--release|--all --strict"
```

**4.1.2 Modify parameters block** — `mode` stays as the existing top-level enum; new sub-flags are separate booleans that ONLY apply when `mode == "wiki"`. The proposal's parameters block design follows the existing pattern of `apply` (which is documented as "Only with --versions"):

```yaml
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
```

**4.1.3 Add `## Wiki Mode` subsection** — inline content from git `9967b3d:commands/wiki-lint.md`:
- 10-step sequential workflow
- 7-check table (Contradiction / Stale claim / Orphan page / Missing page / Missing cross-ref / HOT drift / Hash mismatch)
- HIGH/MEDIUM/LOW reconciliation rules (same as §4 of wiki-runbook.md — see §4.2.1 §4 of this proposal for consistency)
- Output Format + append `memory/wiki/log.md`

**4.1.4 Add `## Retire-Preview Mode` subsection** — full text inlined here (no forward reference to PR #3). The mode is **read-only by capability** (no Bash/Write/Edit in `allowed-tools`), so it can ship in PR #1 alongside the lint workflow. The C1-C5 checks it relies on require Phase 2 `covered_warm[]` schema (PR #2) — running `--retire-preview` before any compiled pages exist returns an empty candidate list with footer "No compiled pages found. Run compile flow first.":

> Workflow when `/aaron:guard --wiki --retire-preview` is invoked:
>
> 1. Glob `memory/wiki/<project>/*.md` (project isolation via hot-cache or `--project`). If empty, print "No compiled pages found. Run compile flow first." and exit.
> 2. Extract `sources[]` and `covered_warm[]` from each compiled page.
> 3. For each referenced WARM file, run C1-C5 (see §5.3).
> 4. Output table:
>    ```
>    | WARM file | covered_by | mtime | safety |
>    |---|---|---|---|
>    | memory/research/competitors/acme.md | entity-acme-corp.md | 95d | safe |
>    | memory/research/competitors/beta.md | entity-beta.md | 45d | too-fresh (C3) |
>    | memory/research/keywords/seo-tools.md | (none) | 120d | not-covered (C5) |
>    | memory/research/keywords/legacy.md | entity-legacy.md (v10.0.x) | 200d | frontmatter-drift (C1) |
>    ```
> 5. Footer (mandatory exact text):
>    > Found N retire candidates (M safe / K too-fresh / L hash-mismatch / J frontmatter-drift / I pinned / H not-covered).
>    > To retire: tell memory-management 'retire <slug>' or 'retire all safe candidates'.
>    > This command moved zero files.
>
> See §5 of this proposal for the retire workflow that follows preview.

**4.1.5 `allowed-tools` constraint** — keep as `["Read", "Glob", "Grep"]`. This structurally guarantees the command itself never invokes file-mutation tools (no Bash, Write, or Edit available; no Task/Agent to escape via subagent). The dry-run promise is enforced by capability for the command's own execution. **Caveat**: the command may emit shell snippets in its output (e.g., recovery script invocation hints); users may copy-paste these into a normal Claude turn that has full tools. The "structural guarantee" applies to this command's execution, not to follow-up actions in unrelated turns.

**Verification**:
```bash
grep -c "Contradiction\|Stale claim\|Orphan page" commands/guard.md   # ≥3
grep -c "retire-preview" commands/guard.md                             # ≥3
grep -c "covered_warm" commands/guard.md                               # ≥1 (C1 referencing the schema)
wc -l commands/guard.md                                                 # ≤220 (was ≤200; bumped for retire-preview block)
```

---

### PR #2 — Phase 2 runbook + conversational reconciliation + remember.md scope (~260 lines, medium risk)

> **rev4 note**: Scope expanded vs rev3 to include `commands/remember.md` updates (was scheduled for PR #4 but creates a forward-reference for the Product API scenarios registered here). The `commands/auto.md` + `commands/remember.md` + `evals/product-api-scenarios.md` triplet must land together so route + scope + scenario all match before any user can hit the new path.

**4.2.1 Create [cross-cutting/memory-management/references/wiki-runbook.md](../cross-cutting/memory-management/references/wiki-runbook.md)** — 6 sections, ~180 lines total.

Sections:
- §1 When to compile (triggers)
- §2 Compile steps (atomic procedure with frontmatter spec)
- §3 `log.md` write rules (4 operation types, year-end rotation)
- §4 Contradiction reconciliation (HIGH/MEDIUM/LOW with confidence table)
- §5 User interaction templates (SessionStart conversational prompt)
- §6 Retirement workflow (Phase 3 — see §5 of this proposal for full content)

Full content for §1-§5 below; §6 in §5 of this proposal.

**§1 When to Compile**:
- User explicitly says "compile wiki page for [X]" / "synthesize what we know about [X]" / "build entity page for [X]" / Chinese equivalents in `commands/auto.md` routing
- Same entity appears in ≥3 WARM files AND not in hot-cache → `memory-management` proactively suggests compile (does not execute)
- `/aaron:guard --wiki` reports "Missing page" → list in report, never auto-compile

**§2 Compile Steps**:
1. Confirm with user: "Will create `memory/wiki/<project>/<type>-<slug>.md` from N sources. Proceed?"
2. Collect sources: `find memory -name '*.md' -not -path 'memory/wiki/*' -not -path 'memory/archive/*' -exec grep -l "<entity>" {} +` (avoids globstar dependency on macOS bash 3.2)
3. Compute hashes: `shasum -a 256 <file> | cut -c1-8`
   - **Tool availability check**: if `/usr/bin/shasum` not present (Windows / minimal containers), abort compile with error: "Compile requires shasum. Install or use Git Bash on Windows." Never fall back to silent skip.
4. Extract + reconcile (see §4). For each source WARM file, also capture its non-system frontmatter fields verbatim into `covered_warm[]` (see step 5 schema).
5. Write file with required frontmatter:
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
   covered_warm:                    # Verbatim snapshot of source WARM frontmatter — used by C1 retirement check
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
   - `covered_warm[].fields` MUST capture all non-system frontmatter fields from the source WARM (system fields = `project`, `mtime` derivatives). Empty/absent fields stored as null.
   - Body ≤200 lines. **If body would exceed 200 lines**: split into `<type>-<slug>-part1.md` / `-part2.md` etc., each with `part: 1/N` field added; sources/covered_warm replicated in each part for atomic retire/restore.
6. Append to `memory/wiki/log.md`:
   ```
   ## [2026-05-01 14:23] compile entity/acme-corp sources=2 contradictions=0
   ```
7. PostToolUse hook auto-refreshes `memory/wiki/index.md` (no action needed)

**§3 log.md Write Rules**:

| Operation | Trigger | Format |
|---|---|---|
| `compile` | New compiled page written | `## [date] compile <type>/<slug> sources=N contradictions=M` |
| `query` | User explicitly says "log this lookup" | `## [date] query <entity> hits=N` |
| `lint` | `/aaron:guard --wiki` completes | `## [date] lint <project> issues=N fixed=M` |
| `retire` | Phase 3 retire executes (see §6) | `## [date] retire <warm-path> → <archive-path>` |

500-line cap; on overflow, `memory-management` rotates to `memory/wiki/log-archive/YYYY.md`. Hook never rotates.

Parseable: `grep "^## \[" memory/wiki/log.md | tail -5`

**§4 Contradiction Reconciliation**:

| Confidence | Trigger condition | Handling | User interaction |
|---|---|---|---|
| **HIGH** | Time-series data; same metric, different dates | Use latest value; older values moved to body changelog section | Auto-applied with `--fix`; otherwise reports "auto-resolved by recency" |
| **MEDIUM** | Semantic ambiguity; comparable source weight | Insert `[CONTRADICTION-{id}]` marker in compiled page body. Append entry to `memory/wiki/.unresolved.md` (id, value-A, value-B, source-A, source-B) | Surface in next SessionStart conversational prompt (§5) |
| **LOW** | Insufficient evidence; fundamental conflict | Both values written side-by-side with `[CONTRADICTION-{id}]` marker. Same `.unresolved.md` entry as MEDIUM | Same as MEDIUM; never auto-resolved even with `--fix` |

**§5 User Interaction Template** (replaces the rejected `[待确认]` file-edit pattern):

SessionStart hook checks `memory/wiki/.unresolved.md`. If non-empty and not snoozed, surface **once per session**, max 3 entries shown:

```
Wiki has 1 unresolved contradiction:
  Entity: acme-corp
  Source A (memory/research/competitors/acme.md): DA=72
  Source B (memory/audits/domain/acme-cite.md): DA=68
Pick: (a) keep A · (b) keep B · (s) snooze 7d · (i) ignore for 90d
```

User response handling:
- **(a)/(b)** → `memory-management` rewrites compiled page (replace marker with chosen value), removes entry from `.unresolved.md`
- **(s)** → entry gains `snoozed_until: YYYY-MM-DD` (today+7); hook skips until that date
- **(i)** → entry gains `ignored_until: YYYY-MM-DD` (today+90); hook skips until that date, then resurfaces. Self-expiring; no permanent one-way doors
- **Freeform response** (e.g., "the second one looks more recent") → `memory-management` interprets in context; if it can map to (a)/(b) confidently, applies. If ambiguous, asks once: "Did you mean keep B (Source B / DA=68)?" before applying. Never resolves freeform without confirmation
- **No response / user changes topic** → entry stays in `.unresolved.md`; not re-shown this session; appears at next SessionStart unless snoozed/ignored

When >3 unresolved entries exist, show condensed: `"N unresolved contradictions. Run /aaron:guard --wiki for full list."`

**First-time UX**: when a contradiction surfaces in a session that has never seen the wiki layer prompt before (heuristic: no `.unresolved.md` mtime older than session start, or no prior `(a)/(b)/(s)/(i)` response in session log), prepend a one-shot banner: `"Wiki layer found a contradiction in your project records. Below: pick which value to keep, or defer."`. Banner shown once per project, not per session.

**§6 First-run migration** (existing v9.9.9 users):
- Existing `memory/wiki/index.md` valid as-is — no rebuild
- `memory/wiki/log.md`, `memory/wiki/.unresolved.md`, `memory/wiki/.drift-log` auto-created empty on first wiki operation
- Existing WARM files not auto-compiled — system never proactively prompts to compile on upgrade

**4.2.2 Modify [cross-cutting/memory-management/SKILL.md](../cross-cutting/memory-management/SKILL.md) lines 166-168** — replace 3-line placeholder with capped 30-line three-subsection block:

```markdown
### Wiki Layer

`memory-management` owns wiki schema and is the sole semantic writer. See [wiki-runbook.md](references/wiki-runbook.md) for execution detail.

#### Phase 1 — Index (auto-refreshed)
PostToolUse hook silently rebuilds `memory/wiki/index.md` after WARM writes. Index rows: precise (`score`/`status`/`next_action`/`mtime`) + best-effort (`summary`). Project-scoped index at `memory/wiki/<project>/index.md`. See [wiki-runbook.md §1](references/wiki-runbook.md).

#### Phase 2 — Compiled Pages (user-confirmed)
On user request or 3+ WARM mentions of an entity, generate `memory/wiki/<project>/<type>-<slug>.md` with source SHA-256 hashes. Contradictions resolved via SessionStart conversational prompt, not file editing. Write log entry to `memory/wiki/log.md`. See [wiki-runbook.md §2-§5](references/wiki-runbook.md).

#### Phase 3 — User-Initiated Retirement
WARM files fully covered by compiled wiki pages may be retired to `memory/archive/`. Always user-confirmed via `/aaron:guard --wiki --retire-preview` followed by explicit memory-management invocation. COLD files receive `originally_at` / `retired_on` / `retired_because_compiled` frontmatter to preserve recovery path. Single retire call hard-capped at 5 files. See [wiki-runbook.md §7](references/wiki-runbook.md).
```

**Verification**: `awk '/^### Wiki Layer/,/^### [^W]/' cross-cutting/memory-management/SKILL.md | wc -l` ≤ 30. Whole file ≤ 350.

**4.2.3 Modify [hooks/hooks.json:59](../hooks/hooks.json#L59)** — replace direct prompt with silent tally (debounce):

```json
{
  "type": "prompt",
  "prompt": "Phase 2 wiki: If file NOT inside memory/, produce NO output. If inside memory/ AND memory/wiki/ has compiled pages, compute shasum -a 256 of the written file (first 8 chars) and compare to compiled page frontmatter sources[].hash. If mismatch, silently append one line 'YYYY-MM-DD HH:MM <path> <old_hash> -> <new_hash>' to memory/wiki/.drift-log. Never prompt user from this hook. If memory/wiki/ absent or shasum unavailable, skip silently."
}
```

**4.2.4 Modify [hooks/hooks.json:17](../hooks/hooks.json#L17)** — append to existing SessionStart prompt. Each conditional gate must check **file existence first** (silent skip if absent) to handle pre-first-compile and post-rm-rf states gracefully:

```
If memory/wiki/.drift-log exists AND has ≥3 entries, mention once: 'N wiki pages have stale sources. Run /aaron:guard --wiki to review.' If memory/wiki/.unresolved.md exists AND has unsnoozed entries (no snoozed_until field, OR snoozed_until date in past, AND no ignored_until field with future date), surface up to 3 contradictions using the (a)/(b)/(s)/(i) template. If memory/wiki/ does NOT exist BUT memory/archive/ contains ≥1 file with originally_at: field in frontmatter, mention once: 'N retired files detected without active wiki layer. Run scripts/recover-retired-warm.sh to restore them, or ignore to keep them archived.' If none of the above conditions match, skip silently.
```

When `/aaron:guard --wiki` completes, `memory-management` clears `.drift-log`.

**4.2.5 Register Product API scenario + add routing triggers** — per the Product API Contract (introduced in commit `965acac`, see §1.2 A1), high-frequency routing additions MUST land as a scenario in [evals/product-api-scenarios.md](../evals/product-api-scenarios.md) first, then the natural-language triggers go into `commands/auto.md`.

**Commit ordering inside PR #2** (per Product API Contract "scenario first" rule and Plan agent #4 review):
1. **Commit A** — register scenarios in `evals/product-api-scenarios.md` (Step 1 below)
2. **Commit B** — exempt memory-management from pack-boundary in `commands/auto.md` rules paragraph (per §1.2 A2 carve-out text)
3. **Commit C** — add natural-language triggers to `commands/auto.md` (Step 2 below)

If PR #2 is reverted partially (commit C only), commits A+B remain — scenarios document intent, exemption stands. Verification: `git log --oneline PR#2 | tac | head -3 | head -1 | grep -qi scenario` (commit A first).

**Step 1 — Register scenarios** in `evals/product-api-scenarios.md` (append to existing list, inline-flow `eval-case` schema matching siblings; both scenarios use the chain syntax used by siblings like `auto-finance-landing-publish-001`):

```yaml
# Distinguishes from existing auto-memory-cleanup-001 (generic memory lifecycle ops):
# this scenario is wiki-page COMPILE specifically — captures WARM frontmatter into
# covered_warm[] for later C1-checkable retirement. Generic memory ops keep their
# existing /aaron:remember route via auto-memory-cleanup-001.
- {id: "auto-wiki-compile-001", type: "eval-case", status: "simulated", target_skill: "memory-management", scenario: "wiki_entity_synthesis", input_summary: "Product API scenario for wiki entity synthesis: compile a derived wiki page from ≥3 existing WARM sources referencing the entity.", expected_behavior: ["Route /aaron:remember -> memory-management wiki Phase 2 compile flow.", "Require risk gates: memory_or_entity_write, data_insufficient.", "Ask blocking inputs: entity name; minimum 3 existing WARM sources referencing the entity; project scope from hot-cache; explicit compile permission.", "Capture every source WARM's non-system frontmatter verbatim into compiled page covered_warm[].fields.", "Confirm before write; never compile from zero sources."], failure_modes: ["Must not compile from fewer than 3 WARM sources.", "Must not edit user's WARM files during compile.", "Must not skip covered_warm[] frontmatter capture (would invalidate future C1 retirement).", "Must not bypass memory-management as sole writer.", "Must not run without explicit user permission."], evolution_use: "Use when changing /aaron:auto routing for wiki compile or covered_warm[] schema.", scenario_family: "wiki_entity_synthesis", risk_gates: ["memory_or_entity_write","data_insufficient"], expected_route: "/aaron:remember", blocking_inputs: ["entity name","≥3 existing WARM sources referencing entity","project scope","explicit compile permission"], must_not: ["compile from zero sources","edit WARM files","skip covered_warm[] capture","let other skills write wiki","compile without explicit user permission"]}

# Distinguishes from existing auto-memory-cleanup-001: this is the wiki-aware
# retirement path (uses C1-C5 coverage check + originally_at recovery field).
# Generic memory cleanup without wiki coverage continues to route via
# auto-memory-cleanup-001 (no recovery guarantee — user accepts data loss).
- {id: "auto-wiki-retire-001", type: "eval-case", status: "simulated", target_skill: "memory-management", scenario: "wiki_warm_retirement", input_summary: "Product API scenario for project memory retirement when compiled wiki pages cover WARM sources (Phase 3).", expected_behavior: ["Two-step chain: /aaron:guard --wiki --retire-preview produces dry-run candidate report, then /aaron:remember invokes memory-management retire flow.", "Require risk gates: memory_or_entity_write.", "Ask blocking inputs: previous --retire-preview output in current session OR explicit user override; per-file or per-batch retire confirmation; cap-respect (5 per call, 20 per UTC day).", "Preserve recovery via originally_at field in COLD frontmatter."], failure_modes: ["Must not retire without preview output (or explicit override).", "Must not exceed safety caps.", "Must not retire WARM lacking C1-C5 coverage.", "Must not destroy recovery path (originally_at must be in COLD, not in wiki/).", "Must not retire without explicit per-file or per-batch confirmation."], evolution_use: "Use when changing Phase 3 retire flow or safety caps.", scenario_family: "wiki_warm_retirement", risk_gates: ["memory_or_entity_write"], expected_route: "/aaron:guard --wiki --retire-preview -> /aaron:remember", blocking_inputs: ["previous --retire-preview output OR explicit user override","explicit per-file or per-batch retire confirmation","day-cap not yet reached"], must_not: ["retire without preview or override","exceed 5/call or 20/day caps","retire uncovered WARM","destroy recovery path","retire without explicit confirmation"]}
```

**Step 2 — Modify [commands/auto.md](../commands/auto.md)** — add wiki triggers using **natural language**, not engineered SEO injections (per §1.2 A2 revised). Memory-management is exempt from the pack-boundary check (added via Commit B above), so triggers do not need an "SEO" keyword to clear scope. Safety is enforced by scenario-level gates, not keyword grep.

```
- "compile a wiki page on X" / "synthesize what we know about X" / "build entity page for X" /
  "what do we know about X" / "summarize our notes on X" /
  "整理一下X的资料" / "把X的研究汇总一下" / "整理X的研究"
  → memory-management (wiki Phase 2 compile flow; scenario auto-wiki-compile-001)
- "retire wiki sources for X" / "clean up old WARM files" / "archive old project notes" /
  "退役X的资料" / "清理旧的项目记录"
  → memory-management (wiki Phase 3 retire flow; scenario auto-wiki-retire-001)
- "restore retired file" / "undo last retire" / "bring back archived X" /
  "恢复退役的文件" / "撤销退役"
  → memory-management (wiki Phase 3 undo flow)
```

Disambiguation rules (handled by `memory-management`'s scenario-level pre-check):
- **Compile**: requires ≥3 existing WARM sources referencing the entity. If <3, decline with "Need ≥3 sources for X — currently have N. Run discovery/competitor analysis first to gather sources."
- **Retire**: requires `--retire-preview` output in current session OR explicit override phrase. If neither, respond with the preview output instead of executing.
- **Restore**: requires an existing archive file with `originally_at` field. If none, decline with "No retired files found. Phase 3 only retires via the documented flow (§5.4)."

Ambiguous phrasings ("tell me about X", "summarize X") that could match research/competitor-analysis OR wiki compile route to **lightweight triage first** — `memory-management` reads hot-cache + index, surfaces what's known, asks ONE clarifying question if action is needed. Eval `wiki-compile-routing-001` covers this disambiguation.

**Inter-PR fallback (PR #2 → PR #3 window)**: After PR #2 merges and before PR #3, the retire trigger routes to `memory-management` but `wiki-runbook.md` lacks §6 retire procedure. `memory-management` MUST detect this state (file-existence check on `wiki-runbook.md` + grep for `## §6`) and decline with: `"Phase 3 retire ships in v9.9.9 PR #3. To archive a single file manually now: mv memory/<path> memory/archive/$(date +%Y-%m-%d)-<slug>.md (no recovery path; not auto-restored by scripts/recover-retired-warm.sh)."` This avoids hallucinated half-shipped retire behavior in the inter-PR window.

**4.2.6 Modify [commands/remember.md](../commands/remember.md)** (rev4 — moved from PR #4 to PR #2 to avoid forward-reference). The current scope statement says memory-management owns "lifecycle, wiki, archive, cleanup, purge, and protocol aggregation" — the bare "wiki" mention is too generic for the Product API scenarios in §4.2.5 to route through cleanly. Replace with explicit operations:

```markdown
Memory-management owns: lifecycle (HOT/WARM/COLD), wiki (compile · query · contradiction-resolution · retire · restore), archive, cleanup, purge, and protocol aggregation. Phase 2/3 wiki operations require explicit user permission and follow the procedures in [wiki-runbook.md](../cross-cutting/memory-management/references/wiki-runbook.md).
```

This change is a 1-line scope expansion. Existing routing tests (`auto-memory-cleanup-001` etc.) continue to work — they predate Phase 2/3 and route via the unchanged "lifecycle" / "cleanup" terms.

---

### PR #3 — Phase 3 retirement + rollback integrity (~200 lines, medium-high risk)

**This PR has the highest risk because it must preserve the rollback invariant. Cannot merge without `scripts/validate-phase3-rollback.sh` passing all 4 fixture variants.**

**4.3.1 Retire-preview mode already shipped in PR #1** — `commands/guard.md` already has the `--retire-preview` workflow from §4.1.4. PR #3 does NOT modify guard.md further. The retire EXECUTION (not preview) is owned by `memory-management` invocation, not by the read-only `guard` command.

**4.3.2 Add §6 Retirement Workflow to [wiki-runbook.md](../cross-cutting/memory-management/references/wiki-runbook.md)** — see §5 below for full text.

**4.3.6a Check in [scripts/recover-retired-warm.sh](../scripts/recover-retired-warm.sh)** — full script body in §6.2 above. Must be `chmod +x`. The validator in §6.2 calls this script directly rather than reimplementing recovery inline.

**4.3.3 Expand [references/state-model.md:73-75](state-model.md#L73)** — current state-model has ~3 lines of Phase 3 placeholder content (single-line `/aaron:guard --wiki --retire-preview` reference plus terminal architecture mention). Replace those 3 lines with the full Phase 3 specification below:

```markdown
### Phase 3 — User-Initiated Retirement

WARM files covered by compiled wiki pages MAY be retired to `memory/archive/` on user request. Retirement is never automatic.

**Triggers**:
- `/aaron:guard --wiki --retire-preview` lists candidates (dry-run, never moves files)
- User explicitly says "retire <slug>" or "retire all safe candidates"

**Recovery invariant**: COLD files store `originally_at`, `retired_on`, and `retired_because_compiled` in their own frontmatter. `rm -rf memory/wiki/` does not destroy retirement history — recovery script in [wiki-runbook §7.6](../cross-cutting/memory-management/references/wiki-runbook.md) restores all retired files to their original WARM paths.

**Safety caps**:
- Single call: max 5 files
- Single day: max 20 files (tracked in `memory/wiki/.retire-day-log`)
- "Covered" requires C1-C5 hard checks (frontmatter coverage + hash match + 90-day mtime + not in hot-cache + ≥1 compile reference)

**Terminal architecture HOT/WIKI/COLD is a ceiling, not a goal**. Most projects will sit indefinitely in HOT/WARM/WIKI/COLD coexistence; full WARM retirement is opt-in optimization for projects with 50+ WARM files where storage hygiene matters.
```

**4.3.4 Modify [references/state-model.md](state-model.md) §WIKI Compilation View capacity table** — add new auxiliary files:

| File | Limit |
|------|-------|
| `memory/wiki/.unresolved.md` | 200 lines (overflow → memory-management archives oldest 50%) |
| `memory/wiki/.drift-log` | 200 lines (overflow → memory-management truncates to last 100) |
| `memory/wiki/.retire-day-log` | 30 lines (one per day, 30-day rolling window) |

**4.3.5 Update GDPR purge in [cross-cutting/memory-management/SKILL.md:238-239](../cross-cutting/memory-management/SKILL.md#L238)** — current step 3 spans lines 238-239 (multi-line list of canonical+derived surfaces). Add to that list:
```
- memory/wiki/.unresolved.md, memory/wiki/.drift-log, memory/wiki/.retire-day-log
- memory/archive/*.md frontmatter scan: grep -l "originally_at:.*<entity>" — purge entity name AND originally_at path string AND retired_because_compiled path string
```

The `originally_at` reverse-link in COLD requires GDPR purge to walk the archive frontmatter. This is ~3 lines of grep, acceptable.

**4.3.6 Create [scripts/validate-phase3-rollback.sh](../scripts/validate-phase3-rollback.sh)** — see §6.2 below.

**Merge gate**: `bash scripts/validate-phase3-rollback.sh` must exit 0.

---

### PR #4 — Sync + evals + cross-reference updates (~100 lines, low risk)

**4.4.1 Version bump 9.9.9 → 9.9.9** in 9 manifests. Run `/aaron:guard --versions --apply` to propagate:

| File | Action |
|---|---|
| `.claude-plugin/plugin.json` | `version: "9.9.9"` |
| `marketplace.json` (root) | `version: "9.9.9"` |
| `.claude-plugin/marketplace.json` | byte-identical copy |
| `gemini-extension.json` | `version: "9.9.9"` |
| `qwen-extension.json` | `version: "9.9.9"` |
| `.codebuddy-plugin/marketplace.json` | `version: "9.9.9"` |
| `VERSIONS.md` | new section v9.9.9 |
| `README.md` | Wiki Layer section update |
| `CLAUDE.md` | Wiki compilation view paragraph expansion |

**4.4.2 VERSIONS.md** new section:

```markdown
## v9.9.9 — Wiki Knowledge Layer Phase 2 + Phase 3 (2026-MM-DD)

- Phase 2 compiled pages with source SHA-256 hashes — `memory-management` writes, `/aaron:guard --wiki` lints
- Conversational contradiction reconciliation via SessionStart prompt (replaces deprecated `[待确认]` marker editing)
- Phase 3 user-initiated WARM retirement with `originally_at` reverse link in COLD frontmatter for full rollback recovery
- `wiki-lint` 7-check workflow restored into `/aaron:guard --wiki` (lost in v9.9.5 migration)
- Hash drift hook converted to silent tally (debounce); SessionStart surfaces only when threshold met
- New auxiliary files: `memory/wiki/log.md`, `memory/wiki/.unresolved.md`, `memory/wiki/.drift-log`, `memory/wiki/.retire-day-log`
- 11 new eval cases under `evals/memory-management/`
- 2 new Product API scenarios under `evals/product-api-scenarios.md` (`wiki_entity_synthesis`, `wiki_warm_retirement`)
- Recovery script `scripts/recover-retired-warm.sh` (checked in) and validator `scripts/validate-phase3-rollback.sh` exercise `rm -rf memory/wiki/` invariant
```

**4.4.3 README.md update** — Wiki Layer section paragraph add:
```
v9.9.9 ships Phase 2 (compiled pages with conversational reconciliation) and Phase 3 (user-initiated WARM retirement). Retired files survive `rm -rf memory/wiki/` — recovery via wiki-runbook §7.6 restore script.
```

**4.4.4 CLAUDE.md update** — replace existing Wiki Layer paragraph:
```
- Wiki compilation view: `memory/wiki/` — auto-refreshed structured index of WARM files (Phase 1), compiled pages with conversational reconciliation (Phase 2), and user-initiated WARM retirement to COLD with full recovery path (Phase 3). Project isolation via `<project>/index.md`. See [wiki-runbook.md](cross-cutting/memory-management/references/wiki-runbook.md). Delete `memory/wiki/` to revert without losing retirement history (COLD frontmatter preserves originally_at).
```

**4.4.5 Eval cases** — add **11** cases to [evals/memory-management/cases.md](../evals/memory-management/cases.md). Templates in §7 below.

**4.4.5b Product API scenarios** — actually registered in PR #2 (§4.2.5 Step 1, Commit A) — listed in PR #4 sync checklist only for completeness verification. The scenarios are `auto-wiki-compile-001` (`wiki_entity_synthesis`) and `auto-wiki-retire-001` (`wiki_warm_retirement`), in [evals/product-api-scenarios.md](../evals/product-api-scenarios.md).

> **Citation note (rev4 fix)**: `evals/product-api-scenarios.md` was introduced by commit `f5d5f0f` (Aaron command architecture migration), NOT by `965acac`. `965acac` formalized the [aaron-product-api-contract.md](aaron-product-api-contract.md) that governs use of this file. Both commits matter: file existence is from `f5d5f0f`; the "scenarios first" rule binding this proposal is from `965acac`.

**4.4.6 Cross-reference doc updates** — 6 files (`commands/remember.md` moved to PR #2 §4.2.6 in rev4):

| File | Change |
|---|---|
| [references/skill-contract.md](skill-contract.md) | Write Paths table: add `memory/wiki/log.md`, `.unresolved.md`, `.drift-log`, `.retire-day-log`. Confirm `memory-management` is sole writer of all wiki content. **No `retired_path` field anywhere** (rejected design). |
| [references/skill-resolver.md](skill-resolver.md) | Verify wiki references; add Phase 3 retire/restore routing |
| [references/evolution-protocol.md](evolution-protocol.md) | Verify wiki references stay accurate; no schema changes |
| [references/entity-geo-handoff-schema.md](entity-geo-handoff-schema.md) | Verify wiki references stay accurate; entity compile flow unchanged |
| [references/proposal-wiki-layer-v3.md](proposal-wiki-layer-v3.md) | Append note: "Update v9.9.9: wiki Phase 2 + wiki Phase 3 landed via [proposal-wiki-phase-2-3-completion.md](proposal-wiki-phase-2-3-completion.md). Conversational reconciliation replaces `[待确认]` file marker. `retired_path` design rejected; COLD frontmatter `originally_at` used instead." |
| [cross-cutting/memory-management/references/examples.md:85](../cross-cutting/memory-management/references/examples.md#L85) | Update Wiki Lint line: `/aaron:guard --wiki [--fix] [--project name] [--retire-preview]` (parens preserved — `--retire-preview` is now real) |
| [references/aaron-product-api-contract.md](aaron-product-api-contract.md) | **(Upstream `965acac`)** No changes required — wiki scenarios fit the existing contract. Verify the `Risk Gate Set` paragraph still lists `memory_or_entity_write` and `data_insufficient` (used by both new scenarios). |

**4.4.7 Modify [scripts/validate-slimming-guardrails.sh](../scripts/validate-slimming-guardrails.sh)** — two edits, both detailed in §6.2 above:
1. Define `changed_paths_match` helper near the top of the script (after existing `pass`/`fail`/`require_*` helpers). Helper does NOT exist on main — verified by Explore #3.
2. Append rollback validator hook AFTER the `fail "platform registry schema is constrained"` line (line **965** on main post-`965acac`, verified by Explore #1, NOT 967 as stated in earlier rev3).

---

## 5. Phase 3 Detailed Runbook (wiki-runbook.md §7)

This is the full text of the §6 added to wiki-runbook.md in PR #3.

### 5.1 §6.1 Triggers

- User explicitly invokes `/aaron:guard --wiki --retire-preview` to enumerate candidates
- User says "retire <slug>" or "retire all safe candidates" or Chinese equivalents
- `memory-management` **never** proactively suggests retirement (deliberate UX choice — addresses General agent's maintenance load concern)

### 5.2 §6.2 Safety Caps

- **Per call**: maximum 5 files. Larger requests split into batches with per-batch confirmation
- **Per day**: maximum 20 files. Day boundary is **UTC midnight** (not local time, not project switch). Tracked in `memory/wiki/.retire-day-log` (30-day rolling window)
- **Per file**: must pass C1-C5 (§6.3) before retirement
- **Day-log format**: one line per completed batch, fixed schema. Single space separator, no key=value form. Format: `YYYY-MM-DDTHH:MM:SSZ count`. Example:
  ```
  2026-05-01T03:14:22Z 5
  2026-05-01T08:22:01Z 3
  2026-05-02T12:00:00Z 2
  ```
- **Day-cap check**: `awk -v today="$(date -u +%Y-%m-%d)" '$1 ~ "^"today {sum += $2} END {exit (sum >= 20)}' memory/wiki/.retire-day-log`. Exit 0 = under cap, exit 1 = at/over cap (refuse new retire)
- **Rolling cleanup**: `memory-management` removes lines >30 days old at append time

When user requests >5 files, prompt: `"Retire batch 1/3 (5 files): a, b, c, d, e. Proceed?"`. After batch 1 confirms, repeat for batch 2/3.

### 5.3 §6.3 "Fully Covered" Hard Checks

All five must pass:

- **C1 — Frontmatter capture**: WARM file is referenced by some compiled page's `sources[]` AND that compiled page's `covered_warm[]` contains an entry with matching `path` whose `fields` map captures every non-system frontmatter field present in the current WARM file. "System fields" excluded from capture: `project`, `mtime`. All other fields (`name`, `description`, `type`, `score`, `status`, `next_action`, plus any custom fields) must be present in `covered_warm[].fields` with values matching the WARM exactly. **Multi-page edge case**: if WARM is referenced by ≥2 compiled pages, **all** referencing pages must independently satisfy C1 (not just one). This is mechanically verifiable: `yq` or hand-rolled YAML diff between WARM frontmatter and `covered_warm[].fields`.
- **C2 — Hash match**: WARM current `shasum -a 256 | cut -c1-8` equals the hash recorded in every compiled page's `sources[]` entry that references it (no drift)
- **C3 — Maturity**: WARM file mtime is older than 90 days (aligns with existing WARM→COLD natural demotion threshold from `state-model.md`)
- **C4 — Not in hot-cache**: `grep -l "<filename>" memory/hot-cache.md` returns empty
- **C5 — Reference count**: WARM is referenced by ≥1 compiled page (basic precondition)

`--retire-preview` output includes per-candidate safety column: `safe` (all 5 pass), `too-fresh` (C3 fails), `hash-mismatch` (C2 fails), `frontmatter-drift` (C1 fails — WARM has fields not captured in any covered_warm entry), `pinned` (C4 fails), `not-covered` (C5 fails — WARM referenced by no compiled page).

> Migration note for existing v10.0.x compiled pages without `covered_warm[]`: such pages cannot pass C1. `/aaron:guard --wiki --retire-preview` reports them as `frontmatter-drift` with hint "compile produced before v9.9.9; re-compile to enable retirement". User explicitly re-compiles to opt in. No automatic backfill.

### 5.4 §6.4 Atomic Retire Procedure (per file)

Steps must execute in order. Failure handling in §6.5.

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
4. **In-place edit archive frontmatter** (sed-based; do NOT awk-stream-pipe — the validator script in §6.2 enforces this exact procedure):
   ```yaml
   originally_at: memory/research/competitors/acme.md
   retired_on: 2026-05-01
   retired_because_compiled: memory/wiki/acme-q2/entity-acme-corp.md
   ```
   Insert these three lines immediately before the closing `---` of the frontmatter, leaving original fields and body untouched.
5. **Verify byte-identity** (the documented integrity check, command included so implementer doesn't reinvent it):
   ```bash
   diff <(awk 'BEGIN{fm=0} /^---$/{fm++; print; next} {print}' memory/research/competitors/acme.md) \
        <(awk 'BEGIN{fm=0}
               /^---$/{fm++; print; next}
               fm==1 && /^(originally_at|retired_on|retired_because_compiled):/ {next}
               {print}' "$archive")
   ```
   Expected: empty (zero diff). If diff non-empty → fail handler (§5.5 step 1-3 row): `rm "$archive"`, leave WARM untouched, report.
6. **Delete original WARM**:
   ```bash
   rm memory/research/competitors/acme.md
   ```
7. **Update compiled page** (audit only): append one line to compiled page body:
   ```
   Source files retired to archive on 2026-05-01.
   ```
   **Do not modify** `sources[].hash` — that hash is a historical snapshot; modifying breaks lint drift detection. **If body+append would exceed 200-line cap**: auto-trigger split per §4.2.1 §2 step 5 spill rule.
8. **Append log**:
   ```
   ## [2026-05-01 14:23] retire memory/research/competitors/acme.md
   - to: memory/archive/2026-05-01-acme.md
   - compiled_in: memory/wiki/acme-q2/entity-acme-corp.md
   - reason: covered (C1+C2+C3+C4+C5 passed)
   ```
9. **Append day-log**: write one line `YYYY-MM-DDTHH:MM:SSZ count` to `memory/wiki/.retire-day-log` (per §5.2 format). Roll cleanup: drop lines >30 days old.
10. **Touch index for refresh**: `touch memory/wiki/index.md`. PostToolUse hook only matches `Write|Edit`, not `rm` from step 6, so explicit touch is required to ensure index rebuild reflects the retire.

### 5.5 §6.5 Failure Handling (Partial Retire)

Step numbers reference §5.4 (10-step procedure). The integrity gate is at step 5 (byte-identity verify); after that, partial state is recoverable but not auto-rolled-back.

| Failed step | State | Recovery |
|---|---|---|
| 1 (pre-check) | Nothing changed | Report C1-C5 fail OR "source modified during preview" → user re-runs preview |
| 2-5 | Archive file may exist or be incomplete; WARM untouched | Delete archive file (`rm "$archive"`); WARM intact; report error to user |
| 6 | Archive complete, WARM still exists (both copies present) | **Do not auto-rollback** — possible user edit interleaved between step 5 verify and step 6 rm. Report: "Both files exist. Keep archive (`mv archive/X.md research/X.md && rm "$archive"`) or keep original (`rm "$archive"`)?" |
| 7-10 | Retire technically successful; only audit/index fields incomplete | Next `/aaron:guard --wiki` detects "WARM file referenced by sources but missing" and prompts for self-heal (re-runs steps 7-10) |

Never auto-rollback step 6+. Possible user edits between steps mean automated revert risks data loss.

### 5.6 §6.6 Recovery Workflow

**User-initiated undo (single file)**:

User says "restore <archive-filename>" or "undo last retire":

1. Read `memory/archive/<file>.md` frontmatter, extract `originally_at`
2. Check destination clear: `[ ! -e "$originally_at" ]` — if exists, abort with: `"<originally_at> already exists. Restore would overwrite. Move existing file first or pick different target."`
3. Copy back: `cp memory/archive/<file>.md "$originally_at"`
4. Strip retire-only fields from restored file: remove `originally_at`, `retired_on`, `retired_because_compiled`
5. Delete archive: `rm memory/archive/<file>.md`
6. Append log: `## [date] restore <archive> → <originally_at>`

**Recovery after `rm -rf memory/wiki/`** (the rollback invariant):

After Phase 3 retirement, if user deletes the entire wiki layer, all retired WARM files must still be recoverable. The COLD files are the source of truth.

Recovery script (place in user's path or run inline):

```bash
#!/usr/bin/env bash
# Recover all retired WARM files after wiki/ deletion.
set -e
recovered=0
for f in memory/archive/*.md; do
  [ -f "$f" ] || continue
  orig=$(awk '/^originally_at:/{print $2; exit}' "$f")
  [ -n "$orig" ] || continue
  if [ -e "$orig" ]; then
    echo "skip: $orig already exists (manual review needed for $f)"
    continue
  fi
  mkdir -p "$(dirname "$orig")"
  awk '
    BEGIN {in_fm=0}
    /^---$/ {in_fm=!in_fm; print; next}
    in_fm && /^(originally_at|retired_on|retired_because_compiled):/ {next}
    {print}
  ' "$f" > "$orig"
  rm "$f"
  recovered=$((recovered+1))
  echo "restored: $orig"
done
echo "Recovered $recovered files."
```

This script is documented in wiki-runbook §7.6 with copy-paste instructions. Users do not need to know it exists until they need it; recovery is discoverable via `/aaron:guard --wiki` reporting "no wiki/ found but N archived files have originally_at — recovery script in wiki-runbook §7.6".

### 5.7 §6.7 Retire-Preview Mode (commands/guard.md)

Workflow when `/aaron:guard --wiki --retire-preview` is invoked:

1. Glob `memory/wiki/<project>/*.md` (project isolation via hot-cache or `--project`)
2. Extract `sources[]` from each compiled page
3. For each referenced WARM file, run C1-C5
4. Output table:
   ```
   | WARM file | covered_by | mtime | safety |
   |---|---|---|---|
   | memory/research/competitors/acme.md | entity-acme-corp.md | 95d | safe |
   | memory/research/competitors/beta.md | entity-beta.md | 45d | too-fresh (C3) |
   | memory/research/keywords/seo-tools.md | (none) | 120d | not-covered (C5) |
   ```
5. Footer (mandatory exact text):
   > Found N retire candidates (M safe / K too-fresh / L hash-mismatch / J frontmatter-drift / I pinned / H not-covered).
   > To retire: tell memory-management 'retire <slug>' or 'retire all safe candidates'.
   > This command moved zero files.

`commands/guard.md` `allowed-tools: ["Read", "Glob", "Grep"]` structurally enforces no file moves possible from this command.

---

## 6. Rollback Invariant + Validation Script

### 6.1 The Invariant (Restated)

**`rm -rf memory/wiki/` after any Phase 3 retirement leaves all retired WARM files fully recoverable to their original paths via the recovery script in §5.6.**

This invariant is the difference between Phase 3 being safe and being a one-way door. It must be tested mechanically.

### 6.2 scripts/validate-phase3-rollback.sh (Merge Gate for PR #3)

The validator must exercise the **exact procedure documented in §5.4** (cp source to archive, then in-place edit archive frontmatter — never stream-pipe source through awk into archive). It must run a **fixture matrix** to catch CRLF, missing-trailing-newline, and multi-line YAML cases. It must call the **checked-in `scripts/recover-retired-warm.sh`** rather than reimplement recovery inline.

```bash
#!/usr/bin/env bash
# Validate Phase 3 rollback invariant against the documented retire procedure (§5.4)
# and the checked-in recovery script. Exits 0 only when all fixtures restore
# byte-identically. Tests four fixture variants:
#   1. plain LF, trailing newline (baseline)
#   2. plain LF, NO trailing newline
#   3. CRLF line endings
#   4. multi-line YAML value (block scalar)
# Each fixture: setup → retire (cp + edit) → rm wiki/ → run recover script → diff.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RECOVER_SCRIPT="$REPO_ROOT/scripts/recover-retired-warm.sh"

if [ ! -x "$RECOVER_SCRIPT" ]; then
  echo "FAIL: $RECOVER_SCRIPT missing or not executable. PR #3 must check it in."
  exit 1
fi

# ---------- helpers ----------

# Insert three retire fields into archive frontmatter, in place.
# Uses sed because awk getline-loop has portability hazards across BSD/GNU.
# Find first '---' (open), find next '---' (close), insert lines BEFORE close.
insert_retire_fields() {
  local file="$1" orig="$2" rdate="$3" compiled="$4"
  local close_line
  close_line=$(awk 'BEGIN{n=0} /^---$/{n++; if(n==2){print NR; exit}}' "$file")
  if [ -z "$close_line" ]; then
    echo "ERROR: no closing --- found in $file" >&2
    return 1
  fi
  # Insert three lines before close_line
  local tmp
  tmp=$(mktemp)
  awk -v cl="$close_line" -v orig="$orig" -v rdate="$rdate" -v compiled="$compiled" '
    NR==cl {
      print "originally_at: " orig
      print "retired_on: " rdate
      print "retired_because_compiled: " compiled
    }
    { print }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

# Run one fixture: name, WARM-content-generator-fn, expected-diff-after-recovery (always 0)
run_fixture() {
  local name="$1" gen_fn="$2"
  local TMPDIR
  TMPDIR=$(mktemp -d)
  trap "rm -rf '$TMPDIR'" RETURN

  mkdir -p "$TMPDIR/memory/research/competitors" \
           "$TMPDIR/memory/wiki/test-proj" \
           "$TMPDIR/memory/archive" \
           "$TMPDIR/snapshot"

  # Generate fixture WARM (caller-provided)
  $gen_fn "$TMPDIR/memory/research/competitors/fixture.md"

  # Snapshot
  cp "$TMPDIR/memory/research/competitors/fixture.md" "$TMPDIR/snapshot/fixture.md"

  # Compile fake wiki page (sources only — covered_warm[] not exercised here;
  # rollback invariant tests recovery, not C1)
  local H
  H=$(shasum -a 256 "$TMPDIR/memory/research/competitors/fixture.md" | cut -c1-8)
  cat > "$TMPDIR/memory/wiki/test-proj/entity-fixture.md" <<EOF
---
name: entity-fixture
type: entity
project: test-proj
sources:
  - path: memory/research/competitors/fixture.md
    hash: $H
last_compiled: 2026-05-01
---
Compiled body.
EOF

  # Retire per §5.4: cp source to archive, then in-place edit archive
  local DATE="2026-05-01"
  local src="$TMPDIR/memory/research/competitors/fixture.md"
  local archive="$TMPDIR/memory/archive/$DATE-fixture.md"
  cp "$src" "$archive"
  insert_retire_fields "$archive" \
    "memory/research/competitors/fixture.md" \
    "$DATE" \
    "memory/wiki/test-proj/entity-fixture.md"
  rm "$src"

  # Delete wiki layer entirely
  rm -rf "$TMPDIR/memory/wiki"

  # Run recovery via the checked-in script
  ( cd "$TMPDIR" && "$RECOVER_SCRIPT" >/dev/null )

  # Diff
  if ! diff -u "$TMPDIR/snapshot/fixture.md" \
              "$TMPDIR/memory/research/competitors/fixture.md"; then
    echo "FAIL [$name]: not byte-identical after recovery"
    return 1
  fi

  echo "PASS [$name]"
  return 0
}

# ---------- fixture generators ----------

gen_plain() {
  cat > "$1" <<'EOF'
---
name: fake-competitor
type: research
description: Test fixture
score: 78
---
Body content. Multiple lines. Some keywords.
EOF
}

gen_no_trailing_newline() {
  printf -- '---\nname: fake-competitor\ntype: research\ndescription: No trailing NL\n---\nBody, no trailing newline.' > "$1"
}

gen_crlf() {
  # Generate file with CRLF line endings
  awk 'BEGIN{
    print "---\r"
    print "name: fake-competitor\r"
    print "type: research\r"
    print "description: CRLF fixture\r"
    print "---\r"
    print "Body with CRLF endings.\r"
  }' > "$1"
}

gen_multiline_yaml() {
  cat > "$1" <<'EOF'
---
name: fake-competitor
type: research
description: |
  This is a multi-line description.
  It spans several lines.
  All preserved.
score: 78
---
Body content.
EOF
}

# ---------- run all fixtures ----------

failed=0
run_fixture "plain"             gen_plain             || failed=$((failed+1))
run_fixture "no-trailing-NL"    gen_no_trailing_newline || failed=$((failed+1))
run_fixture "CRLF"              gen_crlf              || failed=$((failed+1))
run_fixture "multi-line YAML"   gen_multiline_yaml    || failed=$((failed+1))

if [ "$failed" -ne 0 ]; then
  echo "RESULT: $failed fixture(s) failed"
  exit 1
fi

echo "RESULT: all 4 fixtures passed; rollback invariant holds"
exit 0
```

The companion **`scripts/recover-retired-warm.sh`** (checked in by PR #3, see §4.3.6 + §12 Q4):

```bash
#!/usr/bin/env bash
# Recover all retired WARM files after memory/wiki/ deletion (or any time
# user wants to undo Phase 3 retirements). Run from repo root.
# Reads memory/archive/*.md frontmatter; restores files referenced by
# originally_at to their pre-retire paths. Skips files already present at
# destination (manual-review safety). Skips archived files lacking
# originally_at (legacy or non-Phase-3 archives).

set -euo pipefail

recovered=0
skipped_collision=0
skipped_legacy=0

for f in memory/archive/*.md; do
  [ -f "$f" ] || continue
  orig=$(awk '/^originally_at:/{print $2; exit}' "$f")
  if [ -z "$orig" ]; then
    skipped_legacy=$((skipped_legacy+1))
    continue
  fi
  if [ -e "$orig" ]; then
    echo "skip-collision: $orig already exists (manual review needed for $f)"
    skipped_collision=$((skipped_collision+1))
    continue
  fi
  mkdir -p "$(dirname "$orig")"
  # Strip retire-only fields while restoring
  awk '
    BEGIN { in_fm = 0 }
    /^---$/ { in_fm = !in_fm; print; next }
    in_fm && /^(originally_at|retired_on|retired_because_compiled):/ { next }
    { print }
  ' "$f" > "$orig"
  rm "$f"
  recovered=$((recovered+1))
  echo "restored: $orig"
done

echo "Recovered $recovered file(s). Skipped $skipped_collision collision(s), $skipped_legacy legacy archive(s)."
[ "$skipped_collision" -gt 0 ] && exit 2 || exit 0
```

Note exit codes: `0` = clean recovery, `2` = recovery with collisions (some files skipped — caller should review), `1` = hard error. The validator script in §6.2 expects exit 0; partial-recovery testing (eval `wiki-phase3-rollback-002`) covers exit 2.

`scripts/validate-slimming-guardrails.sh` will be modified to call the rollback validator when `wiki-runbook.md §7`, `scripts/recover-retired-warm.sh`, or `scripts/validate-phase3-rollback.sh` is touched.

**Insertion position** (per §1.2 A3, verified by Explore #1): commit `965acac` added OpenClaw bundle and platform registry validation at lines 956-965 of the script (the broader OpenClaw block spans ~942-965). The new wiki-rollback hook MUST be inserted **after** the closing line `fail "platform registry schema is constrained"` (line 965 on main post-`965acac`). Inserting before that block risks triggering the platform registry's `jq -e` schema check on intermediate state.

**`changed_paths_match` does NOT exist** in `validate-slimming-guardrails.sh` on main (verified by Explore #3 + Plan #5). PR #3 must define it. Insert this helper definition **once, near the top of the script** (after existing `pass`/`fail`/`require_*` helpers, before any user of it):

```bash
# Returns 0 if any file changed in HEAD (vs HEAD~1) matches the regex pattern.
# Returns 1 if no match, no prior commit, or git unavailable.
# Used by wiki phase 3 rollback gate to skip expensive validator on unrelated PRs.
changed_paths_match() {
  local pattern="$1"
  git rev-parse HEAD~1 >/dev/null 2>&1 || return 1
  git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -Eq "$pattern"
}
```

Then **append** the wiki-rollback gate **after** the `fail "platform registry schema is constrained"` block:

```bash
# Wiki Phase 3 rollback gate (added in v9.9.9)
if [ -x "$ROOT/scripts/validate-phase3-rollback.sh" ]; then
  if changed_paths_match "cross-cutting/memory-management/references/wiki-runbook.md|scripts/recover-retired-warm.sh|scripts/validate-phase3-rollback.sh"; then
    if "$ROOT/scripts/validate-phase3-rollback.sh" >/dev/null 2>&1; then
      pass "wiki phase 3 rollback invariant holds"
    else
      fail "wiki phase 3 rollback invariant broken (run scripts/validate-phase3-rollback.sh manually for details)"
    fi
  fi
fi
```

**Performance note**: when `changed_paths_match` returns false (the common case for PRs that don't touch wiki phase 3 surface), the validator is skipped entirely — zero cost on unrelated PRs. When it does run, the 4-fixture validator typically completes in <5s on local SSD; CI may be slower but bounded. The helper-gated approach is preferable to "always run" because the rev3 review pass observed every guardrails invocation pays the cost otherwise.

---

## 7. Eval Cases (11 total, in evals/memory-management/cases.md)

```yaml
{id: wiki-compile-001, type: eval-case, status: simulated, target_skill: memory-management, scenario: "User requests compile of entity page from 3 WARM sources.", input_summary: "Compile entity page for acme-corp from research/competitors/acme.md, audits/domain/acme-cite.md, monitoring/serp/acme.md.", expected_behavior: ["Confirm before write.", "Write frontmatter with name/type/project/sources[].path/sources[].hash/covered_warm[]/last_compiled.", "covered_warm[].fields captures every non-system frontmatter field of each source WARM verbatim.", "Hash is shasum -a 256 first 8 chars.", "Append log.md entry with operation type, slug, sources count.", "Trigger PostToolUse index refresh."], failure_modes: ["Silent compile without confirmation.", "Missing required frontmatter field.", "covered_warm[] absent or partial (would invalidate future C1 retirement check).", "Wrong hash format.", "No log entry."], evolution_use: "Use when changing Phase 2 compile semantics or covered_warm[] schema."}

{id: wiki-contradict-medium-001, type: eval-case, status: simulated, target_skill: memory-management, scenario: "Two WARM files give conflicting DA score for same entity.", input_summary: "research/competitors/acme.md says DA=72, audits/domain/acme-cite.md says DA=68.", expected_behavior: ["Mark both values in compiled page body with [CONTRADICTION-{id}].", "Append entry to memory/wiki/.unresolved.md with id, value-A, value-B, source-A, source-B.", "Surface in next SessionStart conversational prompt with (a)/(b)/(s)/(i) options.", "Resolve by user choice; remove marker from compiled page; remove entry from .unresolved.md."], failure_modes: ["Picks one value silently.", "Edits user's WARM files.", "Loops on prompt across sessions without snooze respect.", "Forgets to remove marker after resolution."], evolution_use: "Use when changing Phase 2 reconciliation UX."}

{id: wiki-hash-drift-noop-001, type: eval-case, status: simulated, target_skill: memory-management, scenario: "WARM file edit triggers PostToolUse hook but only 1 drift accumulated.", input_summary: "Edit memory/research/competitors/acme.md when only 1 prior drift in .drift-log.", expected_behavior: ["Silently append to memory/wiki/.drift-log.", "Do NOT prompt user during this turn.", "Do NOT modify compiled page.", "SessionStart only surfaces drift notice when ≥3 entries accumulate."], failure_modes: ["Prompts user on first or second drift.", "Modifies compiled page from hook.", "Surfaces single drift at SessionStart."], evolution_use: "Use when changing hook debounce threshold."}

{id: wiki-project-isolation-001, type: eval-case, status: simulated, target_skill: memory-management, scenario: "User runs /aaron:guard --wiki --project foo with multiple projects active.", input_summary: "Two projects (foo, bar) each have compiled pages; user lints only foo.", expected_behavior: ["Lint scans only memory/wiki/foo/.", "bar project's pages untouched and unmentioned.", "Report scoped to foo entities only.", "log.md entry includes project=foo scope."], failure_modes: ["Cross-project leakage in report.", "Lints global index when project specified.", "Modifies bar project files."], evolution_use: "Use when changing project-scoped lint behavior."}

{id: wiki-rollback-phase2-001, type: eval-case, status: simulated, target_skill: memory-management, scenario: "User runs rm -rf memory/wiki/ after Phase 2 in active use (no Phase 3 retirement).", input_summary: "Delete entire wiki/ directory after compile + lint workflow.", expected_behavior: ["Next SessionStart loads cleanly with no errors.", "WARM files intact and byte-identical.", "No orphan references in memory/ outside wiki/.", "/aaron:guard --wiki returns 'wiki not initialized' message.", "No archived files have originally_at field (Phase 3 not used)."], failure_modes: ["Hook crashes on missing wiki/.", "Modifies WARM during recovery.", "Reports drift errors after deletion."], evolution_use: "Use when changing wiki initialization or hook safety."}

{id: wiki-retire-preview-001, type: eval-case, status: simulated, target_skill: memory-management, scenario: "User invokes /aaron:guard --wiki --retire-preview after compiling 2 entity pages covering 6 WARM files.", input_summary: "Mix of safety states: 2 WARM >90d with hash-match AND covered_warm[] complete (safe), 1 WARM >90d with hash drift, 2 WARM <90d (too-fresh), 1 WARM compiled before v9.9.9 lacking covered_warm[] (frontmatter-drift migration case).", expected_behavior: ["Output table lists all 6 WARM files with per-candidate safety column.", "2 marked 'safe' (C1+C2+C3+C4+C5 pass — covered_warm[].fields captures all WARM frontmatter exactly + hash match + >90d + not-pinned + ≥1 reference).", "1 marked 'hash-mismatch' (C2 fail).", "2 marked 'too-fresh' (C3 fail).", "1 marked 'frontmatter-drift' with hint 'compile produced before v9.9.9; re-compile to enable retirement' (C1 fail due to missing covered_warm[]).", "Footer states 'This command moved zero files.'", "No file in memory/ modified after command."], failure_modes: ["Moves any file (allowed-tools constraint failed).", "Misses any candidate.", "Wrong safety classification.", "C1 implementation falls back to substring matching of WARM body content (would always fail).", "Footer missing or wrong wording.", "Migration hint absent for legacy compiled pages."], evolution_use: "Use when changing C1-C5 hard checks or covered_warm[] schema."}

{id: wiki-retire-cap-001, type: eval-case, status: simulated, target_skill: memory-management, scenario: "User says 'retire all safe candidates' when 12 are safe.", input_summary: "12 WARM files all pass C1-C5.", expected_behavior: ["memory-management splits into 3 batches: batch 1/3 (5 files), batch 2/3 (5 files), batch 3/3 (2 files).", "Per-batch confirmation requested.", "If user declines batch 2, batches 1 confirmed and executed; 2 and 3 skipped.", "Update memory/wiki/.retire-day-log with each completed batch.", "Refuse if .retire-day-log shows ≥20 today."], failure_modes: ["Single-call exceeds 5 files.", "Missing per-batch confirmation.", "Day-log not updated.", "Doesn't enforce 20/day limit."], evolution_use: "Use when changing safety cap thresholds."}

{id: wiki-phase3-rollback-001, type: eval-case, status: simulated, target_skill: memory-management, scenario: "User retires 3 WARM files via Phase 3 then rm -rf memory/wiki/.", input_summary: "Retire 3 files via complete §5.4 procedure, then delete wiki/, then run scripts/recover-retired-warm.sh.", expected_behavior: ["3 archived files survive in memory/archive/ after wiki/ deletion.", "Each archived file has intact originally_at, retired_on, retired_because_compiled fields.", "scripts/recover-retired-warm.sh restores all 3 to original WARM paths.", "Restored files byte-identical to pre-retire state (excluding mtime).", "Restored files have NO originally_at/retired_on/retired_because_compiled fields.", "scripts/recover-retired-warm.sh exits 0.", "scripts/validate-phase3-rollback.sh passes all 4 fixture variants (plain / no-trailing-NL / CRLF / multi-line YAML)."], failure_modes: ["originally_at field stored only in wiki/ (lost on rm).", "Archive file content corrupted.", "Restore script fails on any fixture variant.", "WARM not byte-identical after restore.", "Restored files retain retire-only fields."], evolution_use: "Use when changing Phase 3 retire/restore semantics. CRITICAL: this is the merge gate for PR #3."}

{id: wiki-phase3-rollback-002, type: eval-case, status: simulated, target_skill: memory-management, scenario: "Recovery encounters destination collisions — 5 archived files but 2 destinations are already occupied.", input_summary: "User has 5 retired files in memory/archive/, then manually creates files at 2 of the originally_at paths, then runs scripts/recover-retired-warm.sh.", expected_behavior: ["Script restores 3 non-colliding files to their originally_at paths.", "Script reports 2 'skip-collision: <path> already exists' lines.", "Restored 3 are byte-identical to pre-retire state.", "Skipped 2 archive files remain intact in memory/archive/ (untouched).", "Script exits 2 (partial recovery exit code, not 0 and not 1).", "Final summary line correctly counts: 'Recovered 3 file(s). Skipped 2 collision(s), 0 legacy archive(s).'"], failure_modes: ["Overwrites existing file at collision path.", "Deletes archive file even when collision skipped.", "Exits 0 (would mask partial state).", "Exits 1 (would suggest hard error when skip is intentional)."], evolution_use: "Use when changing recovery script collision handling or exit codes."}

{id: wiki-compile-routing-001, type: eval-case, status: simulated, target_skill: memory-management, scenario: "User says 'tell me about Acme' or '整理一下我们对Acme的认识' but no WARM files mention Acme.", input_summary: "Project has zero WARM files referencing Acme entity. User invokes synthesize/compile-style trigger.", expected_behavior: ["Auto-routing does NOT route to wiki compile flow when zero WARM sources exist for the entity.", "Routing prefers competitor-analysis or entity-optimizer or research depending on phrasing.", "If user explicitly says 'compile wiki page for Acme' (not the ambiguous 'tell me about'), respond with: 'No WARM sources for Acme found. Would you like to research first, or compile from manually-provided content?'", "Never silently creates a wiki page from no sources."], failure_modes: ["Routes ambiguous 'tell me about X' to compile flow.", "Compiles a wiki page with empty sources[].", "Misroutes between compile / competitor-analysis / entity-optimizer."], evolution_use: "Use when changing auto.md compile triggers or disambiguation rules."}

{id: wiki-manual-archive-detect-001, type: eval-case, status: simulated, target_skill: memory-management, scenario: "User manually moves a WARM file to memory/archive/ without using the Phase 3 procedure (no originally_at field).", input_summary: "User runs 'mv memory/research/competitors/x.md memory/archive/2026-05-01-x.md' directly. Then later runs /aaron:guard --wiki.", expected_behavior: ["/aaron:guard --wiki detects archive files lacking originally_at.", "Lint reports: 'N archive file(s) created outside Phase 3 retire flow — these will not auto-recover via scripts/recover-retired-warm.sh. Was this intentional?'", "Lint does NOT modify the archive files.", "Lint suggests next steps: 'To enable recovery, run memory-management retire on the original (would re-archive properly), or add originally_at field manually.'"], failure_modes: ["Lint silently ignores manually-archived files.", "Lint auto-adds originally_at without confirmation (could be wrong path).", "Lint deletes the archive file.", "Lint mistakenly classifies as legitimate Phase 3 archive."], evolution_use: "Use when changing wiki-lint manual-archive detection."}
```

---

## 8. Sync Checklist (Tracking)

For PR #4 reviewer to walk through:

- [ ] `.claude-plugin/plugin.json` → 9.9.9
- [ ] `marketplace.json` (root) → 9.9.9, byte-identical to `.claude-plugin/marketplace.json`
- [ ] `.claude-plugin/marketplace.json` → 9.9.9
- [ ] `gemini-extension.json` → 9.9.9
- [ ] `qwen-extension.json` → 9.9.9
- [ ] `.codebuddy-plugin/marketplace.json` → 9.9.9
- [ ] `VERSIONS.md` → new section per §4.4.2
- [ ] `README.md` → Wiki Layer paragraph per §4.4.3
- [ ] `CLAUDE.md` → Wiki compilation view paragraph per §4.4.4
- [ ] `commands/remember.md` → wiki retire/restore in scope
- [ ] `references/skill-contract.md` → Write Paths table updated; no `retired_path` field
- [ ] `references/skill-resolver.md` → Phase 3 routing added
- [ ] `references/evolution-protocol.md` → wiki references verified
- [ ] `references/entity-geo-handoff-schema.md` → wiki references verified
- [ ] `references/proposal-wiki-layer-v3.md` → update note appended
- [ ] `cross-cutting/memory-management/references/examples.md` → `--retire-preview` reactivated
- [ ] `evals/memory-management/cases.md` → 11 new cases per §7
- [ ] `evals/product-api-scenarios.md` → 2 new scenarios per §4.2.5 (`auto-wiki-compile-001`, `auto-wiki-retire-001`)
- [ ] `commands/auto.md` → SEO/GEO-contextualized wiki triggers added (per §4.2.5, references scenario IDs)
- [ ] `scripts/recover-retired-warm.sh` → checked in, executable, tested
- [ ] `scripts/validate-phase3-rollback.sh` → created, tested, executable
- [ ] `scripts/validate-slimming-guardrails.sh` → calls rollback validator AFTER platform registry block (per §1.2 A3)
- [ ] Implementation branch rebased onto `main` (post-`965acac`) before PR #1 starts
- [ ] `/aaron:guard --release` passes
- [ ] `/aaron:guard --contracts` passes (SKILL.md ≤350, §Wiki Layer ≤30)
- [ ] `/aaron:guard --evals` reports 11 new memory-management cases passing
- [ ] `bash scripts/validate-phase3-rollback.sh` exits 0 (all 4 fixture variants)
- [ ] No PR/commit message uses bare "Phase 2/3" — always "wiki Phase 2/3" (per §1.1)

---

## 9. Residual Risks

Risks that survive the redesigned data model. These are accepted, not blocking.

| Risk | Mitigation | Residual |
|---|---|---|
| User manually edits archive file post-retire; restore overwrites those edits | Restore prompts: "archive file mtime > retire time, manually edited?" before proceeding | Low |
| Same WARM referenced by 2 compiled pages, only 1 fully covers it | C1 modified to require **all** referencing compiled pages independently satisfy C1 (not any single one) | Resolved by design |
| `originally_at` path collision (user creates new WARM at original path post-retire) | Restore checks `[ ! -e "$orig" ]`; recovery script returns exit 2 with skip-collision report | Low |
| Same-day archive filename collision (two retires of same slug same UTC day) | §5.4 step 2 appends `-HHMMSS` suffix; further collision aborts with hard error | Low |
| GDPR purge misses substring inside `originally_at` / `retired_because_compiled` fields | Step 3 explicitly greps both fields in archive frontmatter | Resolved |
| User deletes wiki/ without knowing recovery exists | SessionStart hook (§4.2.4) detects archive-with-no-wiki state and surfaces recovery hint; README + CLAUDE.md call out recovery | Low (passively discoverable) |
| `shasum` unavailable on user's system | Compile aborts with clear error message; no silent skip | Low |
| 3-second hook timeout drops drift logging under load | Documented behavior; users with >50 WARM and frequent edits should run `/aaron:guard --wiki` weekly to catch drifts | Low (workflow workaround) |
| `.unresolved.md` ignored entries auto-resurface after 90 days, may surprise user | UX shows ignore_until date when prompting; user can re-ignore for another 90d | Low |
| Manual archives (user `mv` without using procedure) skipped by recovery | Eval `wiki-manual-archive-detect-001` covers lint detection; user gets clear warning at next `/aaron:guard --wiki` | Low (lint catches it) |

### 9.1 Concurrency Scenarios (single user, multiple Claude sessions or IDE auto-save)

Three realistic scenarios are explicitly handled:

**Scenario A — Compile reads source while parallel session retires it**:
Session 1 starts compile of entity-X (collects sources WARM-A, WARM-B, computes hashes). Session 2 retires WARM-A using a previously compiled page that already covers it. Session 1 writes new compiled page citing WARM-A by path; WARM-A is now in `memory/archive/`.

- **Mitigation**: §4.2.1 §2 step 3 has a re-shasum gate at step 5 (write phase). If any source mtime advanced between collect and write, compile aborts with "source modified during compile; re-run". User re-runs compile; the second run sees WARM-A as no longer present and reports cleanly.
- **Residual**: Low. Window is small (seconds); user retry is the recovery.

**Scenario B — IDE auto-save during compile**:
User starts compile in Claude session. Mid-compile (between hash collection and write), their IDE auto-saves an open WARM-B with whitespace-only changes. PostToolUse hook fires and silently logs hash drift (Phase 2 hook from §4.2.3). Compile continues with pre-edit hash, writes compiled page citing pre-edit hash. Drift log immediately shows mismatch on the brand-new compiled page.

- **Mitigation**: same re-shasum gate as Scenario A. Compile detects mid-flight write and aborts. If user explicitly says "ignore IDE auto-save churn, proceed anyway" — `memory-management` may proceed once with a flag, treating the compile as advisory; lint will still flag drift on next run.
- **Residual**: Low. IDE auto-save typically doesn't change content (whitespace-only) but Claude can't tell from hash alone.

**Scenario C — Retire's `rm` doesn't trigger PostToolUse**:
§5.4 step 6 deletes WARM. Existing PostToolUse hook (`hooks.json`) only matches `Write|Edit`, not deletion. Index becomes stale (still references retired WARM until next manual write).

- **Mitigation**: §5.4 step 10 explicitly adds `touch memory/wiki/index.md` at end of retire procedure to force index rebuild on next session via mtime change detection. Index drift window: zero seconds within retire; whole rebuild is delegated to PostToolUse hook by virtue of the touch.
- **Residual**: Low. Touch is cheap; failure to touch falls back to next compile/lint detecting orphan and prompting refresh.

---

## 10. Future Work (Explicitly Out of Scope for v9.9.9)

Captured here so future maintainers don't relitigate decisions:

- **Auto-compile**: requires confidence model for entity disambiguation; reconsider after 6 months of Phase 2 usage data
- **Cross-project entity merging**: requires global entity registry; would conflict with current project isolation invariant
- **Wiki page export**: separate concern; could reuse compile schema as portable format
- **Performance tuning for >500 WARM files**: current implementation is O(n) for index refresh; revisit when complaints arise
- **Auto-archive of `ignored: true` entries**: low-priority cleanup automation
- **Reconciliation memory**: remember user choices to auto-resolve future similar contradictions; risky (could mask real disagreements) — needs design

---

## 11. Acceptance Criteria

This proposal is implementation-complete when:

1. All 4 PRs merged in order (#1 → #2 → #3 → #4)
2. All **13** wiki eval cases pass under `/aaron:guard --evals` (11 from v9.9.9: compile-001, contradict-medium-001, hash-drift-noop-001, project-isolation-001, rollback-phase2-001, retire-preview-001, retire-cap-001, phase3-rollback-001, phase3-rollback-002, compile-routing-001, manual-archive-detect-001; +2 from v9.9.9: restore-001, show-deferred-001)
3. `bash scripts/validate-phase3-rollback.sh` exits 0 in clean checkout (passes all 4 fixture variants: plain / no-trailing-NL / CRLF / multi-line YAML)
4. `bash scripts/recover-retired-warm.sh` exists, is executable, and is invoked by the validator (not reimplemented inline)
5. `/aaron:guard --release` reports no version drift across **9** manifests (`.claude-plugin/plugin.json`, root `marketplace.json`, `.claude-plugin/marketplace.json`, `gemini-extension.json`, `qwen-extension.json`, `.codebuddy-plugin/marketplace.json`, `VERSIONS.md`, `README.md`, `CLAUDE.md`)
6. `/aaron:guard --contracts` reports SKILL.md within line budget (≤350 total, §Wiki Layer ≤30)
7. `/aaron:guard --wiki` runs end-to-end on a project with ≥3 compiled pages with no errors
8. `/aaron:guard --wiki --retire-preview` runs on a project with no compiled pages and prints "No compiled pages found. Run compile flow first." (graceful empty-state handling)
9. Manual smoke: compile → introduce contradiction → SessionStart prompt appears → user resolves → marker removed
10. Manual smoke: retire 3 files → `rm -rf memory/wiki/` → SessionStart hook surfaces recovery hint → user runs recovery script → all 3 restored byte-identically

---

## 12. Decisions and Remaining Open Questions

### 12.1 Decisions (locked, no further discussion needed)

These were open in the v1 draft; review feedback closed them. Listed here so PR authors don't relitigate.

- **D1. `.unresolved.md` format**: **YAML list of entries**, not markdown blocks. Rationale: machine-parseable, hand-editable with structural validation by power users, round-trips cleanly through programmatic snooze/ignore-until updates. Markdown blocks were considered but rejected — silent parse failure mode if user mis-edits is too risky for a SessionStart-driven UX. Schema:
  ```yaml
  - id: contradiction-001
    entity: acme-corp
    field: DA
    value_a: 72
    source_a: memory/research/competitors/acme.md
    value_b: 68
    source_b: memory/audits/domain/acme-cite.md
    confidence: medium
    created_at: 2026-05-01
    snoozed_until: null      # or YYYY-MM-DD
    ignored_until: null      # or YYYY-MM-DD (90 days from ignore)
  ```
- **D2. HIGH-confidence auto-resolution logging**: yes, append to `log.md` as `## [date] compile <slug> sources=N contradictions=M auto_resolved=K`. The `auto_resolved` count gives users visibility into automated decisions without surfacing each one.
- **D3. SessionStart prompt path display**: full paths (e.g., `memory/research/competitors/acme.md`), not abbreviated. Source attribution is required for the user to make an informed pick; abbreviation saves screen real estate at the cost of context.
- **D4. Recovery script check-in**: **checked in** at `scripts/recover-retired-warm.sh` as part of PR #3 (see §4.3.6a). Documentation-only was rejected — Phase 3's safety promise depends on this being runnable, not just readable. The validator script in §6.2 calls this script directly rather than reimplementing recovery.
- **D5. `.retire-day-log` boundary**: **UTC midnight**. Local time creates ambiguity across DST transitions and traveling users; project rotation creates hidden coupling between project switches and retire counts. UTC is universal.
- **D6. Retire without compile coverage**: **not allowed via override flag**. That operation is just file move — user can `mv memory/x.md memory/archive/<date>-x.md` directly. Phase 3 specifically retires files because compile pages cover them; without coverage, there's nothing distinguishing the operation from a manual archive.

### 12.2 Open Questions (still need decision before relevant PR)

To resolve before/during PR #2:

- (none — D1/D2/D3 close all PR #2 questions)

To resolve before/during PR #3:

- **OQ1. Day-log retention beyond 30 days**: spec says rolling 30-day window, but does the rotated content go anywhere (audit / GDPR)? Recommend: dropped, not archived — it's a rate limit log, not an audit log; the actual retire events are recorded in `memory/wiki/log.md` permanently.
- **OQ2. Should the retire procedure write to `memory/wiki/log.md` even when the wiki has been deleted (recovery-only state)?** Edge case: user already ran `rm -rf memory/wiki/` then asks "retire X" — should `memory-management` refuse, or recreate `memory/wiki/log.md` to record the operation? Recommend: refuse with "wiki layer not initialized; restore via scripts/recover-retired-warm.sh first or run `/aaron:remember` to bootstrap fresh".

To resolve before/during PR #4:

- (none)

---

## 13. Document History

- **2026-05-01**: Initial draft (this document)
- **2026-05-01 rev2**: Multi-agent review pass — fixed 2 RED (C1 unimplementable, validator script bugs) + 8 YELLOW (forward-refs, SKILL.md size, allowed-tools wording, etc.). Added 3 evals (rollback-002, compile-routing-001, manual-archive-detect-001). Total eval count 8 → 11.
- **2026-05-01 rev3**: Upstream-adaptation pass for commit `965acac docs: position seo-geo as slash-aaron anchor pack`. Added §1.1 (wiki Phase 2/3 vs anchor-pack Phase 2/3 disambiguation) and §1.2 (3 adaptations A1/A2/A3). Split §4.2.5 routing into scenario-first → triggers-second per Product API Contract. Sharpened wiki routing trigger phrasing for SEO/GEO scope. Added §4.4.5b (Product API scenario registration) and §4.4.7 (validate-slimming-guardrails.sh insertion position). Sync checklist gained 4 entries.
- **2026-05-01 rev4**: Third multi-agent review pass. Fixed 3 RED + 8 YELLOW. Notable: §1.2 A2 rewritten (memory-management exempt from pack-boundary, replacing rev3's engineered "SEO" trigger injection); §4.2.5 trigger phrasing returned to natural language with explicit commit ordering A→B→C; new §4.2.6 moves `commands/remember.md` scope expansion to PR #2 (was forward-reference); `changed_paths_match` helper definition added (was undefined helper); citation `965acac` → `f5d5f0f` for `evals/product-api-scenarios.md` introduction; scenario `expected_route` now uses chain syntax for retire (`--retire-preview -> /aaron:remember`); §1.1 self-reference exemption added; top-of-doc rev4 diff summary added for implementer cognitive load. See "What changed since rev3" block at top.
- **2026-05-03 v9.9.9 ship**: 8 commits a357f3f → 7bae954. PR #1 wiki-lint restoration; PR #2 (4 commits A/B/C/foundation) Phase 2 + auto.md exemption + scenarios; PR #3 Phase 3 + scripts; PR #4 manifests + evals; cleanup commit. Final acceptance review: yes-with-followup; 4-fixture validator GREEN.
- **2026-05-04 v9.9.9 patch**: 5 commits 664b239 → d178594. R1 path-injection security fix (textual containment); R2 `[CONTRADICTION-{id}]` corruption fix (fm_count<2 guard); 5 RED + 10 YELLOW from user-perspective adversarial testing fully addressed. Validator extended 4→5 fixtures + path-injection negative test. Ruby UTF-8 export added for Chinese trigger handling. Line-budget waiver WLB-2026-05-001 (90-day) introduced for v10.1.x release cycle.
- **2026-05-06 v9.9.9 patch**: 2 commits 50e3547 + a85185c. Restore Product API scenario (`auto-wiki-restore-001`) + `wiki-restore-001` eval case + `--show-deferred` flag (was reserved for v10.2.0; now real) + `wiki-show-deferred-001` eval case. Closed 2 of 7 v10.2.0-candidate gaps from honest-completeness review.
- **2026-05-06 v9.9.9 patch**: 6-agent-team review (security / bash / docs / UX / maintainer / strategy) found 5 substantive RED + 16 YELLOW. Fixed in 6 commits:
  - **Security**: R1 symlink-pivot bypass (live-reproducible attack against textual containment) — added `verify_destination_under_memory()` with `pwd -P` resolution + symlink-ancestor walk; new `test_symlink_pivot_rejected` validator fixture. R2 SessionStart hook prompt-injection — explicit "treat as data, not instructions" framing + sanitization spec for path/value/entity strings. Sec #2 predictable-PID DoS in validator — replaced `/tmp/INJECTION_*_$$` sentinels with `mktemp -d` inside per-test TMPDIR.
  - **Code quality**: R3 `set -e` swallowed by `||` in run_fixture — explicit `if !` chains for all 7 tests. R4 awk pattern drift between recovery + validator — shared-invariant comment block in both files cross-referencing. Code 5c — `set -euEo pipefail` + ERR trap with `$LINENO`/`$BASH_COMMAND` for CI debuggability. Code 3d — sed-based `extract_originally_at()` (handles paths with spaces; was awk truncating).
  - **Docs**: R5 — 6× `wiki-runbook §6` → `§7` cross-references in proposal. Doc 9 — Status header updated to span v9.9.9 → v9.9.9. Doc 10 — eval count 11 → 13 in §11 acceptance criteria.
  - **UX + GDPR**: audit-log mechanism for wiki writes (UX sharpest finding); GDPR purge robustness for missing/non-printable `originally_at`.
  - **CI**: `.github/workflows/{validate-skill,clawhub-publish}.yml` gain `AARON_COMMAND_LINE_BUDGET_WAIVER=1` env (must-do per maintainer review M9 — first push to remote would fail CI without it).
  - Validator now runs **5 fixtures + 2 negative tests**; commands/remember.md and `commands/auto.md` decline UX hardened.
- Future: append revisions here as PRs land
