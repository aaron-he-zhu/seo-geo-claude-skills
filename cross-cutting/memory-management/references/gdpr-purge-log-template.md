---
name: gdpr-purge-log-template
description: Canonical schema for memory/audits/gdpr-purges.md entries. Required for compliance auditability per memory-management SKILL.md GDPR section.
type: reference
---

# GDPR / CCPA Purge Log Schema (v9.9.9+)

`memory/audits/gdpr-purges.md` is an append-only log of every Art 17 / CCPA §1798.105 erasure executed by `memory-management`. The structured schema enables a compliance audit to verify scope, action, and reingest-blocking — without requiring access to the raw subject data (which has been redacted).

## Why a template

Pre-v9.9.9: SKILL.md described the log surface but didn't enforce a structure. Sufficiently sloppy LLM sessions could write inconsistent entries (missing fingerprint, missing scope, missing action taken). Surfaced by the fintech persona testing of v9.9.9: "memory/audits/gdpr-purges.md schema is described but not formalized — counsel will want one."

This template is the canonical structure. Every purge entry MUST conform.

## Entry schema

Append-only YAML list. One entry per purge invocation. Newest entries at the bottom.

```yaml
- purge_id: 2026-05-06-001                   # YYYY-MM-DD-NNN, unique within day
  date: 2026-05-06                            # UTC date of the purge
  redacted_label: "Subject-A1B2"              # NEVER store raw subject. Use a salted, non-reversible label.
  fingerprint: "sha256:8f9c...3e21"           # Salted SHA-256 of (subject_name + project_salt). Truncated 8-byte prefix OK.
  scope:                                       # Where the purge ran
    - canonical:
        - memory/hot-cache.md
        - memory/research/competitors/acme-2024.md
        - memory/audits/domain/acme-cite.md
        - memory/entities/acme-corp.md
    - wiki:
        - memory/wiki/acme-q2/entity-acme-corp.md
        - memory/wiki/log.md             # entry redacted, structure preserved
        - memory/wiki/.unresolved.md      # value-field scrub per v9.9.9
        - memory/wiki/.drift-log
    - archive:
        - memory/archive/2026-05-01-acme-2024.md  # if retired pre-purge, originally_at + body scrubbed
  action: anonymize                            # delete | anonymize | structural-preserve
  action_detail: |
    Replaced "Jane Doe" string with "[REDACTED]" in 14 lines across 9 files.
    Preserved contradiction structure in .unresolved.md (entry id 042).
    Updated wiki index after rewrite.
  legal_basis: art_17_request                  # art_17_request | ccpa_1798.105 | proactive_data_minimization
  malformed_archives_processed: 0              # count of archives lacking originally_at that were body-grepped (v9.9.9+ fix)
  override_used: false                         # true if user invoked any override (e.g., partial-skip for audit integrity)
  reingest_blocked: true                       # mirrors memory/privacy/tombstones.md entry — must always be true post-purge
  proof:
    grep_count_before: 14
    grep_count_after: 0
    files_modified: 9
    log_md_lines_appended: 1
  audit_signature: "automated"                 # automated | human-reviewed | dual-signed
  reviewer: null                                # human reviewer id if dual-signed; null otherwise
```

## Field reference

| Field | Required | Type | Notes |
|-------|----------|------|-------|
| `purge_id` | ✅ | `YYYY-MM-DD-NNN` | Unique within a day. Sequential. |
| `date` | ✅ | UTC date | Matches `purge_id` prefix. |
| `redacted_label` | ✅ | string | Stable label for cross-referencing the tombstone (`memory/privacy/tombstones.md`). NEVER raw name. |
| `fingerprint` | ✅ | `sha256:<hex>` | Salted with project-level secret. Non-reversible. Allows re-detection of reingest attempts. |
| `scope.canonical[]` | ✅ | path[] | Files in HOT/WARM/COLD tiers touched. Empty list if none. |
| `scope.wiki[]` | ✅ | path[] | Wiki layer files touched. Empty list if none. |
| `scope.archive[]` | ✅ | path[] | `memory/archive/*.md` files touched (Phase 3 retirement reverse-link). |
| `action` | ✅ | enum | `delete` (file removed entirely) / `anonymize` (subject replaced with `[REDACTED]`) / `structural-preserve` (e.g., `.unresolved.md` entry kept for audit, value scrubbed). |
| `action_detail` | ✅ | string | Human-readable summary of what was done. NEVER include the raw subject name here. |
| `legal_basis` | ✅ | enum | Drives auditor verification. |
| `malformed_archives_processed` | ✅ | int | v9.9.9+ tracks archives without `originally_at` that were body-grepped. |
| `override_used` | ✅ | bool | `true` if user picked a partial-skip option (e.g., refused to delete an audit-integrity entry). |
| `reingest_blocked` | ✅ | bool | MUST be `true` after purge. Cross-references the tombstone fingerprint. |
| `proof` | ✅ | object | grep counts before/after, file modification count, log entries appended. The mechanical proof an auditor can verify. |
| `audit_signature` | ✅ | enum | `automated` (memory-management only) / `human-reviewed` (user confirmed) / `dual-signed` (memory-management + named human reviewer). |
| `reviewer` | ⚠️ | string\|null | Required when `audit_signature: dual-signed`. |

## Append procedure

memory-management writes a NEW entry to the bottom of `memory/audits/gdpr-purges.md` after every purge. The entry is generated from in-flight grep counts and action records, NOT inferred post-hoc. The `proof.grep_count_before` value is captured BEFORE the purge runs; `grep_count_after` is captured AFTER.

If the purge spans multiple days (e.g., user paused mid-action), each day's portion gets its own entry sharing the same `redacted_label` and `fingerprint`.

## Auditor verification

A compliance auditor with read access to `memory/audits/gdpr-purges.md` can verify:

1. **Coverage**: scope arrays match the documented surface in SKILL.md GDPR step 3.
2. **Mechanical proof**: `grep_count_before` > 0 AND `grep_count_after` == 0 in canonical/wiki/archive scopes.
3. **No raw data persistence**: `redacted_label` and `fingerprint` only — confirm no plaintext name appears anywhere in the entry.
4. **Reingest block**: `reingest_blocked: true` AND tombstone exists at `memory/privacy/tombstones.md` matching the fingerprint.
5. **Override accountability**: `override_used: true` entries get extra scrutiny; the `action_detail` should explain what was preserved and why (typically audit integrity).

## Cross-references

- [memory-management SKILL.md GDPR section](../SKILL.md) — purge procedure
- [wiki-runbook.md §3](wiki-runbook.md) — log.md write rules (separate audit trail for wiki ops)
- [references/skill-contract.md](../../../references/skill-contract.md) — Write Paths table

## History

- **v9.9.9** (2026-05-06): initial template, addressing the v9.9.9 fintech-persona testing finding that the schema was undocumented.
