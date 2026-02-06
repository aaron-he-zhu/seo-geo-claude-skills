---
name: memory-management
description: Manages a two-layer memory system (hot cache + cold storage) for SEO/GEO project context, tracking keywords, competitors, metrics, and campaign status with intelligent promotion/demotion.
---

# Memory Management

This skill implements a two-layer memory system for SEO and GEO projects, maintaining a hot cache for active context and cold storage for detailed historical data. It automatically promotes frequently referenced items and demotes stale data, ensuring optimal context loading and efficient project memory.

## When to Use This Skill

- Setting up memory structure for a new SEO project
- After completing audits, ranking checks, or performance reports
- When starting a new campaign or optimization initiative
- When project context needs updating (new keywords, competitors, priorities)
- When you need to look up historical data or project-specific terminology
- After 30+ days of work to clean up and archive stale data
- When context retrieval feels slow or cluttered

## What This Skill Does

1. **Hot Cache Management**: Maintains CLAUDE.md (~100 lines) with active context that's always loaded
2. **Cold Storage Organization**: Structures detailed archives in memory/ subdirectories
3. **Context Lookup**: Implements efficient lookup flow from hot cache to cold storage
4. **Promotion/Demotion**: Moves items between layers based on reference frequency
5. **Glossary Maintenance**: Manages project-specific terminology and shorthand
6. **Update Triggers**: Refreshes memory after audits, reports, or ranking checks
7. **Archive Management**: Time-stamps and archives old data systematically

## How to Use

### Initialize Memory Structure

```
Set up SEO memory for [project name]
```

```
Initialize memory structure for a new [industry] website optimization project
```

### Update After Analysis

```
Update memory after ranking check for [keyword group]
```

```
Refresh hot cache with latest competitor analysis findings
```

### Query Stored Context

```
What are our hero keywords?
```

```
Show me the last ranking update date for [keyword category]
```

```
Look up our primary competitors and their domain authority
```

### Promotion and Demotion

```
Promote [keyword] to hot cache
```

```
Archive stale data that hasn't been referenced in 30+ days
```

### Glossary Management

```
Add [term] to project glossary: [definition]
```

```
What does [internal jargon] mean in this project?
```

## Data Sources

> See [CONNECTORS.md](../../CONNECTORS.md) for tool category placeholders.

**With ~~SEO tool + ~~analytics + ~~search console connected:**
Automatically populate memory from historical data: keyword rankings over time, competitor domain authority changes, traffic metrics, conversion data, backlink profile evolution. The skill will fetch current rankings, alert on significant changes, and update both hot cache and cold storage.

**With manual data only:**
Ask the user to provide:
1. Current target keywords with priority levels
2. Primary competitors (3-5 domains)
3. Key performance metrics and last update date
4. Active campaigns and their status
5. Any project-specific terminology or abbreviations

Proceed with memory structure creation using provided data. Note in CLAUDE.md which data requires manual updates vs. automated refresh.

## Instructions

When a user requests SEO memory management:

### 1. Initialize Memory Structure

For new projects, create the following structure:

```markdown
## Directory Structure

project-root/
├── CLAUDE.md                           # Hot cache (~100 lines)
└── memory/
    ├── glossary.md                     # Project terminology
    ├── keywords/
    │   ├── hero-keywords.md           # Top priority keywords
    │   ├── secondary-keywords.md      # Medium priority
    │   ├── long-tail-keywords.md      # Long-tail opportunities
    │   └── historical-rankings.csv    # Dated ranking data
    ├── competitors/
    │   ├── primary-competitors.md     # Top 3-5 competitors
    │   ├── [competitor-domain].md     # Individual reports
    │   └── analysis-history/          # Dated analyses
    ├── audits/
    │   ├── technical/                 # Technical SEO audits
    │   ├── content/                   # Content audits
    │   └── backlink/                  # Backlink audits
    ├── content-calendar/
    │   ├── active-calendar.md         # Current quarter
    │   ├── published-content.md       # Performance tracking
    │   └── archive/                   # Past calendars
    └── reports/
        ├── monthly/                   # Monthly reports
        ├── quarterly/                 # Quarterly reports
        └── campaign/                  # Campaign-specific reports
```

### 2. Hot Cache (CLAUDE.md) Structure

Create or update CLAUDE.md with this template:

```markdown
# [Project Name] - SEO Memory (Hot Cache)

**Last Updated**: [Date]
**Project Status**: [Active/Maintenance/Growth]

## Active Target Keywords (Top 10-20)

### Hero Keywords (Priority 1)
| Keyword | Current Rank | Target Rank | Volume | Status |
|---------|--------------|-------------|--------|--------|
| [keyword 1] | #[X] | #[Y] | [vol] | [tracking/optimizing/achieved] |
| [keyword 2] | #[X] | #[Y] | [vol] | [tracking/optimizing/achieved] |

### Secondary Keywords (Priority 2)
| Keyword | Current Rank | Target Rank | Volume | Status |
|---------|--------------|-------------|--------|--------|
| [keyword 1] | #[X] | #[Y] | [vol] | [tracking/optimizing/achieved] |

_Full keyword database: memory/keywords/_

## Primary Competitors (Top 3-5)

1. **[Competitor 1]** (DA: [X])
   - Main strengths: [brief]
   - Our position vs. them: [ahead/behind/competitive]

2. **[Competitor 2]** (DA: [X])
   - Main strengths: [brief]
   - Our position vs. them: [ahead/behind/competitive]

_Detailed analyses: memory/competitors/_

## Current Optimization Priorities

1. **[Priority 1]** - [Brief description]
   - Status: [not started/in progress/completed]
   - Expected impact: [high/medium/low]
   - Deadline: [date]

2. **[Priority 2]** - [Brief description]
   - Status: [not started/in progress/completed]
   - Expected impact: [high/medium/low]
   - Deadline: [date]

## Key Metrics Snapshot

**Last Metrics Update**: [Date]

| Metric | Current | Previous | Change | Target |
|--------|---------|----------|--------|--------|
| Organic Traffic | [X] | [X] | [+/-X%] | [target] |
| Avg. Position | [X] | [X] | [+/-X] | [target] |
| Total Keywords Ranking | [X] | [X] | [+/-X] | [target] |
| Page 1 Rankings | [X] | [X] | [+/-X] | [target] |
| Domain Authority | [X] | [X] | [+/-X] | [target] |
| Total Backlinks | [X] | [X] | [+/-X%] | [target] |

_Historical data: memory/reports/_

## Active Campaigns

### [Campaign Name 1]
- **Duration**: [Start date] - [End date]
- **Goal**: [Specific goal]
- **Status**: [planning/active/completed]
- **Progress**: [X]%
- **Key activities**: [brief list]

### [Campaign Name 2]
- **Duration**: [Start date] - [End date]
- **Goal**: [Specific goal]
- **Status**: [planning/active/completed]
- **Progress**: [X]%
- **Key activities**: [brief list]

_Campaign archives: memory/reports/campaign/_

## Quick Reference Notes

- [Important note 1]
- [Important note 2]
- [Important note 3]

_For project terminology, see: memory/glossary.md_
```

### 3. Glossary Structure (memory/glossary.md)

```markdown
# [Project Name] - SEO Glossary

**Purpose**: Project-specific terminology, brand terms, internal jargon, and abbreviations.

**Last Updated**: [Date]

## Brand Terms

| Term | Full Name | Context |
|------|-----------|---------|
| [abbreviation] | [full name] | [when/how it's used] |

## Product Names

| Internal Name | Public Name | Category |
|---------------|-------------|----------|
| [code name] | [market name] | [product type] |

## Custom Segments

| Segment Name | Definition | Keyword Count |
|--------------|------------|---------------|
| Hero KWs | Top 10 revenue-driving keywords | 10 |
| Quick Wins | Low-difficulty, high-value targets | 25 |
| Brand Defense | Brand + modifier combinations | 15 |

## Competitor Shorthand

| Shorthand | Full Domain | Notes |
|-----------|-------------|-------|
| Comp A | competitor-a.com | Main competitor, [industry] |
| Comp B | competitor-b.com | Niche competitor, [specialty] |

## Project Acronyms

| Acronym | Full Term | Definition |
|---------|-----------|------------|
| [ABC] | [Full term] | [What it means in this project] |

## Internal Jargon

| Phrase | Meaning | Example Usage |
|--------|---------|---------------|
| [phrase] | [definition] | "Check rankings for [phrase]" |

## Historical Context

- **Project started**: [Date]
- **Major algorithm updates affecting us**: [List with dates]
- **Site migrations/redesigns**: [List with dates]
- **Key milestones**: [List with dates]

---

_This glossary helps decode project shorthand and maintain consistency across reports and communications._
```

### 4. Context Lookup Flow

When a user references something unclear, follow this lookup sequence:

**Step 1: Check CLAUDE.md (Hot Cache)**
- Is it in active keywords?
- Is it in primary competitors?
- Is it in current priorities or campaigns?

**Step 2: Check memory/glossary.md**
- Is it defined as project terminology?
- Is it a custom segment or shorthand?

**Step 3: Check Cold Storage**
- Search memory/keywords/ for historical data
- Search memory/competitors/ for past analyses
- Search memory/reports/ for archived mentions

**Step 4: Ask User**
- If not found in any layer, ask for clarification
- Log the new term in glossary if it's project-specific

Example lookup:

```markdown
User: "Update rankings for our hero KWs"

Step 1: Check CLAUDE.md → Found "Hero Keywords (Priority 1)" section
Step 2: Extract keyword list from hot cache
Step 3: Execute ranking check
Step 4: Update both CLAUDE.md and memory/keywords/historical-rankings.csv
```

### 5. Promotion Logic

**Promote to Hot Cache when:**

1. **Keyword promotion triggers:**
   - Keyword referenced in 3+ conversations within 7 days
   - Keyword showing significant movement (5+ position change)
   - Keyword targeted in new active campaign
   - Keyword suddenly driving traffic spike

2. **Competitor promotion triggers:**
   - Competitor mentioned in 3+ recent analyses
   - Competitor showing aggressive SEO activity
   - Competitor launching competing content

3. **Metric promotion triggers:**
   - Metric requested frequently for reporting
   - Metric showing anomalous behavior
   - Metric tied to active priority/campaign

**Promotion action:**
```markdown
1. Add item to relevant section in CLAUDE.md
2. Add note: "Promoted [date] - [reason]"
3. Keep detailed data in cold storage
4. Set reminder to review in 30 days
```

### 6. Demotion Logic

**Demote to Cold Storage when:**

1. **Keyword demotion triggers:**
   - Not referenced in 30+ days
   - Target rank achieved and stable for 60+ days
   - Keyword no longer in active strategy
   - Keyword replaced by higher-priority target

2. **Competitor demotion triggers:**
   - No significant activity in 60+ days
   - Fell out of top 5 competitors by relevance
   - No longer targeting same keywords

3. **Campaign demotion triggers:**
   - Campaign completed 30+ days ago
   - Campaign cancelled or postponed indefinitely

**Demotion action:**
```markdown
1. Remove from CLAUDE.md
2. Archive full data in memory/[category]/archive/
3. Add line to CLAUDE.md: "Last reviewed [category]: [date]"
4. Keep 1-line summary if historically significant
```

### 7. Update Triggers

After specific events, update memory systematically:

**After Ranking Check:**
```markdown
1. Update CLAUDE.md → Hero Keywords table (current ranks)
2. Append to memory/keywords/historical-rankings.csv
3. Note any keywords with significant movement
4. Update "Last Metrics Update" date in CLAUDE.md
5. If hero keyword moves ±5 positions, create alert note
```

**After Competitor Analysis:**
```markdown
1. Update CLAUDE.md → Primary Competitors section (DA, position vs. them)
2. Save full report to memory/competitors/analysis-history/YYYY-MM-DD-analysis.md
3. Update individual competitor files if detailed findings
4. Note new competitor strategies in hot cache
```

**After Audit (Technical/Content/Backlink):**
```markdown
1. Save full report to memory/audits/[type]/YYYY-MM-DD-[audit-name].md
2. Extract top 3-5 action items → CLAUDE.md Current Optimization Priorities
3. Update Key Metrics Snapshot if audit includes metrics
4. Create campaign entry if audit spawns new initiative
```

**After Monthly/Quarterly Report:**
```markdown
1. Save report to memory/reports/[period]/YYYY-MM-report.md
2. Update all metrics in CLAUDE.md Key Metrics Snapshot
3. Review hot cache → demote stale items
4. Update campaign statuses
5. Archive completed campaigns
```

### 8. Archive Management

**Monthly Archive Routine:**

```markdown
1. Review CLAUDE.md for items not referenced in 30 days
2. Move stale items to appropriate cold storage
3. Create monthly snapshot: memory/snapshots/YYYY-MM-CLAUDE.md
4. Compress old historical-rankings.csv (keep only last 90 days in main file)
5. Update glossary with new terms from the month
```

**Quarterly Archive Routine:**

```markdown
1. Review entire cold storage structure
2. Compress files older than 6 months
3. Create quarterly summary report
4. Update project timeline in glossary
5. Audit all active campaigns → archive completed ones
```

### 9. Cross-Skill Memory Integration

This skill coordinates with other SEO skills:

**When keyword-research runs:**
- Add discovered keywords to memory/keywords/
- Promote top opportunities to CLAUDE.md if high-value
- Update glossary if new terminology emerges

**When rank-tracker runs:**
- Update historical-rankings.csv
- Refresh CLAUDE.md Hero Keywords table
- Flag significant movements for hot cache notes

**When competitor-analysis runs:**
- Update competitor files in memory/competitors/
- Refresh CLAUDE.md Primary Competitors section
- Add new competitors if they outrank current top 5

**When content-gap-analysis runs:**
- Store full findings in memory/audits/content/
- Promote gap opportunities to CLAUDE.md priorities
- Update content calendar with recommended topics

**When seo-content-writer produces content:**
- Log to memory/content-calendar/published-content.md
- Track target keyword and publish date
- Set reminder to check performance in 30 days

## Validation Checkpoints

### Structure Validation
- [ ] CLAUDE.md exists and is under 150 lines (aim for ~100)
- [ ] memory/ directory structure matches template
- [ ] glossary.md exists and is populated with project basics
- [ ] All historical data files include timestamps in filename or metadata

### Content Validation
- [ ] CLAUDE.md "Last Updated" date is current
- [ ] Every keyword in hot cache has current rank, target rank, and status
- [ ] Every competitor has domain authority and position assessment
- [ ] Every active campaign has status percentage and expected completion date
- [ ] Key Metrics Snapshot shows "Previous" values for comparison

### Lookup Validation
- [ ] Test lookup flow: reference a term → verify it finds it in correct layer
- [ ] Test promotion: manually promote item → verify it appears in CLAUDE.md
- [ ] Test demotion: manually archive item → verify removed from CLAUDE.md
- [ ] Glossary contains all custom segments and shorthand used in CLAUDE.md

### Update Validation
- [ ] After ranking check, historical-rankings.csv has new row with today's date
- [ ] After competitor analysis, analysis-history/ has dated file
- [ ] After audit, top action items appear in CLAUDE.md priorities
- [ ] After monthly report, metrics snapshot reflects new data

## Example

**User**: "Update rankings for our hero keywords"

**Assistant**:

```markdown
I'll update rankings for your hero keywords. Let me check the hot cache for the list.

[Reads CLAUDE.md, finds Hero Keywords section:]
- keyword research tools (currently #15, target #5)
- best seo software (currently #23, target #10)
- free backlink checker (currently #8, target #3)
- content optimization guide (currently #12, target #5)
- technical seo audit (currently #18, target #8)

[If ~~SEO tool connected: runs automated ranking check]
[If manual: asks user for current rankings]

---

## Ranking Update - December 15, 2024

| Keyword | Previous | Current | Change | Target | Status |
|---------|----------|---------|--------|--------|--------|
| keyword research tools | #15 | #12 | ↑3 | #5 | Improving ⭐ |
| best seo software | #23 | #24 | ↓1 | #10 | Stable |
| free backlink checker | #8 | #6 | ↑2 | #3 | Near target ⭐⭐ |
| content optimization guide | #12 | #11 | ↑1 | #5 | Improving |
| technical seo audit | #18 | #16 | ↑2 | #8 | Improving |

### Notable Changes
- **free backlink checker** moved to #6 (only 3 positions from target!)
- **keyword research tools** gained 3 positions (strong movement)
- All other keywords showing stable or positive movement

### Updated Files
1. CLAUDE.md → Hero Keywords table updated with current ranks
2. memory/keywords/historical-rankings.csv → New row added:
   `2024-12-15,keyword research tools,12,best seo software,24,free backlink checker,6,...`

### Recommendations
1. Push additional content/backlinks to "free backlink checker" pages to hit #3 target
2. Investigate why "keyword research tools" suddenly gained 3 positions (replicate success)
3. Monitor "best seo software" for any negative trends

Hot cache refreshed. Next ranking check recommended: December 22, 2024.
```

---

**User**: "What does 'quick wins' mean in our project?"

**Assistant**:

```markdown
Let me look that up in the project memory.

[Step 1: Check CLAUDE.md → not found]
[Step 2: Check memory/glossary.md → found!]

From your project glossary:

**Quick Wins**
- **Definition**: Low-difficulty, high-value target keywords
- **Keyword Count**: 25 keywords
- **Context**: This segment includes keywords where you can achieve page 1 rankings within 30-60 days due to low competition, despite having decent search volume

According to your memory files, your current quick wins are stored in:
`memory/keywords/long-tail-keywords.md` (tagged with "quick-win" label)

Would you like me to show you the current list of quick win keywords?
```

---

**User**: "Set up memory for a new e-commerce site selling outdoor gear"

**Assistant**:

```markdown
I'll set up the two-layer memory system for your outdoor gear e-commerce site.

## Creating Directory Structure

[Creates: memory/glossary.md, memory/keywords/, memory/competitors/, etc.]

## CLAUDE.md (Hot Cache) - Initial Setup

I'll need some information to populate the hot cache:

1. **Target Keywords**: What are your top 10 hero keywords?
   (e.g., "hiking backpacks", "camping tents", "outdoor clothing")

2. **Primary Competitors**: Who are your top 3-5 competitors?
   (e.g., rei.com, backcountry.com, moosejaw.com)

3. **Current Metrics** (if available):
   - Domain authority?
   - Current organic traffic?
   - Any existing rankings?

4. **Active Initiatives**:
   - Are you launching a new category?
   - Running a content campaign?
   - Focusing on any specific product line?

5. **Project Terminology**:
   - Any internal product names or abbreviations?
   - How do you segment your keyword strategy?

Please provide what you have, and I'll create your initial CLAUDE.md and glossary. We can start with basics and enrich as we gather more data.

---

Once you provide this information, I'll generate:
- CLAUDE.md with your initial hot cache
- memory/glossary.md with project terminology
- memory/keywords/ structure with placeholder files
- memory/competitors/ with initial competitor list
- memory/content-calendar/active-calendar.md for Q1 2025

After setup, you can use commands like:
- "Update rankings for hero keywords"
- "Add new competitor [domain]"
- "Promote [keyword] to hot cache"
- "Archive campaigns from Q3 2024"
```

## Advanced Features

### Smart Context Loading

```
Load full context for [campaign name]
```

Retrieves hot cache + all cold storage files related to campaign.

### Memory Health Check

```
Run memory health check
```

Audits memory structure: finds orphaned files, missing timestamps, stale hot cache items, broken references.

### Bulk Promotion/Demotion

```
Promote all keywords ranking in top 10 to hot cache
```

```
Demote all completed campaigns from Q3 2024
```

### Memory Snapshot

```
Create memory snapshot for [date/milestone]
```

Takes point-in-time copy of entire memory structure for major milestones (site launches, algorithm updates, etc.).

### Cross-Project Memory

```
Compare memory with [other project name]
```

Identifies keyword overlaps, competitor intersections, and strategy similarities across multiple projects.

## Tips for Success

1. **Keep hot cache lean** - CLAUDE.md should never exceed 150 lines. If it grows larger, aggressively demote.

2. **Date everything** - Every file in cold storage should have YYYY-MM-DD in filename or prominent metadata.

3. **Update after every significant action** - Don't let memory drift from reality. Update immediately after ranking checks, audits, or reports.

4. **Use glossary liberally** - If you find yourself explaining a term twice, add it to glossary.

5. **Review hot cache weekly** - Quick scan to ensure everything there is still relevant and active.

6. **Automate where possible** - If ~~SEO tool or ~~search console connected, set up automatic updates to historical-rankings.csv.

7. **Archive aggressively** - Better to have data in cold storage and not need it than clutter hot cache.

8. **Link between layers** - CLAUDE.md should always reference where detailed data lives ("Full data: memory/keywords/").

9. **Timestamp changes** - When updating CLAUDE.md, always update "Last Updated" date.

10. **Use memory for continuity** - If you switch between different analysis sessions, memory ensures nothing is forgotten.

## Related Skills

- [rank-tracker](../../monitor/rank-tracker/) - Provides ranking data to update memory
- [competitor-analysis](../../research/competitor-analysis/) - Generates competitor reports for storage
- [keyword-research](../../research/keyword-research/) - Discovers keywords to add to memory
- [performance-reporter](../../monitor/performance-reporter/) - Creates reports that trigger memory updates
- [content-gap-analysis](../../research/content-gap-analysis/) - Identifies optimization priorities for hot cache
- [seo-content-writer](../../build/seo-content-writer/) - Logs published content to memory calendar
- [content-quality-auditor](../content-quality-auditor/) - Audit results stored in memory for tracking
