---
description: Generate a comprehensive SEO and GEO performance report
argument-hint: "<domain> <time period>"
---

# Report Command

> If you see unfamiliar ~~placeholders in this document, see [CONNECTORS.md](../CONNECTORS.md) for the tool category mapping.

A comprehensive performance report command that aggregates SEO and GEO data across all channels, identifies trends, and delivers actionable recommendations prioritized by impact.

## Usage

```
/seo:report example.com last-month
/seo:report example.com Q4-2024 vs Q3-2024
/seo:report example.com 2024-01-01 to 2024-03-31
/seo:report example.com last-90-days format=executive
/seo:report example.com custom period="Dec 2024"
```

**Arguments:**
- Domain (required)
- Time period (required): `last-month`, `last-quarter`, `Q1-2024`, `YYYY-MM-DD to YYYY-MM-DD`, `last-30-days`, `last-90-days`
- Comparison period (optional): `vs Q3-2024`, `vs last-year`, `vs previous-period`
- `format=executive` (optional): Condensed summary for stakeholders
- `format=detailed` (default): Full report with all sections

## Workflow

### 1. Collect Data Across All Channels

Gather comprehensive metrics from integrated tools:

#### Organic Traffic Data (via `~~analytics`)
- Sessions, users, pageviews
- Bounce rate, time on site, pages per session
- Traffic by landing page
- Traffic by device (desktop, mobile, tablet)
- Traffic by country/region
- New vs returning visitors
- Goal completions and conversions

#### Search Console Data (via `~~search console`)
- Total impressions and clicks
- Average CTR and position
- Top performing queries
- Top performing pages
- Click and impression trends
- Mobile usability issues
- Core Web Vitals status

#### Ranking Data (via `~~SEO tool`)
- Keyword rankings (current positions)
- Ranking changes (gains/losses)
- Visibility score
- SERP feature presence (featured snippets, local pack, etc.)
- Share of voice in target keyword categories
- Competitor ranking comparison

#### Backlink Data (via `~~SEO tool`)
- Total backlinks
- Referring domains (new and lost)
- Domain authority/rating
- Toxic backlink ratio
- Top linking domains
- Anchor text distribution
- Backlink velocity

#### GEO Visibility Data (via `~~AI monitor`)
- AI citation count across platforms (ChatGPT, Perplexity, Claude, Gemini, etc.)
- Citation ranking/position in AI responses
- Sentiment of citations
- Topic/query categories driving citations
- Competitor citation comparison
- Source attribution presence

#### Technical Health Data (via `~~web crawler`)
- Crawl errors and status codes
- Page speed metrics (Core Web Vitals)
- Mobile-friendliness issues
- Structured data errors
- XML sitemap status
- Robots.txt issues
- Duplicate content instances
- Broken internal/external links

**Without Integrations (Progressive Enhancement):**
- Request manual data export from Google Analytics
- Use free Search Console data export
- Accept manual keyword ranking input
- Generate report with available data
- Provide guidance on which metrics to track manually

### 2. Compute Period-over-Period Changes

Calculate change metrics for all KPIs:

**Standard calculations:**
- Absolute change: `Current - Previous`
- Percentage change: `((Current - Previous) / Previous) × 100`
- Trend direction: ↑ (increase), ↓ (decrease), → (stable)

**Statistical significance:**
- Flag changes that meet minimum thresholds (e.g., >10% change)
- Identify anomalies (sudden spikes or drops >50%)
- Note seasonal patterns if historical data available

**Segmentation analysis:**
- Break down changes by traffic source
- Analyze by device type
- Compare by landing page category
- Segment by user type (new vs returning)

**Example calculation:**
```
Organic Sessions:
- Current Period: 15,420
- Previous Period: 12,800
- Change: +2,620 (+20.5%) ↑
- Status: Significant increase
```

### 3. Identify Wins, Concerns, and Opportunities

Categorize findings into actionable insights:

#### WINS (Positive Performance)
**Criteria:**
- Metrics exceeding targets or showing >15% improvement
- New keyword rankings in top 10
- Significant backlink gains from high-authority domains
- Technical issues resolved
- GEO citations from new AI platforms

**Example wins:**
- "Organic traffic increased 32% driven by improved rankings for 'product category' keywords"
- "Earned featured snippet for 'how to [topic]' query (2,400 monthly searches)"
- "Core Web Vitals scores improved from 'Needs Improvement' to 'Good' on 85% of pages"
- "ChatGPT now cites our brand in 18% of [industry] queries (up from 3%)"

#### CONCERNS (Negative Trends)
**Criteria:**
- Metrics declining >10% without clear seasonal explanation
- Loss of keyword rankings (especially top 3 positions)
- Increase in technical errors or page speed degradation
- Toxic backlink growth
- Decrease in GEO visibility

**Example concerns:**
- "Homepage traffic declined 22% due to ranking drop from position 2 to 7 for primary keyword"
- "Lost 15 high-quality backlinks from industry publications (domain rating 70+)"
- "Mobile page speed regressed to 'Poor' status affecting 40% of traffic"
- "Zero AI citations in Perplexity despite being mentioned previously"

#### OPPORTUNITIES (Untapped Potential)
**Criteria:**
- High-impression, low-CTR keywords (opportunity to optimize meta)
- Keywords ranking 11-20 (one push away from page 1)
- Content gaps vs competitors
- Unoptimized high-traffic pages
- Emerging AI platforms with zero presence

**Example opportunities:**
- "12 keywords ranking positions 11-15 with combined 8,500 monthly searches"
- "Product pages have 45% lower CTR than category average despite high impressions"
- "Competitors ranking for 87 keywords we don't target (qualified traffic opportunity)"
- "Google Discover potential: 3 articles match typical Discover content patterns"

### 4. Generate Executive Summary

Create a concise overview for stakeholders:

**Structure:**
1. **Performance Snapshot** (3-5 key metrics with % change)
2. **Key Wins** (top 3 achievements)
3. **Critical Concerns** (top 3 issues requiring action)
4. **Strategic Recommendations** (3-5 high-impact actions)

**Executive summary guidelines:**
- Use non-technical language
- Focus on business impact (traffic, conversions, revenue)
- Include visual performance indicators (↑ ↓ →)
- Keep to 1 page maximum
- Link metrics to business outcomes

**Example:**
```
EXECUTIVE SUMMARY - January 2026

Performance: Strong Growth (+28% organic traffic)
✓ Organic traffic reached 24,500 sessions (+28% vs Dec)
✓ Keyword rankings improved with 15 new page-1 positions
✗ Mobile conversion rate declined 12% (site speed issue)

Top Priority: Fix mobile page speed to recover conversion rate
Estimated Impact: +$8,500 monthly revenue if resolved
```

### 5. Generate Detailed Sections

Provide in-depth analysis for each channel:

#### Section 1: Organic Traffic Performance
- Traffic trends (graph/table)
- Top landing pages with change %
- Traffic by source/medium
- Device breakdown
- Geographic distribution
- Goal conversion metrics

#### Section 2: Keyword Rankings & Visibility
- Visibility score trend
- Ranking distribution (top 3, 4-10, 11-20, 21-50, 51+)
- Top ranking gains
- Top ranking losses
- SERP feature wins
- Share of voice vs competitors

#### Section 3: Backlink Profile Health
- Backlink growth trend
- New referring domains
- Lost backlinks (with domain rating)
- Toxic backlink ratio
- Top new backlinks
- Anchor text health check

#### Section 4: Technical SEO Health
- Crawl error summary
- Core Web Vitals status
- Mobile usability issues
- Structured data validation
- Indexability status
- Site speed metrics by page template

#### Section 5: GEO Performance
- Total AI citations by platform
- Citation position/ranking trends
- Citation sentiment analysis
- Query categories driving citations
- Source attribution rate
- Competitor citation comparison

#### Section 6: Content Performance
- Top performing content by traffic
- Content with declining performance
- Content gap analysis
- Engagement metrics (time on page, bounce rate)
- Internal link equity distribution

### 6. Provide Actionable Recommendations Prioritized by Impact

Deliver clear, prioritized action plan:

#### Impact Scoring Framework
Each recommendation scored on:
- **Effort:** Low (1-5 hours), Medium (1-2 days), High (1+ weeks)
- **Impact:** Low (1-5% improvement), Medium (5-15%), High (15%+ improvement)
- **Timeframe:** Quick win (<1 week), Short-term (1-4 weeks), Long-term (1-3 months)

#### Priority Matrix

**P0 - CRITICAL (Do This Week):**
High Impact + Low-to-Medium Effort
- Fix technical errors blocking indexation
- Recover lost rankings for primary keywords
- Resolve Core Web Vitals failures

**P1 - HIGH (Do This Month):**
High Impact + High Effort OR Medium Impact + Low Effort
- Optimize high-impression, low-CTR pages
- Target keywords ranking positions 11-20
- Create content for high-volume gaps

**P2 - MEDIUM (Do This Quarter):**
Medium Impact + Medium Effort
- Refresh underperforming existing content
- Build backlinks to strategic pages
- Improve internal linking architecture

**P3 - LOW (Backlog):**
Low Impact OR Very High Effort
- Minor technical optimizations
- Long-tail keyword expansion
- Experimental content formats

#### Recommendation Format

For each recommendation:
```
[P0] Fix Mobile Page Speed on Product Pages

Problem: 40% of traffic lands on mobile product pages with "Poor" Core Web Vitals
Impact: Estimated +12% conversion rate improvement = +$8,500/month revenue
Effort: Medium (2-3 days developer time)
Timeframe: Complete by end of week

Action Steps:
1. Compress hero images (currently 2.5MB avg, target <200KB)
2. Implement lazy loading for below-fold content
3. Defer non-critical JavaScript
4. Enable server-side caching

Success Metrics:
- LCP < 2.5s on all product pages
- Mobile conversion rate increases to 3.2% (from current 2.8%)
- Track via PageSpeed Insights + Google Analytics
```

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SEO & GEO PERFORMANCE REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DOMAIN: example.com
PERIOD: January 1-31, 2026
COMPARISON: vs December 2024

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EXECUTIVE SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PERFORMANCE SNAPSHOT

Organic Traffic:      24,542 sessions    +28.4% ↑
Keyword Rankings:     Top 10: 127        +15 ↑
Backlink Profile:     2,847 domains      +142 ↑
AI Citations (GEO):   384 mentions       +67% ↑
Avg. Position:        8.2                -1.3 ↑ (improved)
Conversion Rate:      2.8%               -12.5% ↓

OVERALL HEALTH: GOOD with 1 Critical Issue

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

KEY WINS

✓ Organic traffic grew 28% driven by 15 new page-1 keyword rankings
✓ ChatGPT citations increased 89% (now cited in 18% of industry queries)
✓ Earned featured snippet for "how to [topic]" (2,400 monthly searches)

CRITICAL CONCERNS

✗ Mobile conversion rate dropped 12.5% due to Core Web Vitals degradation
✗ Lost 3 high-authority backlinks from Forbes, TechCrunch (DR 90+)
✗ Homepage ranking declined from position 2 to 7 for primary keyword

STRATEGIC RECOMMENDATIONS

Priority 1: Fix mobile page speed on product pages (Est. impact: +$8.5K/month)
Priority 2: Recover homepage ranking through content refresh + backlinks
Priority 3: Optimize 12 high-impression pages with low CTR (Est. impact: +15% clicks)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DETAILED FINDINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Full section-by-section breakdown with tables, trends, and analysis]

1. ORGANIC TRAFFIC PERFORMANCE
2. KEYWORD RANKINGS & VISIBILITY
3. BACKLINK PROFILE HEALTH
4. TECHNICAL SEO HEALTH
5. GEO PERFORMANCE
6. CONTENT PERFORMANCE

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRIORITIZED ACTION PLAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔴 P0 - CRITICAL (Do This Week)

[Detailed recommendations with problem, impact, effort, steps]

🟡 P1 - HIGH (Do This Month)

[Detailed recommendations]

🟢 P2 - MEDIUM (Do This Quarter)

[Detailed recommendations]

⚪ P3 - LOW (Backlog)

[Brief list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
APPENDIX
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- Data Sources & Methodology
- Metric Definitions
- Historical Trends (if available)
- Competitor Benchmarking

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Tips

**Report Cadence Recommendations:**
- **Monthly reports:** Standard for most businesses
- **Quarterly reports:** Executive stakeholder updates
- **Weekly dashboards:** High-priority campaigns or during site migrations
- **Ad-hoc reports:** After major changes, algorithm updates, or traffic anomalies

**Customization by Audience:**
- **Executives:** Focus on business metrics (revenue, conversions, ROI)
- **Marketing team:** Balance traffic, rankings, and conversion insights
- **Developers:** Emphasize technical SEO, page speed, crawl health
- **Content team:** Highlight content performance, gaps, engagement

**Trend Analysis Tips:**
- Compare to same period last year to account for seasonality
- Flag week-over-week volatility (potential algorithm update impact)
- Normalize data for holidays or known traffic events
- Use moving averages to smooth out daily fluctuations

**Data Quality Checks:**
- Verify Google Analytics tracking is firing correctly
- Cross-reference traffic spikes with known campaigns
- Check for data anomalies (sudden drops = tracking issue?)
- Ensure date ranges match exactly for period comparisons

**Without Integrations:**
- Create manual data collection template (spreadsheet)
- Set calendar reminders for monthly data exports
- Use free tools: Google Search Console, Analytics, PageSpeed Insights
- Focus on trend analysis vs absolute numbers
- Document manual data sources for consistency

**Automation Opportunities:**
- Schedule monthly report generation
- Set up automated email delivery to stakeholders
- Create real-time dashboard for continuous monitoring
- Integrate with project management tools for automatic task creation
