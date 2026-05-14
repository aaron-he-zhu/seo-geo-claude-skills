#!/usr/bin/env bash
# Validate Phase 3 rollback invariant against the documented retire procedure
# (wiki-runbook.md §7) and the checked-in recovery script. Exits 0 only when
# all fixtures restore byte-identically. Tests (v9.9.9):
#   1. plain LF, trailing newline (baseline)
#   2. plain LF, NO trailing newline
#   3. CRLF line endings
#   4. multi-line YAML value (block scalar)
#   5. body-with-HR (markdown horizontal rules + retire-keyword strings in body)
#   6. path-injection negative test (3 adversarial archives — must reject)
#   7. symlink-pivot negative test (planted symlink under memory/ — must reject)
# Each round-trip fixture: setup → retire (cp + edit) → rm wiki/ → run recover
# script → diff. Each negative test: adversarial archive → recovery → assert
# no malicious write happened, exit 2, diagnostic emitted.
#
# Phase 3 rollback merge gate. Originally introduced in v9.9.9 PR #3.
#
# SHARED INVARIANT — frontmatter delimiter recognition:
# Both this validator AND scripts/recover-retired-warm.sh treat ONLY the
# first two `^---\r?$` lines as the YAML frontmatter open/close. Body lines
# matching `^---$` (markdown horizontal rules) MUST pass through unmodified.
# This validator's `insert_retire_fields` uses `if(n==2)` short-circuit;
# recover-retired-warm.sh uses `fm_count < 2` gate. Different awk patterns,
# IDENTICAL semantics. If you change one, change the other AND verify the
# body-with-HR fixture still passes round-trip.

set -euEo pipefail
# v9.9.9+ ERR trap — print failing line + command for CI debuggability.
trap 'echo "ERR: $0:$LINENO failed: $BASH_COMMAND" >&2' ERR

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RECOVER_SCRIPT="$REPO_ROOT/scripts/recover-retired-warm.sh"

if [ ! -x "$RECOVER_SCRIPT" ]; then
  echo "FAIL: $RECOVER_SCRIPT missing or not executable. PR #3 must check it in."
  exit 1
fi

# ---------- helpers ----------

# Insert three retire fields into archive frontmatter, in place.
# Find first '---' (open), find next '---' (close), insert lines BEFORE close.
insert_retire_fields() {
  local file="$1" orig="$2" rdate="$3" compiled="$4"
  local close_line
  # Match `---` with optional CR for CRLF source files. Note: this is naturally
  # safe (only takes the FIRST 2 `---` lines via if(n==2)), so it would not
  # be tricked by body-content `---` lines even before the v9.9.9 fix.
  # The recovery script needed an analogous fm_count<2 guard (it didn't have one).
  close_line=$(awk 'BEGIN{n=0} /^---\r?$/{n++; if(n==2){print NR; exit}}' "$file")
  if [ -z "$close_line" ]; then
    echo "ERROR: no closing --- found in $file" >&2
    return 1
  fi
  # Insert three lines before close_line. Inserted lines use plain LF; recovery
  # strip pattern catches them regardless of source line ending. Original CRLF
  # content survives the awk pass intact (awk reads up to \n; \r becomes part of line).
  # Preserve trailing-newline state of source.
  local content
  content=$(awk -v cl="$close_line" -v orig="$orig" -v rdate="$rdate" -v compiled="$compiled" '
    NR==cl {
      print "originally_at: " orig
      print "retired_on: " rdate
      print "retired_because_compiled: " compiled
    }
    { print }
  ' "$file")
  local tmp
  tmp=$(mktemp)
  if [ -n "$(tail -c 1 "$file")" ]; then
    printf '%s' "$content" > "$tmp"
  else
    printf '%s\n' "$content" > "$tmp"
  fi
  mv "$tmp" "$file"
}

# Run one fixture: name, WARM-content-generator-fn
run_fixture() {
  local name="$1" gen_fn="$2"
  local TMPDIR
  TMPDIR=$(mktemp -d)
  # Use trap inside subshell to scope cleanup to this fixture
  trap "rm -rf '$TMPDIR'" RETURN

  mkdir -p "$TMPDIR/memory/research/competitors" \
           "$TMPDIR/memory/wiki/test-proj" \
           "$TMPDIR/memory/archive" \
           "$TMPDIR/snapshot"

  # Generate fixture WARM (caller-provided)
  $gen_fn "$TMPDIR/memory/research/competitors/fixture.md"

  # Snapshot (preserves byte-identity reference)
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

  # Retire per wiki-runbook.md §7.4: cp source to archive, then in-place edit archive
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

  # Run recovery via the checked-in script (in subshell so cd doesn't escape)
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

# Body containing literal `---` lines AND `originally_at:` text inside the body.
# Pre-v9.9.9 recovery would silently strip these body lines because awk
# `in_fm = !in_fm` toggled on every `^---$`. Real bug: meta-docs and ADRs
# about Phase 3 itself trigger this. Added by user-perspective Test 2 T6.
gen_body_with_hr() {
  cat > "$1" <<'EOF'
---
name: fake-meta-doc
type: research
description: ADR discussing the originally_at field design
---
Pre-v9.9.9 this body would get corrupted.

---

Section about the `originally_at:` field semantics.
The retired_on: timestamp also appears in body discussion.
Even retired_because_compiled: gets discussed here.

---

End of body. All these lines must survive recovery byte-identically.
EOF
}

# Negative test (v9.9.9+): path injection MUST be rejected.
# Creates archives with adversarial originally_at values, runs recovery,
# verifies (a) malicious paths NOT written, (b) script exits 2, (c) skip-injection
# diagnostics emitted. Added by user-perspective Test 2 T8.
test_path_injection_rejected() {
  local TMPDIR
  TMPDIR=$(mktemp -d)
  trap "rm -rf '$TMPDIR'" RETURN

  mkdir -p "$TMPDIR/memory/archive"

  # v9.9.9+: use mktemp-based sentinel paths inside the per-test tmpdir so
  # they're (a) unguessable by other processes, (b) auto-cleaned on exit,
  # (c) not subject to PID-collision DoS where a malicious local process
  # pre-creates /tmp/INJECTION_ABS_$$ and tricks the test into FAIL.
  local SENTINEL_DIR
  SENTINEL_DIR=$(mktemp -d "$TMPDIR/sentinel.XXXXXX")
  local ABS_TARGET="$SENTINEL_DIR/abs_target.md"
  local REL_TARGET_NAME="rel_target_$(basename "$SENTINEL_DIR").md"

  # Three adversarial archives
  cat > "$TMPDIR/memory/archive/2026-05-01-abs.md" <<EOF
---
name: malicious-abs
originally_at: $ABS_TARGET
retired_on: 2026-05-01
retired_because_compiled: memory/wiki/test/x.md
---
abs body
EOF

  cat > "$TMPDIR/memory/archive/2026-05-01-rel.md" <<EOF
---
name: malicious-rel
originally_at: ../../$REL_TARGET_NAME
retired_on: 2026-05-01
retired_because_compiled: memory/wiki/test/x.md
---
rel body
EOF

  cat > "$TMPDIR/memory/archive/2026-05-01-bad-prefix.md" <<EOF
---
name: malicious-prefix
originally_at: etc/passwd
retired_on: 2026-05-01
retired_because_compiled: memory/wiki/test/x.md
---
no memory/ prefix body
EOF

  # Run recovery — capture exit code WITHOUT `|| true` swallowing it.
  # set +eE + trap '' ERR temporarily because the subshell's intentional
  # exit-2 (skip-collision/skip-injection) would otherwise fire the
  # ERR trap inherited via set -E. Restore on the way out.
  local recovery_output recovery_exit
  set +eE
  trap '' ERR
  recovery_output=$(cd "$TMPDIR" && "$RECOVER_SCRIPT" 2>&1)
  recovery_exit=$?
  set -eE
  trap 'echo "ERR: $0:$LINENO failed: $BASH_COMMAND" >&2' ERR

  # Assert: NO injection paths written (using tmpdir-scoped sentinels)
  if [ -e "$ABS_TARGET" ]; then
    echo "FAIL [path-injection]: absolute-path injection wrote to $ABS_TARGET"
    return 1
  fi
  # Relative escape would land at $TMPDIR/../../$REL_TARGET_NAME — i.e., the
  # parent of the system tmp root in some configs. Check the parent dir.
  if find "$(dirname "$(dirname "$TMPDIR")")" -maxdepth 2 -name "$REL_TARGET_NAME" 2>/dev/null | grep -q .; then
    echo "FAIL [path-injection]: relative-escape injection wrote outside cwd"
    find "$(dirname "$(dirname "$TMPDIR")")" -maxdepth 2 -name "$REL_TARGET_NAME" -delete 2>/dev/null
    return 1
  fi
  # bad-prefix should NOT have written `etc/passwd` under tmpdir
  if [ -e "$TMPDIR/etc/passwd" ]; then
    echo "FAIL [path-injection]: bad-prefix injection wrote to etc/passwd under tmpdir"
    return 1
  fi

  # Assert: skip-injection diagnostics present
  if ! echo "$recovery_output" | grep -q "skip-injection"; then
    echo "FAIL [path-injection]: no skip-injection diagnostic in output"
    echo "Output was: $recovery_output"
    return 1
  fi

  # Assert: exit code 2 (collision/injection — non-zero, but not 1 hard error)
  if [ "$recovery_exit" -ne 2 ]; then
    echo "FAIL [path-injection]: expected exit 2, got $recovery_exit"
    return 1
  fi

  echo "PASS [path-injection]: 3 adversarial paths rejected; exit 2; diagnostics present"
  return 0
}

# ---------- run all fixtures ----------

# v9.9.9+: symlink-pivot negative test. A symlink under memory/ that points
# outside the repo would otherwise let recovery's `mkdir -p` chase it and
# write outside memory/. The path-textual-prefix check (memory/...) doesn't
# catch this because the path string is correct — the directory ITSELF is
# what's malicious. Recovery v9.9.9+ adds verify_destination_under_memory()
# which uses `pwd -P` to resolve the destination dir's canonical path AND
# walks ancestors checking for `[ -L ]`.
test_symlink_pivot_rejected() {
  local TMPDIR
  TMPDIR=$(mktemp -d)
  trap "rm -rf '$TMPDIR'" RETURN

  mkdir -p "$TMPDIR/memory/archive"
  # Create a target outside memory/ that we DON'T want to be written to
  local OUTSIDE_TARGET
  OUTSIDE_TARGET=$(mktemp -d "$TMPDIR/outside-memory.XXXXXX")

  # Plant a symlink under memory/ pointing at the outside target
  ln -s "$OUTSIDE_TARGET" "$TMPDIR/memory/research"

  # Archive that uses memory/research/pwned.md — textually under memory/,
  # but resolves to OUTSIDE_TARGET because of the symlink.
  cat > "$TMPDIR/memory/archive/2026-05-01-symlink-pivot.md" <<EOF
---
name: malicious-symlink
originally_at: memory/research/pwned.md
retired_on: 2026-05-01
retired_because_compiled: memory/wiki/test/x.md
---
symlink-pivot body
EOF

  # Run recovery (intentional exit 2; suppress ERR trap inherited via set -E)
  local recovery_output recovery_exit
  set +eE
  trap '' ERR
  recovery_output=$(cd "$TMPDIR" && "$RECOVER_SCRIPT" 2>&1)
  recovery_exit=$?
  set -eE
  trap 'echo "ERR: $0:$LINENO failed: $BASH_COMMAND" >&2' ERR

  # Assert: pwned.md was NOT written to the outside target
  if [ -e "$OUTSIDE_TARGET/pwned.md" ]; then
    echo "FAIL [symlink-pivot]: recovery followed symlink and wrote $OUTSIDE_TARGET/pwned.md"
    return 1
  fi

  # Assert: skip-injection diagnostic mentions symlink
  if ! echo "$recovery_output" | grep -qi "symlink"; then
    echo "FAIL [symlink-pivot]: no symlink-related diagnostic; output was:"
    echo "$recovery_output"
    return 1
  fi

  # Assert: exit code 2 (skipped, not silent success or hard error)
  if [ "$recovery_exit" -ne 2 ]; then
    echo "FAIL [symlink-pivot]: expected exit 2, got $recovery_exit"
    return 1
  fi

  echo "PASS [symlink-pivot]: symlink ancestor rejected; exit 2; diagnostic present"
  return 0
}

failed=0
# Wrap calls in `if !` so set -e is preserved INSIDE run_fixture. The previous
# `run_fixture ... || failed=...` swallowed errors — set -e doesn't fire in a
# function called as part of an || chain. Caught by code review v9.9.9.
if ! run_fixture "plain"             gen_plain;               then failed=$((failed+1)); fi
if ! run_fixture "no-trailing-NL"    gen_no_trailing_newline; then failed=$((failed+1)); fi
if ! run_fixture "CRLF"              gen_crlf;                then failed=$((failed+1)); fi
if ! run_fixture "multi-line YAML"   gen_multiline_yaml;      then failed=$((failed+1)); fi
if ! run_fixture "body-with-HR"      gen_body_with_hr;        then failed=$((failed+1)); fi
if ! test_path_injection_rejected;                            then failed=$((failed+1)); fi
if ! test_symlink_pivot_rejected;                             then failed=$((failed+1)); fi

if [ "$failed" -ne 0 ]; then
  echo "RESULT: $failed fixture(s)/test(s) failed"
  exit 1
fi

echo "RESULT: all 5 fixtures + path-injection + symlink-pivot negative tests passed; rollback invariant holds"
exit 0
