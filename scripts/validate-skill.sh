#!/usr/bin/env bash
# validate-skill.sh — Validate a SKILL.md against the ClawHub, Agent Skills, and Vercel Labs skill specs
# Usage: ./scripts/validate-skill.sh <path-to-skill-directory>
# Example: ./scripts/validate-skill.sh research/keyword-research

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# --status: verify version: == metadata.version: within each SKILL.md (internal consistency)
#           and display library version from plugin.json and marketplace.json for reference
if [ "$1" = "--status" ]; then
    REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
    PLUGIN_JSON="$REPO_ROOT/.claude-plugin/plugin.json"
    MARKETPLACE_JSON="$REPO_ROOT/marketplace.json"

    if [ ! -f "$PLUGIN_JSON" ]; then
        echo -e "${RED}ERROR${NC}: plugin.json not found at $PLUGIN_JSON"
        exit 1
    fi
    if [ ! -f "$MARKETPLACE_JSON" ]; then
        echo -e "${RED}ERROR${NC}: marketplace.json not found at $MARKETPLACE_JSON"
        exit 1
    fi

    # Library-level version (single entry in plugin.json / marketplace.json)
    lib_plugin=$(grep '"version"' "$PLUGIN_JSON" | head -1 | sed 's/.*"version" *: *"//' | sed 's/".*//' | tr -d '\r')
    lib_market=$(grep '"version"' "$MARKETPLACE_JSON" | head -1 | sed 's/.*"version" *: *"//' | sed 's/".*//' | tr -d '\r')
    echo ""
    echo "Library version — plugin.json: ${lib_plugin}  marketplace.json: ${lib_market}"
    if [ "$lib_plugin" != "$lib_market" ]; then
        echo -e "${RED}WARN${NC}: plugin.json and marketplace.json library versions differ"
    fi
    echo ""

    SPLIT=0

    printf "%-30s %-12s %-18s %s\n" "SKILL" "version:" "metadata.version:" "STATUS"
    printf "%-30s %-12s %-18s %s\n" "-----" "--------" "-----------------" "------"

    while IFS= read -r skill_file; do
        skill_dir="$(dirname "$skill_file")"
        skill_name="$(basename "$skill_dir")"

        # Extract top-level version: from SKILL.md frontmatter
        skill_ver=$(awk '/^---/{if(++n==2)exit} n && /^version:/{gsub(/version: */, ""); gsub(/["'"'"']/, ""); print; exit}' "$skill_file" | tr -d '\r')

        # Extract metadata.version: (indented) from SKILL.md frontmatter
        meta_ver=$(awk '/^---/{if(++n==2)exit} n && /^  version:/{gsub(/ *version: */, ""); gsub(/["'"'"']/, ""); print; exit}' "$skill_file" | tr -d '\r')

        # Determine status
        if [ -z "$skill_ver" ]; then
            status="${RED}MISSING${NC}"
            SPLIT=1
        elif [ -z "$meta_ver" ]; then
            status="${RED}MISSING${NC}"
            SPLIT=1
        elif [ "$skill_ver" = "$meta_ver" ]; then
            status="${GREEN}OK${NC}"
        else
            status="${RED}SPLIT${NC}"  # version: and metadata.version: disagree within SKILL.md
            SPLIT=1
        fi

        printf "%-30s %-12s %-18s " "$skill_name" "${skill_ver:-—}" "${meta_ver:-—}"
        echo -e "$status"
    done < <(find "$REPO_ROOT" -name "SKILL.md" -not -path "$REPO_ROOT/docs/*" -not -path "$REPO_ROOT/.claude/*" | sort)

    echo ""
    if [ "$SPLIT" -gt 0 ]; then
        echo -e "${RED}SPLIT detected — version: and metadata.version: disagree in one or more skills${NC}"
        exit 1
    else
        echo -e "${GREEN}All skill versions internally consistent${NC}"
        exit 0
    fi
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="${1:-.}"
SKILL_FILE="$SKILL_DIR/SKILL.md"

PASS=0
FAIL=0
WARN=0

pass() { echo -e "${GREEN}  ✅ PASS${NC}: $1"; PASS=$((PASS + 1)); }
fail() { echo -e "${RED}  ❌ FAIL${NC}: $1"; FAIL=$((FAIL + 1)); }
warn() { echo -e "${YELLOW}  ⚠️  WARN${NC}: $1"; WARN=$((WARN + 1)); }

hash_file() {
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        sha256sum "$1" | awk '{print $1}'
    fi
}

hash_stdin() {
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 | awk '{print $1}'
    else
        sha256sum | awk '{print $1}'
    fi
}

extract_runbook_execution_block() {
    awk 'BEGIN{found=0} /^## §1 · Handoff Schema/{found=1} /^## §6 /{if(found) exit} found{print}' "$1"
}

echo ""
echo "Validating: $SKILL_FILE"
echo "Specs: ClawHub · Agent Skills · Vercel Labs skills ecosystem"
echo "=============================================="

# Check file exists
if [ ! -f "$SKILL_FILE" ]; then
    echo -e "${RED}ERROR${NC}: SKILL.md not found at $SKILL_FILE"
    exit 1
fi

# Extract frontmatter (between first --- and second ---)
FRONTMATTER=$(awk '/^---/{if(++n==2)exit} n' "$SKILL_FILE")

# --- Required field: name ---
# Agent Skills: lowercase, hyphens, ≤64 chars, matches dir name
# ClawHub: slug pattern ^[a-z0-9][a-z0-9-]*$ (slightly more permissive — allows leading digit)
# Vercel Labs: same as Agent Skills
NAME=$(echo "$FRONTMATTER" | grep -E '^name:' | sed 's/name: *//' | tr -d '"'"'" | tr -d '\r')
if [ -z "$NAME" ]; then
    fail "Missing required field: name"
else
    # Agent Skills + Vercel Labs: must start with letter
    if echo "$NAME" | grep -qE '^[a-z][a-z0-9-]*[a-z0-9]$' || echo "$NAME" | grep -qE '^[a-z]$'; then
        if echo "$NAME" | grep -q '\-\-'; then
            fail "name contains consecutive hyphens: $NAME"
        elif [ ${#NAME} -gt 64 ]; then
            fail "name exceeds 64 chars: ${#NAME} chars"
        else
            pass "name is valid (Agent Skills + Vercel Labs): $NAME"
        fi
    else
        fail "name must be lowercase letters, numbers, hyphens only (got: $NAME)"
    fi

    # ClawHub slug check: ^[a-z0-9][a-z0-9-]*$ (no consecutive hyphens implied)
    if echo "$NAME" | grep -qE '^[a-z0-9][a-z0-9-]*$' && ! echo "$NAME" | grep -q '\-\-'; then
        pass "name passes ClawHub slug pattern"
    else
        fail "name fails ClawHub slug pattern ^[a-z0-9][a-z0-9-]*$: $NAME"
    fi

    # Check name matches directory
    DIR_NAME=$(basename "$SKILL_DIR")
    if [ "$NAME" != "$DIR_NAME" ]; then
        fail "name '$NAME' does not match directory '$DIR_NAME'"
    else
        pass "name matches directory name"
    fi
fi

# --- Required field: version ---
VERSION=$(echo "$FRONTMATTER" | grep -E '^version:' | sed 's/version: *//' | tr -d '"'"'" | tr -d '\r')
if [ -z "$VERSION" ]; then
    fail "Missing required field: version"
elif echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+([.-][A-Za-z0-9]+)?$'; then
    pass "version is valid semver-like value: $VERSION"
else
    fail "version must be semver-like (got: $VERSION)"
fi

# --- Required field: description ---
DESCRIPTION=$(echo "$FRONTMATTER" | grep -E '^description:' | sed "s/description: *//")
if [ -z "$DESCRIPTION" ]; then
    fail "Missing required field: description"
else
    DESC_LEN=${#DESCRIPTION}
    if [ "$DESC_LEN" -gt 1024 ]; then
        fail "description exceeds 1024 chars: $DESC_LEN chars"
    elif [ "$DESC_LEN" -lt 10 ]; then
        fail "description too short: $DESC_LEN chars"
    else
        pass "description is valid ($DESC_LEN chars)"
    fi

    # Check for trigger phrases pattern
    if echo "$DESCRIPTION" | grep -qiE '"[^"]+"|Use when'; then
        pass "description contains trigger phrases"
    else
        warn "description should include trigger phrases (e.g., 'Use when the user asks to \"...\"')"
    fi
fi

# --- Optional but recommended: license ---
if echo "$FRONTMATTER" | grep -qE '^license:'; then
    LICENSE=$(echo "$FRONTMATTER" | grep -E '^license:' | sed 's/license: *//')
    pass "license present: $LICENSE"
else
    warn "Missing recommended field: license"
fi

# --- Optional but recommended: compatibility ---
if echo "$FRONTMATTER" | grep -qE '^compatibility:'; then
    pass "compatibility field present"
else
    warn "Missing recommended field: compatibility"
fi

# --- Optional but recommended: metadata ---
if echo "$FRONTMATTER" | grep -qE '^metadata:'; then
    pass "metadata block present"
    if echo "$FRONTMATTER" | grep -qE '  author:'; then
        pass "metadata.author present"
    else
        warn "metadata.author not found"
    fi
    if echo "$FRONTMATTER" | grep -qE '  version:'; then
        pass "metadata.version present"
    else
        warn "metadata.version not found"
    fi
    # ClawHub: metadata.openclaw (or metadata.clawdbot / metadata.clawdis)
    # Tool-agnostic skills (no hard dependencies) should omit the openclaw block entirely.
    # If present, check for inconsistencies (primaryEnv declared but requires.env empty).
    if echo "$FRONTMATTER" | grep -qE '  openclaw:|  clawdbot:|  clawdis:'; then
        # Check for primaryEnv + empty requires.env inconsistency
        HAS_PRIMARY_ENV=$(echo "$FRONTMATTER" | grep -qE '    primaryEnv:' && echo "yes" || echo "no")
        HAS_EMPTY_REQ_ENV=$(echo "$FRONTMATTER" | grep -qE '      env: \[\]' && echo "yes" || echo "no")
        if [ "$HAS_PRIMARY_ENV" = "yes" ] && [ "$HAS_EMPTY_REQ_ENV" = "yes" ]; then
            fail "ClawHub: metadata.openclaw declares primaryEnv but requires.env is empty — inconsistent (either add the key to requires.env or remove the openclaw block for tool-agnostic skills)"
        else
            pass "ClawHub: metadata.openclaw runtime declaration present and consistent"
        fi
    else
        pass "ClawHub: no metadata.openclaw block (tool-agnostic skill — OK per AGENTS.md)"
    fi
else
    warn "Missing recommended field: metadata"
fi

# --- Body length check ---
BODY_LINES=$(awk 'BEGIN{n=0} /^---/{n++; next} n>=2{print}' "$SKILL_FILE" | wc -l | tr -d ' ')
IS_AUDITOR=$(echo "$FRONTMATTER" | grep -qE '^class: *auditor' && echo "yes" || echo "no")
RUNBOOK_START_COUNT=$(grep -c 'runbook-sync start' "$SKILL_FILE" 2>/dev/null || true)
RUNBOOK_END_COUNT=$(grep -c 'runbook-sync end' "$SKILL_FILE" 2>/dev/null || true)
RUNBOOK_START_LINE=""
RUNBOOK_END_LINE=""
HAS_RUNBOOK_SYNC="no"

if [ "$RUNBOOK_START_COUNT" -eq 1 ] && [ "$RUNBOOK_END_COUNT" -eq 1 ]; then
    RUNBOOK_START_LINE=$(grep -n 'runbook-sync start' "$SKILL_FILE" | cut -d: -f1)
    RUNBOOK_END_LINE=$(grep -n 'runbook-sync end' "$SKILL_FILE" | cut -d: -f1)
    if [ "$RUNBOOK_START_LINE" -lt "$RUNBOOK_END_LINE" ]; then
        HAS_RUNBOOK_SYNC="yes"
    fi
fi

if [ "$IS_AUDITOR" = "yes" ] && [ "$HAS_RUNBOOK_SYNC" = "yes" ]; then
    if [ "$BODY_LINES" -gt 750 ]; then
        warn "Auditor inline runbook is $BODY_LINES lines (allowed target: ≤750). Keep protocol-critical runbook inline, but consider trimming examples."
    else
        pass "Auditor inline runbook length OK: $BODY_LINES lines (≤750 exception)"
    fi
elif [ "$BODY_LINES" -gt 350 ]; then
    warn "Skill body is $BODY_LINES lines (recommended: ≤350 lines / ~4000 tokens). Move reference data to references/ subdirectory."
else
    pass "Skill body length OK: $BODY_LINES lines"
fi

# --- Check for references/ directory if body is large ---
if [ "$IS_AUDITOR" = "yes" ] && [ "$HAS_RUNBOOK_SYNC" = "yes" ]; then
    pass "Auditor inline runbook keeps protocol detail in SKILL.md by design"
elif [ "$BODY_LINES" -gt 250 ] && [ ! -d "$SKILL_DIR/references" ]; then
    warn "Skill body is $BODY_LINES lines but no references/ directory found. Consider extracting detailed tables/rubrics."
fi

# --- Shared contract section checks ---
REQUIRED_HEADINGS=(
    "## Quick Start"
    "## Skill Contract"
    "## Data Sources"
    "## Instructions"
    "## Reference Materials"
    "## Next Best Skill"
)

for heading in "${REQUIRED_HEADINGS[@]}"; do
    if grep -Fxq "$heading" "$SKILL_FILE"; then
        pass "shared contract heading present: $heading"
    else
        fail "Missing shared contract heading: $heading"
    fi
done

if grep -Fxq "### Handoff Summary" "$SKILL_FILE"; then
    pass "shared contract handoff heading present: ### Handoff Summary"
elif [ "$IS_AUDITOR" = "yes" ] && grep -Fxq "## §1 · Handoff Schema (authoritative)" "$SKILL_FILE"; then
    pass "auditor handoff schema section satisfies Handoff Summary contract"
else
    fail "Missing shared contract handoff section: ### Handoff Summary"
fi

if [ "$IS_AUDITOR" = "yes" ]; then
    if grep -Fxq "## When This Must Trigger" "$SKILL_FILE"; then
        pass "auditor heading present: ## When This Must Trigger"
    else
        fail "Auditor skill missing heading: ## When This Must Trigger"
    fi
    if grep -Fxq "## Validation Checkpoints" "$SKILL_FILE"; then
        pass "auditor heading present: ## Validation Checkpoints"
    else
        fail "Auditor skill missing heading: ## Validation Checkpoints"
    fi
    if [ "$HAS_RUNBOOK_SYNC" = "yes" ]; then
        pass "auditor runbook-sync start/end markers present and ordered"
    else
        fail "Auditor skill must have exactly one ordered runbook-sync start marker and end marker"
    fi

    if [ "$HAS_RUNBOOK_SYNC" = "yes" ]; then
        RUNBOOK_SOURCE="$REPO_ROOT/references/auditor-runbook.md"
        MARKER_LINE=$(sed -n "${RUNBOOK_START_LINE}p" "$SKILL_FILE")
        DECLARED_SOURCE_SHA=$(echo "$MARKER_LINE" | sed -n 's/.*source_sha256=\([0-9a-f]\{64\}\).*/\1/p')
        DECLARED_BLOCK_SHA=$(echo "$MARKER_LINE" | sed -n 's/.*block_sha256=\([0-9a-f]\{64\}\).*/\1/p')

        if [ -z "$DECLARED_SOURCE_SHA" ]; then
            fail "Auditor runbook-sync start marker missing source_sha256"
        elif [ -f "$RUNBOOK_SOURCE" ]; then
            ACTUAL_SOURCE_SHA=$(hash_file "$RUNBOOK_SOURCE")
            if [ "$DECLARED_SOURCE_SHA" = "$ACTUAL_SOURCE_SHA" ]; then
                pass "auditor runbook source_sha256 matches references/auditor-runbook.md"
            else
                fail "Auditor runbook source_sha256 drift: expected $ACTUAL_SOURCE_SHA, found $DECLARED_SOURCE_SHA"
            fi
        else
            fail "Missing references/auditor-runbook.md for auditor hash validation"
        fi

        if [ -z "$DECLARED_BLOCK_SHA" ]; then
            fail "Auditor runbook-sync start marker missing block_sha256"
        else
            ACTUAL_BLOCK_SHA=$(awk -v s="$RUNBOOK_START_LINE" -v e="$RUNBOOK_END_LINE" 'NR>s && NR<e {print}' "$SKILL_FILE" | hash_stdin)
            SOURCE_BLOCK_SHA=$(extract_runbook_execution_block "$RUNBOOK_SOURCE" | hash_stdin)
            if [ "$DECLARED_BLOCK_SHA" = "$ACTUAL_BLOCK_SHA" ]; then
                pass "auditor runbook block_sha256 matches inline block"
            else
                fail "Auditor runbook block_sha256 drift: expected $ACTUAL_BLOCK_SHA, found $DECLARED_BLOCK_SHA"
            fi
            if [ "$DECLARED_BLOCK_SHA" = "$SOURCE_BLOCK_SHA" ]; then
                pass "auditor runbook block_sha256 matches source §1-5"
            else
                fail "Auditor runbook source §1-5 drift: expected $SOURCE_BLOCK_SHA, found $DECLARED_BLOCK_SHA"
            fi
        fi
    fi
fi

# --- Next Best Skill termination contract ---
NEXT_BEST_BLOCK=$(awk 'found && /^## /{exit} found{print} /^## Next Best Skill$/{found=1}' "$SKILL_FILE")
if [ -z "$NEXT_BEST_BLOCK" ]; then
    fail "Next Best Skill block is empty"
elif echo "$NEXT_BEST_BLOCK" | grep -qiE 'visited-set|chain-complete|terminal|verdict|max-depth|stop|BLOCK|SHIP|TRUSTED|CAUTIOUS|UNTRUSTED|FIX'; then
    pass "Next Best Skill block has explicit termination or branching language"
elif grep -q "Global default termination rule applies to every Next Best Skill block" "$REPO_ROOT/references/skill-contract.md"; then
    pass "Next Best Skill block inherits global visited-set/max-depth termination contract"
else
    fail "Next Best Skill block lacks termination language and no global default contract was found"
fi

# --- ClawHub: file type check (text only, no binaries) ---
NON_TEXT=$(find "$SKILL_DIR" -type f ! -name "*.md" ! -name "*.txt" ! -name "*.json" ! -name "*.yaml" ! -name "*.yml" ! -name "*.sh" ! -name "*.csv" ! -name ".clawhubignore" ! -name ".gitignore" 2>/dev/null | grep -v '/\.' | head -5)
if [ -n "$NON_TEXT" ]; then
    warn "ClawHub: non-text files found (ClawHub only supports text-based files): $NON_TEXT"
else
    pass "ClawHub: all files are text-based"
fi

# --- Vercel Labs: description optimized for 'npx skills find' discovery ---
if echo "$FRONTMATTER" | grep -qE '^description:'; then
    VERCEL_DESC=$(echo "$FRONTMATTER" | grep -E '^description:' | sed "s/description: *//")
    VERCEL_LEN=${#VERCEL_DESC}
    if [ "$VERCEL_LEN" -gt 50 ]; then
        pass "Vercel Labs: description suitable for 'npx skills find' discovery ($VERCEL_LEN chars)"
    else
        warn "Vercel Labs: description may be too short for effective 'npx skills find' discovery"
    fi
fi

# --- Summary ---
echo ""
echo "=============================================="
echo -e "Results: ${GREEN}$PASS passed${NC}, ${YELLOW}$WARN warnings${NC}, ${RED}$FAIL failed${NC}"

if [ "$FAIL" -gt 0 ]; then
    echo -e "${RED}Validation FAILED — fix errors above before publishing${NC}"
    exit 1
elif [ "$WARN" -gt 0 ]; then
    echo -e "${YELLOW}Validation PASSED with warnings — review recommendations above${NC}"
    exit 0
else
    echo -e "${GREEN}Validation PASSED — skill is spec-compliant${NC}"
    exit 0
fi
