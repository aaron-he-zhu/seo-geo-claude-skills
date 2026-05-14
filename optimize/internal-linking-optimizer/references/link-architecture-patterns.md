# Link Architecture Patterns

Architecture models, selection thresholds, migration safeguards, and measurement targets for internal linking optimization.

## Model Selector

| Model | Best For | Site Size Fit | Core Rules | Measurement Targets |
|-------|----------|---------------|------------|---------------------|
| Hub-and-Spoke | Content marketing, SaaS, publishers, topic clusters | 50-500 content pages | 3-7 pillars, 800-2,000 word clusters, bidirectional pillar/cluster links, related cluster cross-links, bridge links where topics overlap | Pillars top 10 for head terms; clusters top 20 for long-tail; 3-5 internal links per cluster; click depth <=3 |
| Silo | E-commerce, directories, separate business lines | 100+ categories or distinct taxonomies | 5-15 top categories, vertical parent/child links, breadcrumbs, strict or sparing cross-silo links | Avg click depth <=4; orphan pages 0; avg internal links/page 3-7 |
| Flat | Small sites and shallow URL structures | <50 ideal; 50-100 manageable; 100-500 difficult; 500+ not recommended | Key pages linked from homepage, shallow URLs, free cross-links, navigation/menu support | Avg click depth <=2; orphan pages 0; avg internal links/page 8-15 |
| Pyramid | News/media, large blogs, corporate, government/education | 500+ posts or clear hierarchy | 3-4 hierarchy levels max, homepage -> category -> subcategory -> page, breadcrumbs, related content cross-links | Avg click depth <=4; orphan pages 0; avg internal links/page 3-5 |
| Mesh/Matrix | Knowledge bases, wikis, research repositories, FAQ/help centers | Dense topic networks | Link only when topically relevant, descriptive anchors, 5-15 contextual links per 1,000 words, quarterly pruning, maintained link map | Avg click depth <=3; orphan pages 0; avg internal links/page 8-15 |

## Link Rules by Model

| Model | Required Links | Optional / Conditional Links | Avoid |
|-------|----------------|------------------------------|-------|
| Hub-and-Spoke | Pillar -> all clusters; every cluster -> pillar | Cluster <-> related cluster; hub <-> hub bridge | Unrelated bridges that dilute topical focus |
| Silo | Parent -> child; child -> parent; sibling links within same parent | Modified cross-silo links when user intent overlaps | Strict model: broad cross-silo linking |
| Flat | Homepage/navigation -> all key pages; contextual cross-links | HTML sitemap for larger flat sites | Letting pages drift beyond 2 clicks |
| Pyramid | Each level links down and up; breadcrumbs | Related content links at page level | More than 4 levels without shortcuts |
| Mesh | Contextual links with descriptive anchors | Cross-topic links only with clear relevance | >15 contextual links per 1,000 words or generic anchors |

## Migration Between Models

| From | To | Trigger | Difficulty |
|------|----|---------|------------|
| Flat | Hub-and-Spoke | Site grew beyond 100 pages | Medium |
| Silo | Hub-and-Spoke | Silos too rigid for topical authority | Medium |
| Pyramid | Hub-and-Spoke | Want topic clusters over hierarchy | High |
| No structure | Any model | Orphans, depth, or chaotic linking | High |

**Migration safety checklist**

1. Audit current state: map existing internal links, orphan pages, click depth, and top linked pages.
2. Design target architecture: assign every important page to its new position.
3. Create a link-change plan: document each link to add, keep, move, or remove.
4. Implement in phases: start with highest-priority cluster/silo and avoid sitewide flips.
5. Preserve existing equity: do not remove valuable links without replacement.
6. Monitor rankings, crawl stats, traffic, and indexation for 4-8 weeks per phase.
7. Iterate only after measured impact is clear.

## Monthly Monitoring

| Check | Target | Action if Failing |
|-------|--------|-------------------|
| Orphan pages | 0 | Add internal links immediately or redirect/remove low-value pages |
| Average click depth | Model target above | Add homepage/category shortcuts to deep pages |
| Internal link count/page | Model target above | Add links to under-linked pages or prune over-linked pages |
| Anchor text diversity | Natural, descriptive mix | Vary anchors for over-optimized pages |
| Broken internal links | 0 | Fix, redirect, or remove |
| New content linked | Within 48 hours | Add to related pages upon publishing |

## Hybrid: Hub-and-Spoke + Silo

Recommended for medium-large sites that need both taxonomy clarity and topical authority.

```text
Homepage
  +-- Category Silo A
  |     +-- Hub A1 (pillar) <-> Cluster articles
  |     +-- Hub A2 (pillar) <-> Cluster articles
  +-- Category Silo B
  |     +-- Hub B1 (pillar) <-> Cluster articles
  +-- Cross-category bridge links only where user intent overlaps
```

Implementation priority:

1. Fix structural defects first: orphan pages, broken links, and excessive crawl depth.
2. Choose the primary architecture model.
3. Add cluster/silo cross-links where relevance is clear.
4. Optimize anchor text after structure is stable.
5. Monitor, then iterate.
