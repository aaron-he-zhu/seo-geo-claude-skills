---
description: Run a quick technical SEO health check for a given URL or domain
argument-hint: "<URL or domain>"
---

# Check Technical Command

> If you see unfamiliar ~~placeholders in this document, see [CONNECTORS.md](../CONNECTORS.md) for the tool category mapping.

A focused technical SEO check that analyzes site infrastructure, performance, and crawlability. Complements `/seo:audit-page` which covers content quality + on-page SEO.

**Scope**: Technical health only (server, speed, crawlability, security). Does NOT cover content quality or on-page SEO — use `/seo:audit-page` for that.

## Usage

```
/seo:check-technical https://example.com
/seo:check-technical https://example.com/specific-page
/seo:check-technical example.com
```

**Arguments:**
- URL or domain (required)

## Workflow

### 1. Gather Input

**With URL:**
- Fetch page via `~~web crawler`
- Run speed test via `~~page speed tool`
- Check robots.txt and sitemap

**Without Integrations:**
- Request user to share PageSpeed Insights results
- Manual checks via browser DevTools

### 2. Run Technical Checks

Analyze 6 core areas:

#### A. Crawlability & Indexing
- robots.txt present and valid
- XML sitemap exists and is linked
- Meta robots directives (index/noindex)
- Canonical tag correctness
- Crawl budget efficiency (orphan pages, redirect chains)
- **Score: X/10**

#### B. HTTPS & Security
- Site-wide HTTPS enforcement
- No mixed content warnings
- Valid SSL certificate (not expired)
- HTTP→HTTPS redirect in place
- HSTS headers present
- **Score: X/10**

#### C. Page Speed & Core Web Vitals
- Largest Contentful Paint (LCP): target <2.5s
- First Input Delay (FID) / Interaction to Next Paint (INP): target <200ms
- Cumulative Layout Shift (CLS): target <0.1
- Time to First Byte (TTFB): target <800ms
- Total page size and request count
- **Score: X/10**

#### D. Mobile Responsiveness
- Viewport meta tag present
- Touch-friendly tap targets (≥48px)
- No horizontal scrolling
- Font sizes readable without zoom
- Mobile-specific usability issues
- **Score: X/10**

#### E. URL & Redirect Health
- Clean URL structure (descriptive, lowercase, hyphens)
- No redirect chains (max 1 redirect)
- No 404 errors on internal links
- Proper 301 redirects for moved content
- URL parameters handled correctly
- **Score: X/10**

#### F. Infrastructure
- Server response codes (200, 301, 404, 500)
- CDN usage via `~~CDN`
- Compression enabled (gzip/brotli)
- Browser caching headers
- Lazy loading for images/videos
- **Score: X/10**

### 3. Calculate Overall Technical Score

Compute weighted average:
- Crawlability & Indexing: 25%
- HTTPS & Security: 20%
- Page Speed & Core Web Vitals: 25%
- Mobile Responsiveness: 15%
- URL & Redirect Health: 10%
- Infrastructure: 5%

**Overall Technical Score: XX/100**

### 4. Generate Priority-Ranked Action List

**CRITICAL (Fix Immediately):**
- No HTTPS or expired SSL
- robots.txt blocking important pages
- Core Web Vitals all failing
- Server errors (5xx)

**IMPORTANT (Fix This Week):**
- Slow page speed (LCP >4s)
- Missing XML sitemap
- Redirect chains (3+ hops)
- Mixed content warnings

**MINOR (Optimize When Possible):**
- Missing HSTS headers
- Uncompressed assets
- Missing lazy loading
- URL cleanup opportunities

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TECHNICAL SEO CHECK: [URL or Domain]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

OVERALL TECHNICAL SCORE: 78/100

[█████████████████████████████░░░░░░░░░░░] 78%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SECTION SCORES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Crawlability & Indexing  [████████░░] 8/10
HTTPS & Security         [██████████] 10/10
Page Speed & CWV         [██████░░░░] 6/10
Mobile Responsiveness    [████████░░] 8/10
URL & Redirect Health    [███████░░░] 7/10
Infrastructure           [████████░░] 8/10

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CORE WEB VITALS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LCP:  2.8s  ⚠️ (target: <2.5s)
INP:  150ms ✅ (target: <200ms)
CLS:  0.05  ✅ (target: <0.1)
TTFB: 650ms ✅ (target: <800ms)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRIORITY ACTION LIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔴 CRITICAL
1. [Critical issue with fix]

🟡 IMPORTANT
2. [Important issue with fix]
3. [Important issue with fix]

🟢 MINOR
4. [Minor issue with fix]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ACTION CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[ ] [Action 1]
[ ] [Action 2]
[ ] [Action 3]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTE: This check covers technical SEO only.
For content quality + on-page SEO, run: /seo:audit-page
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Tips

**For Best Results:**
- Run alongside `/seo:audit-page` for a complete picture
- Prioritize Core Web Vitals — they directly impact rankings
- Check both desktop and mobile performance
- Re-run after infrastructure changes

**Interpreting Scores:**
- 90-100: Excellent technical foundation
- 70-89: Good, address important items
- 50-69: Needs work, critical issues likely present
- <50: Serious technical debt, prioritize fixes

**Without Integrations:**
- Use Google PageSpeed Insights for Core Web Vitals
- Use browser DevTools for mobile testing
- Check robots.txt manually at /robots.txt
- Use Google Search Console for indexing issues
