# CORE-EEAT Deep Integration Design

> Based on [CORE-EEAT Content Benchmark](https://github.com/aaron-he-zhu/core-eeat-content-benchmark)

## Goal

Full lifecycle integration of the CORE-EEAT 80-item content quality benchmark into seo-geo-claude-skills:
- **Quality Gate**: Evaluate content produced by skills against 80 items
- **Writing Enhancement**: Embed CORE-EEAT criteria into creation/optimization skills
- **Standalone Audit**: Dedicated cross-cutting skill for complete 80-item audits

## Architecture Changes

### File Structure

```
seo-geo-claude-skills/
├── references/
│   └── core-eeat-benchmark.md           # NEW: shared benchmark (source of truth)
├── cross-cutting/                        # NEW: cross-cutting category
│   ├── memory-management/SKILL.md        # MOVED from root
│   └── content-quality-auditor/SKILL.md  # NEW: 80-item audit skill
├── build/
│   ├── seo-content-writer/SKILL.md       # DEEP: checklist pre-load + self-check
│   ├── geo-content-optimizer/SKILL.md    # DEEP: GEO-First items as optimization targets
│   ├── meta-tags-optimizer/SKILL.md      # LIGHT: C01 + C02 validation
│   └── schema-markup-generator/SKILL.md  # LIGHT: O05 + content-type schema mapping
├── optimize/
│   ├── on-page-seo-auditor/SKILL.md      # LIGHT: CORE-EEAT quick scan subset
│   ├── content-refresher/SKILL.md        # DEEP: score-first to identify weak dimensions
│   └── ...
├── commands/
│   ├── audit-page.md                     # ENHANCED: add CORE-EEAT 80-item scoring
│   └── check-technical.md                # NEW: technical SEO quick check
├── README.md                             # UPDATED
└── ...
```

### Design Principles

- Benchmark data has a single source of truth: `references/core-eeat-benchmark.md`
- All skills reference (not copy) benchmark content
- File header declares: `Based on https://github.com/aaron-he-zhu/core-eeat-content-benchmark`

## Changes Summary

### New Files (3)

| File | Description |
|------|-------------|
| `references/core-eeat-benchmark.md` | Complete benchmark: 80 items, scoring methodology, content-type weights. Header declares source repo. |
| `cross-cutting/content-quality-auditor/SKILL.md` | Full 80-item audit skill with per-item scoring, dimension scores, weighted totals, Top 5 improvements, action plan. |
| `commands/check-technical.md` | Technical SEO quick check: crawlability, HTTPS, speed, robots.txt, Core Web Vitals. |

### Deep Changes (3 skills)

| File | Change |
|------|--------|
| `build/seo-content-writer/SKILL.md` | Add step in Instructions: before writing, load high-weight CORE-EEAT items for the content type as constraints; after writing, run self-check checklist. |
| `build/geo-content-optimizer/SKILL.md` | Same pattern: load GEO-First tagged items (~25 items) as optimization targets; post-optimization self-check. |
| `optimize/content-refresher/SKILL.md` | Before refreshing, run CORE-EEAT quick score to identify weakest dimensions; focus refresh effort on those. |

### Light Changes (3 skills)

| File | Change |
|------|--------|
| `optimize/on-page-seo-auditor/SKILL.md` | Add "CORE-EEAT Quick Scan" section with relevant subset (~20-25 items). Prompt user to use `content-quality-auditor` for full audit. |
| `build/meta-tags-optimizer/SKILL.md` | Add C01 (Intent Alignment) and C02 (Direct Answer) checks in validation step. |
| `build/schema-markup-generator/SKILL.md` | Reference O05 standard in schema selection logic + benchmark's content-type to schema mapping. |

### Enhanced (1 command)

| File | Change |
|------|--------|
| `commands/audit-page.md` | Add CORE-EEAT 80-item scoring output. Clarify scope: content quality + on-page SEO only. Guide users to `/seo:check-technical` for technical checks. |

### Structural (1 move)

| Action | Description |
|--------|-------------|
| `memory-management/` → `cross-cutting/memory-management/` | Move into cross-cutting category directory. |

### Updated (1 file)

| File | Changes |
|------|---------|
| `README.md` | Update architecture diagram; add cross-cutting category; add CORE-EEAT integration section with source attribution; update command list (6 commands); update recommended workflow with audit step. |

## Command Scope Separation

| Command | Focuses on | Does NOT cover |
|---------|-----------|----------------|
| `/seo:audit-page` | Content quality (CORE-EEAT 80 items) + on-page SEO signals | Server, speed, crawlability |
| `/seo:check-technical` | Technical health (crawl, HTTPS, speed, robots.txt, Core Web Vitals) | Content quality |

## content-quality-auditor Skill Design

### Input
- Content: text / URL / local file path
- Content type: one of 9 types (auto-detectable), e.g., Product Review, How-to, Comparison
- Optional: competitor content for benchmarking

### Workflow

```
Step 1: Preparation
├── Identify/confirm content type
├── Load corresponding weight configuration
└── Check veto items (T04, C01, R10) → flag red alert if triggered

Step 2: CORE Audit (40 items)
├── C: Contextual Clarity (10)
├── O: Organization (10)
├── R: Referenceability (10)
└── E: Exclusivity (10)

Step 3: EEAT Audit (40 items)
├── Exp: Experience (10)
├── Ept: Expertise (10)
├── A: Authority (10)
└── T: Trust (10)

Step 4: Scoring & Report
├── Per-item scoring (Pass=10 / Partial=5 / Fail=0)
├── 8 dimension scores (0-100 each)
├── GEO Score = (C+O+R+E)/4
├── SEO Score = (Exp+Ept+A+T)/4
├── Weighted total (by content-type weights)
├── Rating (Excellent/Good/Medium/Low/Poor)
├── Top 5 priority improvements (sorted by weight × points lost)
└── Action plan (specific modification suggestions)
```

### Report Structure

```
## Audit Report

### Overview
- Content type: [type]
- Total score: [score]/100 ([rating])
- GEO Score: [score] | SEO Score: [score]
- Veto status: pass / [item] triggered

### Dimension Scores
| Dimension | Score | Rating |
|-----------|-------|--------|
| C - Contextual Clarity | xx | Good |
| O - Organization | xx | Excellent |
| R - Referenceability | xx | ... |
| E - Exclusivity | xx | ... |
| Exp - Experience | xx | ... |
| Ept - Expertise | xx | ... |
| A - Authority | xx | ... |
| T - Trust | xx | ... |

### Per-Item Scores
| ID | Check Item | Score | Notes |
|----|-----------|-------|-------|
| C01 | Intent Alignment | Pass | ... |
| C02 | Direct Answer | Partial | Core answer not in first 150 words |
| ... | | | |

### Top 5 Priority Improvements
1. [item] — [specific modification suggestion]
2. ...

### Action Plan
[Actionable improvement steps grouped by dimension]
```

## Checklist Pre-load Pattern (for deep-change skills)

Used by `seo-content-writer`, `geo-content-optimizer`, `content-refresher`:

```
Before [writing/optimizing/refreshing]:
1. Identify content type
2. Load CORE-EEAT items with highest weights for this content type
3. Load all GEO-First tagged items (for geo-content-optimizer)
4. Present loaded items as constraints/targets

After [writing/optimizing/refreshing]:
1. Self-check against loaded items
2. Flag any Fail items
3. Suggest if full audit via content-quality-auditor is warranted
```

## Totals

- New files: 3
- Modified files: 8
- Moved: 1 directory
- Commands: 5 → 6
- Skills: 17 → 18
- Cross-cutting skills: 1 → 2
