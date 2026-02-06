---
description: Run a comprehensive on-page SEO + CORE-EEAT content quality audit for a given URL or content
argument-hint: "<URL or paste content>"
---

# Audit Page Command

> If you see unfamiliar ~~placeholders in this document, see [CONNECTORS.md](../CONNECTORS.md) for the tool category mapping.
>
> Content quality scoring based on [CORE-EEAT Content Benchmark](https://github.com/aaron-he-zhu/core-eeat-content-benchmark). Full reference: [references/core-eeat-benchmark.md](../references/core-eeat-benchmark.md)

A comprehensive audit command that analyzes both **on-page SEO health** and **content quality (CORE-EEAT 80-item benchmark)**, delivering a unified scored report with actionable recommendations.

**Scope**: Content quality + on-page SEO signals + basic page-level technical checks. For full site-wide technical SEO (infrastructure, crawl budget, redirect chains), use `/seo:check-technical`.

## Usage

```
/seo:audit-page https://example.com/blog-post
/seo:audit-page [paste content here] targeting "keyword"
/seo:audit-page https://example.com/landing-page keyword="primary keyword"
```

**Arguments:**
- URL or pasted content (required)
- `keyword="target keyword"` (optional but recommended for relevance scoring)

## Workflow

### 1. Gather Input

**With URL:**
- Fetch page content using `~~web crawler`
- Extract HTML, meta tags, headers, images, links
- Identify canonical URL and indexing directives

**With Pasted Content:**
- Accept raw HTML or plain text
- Parse structure manually
- Request target keyword if not provided

**Without Integrations:**
- Request user to paste full HTML source
- Manually extract key elements (title, meta, headings, body)

### 2. Validate Input

Check prerequisites before running audit:
- Content length >= 300 words (minimum for meaningful audit)
- Page accessible (status 200) if URL provided
- Valid HTML structure (parseable)
- Target keyword provided (prompt if missing)

If validation fails, provide specific guidance on what's needed.

### 3. Run Comprehensive Audit

Analyze 8 core areas:

#### A. Title Tag Analysis
- Length (50-60 characters optimal)
- Keyword placement (earlier = better)
- Brand inclusion
- Uniqueness check via `~~SEO tool`
- CTR appeal (power words, numbers, emotional triggers)
- **Score: X/10**

#### B. Meta Description Analysis
- Length (150-160 characters optimal)
- Keyword presence
- Call-to-action clarity
- Unique value proposition
- Duplication check via `~~SEO tool`
- **Score: X/10**

#### C. Header Structure
- H1 presence and uniqueness (must have exactly one)
- Keyword in H1
- Logical hierarchy (H2 → H3, no skipping)
- Header count and distribution
- Keyword usage in subheadings
- **Score: X/10**

#### D. Content Quality
- Word count (benchmark against top 10 for keyword via `~~SEO tool`)
- Keyword density (1-2% target)
- Readability score (Flesch Reading Ease)
- LSI keyword presence (topically related terms)
- Content freshness (date stamps, recent references)
- Multimedia integration (images, videos, diagrams)
- **Score: X/10**

#### E. Keyword Optimization
- Primary keyword in first 100 words
- Keyword variants and synonyms
- Natural language usage (not stuffed)
- Semantic relevance (TF-IDF analysis via `~~SEO tool`)
- Long-tail keyword coverage
- **Score: X/10**

#### F. Internal & External Links
- Internal link count (3-5 contextual links minimum)
- External link quality (authority sites)
- Anchor text optimization
- Link placement (natural, in-content)
- Broken link check via `~~web crawler`
- NoFollow usage appropriateness
- **Score: X/10**

#### G. Image Optimization
- Alt text presence (all images)
- Alt text keyword optimization
- File name descriptiveness
- Image size and load time
- Modern format usage (WebP, AVIF)
- Lazy loading implementation
- **Score: X/10**

#### H. Page-Level Technical Signals
- Schema markup presence and correctness
- Canonical tag correctness
- Robots meta tag (index/noindex)
- URL structure (clean, descriptive, lowercase)
- **Score: X/10**

> **Note**: This covers page-level signals only. For site-wide technical checks (crawlability, Core Web Vitals, HTTPS, mobile responsiveness, server infrastructure), run `/seo:check-technical`.

### 4. Run CORE-EEAT Content Quality Audit

Run the full 80-item CORE-EEAT benchmark evaluation using [references/core-eeat-benchmark.md](../references/core-eeat-benchmark.md):

#### Veto Check (Emergency Brake)
Check these first — any failure triggers immediate alert:
- **T04**: Affiliate links present without disclosure → VETO
- **C01**: Clickbait title not matching content → VETO
- **R10**: Core data contradicts itself → VETO

#### CORE Audit (40 Items)
Score each item: Pass=10, Partial=5, Fail=0

- **C — Contextual Clarity** (C01–C10): Intent alignment, direct answer, query coverage, definitions, scope, audience, coherence, use cases, FAQ, closure
- **O — Organization** (O01–O10): Heading hierarchy, summary box, data tables, lists, schema, chunking, visual hierarchy, navigation, density, multimedia
- **R — Referenceability** (R01–R10): Data precision, citations, source hierarchy, evidence mapping, methodology, timestamps, entity precision, internal links, HTML semantics, consistency
- **E — Exclusivity** (E01–E10): Original data, novel framework, primary research, contrarian view, visuals, gap filling, tools, depth, synthesis, forward insights

#### EEAT Audit (40 Items)
- **Exp — Experience** (Exp01–Exp10): First-person narrative, sensory details, process docs, tangible proof, usage duration, problems, before/after, metrics, repeated testing, limitations
- **Ept — Expertise** (Ept01–Ept10): Author identity, credentials, vocabulary, technical depth, methodology rigor, edge cases, historical context, reasoning, cross-domain, editorial process
- **A — Authority** (A01–A10): Backlinks, media mentions, awards, publishing record, brand recognition, social proof, knowledge graph, entity consistency, partnerships, community
- **T — Trust** (T01–T10): Legal compliance, contact transparency, HTTPS, disclosure, editorial policy, corrections, ads, disclaimers, review authenticity, customer support

**Note**: Some EEAT items (A01, A05, A07, etc.) require site-level data. Mark as "N/A" if not observable from content alone.

#### Calculate CORE-EEAT Scores

```
GEO Score = (C + O + R + E) / 4
SEO Score = (Exp + Ept + A + T) / 4
Weighted Score = Σ (dimension_score × content_type_weight)
```

Rating: 90-100 Excellent | 75-89 Good | 60-74 Medium | 40-59 Low | 0-39 Poor

### 5. Calculate Overall Score

Compute weighted average for on-page SEO:
- Title Tag: 15%
- Meta Description: 10%
- Headers: 12%
- Content Quality: 22%
- Keyword Optimization: 15%
- Links: 10%
- Images: 8%
- Page-Level Technical: 8%

**Overall Score: XX/100**

### 6. Generate Priority-Ranked Action List

Categorize issues by severity and impact:

**CRITICAL (Fix Immediately):**
- Missing or duplicate H1
- Title tag too short/long or missing keyword
- Page not mobile-friendly
- Broken canonical tags
- No SSL/HTTPS
- Content <300 words

**IMPORTANT (Fix This Week):**
- Meta description issues
- Poor header hierarchy
- Low keyword density or stuffing
- Missing alt text on images
- Slow page load (>3s)
- Thin content compared to competitors

**MINOR (Optimize When Possible):**
- Missing LSI keywords
- Internal linking opportunities
- Image format optimization
- Schema markup opportunities
- URL structure improvements

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ON-PAGE SEO AUDIT: [Page Title or URL]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

OVERALL SCORE: 72/100

[████████████████████░░░░░░░░░░░░░░░░░░░░] 72%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SECTION SCORES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Title Tag          [████████░░] 8/10
Meta Description   [██████░░░░] 6/10
Header Structure   [██████████] 10/10
Content Quality    [██████░░░░] 6/10
Keyword Optimization [███████░░░] 7/10
Links              [█████░░░░░] 5/10
Images             [████░░░░░░] 4/10
Technical SEO      [█████████░] 9/10

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRIORITY ACTION LIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔴 CRITICAL (Fix Immediately)

1. Add alt text to 8 images currently missing it
2. Expand content from 450 to 1200+ words (top 10 avg: 1850 words)

🟡 IMPORTANT (Fix This Week)

3. Rewrite meta description to include target keyword "best running shoes"
4. Add 3-5 internal links to related product pages
5. Optimize images: compress 4 files >500KB

🟢 MINOR (Optimize When Possible)

6. Add FAQ schema markup for bottom section
7. Include LSI keywords: "athletic footwear", "marathon training", "cushioned running shoes"
8. Improve URL from /product-page-123 to /best-running-shoes-2026

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CONCRETE ACTION CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[ ] Update title tag: "Best Running Shoes 2026: Top 10 Picks for Marathon Training | BrandName"
[ ] Rewrite meta description: "Discover the best running shoes for 2026. Expert-tested reviews of 10 top marathon training shoes with buyer's guide. Free shipping."
[ ] Add alt text to all 8 images (see detailed list below)
[ ] Expand content sections: add comparison table, sizing guide, care tips
[ ] Insert internal links to: /marathon-training-guide, /running-shoe-reviews, /athletic-gear
[ ] Compress images using TinyPNG or WebP conversion
[ ] Add FAQ schema for "How to choose running shoes" section
[ ] Request URL change from dev team

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CORE-EEAT CONTENT QUALITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Content Type: [type]
Veto Status: ✅ No triggers / ⚠️ [item] triggered
Weighted Score: XX/100 ([rating])

GEO Score (CORE): XX/100    SEO Score (EEAT): XX/100

Dimension Scores:
C — Contextual Clarity  [████████░░] 80/100
O — Organization        [██████░░░░] 60/100
R — Referenceability    [███████░░░] 70/100
E — Exclusivity         [█████░░░░░] 50/100
Exp — Experience        [██████░░░░] 60/100
Ept — Expertise         [███████░░░] 70/100
A — Authority           [████░░░░░░] 40/100
T — Trust               [████████░░] 80/100

Top 5 Content Quality Improvements:
1. [ID] [Item] — [specific action]
2. [ID] [Item] — [specific action]
3. [ID] [Item] — [specific action]
4. [ID] [Item] — [specific action]
5. [ID] [Item] — [specific action]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DETAILED FINDINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Full section-by-section breakdown with specific examples and recommendations]
[Full 80-item per-item score table]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTE: This audit covers content quality + on-page SEO.
For technical SEO (speed, crawl, HTTPS), run: /seo:check-technical
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Tips

**For Best Results:**
- Provide target keyword for accurate relevance scoring
- Run audits regularly (monthly for key pages)
- Compare scores over time to track improvement
- Prioritize critical issues before minor optimizations
- Use audit alongside `/seo:report` for comprehensive analysis

**Interpreting Scores:**
- 90-100: Excellent, maintain and monitor
- 70-89: Good, focus on important items
- 50-69: Needs work, address critical issues first
- <50: Poor, requires immediate overhaul

**Common Quick Wins:**
1. Add missing alt text (5 minutes per image)
2. Optimize title tag length (10 minutes)
3. Add internal links (15 minutes)
4. Compress oversized images (5 minutes via tool)

**Without Integrations:**
- Manually check competitor content length via Google search
- Use browser DevTools for mobile responsiveness test
- Run PageSpeed Insights separately for Core Web Vitals
- Use Schema.org validator for markup validation
