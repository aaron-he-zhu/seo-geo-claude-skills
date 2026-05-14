# Auditor Authors Guide

> For contributors writing a new auditor-class skill. If you are NOT writing an auditor, read [skill-contract.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/skill-contract.md) instead.

## Start here

Read these three files in order before touching anything:
1. **[skill-contract.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/skill-contract.md)** — general handoff contract all 20 skills follow
2. **[auditor-runbook.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/auditor-runbook.md) §1-5** — auditor-specific extension: handoff schema, cap arithmetic, guardrails, Artifact Gate, translation
3. **[contract-fail-caps.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/contract-fail-caps.md)** — cap numbers, single source of truth

Then copy the template below.

---

## Template skill

`optimize/your-auditor/SKILL.md`:

````markdown
---
name: your-auditor
description: "Audits [what] and returns a verdict. Part of the seo-geo skills library."
version: "1.0.0"
class: auditor
when_to_use: "..."
argument-hint: "<url or content>"
license: Apache-2.0
metadata:
  author: your-handle
---

# Your Auditor

## When This Must Trigger
[standard sections per skill-contract.md]

## Quick Start
[one-line invocation + common scenario + output expectation]

## Skill Contract
- **Reads**: ...
- **Writes**: ...
- **Promotes**: ...
- **Primary next skill**: ...

## Instructions

### Step 1-3: [your specific audit logic]

<!-- runbook-sync start: source_sha256=<computed> block_sha256=<computed> -->
## Scoring Runbook (authoritative)

> DO NOT EDIT THIS BLOCK. Mirror of references/auditor-runbook.md §1-5.

[... full Runbook §1-5 content copied verbatim ...]
<!-- runbook-sync end -->

### Step 4.5: Apply Scoring Runbook
Execute in order:
1. Cap Enforcement (Runbook §2): walk the decision table
2. Artifact Gate Self-Check (Runbook §4): run the 7-item checklist
3. User-Facing Translation (Runbook §5): translate before rendering

## Validation Checkpoints
## Reference Materials
## Next Best Skill
````

---

## Veto registration checklist

To add a new veto item (e.g., `M01` for missing mobile viewport tag):
1. Define M01 in your framework file (e.g., `references/mobile-seo-benchmark.md`)
2. Append M01 row to `references/contract-fail-caps.md` with cap number
3. Do NOT edit `auditor-runbook.md §2` worked examples — they are generic
4. Your SKILL.md inlines the Runbook as-is
5. Run `/aaron:guard --contracts` before committing

**Principle**: cap arithmetic is veto-agnostic. Adding a veto item does not require Runbook or existing auditor changes.

---

## Anti-patterns

- Do NOT link the Runbook instead of inlining it (links are inert at activation time)
- Do NOT restate cap numbers outside the Runbook/contract-fail-caps.md
- Do NOT leak veto IDs to user output (Runbook §5 Translation Layer is mandatory)
- Do NOT invent new handoff fields (extend via `auditor-runbook.md §1`, propose via ADR)
- Do NOT edit the inlined Runbook copy directly (edit source, re-run sync)
- Do NOT silently cap scores (always show raw and capped values internally)

---

## Runbook update procedure

1. Edit `references/auditor-runbook.md` and update frontmatter version
2. Recompute sha256: `shasum -a 256 references/auditor-runbook.md`
3. Update inlined §1-5 block in every auditor SKILL.md with new content and sha256
4. If §1-5 rules changed, update §6 Lint Coverage Manifest and `commands/guard.md`
5. Run `/aaron:guard --contracts` to verify
6. Commit everything: `runbook: <description>`

---

## FAQ

**My skill scores but isn't a protocol gate. Inline the Runbook?**
No. Only protocol-layer auditors inline the Runbook. Advisory-scoring skills follow `skill-contract.md §Handoff Summary Format`.

**`/aaron:guard --contracts` fails but I didn't touch the Runbook?**
The Runbook was updated upstream. Pull main, re-run sync, commit updates.

**How is my auditor registered with `/aaron:guard --contracts`?**
Add `class: auditor` to frontmatter. The contract gate discovers auditors via frontmatter glob.

**Can I write custom cap arithmetic?**
No. `auditor-runbook.md §2` is authoritative. Propose changes via ADR.

**350-line SKILL.md rule?**
Formally exempted for auditor-class skills (~750 line ceiling). See [ADR-001](decisions/2026-04-adr-001-inline-auditor-runbook.md).

**Manual or automated Runbook sync?**
v7.1.0: manual copy-paste. `/aaron:guard --contracts` detects drift but does not auto-fix.

**Different framework (not CORE-EEAT/CITE)?**
Yes, still inline the Runbook if you have veto items. The arithmetic is framework-agnostic.

---

## Related

- [auditor-runbook.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/auditor-runbook.md) — authoritative Runbook
- [skill-contract.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/skill-contract.md) — general contract
- [ADR-001](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/references/decisions/2026-04-adr-001-inline-auditor-runbook.md) — why inlining was chosen
- [commands/guard.md](https://github.com/aaron-he-zhu/seo-geo-claude-skills/blob/main/commands/guard.md) — drift detection and validation command
