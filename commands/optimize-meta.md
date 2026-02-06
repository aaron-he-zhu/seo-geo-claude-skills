---
description: Optimize title tags, meta descriptions, and Open Graph tags for a page
argument-hint: "<URL or page details>"
---

# Optimize Meta Command

> If you see unfamiliar ~~placeholders in this document, see [CONNECTORS.md](../CONNECTORS.md) for the tool category mapping.

A meta tag optimization command that analyzes and enhances title tags, meta descriptions, and social media tags to maximize click-through rates and search visibility.

## Usage

```
/seo:optimize-meta https://example.com/landing-page
/seo:optimize-meta title="Current Title" keyword="target keyword"
/seo:optimize-meta https://example.com/blog-post target="best practices"
/seo:optimize-meta url="..." mode="a/b-test"
```

**Arguments:**
- URL or page details (required)
- `keyword="target keyword"` (optional but recommended)
- `target="focus topic"` (alternative to keyword)
- `mode="a/b-test"` (generates multiple variants for testing)

## Workflow

### 1. Analyze Current Meta Tags

**With URL provided:**
- Fetch page via `~~web crawler`
- Extract all meta tags (title, description, Open Graph, Twitter Card)
- Retrieve current search console CTR data via `~~search console` (if available)
- Analyze competitor title tags via `~~SEO tool`

**With manual input:**
- Accept current title, description, and target keyword
- Prompt for missing critical elements
- Request page context if needed

**Extract these elements:**
```html
<title>Current Page Title</title>
<meta name="description" content="Current meta description">
<meta property="og:title" content="Open Graph title">
<meta property="og:description" content="OG description">
<meta property="og:image" content="image-url">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Twitter title">
<meta name="twitter:description" content="Twitter description">
```

**Without Integrations:**
- Request user to paste HTML source or manually provide meta tags
- Skip CTR analysis (provide general optimization guidance)

### 2. Evaluate Title Tag

Run comprehensive title tag analysis:

#### Length Check
- **Optimal:** 50-60 characters (displays fully in SERPs)
- **Warning:** 60-70 characters (may truncate on mobile)
- **Critical:** >70 characters (will truncate)
- **Critical:** <30 characters (wasted SERP real estate)

Calculate pixel width (Google uses ~600px limit):
- W, M = ~12px each
- lowercase letters = ~6-8px average
- i, l, t = ~4px
- Spaces = ~3px

#### Keyword Analysis
- **Position:** Keyword in first 50% of title (earlier = higher relevance signal)
- **Exact match:** Target keyword appears verbatim
- **Partial match:** Keyword components present but separated
- **Missing:** Keyword absent (critical issue)

#### Brand Placement
- **Pattern A:** `Primary Keyword - Secondary | Brand` (recommended for most)
- **Pattern B:** `Brand: Primary Keyword` (use for brand-focused queries)
- **Pattern C:** `Primary Keyword (Year) - Brand` (good for recurring topics)

#### CTR Appeal Elements
Check for psychological triggers:
- **Numbers:** "10 Ways", "Save 50%", "2026 Guide"
- **Power words:** Best, Ultimate, Essential, Proven, Free, Easy
- **Emotional triggers:** Transform, Discover, Unlock, Master
- **Brackets/Parentheses:** "[Updated 2026]", "(with Examples)"
- **Questions:** "How to...", "Why...", "What..."
- **Urgency:** Today, Now, Limited, New

#### Uniqueness Verification
- Check for duplicate title tags on site via `~~SEO tool`
- Identify overly similar titles that should be differentiated
- Flag template-based titles that need customization

**Score Title: X/10**

Scoring breakdown:
- Length optimal (50-60 chars): 2 points
- Keyword in first half: 2 points
- Contains power words: 2 points
- Unique on site: 2 points
- Includes brand: 1 point
- Emotionally compelling: 1 point

### 3. Evaluate Meta Description

Run comprehensive meta description analysis:

#### Length Check
- **Optimal:** 150-160 characters (displays fully on desktop)
- **Mobile optimal:** 120-130 characters (mobile truncates earlier)
- **Warning:** 160-175 characters (may truncate)
- **Critical:** >175 characters (will truncate)
- **Critical:** <120 characters (wasted opportunity)

#### Keyword Presence
- Primary keyword present: Yes/No
- Keyword position (earlier = better)
- Related keywords included
- Natural language (not stuffed)

#### Call-to-Action (CTA) Clarity
Strong CTAs that drive clicks:
- **Action verbs:** Learn, Discover, Get, Start, Download, Try, Shop, Compare
- **Benefit-focused:** "Save time", "Increase revenue", "Reduce costs"
- **Urgency:** "Get started today", "Limited offer"
- **Value proposition:** "Free shipping", "30-day trial", "Expert guide"

#### Unique Value Proposition
What differentiates this page from competitors?
- Specific benefits mentioned
- Unique features highlighted
- Social proof implied (e.g., "trusted by 10,000+")
- Competitive advantages stated

#### Duplication Check
- Verify uniqueness across site via `~~SEO tool`
- Flag auto-generated descriptions that need rewriting
- Identify pages sharing identical descriptions

**Score Meta Description: X/10**

Scoring breakdown:
- Length optimal (150-160 chars): 2 points
- Contains target keyword: 2 points
- Clear CTA present: 2 points
- Unique value proposition: 2 points
- Unique on site: 1 point
- Emotionally compelling: 1 point

### 4. Evaluate Open Graph and Twitter Card Tags

Social media optimization analysis:

#### Open Graph Tags (Facebook, LinkedIn, etc.)
**Required tags:**
```html
<meta property="og:title" content="...">
<meta property="og:description" content="...">
<meta property="og:image" content="...">
<meta property="og:url" content="...">
```

**Image requirements:**
- Minimum size: 1200x630px (recommended)
- Aspect ratio: 1.91:1 (ideal for Facebook)
- Format: JPG or PNG (WebP not universally supported)
- File size: <8MB
- Include text overlay carefully (avoid <20% text coverage)

**Best practices:**
- og:title can differ from page title (optimize for social context)
- og:description can be more casual/engaging than meta description
- Always use absolute URLs for images

#### Twitter Card Tags
**Required tags:**
```html
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="...">
<meta name="twitter:description" content="...">
<meta name="twitter:image" content="...">
```

**Card types:**
- `summary_large_image`: Most common, prominent image
- `summary`: Smaller square image
- `player`: For video/audio content
- `app`: For mobile app promotion

**Image requirements:**
- summary_large_image: 1200x628px minimum (2:1 ratio)
- summary: 120x120px minimum (1:1 ratio)

**Validation:**
- Test with Twitter Card Validator (if available)
- Ensure fallback to og: tags when twitter: tags absent

**Score Social Tags: X/10**

Scoring breakdown:
- All required OG tags present: 3 points
- OG image meets size requirements: 2 points
- Twitter Card tags present: 2 points
- Social-optimized copy (differs from page meta): 2 points
- Tested in validators: 1 point

### 5. Generate Optimized Alternatives

Create multiple optimized variants:

#### Title Tag Variants (3-5 options)
**Variant A (Power Word Focus):**
- Optimized for CTR with emotional triggers
- Example: "The Ultimate Guide to SEO in 2026 [Expert Tips]"

**Variant B (Keyword Focus):**
- Optimized for relevance and ranking
- Example: "SEO Guide 2026: Proven Strategies to Rank Higher"

**Variant C (Brand Focus):**
- Optimized for brand recognition
- Example: "BrandName SEO Guide: Master Search Rankings in 2026"

**Variant D (Question Format):**
- Optimized for featured snippet and voice search
- Example: "How to Master SEO in 2026? Complete Guide | BrandName"

**Variant E (Numeric Focus):**
- Optimized for list-based queries
- Example: "21 SEO Strategies That Actually Work in 2026 | BrandName"

#### Meta Description Variants (3-5 options)
Follow same variant strategy as titles, tailored to description format.

#### A/B Test Recommendations
When mode="a/b-test":
- Suggest which variants to test against each other
- Define success metrics (CTR improvement)
- Recommend test duration (minimum 2-4 weeks for statistical significance)
- Provide implementation guidance via `~~analytics` tag manager

**Without Integrations:**
- Generate variants based on best practices alone
- Provide manual A/B test setup instructions
- Suggest third-party tools for testing (Google Optimize alternatives)

### 6. Provide Competitor Context

Compare against top-ranking competitors:

**Via `~~SEO tool`:**
- Extract title tags from top 10 results for target keyword
- Identify common patterns (length, structure, word choice)
- Highlight unique approaches that stand out
- Analyze average CTR by position

**Show comparative analysis:**
```
Top 10 Title Tag Analysis for "target keyword":

Average length: 58 characters
Common patterns:
- 7/10 include year (2026)
- 6/10 use brackets or parentheses
- 5/10 include "guide" or "tips"
- 4/10 lead with numbers

Top performer (Position 2, Est. CTR 12.4%):
"10 SEO Tips That Actually Work in 2026 [Tested]"
Why it works: Number, power word, year, social proof, optimal length
```

**Recommendation:**
Based on competitor analysis, suggest which variant aligns with winning patterns while maintaining uniqueness.

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
META TAG OPTIMIZATION REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PAGE: [URL or Title]
TARGET KEYWORD: [keyword]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CURRENT META TAGS ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TITLE TAG: 6/10
Current: "Old Title That Could Be Better"
Length: 35 chars (too short, wasting SERP space)
Issues:
  ✗ Missing target keyword in first half
  ✗ No power words or emotional triggers
  ✗ Too short (optimal: 50-60 chars)
  ✓ Includes brand name
  ✓ Unique on site

META DESCRIPTION: 5/10
Current: "A description that exists but isn't optimized well."
Length: 52 chars (too short)
Issues:
  ✗ Too short (optimal: 150-160 chars)
  ✗ No clear call-to-action
  ✗ Missing unique value proposition
  ✓ Contains target keyword
  ✗ Not compelling

SOCIAL TAGS: 4/10
Issues:
  ✗ Missing Open Graph image
  ✗ Twitter Card tags not present
  ✓ Basic OG tags present

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPTIMIZED TITLE TAG VARIANTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ RECOMMENDED (Best Balance):
"Complete SEO Guide 2026: Proven Strategies to Rank #1 | BrandName"
Length: 62 chars | Score: 9/10
Why: Keyword-rich, includes year, power word "proven", clear benefit

VARIANT A (CTR Focus):
"The Ultimate SEO Guide: Transform Your Rankings in 2026"
Length: 56 chars | Score: 8/10
Why: Emotional trigger "transform", power word "ultimate"

VARIANT B (Keyword Focus):
"SEO Guide 2026: Complete Strategies for Higher Rankings"
Length: 56 chars | Score: 8/10
Why: Keyword-first, clear topic, benefit-focused

VARIANT C (Question Format):
"How to Master SEO in 2026? Complete Guide + Expert Tips"
Length: 56 chars | Score: 8/10
Why: Question format good for voice search, includes "expert"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPTIMIZED META DESCRIPTION VARIANTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ RECOMMENDED:
"Master SEO in 2026 with our comprehensive guide. Learn proven strategies, avoid common mistakes, and rank higher in Google. Includes step-by-step checklist. Start today!"
Length: 158 chars | Score: 9/10

VARIANT A (Benefit Focus):
"Boost your search rankings with our 2026 SEO guide. Get expert strategies, actionable tips, and real examples. Free downloadable checklist included. Learn more!"
Length: 159 chars | Score: 9/10

VARIANT B (Social Proof):
"Join 50,000+ marketers using our SEO guide to rank higher. Updated for 2026 with latest Google algorithms. Proven strategies that work. Get started free today!"
Length: 160 chars | Score: 9/10

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPETITOR ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Top 10 Title Patterns for "seo guide":
- Average length: 58 chars
- 8/10 include year (2026)
- 6/10 use "guide" terminology
- 5/10 include numbers or lists

Best Performer (Position 3):
"SEO Guide 2026: 15 Strategies to Rank Higher [Updated]"
Estimated CTR: 11.2% | Length: 55 chars

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IMPLEMENTATION CODE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```html
<!-- Primary Meta Tags -->
<title>Complete SEO Guide 2026: Proven Strategies to Rank #1 | BrandName</title>
<meta name="description" content="Master SEO in 2026 with our comprehensive guide. Learn proven strategies, avoid common mistakes, and rank higher in Google. Includes step-by-step checklist. Start today!">

<!-- Open Graph / Facebook -->
<meta property="og:type" content="article">
<meta property="og:url" content="https://example.com/seo-guide">
<meta property="og:title" content="The Complete SEO Guide for 2026: Rank Higher in Google">
<meta property="og:description" content="Master SEO with our expert guide. Get proven strategies, avoid mistakes, and boost your rankings. Free checklist included!">
<meta property="og:image" content="https://example.com/images/seo-guide-2026-og.jpg">

<!-- Twitter -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:url" content="https://example.com/seo-guide">
<meta name="twitter:title" content="The Complete SEO Guide for 2026: Rank Higher in Google">
<meta name="twitter:description" content="Master SEO with our expert guide. Get proven strategies, avoid mistakes, and boost your rankings. Free checklist included!">
<meta name="twitter:image" content="https://example.com/images/seo-guide-2026-twitter.jpg">
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
A/B TEST RECOMMENDATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Test Setup:
- Duration: 4 weeks minimum
- Success metric: >5% CTR improvement
- Statistical significance: 95% confidence

Test 1: Power Word Impact
- Control: "Complete SEO Guide 2026: Proven Strategies to Rank #1"
- Variant: "The Ultimate SEO Guide: Transform Your Rankings in 2026"
- Hypothesis: "Ultimate" + "Transform" increases CTR by 8-12%

Test 2: Question Format
- Control: "Complete SEO Guide 2026: Proven Strategies to Rank #1"
- Variant: "How to Master SEO in 2026? Complete Guide + Expert Tips"
- Hypothesis: Question format increases CTR for informational queries

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Tips

**Title Tag Best Practices:**
- Front-load primary keyword (first 50% of title)
- Use modifiers: Best, Guide, 2026, Tips, Examples, Free
- Include numbers when relevant (list posts, statistics)
- Keep brand at the end unless brand-focused query
- Test brackets/parentheses for added emphasis

**Meta Description Best Practices:**
- Write for humans first, search engines second
- Use active voice and direct address ("you", "your")
- Include one clear call-to-action
- Mention specific benefits or features
- Add urgency when appropriate ("today", "now", "limited")

**Common Mistakes to Avoid:**
- Keyword stuffing (looks spammy, reduces CTR)
- Duplicate meta tags across multiple pages
- Generic descriptions like "Welcome to our website"
- Missing brand name (unless intentionally testing)
- Overly promotional language (may reduce trust)

**Quick Wins:**
1. Add year to title tags for recurring topics (+3-8% CTR)
2. Include numbers in titles for list content (+6-12% CTR)
3. Add brackets with value prop "[Free Template]" (+4-9% CTR)
4. Rewrite vague CTAs to specific actions (+5-10% CTR)

**Without Integrations:**
- Use Google search to manually review competitor titles
- Check your site's meta tags with browser "View Source"
- Test title length with SERP preview tools (free online)
- Monitor organic CTR in Google Search Console (free)
