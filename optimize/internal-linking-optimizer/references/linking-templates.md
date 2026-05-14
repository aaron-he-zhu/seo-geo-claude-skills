# Internal Linking Optimizer Output Templates

Compact templates for `internal-linking-optimizer` steps 3-7. Keep thresholds intact when slimming: orphan pages target **0**, over-optimized anchors target **<10%**, and exact-match anchors should stay at **10-20%**.

## Step 3: Anchor Text Analysis

```markdown
## Anchor Text Analysis

CORE-EEAT alignment: R08 Internal Link Graph.

| Check | Finding | Risk | Action |
|-------|---------|------|--------|
| Most-used anchors | [anchor + count] | [generic/over-optimized/unclear] | [rewrite or diversify] |
| Target-page distribution | [URL + anchor mix] | [cannibalization or repetition] | [recommended variation set] |
| Generic anchors | [X instances] | Poor context | Replace with descriptive anchors |
| Same anchor to multiple pages | [anchor + targets] | Ambiguous relevance | Assign one primary target |

### Recommended Variations for [URL]
| Anchor type | Usage target | Examples |
|-------------|--------------|----------|
| Exact match | 10-20% | "[primary keyword]" |
| Partial match | 30-40% | "[keyword + modifier]" |
| Branded | 10-20% | "[Brand]'s guide to..." |
| Natural | 20-30% | "this checklist", "the full guide" |

**Anchor Score**: [X]/10
```

## Step 4: Topic Cluster Link Strategy

```markdown
## Topic Cluster Internal Linking

**Cluster**: [Main topic]
**Pillar page**: [URL]
**Cluster articles**: [count]

### Required Link Pattern
| Link path | Requirement | Status |
|-----------|-------------|--------|
| Pillar -> cluster | Pillar links to every indexable cluster article | [pass/fail] |
| Cluster -> pillar | Every cluster article links back to pillar | [pass/fail] |
| Cluster -> cluster | Related articles cross-link where context helps users | [pass/fail] |

### Links to Add
| From page | To page | Anchor text | Location | Priority |
|-----------|---------|-------------|----------|----------|
| [URL] | [URL] | "[anchor]" | [section/paragraph] | [High/Med/Low] |
```

## Step 5: Contextual Link Opportunities

```markdown
## Contextual Link Opportunities

**Page**: [URL]
**Topic**: [topic]
**Current internal links**: [count]

| Source context | Target page | Anchor text | Reason | Priority |
|----------------|-------------|-------------|--------|----------|
| Paragraph mentions "[topic]" | [URL] | "[topic phrase]" | Topic match | [High/Med/Low] |
| Section covers "[subject]" | [URL] | "[anchor]" | Supports next step | [High/Med/Low] |

### Priority Addition
**From**: [source URL]
**To**: [target URL]
**Anchor**: "[anchor text]"
**Where**: [specific sentence/section]
**Why now**: [ranking, orphan fix, crawl depth, conversion path]
```

## Step 6: Navigation and Footer Optimization

```markdown
## Site-Wide Link Optimization

| Element | Current | Recommended | Reason |
|---------|---------|-------------|--------|
| Main nav | [links/status] | [change] | [priority page/user path] |
| Footer | [links/status] | [change] | [support/commercial path] |
| Sidebar | [status] | [change] | [context] |
| Breadcrumbs | [status] | [change] | [crawl path/user clarity] |

### Add, Demote, Remove
| Page | Action | Location | Reason |
|------|--------|----------|--------|
| [URL] | [add/demote/remove] | [nav/footer/sidebar] | [reason] |
```

## Step 7: Implementation Plan

```markdown
# Internal Linking Optimization Plan

**Site**: [domain] | **Analysis date**: [date]

## Summary
| Metric | Current | Target | Gap |
|--------|---------|--------|-----|
| Avg links per page | [X] | [X] | [X] |
| Orphan pages | [X] | 0 | [X] |
| Over-optimized anchors | [X]% | <10% | [X]% |
| Topic cluster coverage | [X]% | 100% | [X]% |

## Phased Work
| Phase | Timing | Required actions |
|-------|--------|------------------|
| Critical fixes | Week 1 | Fix orphan pages; add high-value contextual links from authority pages. |
| Topic clusters | Weeks 2-3 | Ensure pillar -> cluster, cluster -> pillar, and useful cluster cross-links. |
| Optimization | Week 4+ | Diversify anchors, adjust nav/footer, and rebalance under-linked priority pages. |

## Tracking
- [ ] Rankings for target keywords
- [ ] Traffic to previously orphan pages
- [ ] Crawl stats in Search Console
- [ ] Internal link distribution changes
- [ ] Over-optimized anchors below 10%
```
