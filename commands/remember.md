---
name: remember
description: "Manage project memory lifecycle: initialize, query, review, update, promote, demote, archive, cleanup, purge, and feedback state. Not sure? Use /aaron:auto."
argument-hint: "<memory-request>"
parameters:
  - name: request
    type: string
    required: true
    description: "Recall, write, cleanup, purge, or project-memory request"
---

# Remember Command

Manage project memory lifecycle: initialize, query, review, update, promote, demote, archive, cleanup, purge, and feedback state.

## Route

- memory-management
- entity-optimizer

## Rules

- Distinguish read-only recall from write/update requests.
- Memory-management owns lifecycle (HOT/WARM/COLD), wiki (compile · query · contradiction-resolution · retire · restore), archive, cleanup, purge, and protocol aggregation; canonical entity profiles route to entity-optimizer. Phase 2/3 wiki operations require explicit user permission and follow the procedures in [wiki-runbook.md](../cross-cutting/memory-management/references/wiki-runbook.md).
- **Wiki Phase 2 compile preconditions** (v9.9.9+, restated here so the gate works regardless of entry path): `"compile"`/`"synthesize"`/`"build entity page for"` requests require **≥3 existing WARM sources referencing the entity**. If fewer, decline with explicit next steps (run `/aaron:discover` or `/aaron:compete` first, OR ask "compile from this content" with user-provided sources to bypass). Same precondition whether routed via `/aaron:auto` or directly via `/aaron:remember`.
- **Wiki Phase 3 retire preconditions** (v9.9.9+): retire trigger requires either (a) prior `/aaron:guard --wiki --retire-preview` output in current session, OR (b) explicit user override phrase. Without either, respond with the preview output instead of executing. Caps: 5 files per call, 20 per UTC day. Restore (undo) requires an existing `memory/archive/<file>.md` with `originally_at` field; otherwise decline.
- **Recovery via `/aaron:remember`** (v9.9.9+, addresses non-technical-user accessibility): users who lost `memory/wiki/` (rm/backup-restore/etc.) DO NOT need to know about `scripts/recover-retired-warm.sh`. Phrases that trigger recovery via this command: `"recover wiki"` · `"recover retired files"` · `"undo last retire"` · `"restore my wiki"` · `"恢复wiki"` · `"恢复退役"`. memory-management MUST: (1) check Bash tool availability, (2) if available, run `bash scripts/recover-retired-warm.sh` itself and surface the output, (3) if not available (e.g., read-only context), explain the manual path with the exact command. NEVER tell a non-technical user "Run scripts/recover-retired-warm.sh" without first attempting to run it on their behalf. Surface the audit-log receipt per wiki-runbook.md §3.1.
- Only content-quality-auditor and domain-authority-auditor may append one veto marker to memory/hot-cache.md without extra confirmation.
- Purge/GDPR/CCPA requests require scoped targets and must delete or anonymize matching canonical and derived memory surfaces.

## Output

Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
