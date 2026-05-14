---
name: skillify
description: "Audit proposed or changed skills, commands, routing, evals, and release impact. Read-only and proposal-only. Not sure? Use /aaron:auto."
argument-hint: "<skill-or-change> [--new] [--pr-ready]"
allowed-tools: ["Read", "Glob", "Grep"]
parameters:
  - name: target
    type: string
    required: true
    description: "Skill, command, diff, or proposed change"
  - name: pr-ready
    type: boolean
    required: false
    description: "Include PR checklist and release-surface notes"
---

# Skillify Command

Audit proposed or changed skills, commands, routing, evals, and release impact. Read-only and proposal-only.

## Route

- resolver
- skill contract

## Rules

- This command is read-only: do not edit files, commit, publish, or mark changes accepted.
- Check skill completeness, frontmatter, routing fit, Next Best Skill, handoff, eval coverage, command impact, release surfaces, and guardrail updates.
- If evidence implies behavior change, recommend `/aaron:evolve --signal <source>`; do not accept the change here.

## Output

Return inline review artifacts only. This command never edits files, writes memory, commits changes, publishes releases, or accepts its own recommendations.
