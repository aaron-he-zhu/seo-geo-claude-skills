#!/usr/bin/env bash
# Recover all retired WARM files after memory/wiki/ deletion (or any time
# user wants to undo Phase 3 retirements). Run from repo root.
# Reads memory/archive/*.md frontmatter; restores files referenced by
# originally_at to their pre-retire paths. Skips files already present at
# destination (manual-review safety). Skips archived files lacking
# originally_at (legacy or non-Phase-3 archives).
#
# Exit codes:
#   0 — clean recovery (all eligible files restored, no skips)
#   2 — recovery with collisions / injection-attempts skipped — caller should review
#   1 — hard error (invalid invocation, mkdir failure, etc.)
#
# SHARED INVARIANT (with scripts/validate-phase3-rollback.sh):
# Only the first two `^---\r?$` lines bound the YAML frontmatter. Body
# lines matching `^---$` (markdown HRs) pass through verbatim. The awk
# pattern below uses `fm_count < 2` to enforce this; the validator uses
# `if(n==2)` short-circuit. Different patterns, identical semantics. If
# you change one, change the other AND run validate-phase3-rollback.sh
# body-with-HR fixture to confirm round-trip survives.

set -euEo pipefail
# v9.9.9+ ERR trap — print failing line + command. Helps CI debugging when
# a `mkdir` or `cp` fails deep in a per-file loop.
trap 'echo "ERR: $0:$LINENO failed: $BASH_COMMAND" >&2' ERR

if [ ! -d "memory/archive" ]; then
  echo "memory/archive/ not found. Nothing to recover."
  exit 0
fi

recovered=0
skipped_collision=0
skipped_legacy=0
skipped_injection=0

# Resolve canonical memory/ path ONCE (used by symlink-pivot guard below).
# Use `cd && pwd -P` instead of GNU `realpath` (not on macOS by default).
canonical_memory="$(cd memory && pwd -P)"

# v9.9.9+: parsing originally_at with sed instead of awk to handle paths
# containing spaces. awk '{print $2}' truncated at first space.
extract_originally_at() {
  sed -n '/^originally_at: /{ s/^originally_at: //; p; q; }' "$1"
}

# v9.9.9+: reject if any ancestor directory under memory/ is a symlink, AND
# verify the resolved destination directory is canonically under memory/.
# Combined with path-prefix textual check, this blocks the symlink-pivot
# attack: a symlink at memory/research/foo -> /tmp/EVIL would otherwise let
# `mkdir -p memory/research/foo/bar` chase the symlink and write outside memory/.
verify_destination_under_memory() {
  local target="$1"
  local p
  # Reject if any existing ancestor in memory/ is a symlink
  p="$(dirname "$target")"
  while [ "$p" != "." ] && [ "$p" != "/" ]; do
    if [ -L "$p" ]; then
      return 1
    fi
    p="$(dirname "$p")"
  done
  # If destination dir exists already, verify resolved path stays under memory/
  if [ -d "$(dirname "$target")" ]; then
    local resolved
    resolved="$(cd "$(dirname "$target")" 2>/dev/null && pwd -P)" || return 1
    case "$resolved" in
      "$canonical_memory"|"$canonical_memory"/*) return 0 ;;
      *) return 1 ;;
    esac
  fi
  return 0  # destination dir doesn't exist yet, no symlink ancestor; safe to mkdir
}

for f in memory/archive/*.md; do
  [ -f "$f" ] || continue
  orig=$(extract_originally_at "$f")
  if [ -z "$orig" ]; then
    skipped_legacy=$((skipped_legacy+1))
    continue
  fi
  # Path containment guard (v9.9.9+): originally_at MUST resolve under memory/.
  # Reject absolute paths and any relative path containing `..` segment.
  # Without this, a malicious or malformed archive could write to ~/.ssh/etc.
  case "$orig" in
    /*)        echo "skip-injection: $orig is an absolute path ($f)"; skipped_injection=$((skipped_injection+1)); continue ;;
    *..*)      echo "skip-injection: $orig contains relative escape ($f)"; skipped_injection=$((skipped_injection+1)); continue ;;
    memory/*)  ;;  # OK
    *)         echo "skip-injection: $orig does not start with memory/ ($f)"; skipped_injection=$((skipped_injection+1)); continue ;;
  esac
  # v9.9.9+ symlink-pivot guard: reject if any ancestor under memory/ is a
  # symlink, OR if the resolved destination dir is not canonically under
  # memory/. Closes the attack reproduced in security review where a
  # planted `memory/research/foo -> /tmp/EVIL` lets `mkdir -p` chase outside.
  if ! verify_destination_under_memory "$orig"; then
    echo "skip-injection: $orig has symlink ancestor or resolves outside memory/ ($f)"
    skipped_injection=$((skipped_injection+1))
    continue
  fi
  if [ -e "$orig" ]; then
    echo "skip-collision: $orig already exists (manual review needed for $f)"
    skipped_collision=$((skipped_collision+1))
    continue
  fi
  if ! mkdir -p "$(dirname "$orig")" 2>/dev/null; then
    echo "skip-mkdir-fail: cannot create $(dirname "$orig") for $f (permission denied or path conflict)"
    skipped_collision=$((skipped_collision+1))
    continue
  fi
  # Strip retire-only fields while restoring. Match `---` with optional CR
  # for CRLF source files. Preserve trailing-newline state of original archive
  # (awk always emits trailing newline; we strip it if source had none).
  # CRITICAL (v9.9.9+): only toggle in_fm for the FIRST TWO `---` lines
  # (frontmatter open + close). Otherwise body lines like markdown horizontal
  # rules get treated as frontmatter delimiters and `originally_at:` literals
  # in the body get silently stripped — real data corruption bug.
  content=$(awk '
    BEGIN { in_fm = 0; fm_count = 0 }
    /^---\r?$/ && fm_count < 2 { in_fm = !in_fm; fm_count++; print; next }
    in_fm && /^(originally_at|retired_on|retired_because_compiled):/ { next }
    { print }
  ' "$f")
  if [ -n "$(tail -c 1 "$f")" ]; then
    # Source has no trailing newline; preserve that
    printf '%s' "$content" > "$orig"
  else
    printf '%s\n' "$content" > "$orig"
  fi
  rm "$f"
  recovered=$((recovered+1))
  echo "restored: $orig"
done

echo "Recovered $recovered file(s). Skipped $skipped_collision collision(s), $skipped_legacy legacy archive(s), $skipped_injection injection-attempt(s)."
# Exit 2 if any non-recovery state needs user attention
{ [ "$skipped_collision" -gt 0 ] || [ "$skipped_injection" -gt 0 ]; } && exit 2 || exit 0
