# Host Namespace Smoke Evidence

```yaml
type: host-namespace-smoke
command_inventory:
  expected_count: 20
  command_files: [audit, authority, auto, brief, compete, discover, evolve, guard, map, max, publish, refresh, remember, report, series, skillify, tech, visibility, watch, write]
hosts:
  - {host: claude-code, slash_commands: supported, auto_entrypoint: "/aaron:auto", command_inventory_display: 20, root_alias: optional_unverified, evidence: static_manifest}
  - {host: openclaw, slash_commands: supported, auto_entrypoint: "/aaron:auto", command_inventory_display: 20, root_alias: optional_unverified, evidence: bundle_manifest}
  - {host: codebuddy, slash_commands: supported, auto_entrypoint: "/aaron:auto", command_inventory_display: 20, root_alias: optional_unverified, evidence: marketplace_manifest}
  - {host: gemini, slash_commands: not_claimed, evidence: extension_context_only}
  - {host: qwen, slash_commands: not_claimed, evidence: extension_context_only}
  - {host: generic-npx, slash_commands: not_claimed, evidence: skill_context_only}
```
