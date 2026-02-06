---
description: Generate Schema.org JSON-LD structured data markup for a page
argument-hint: "<schema type> for <content description>"
---

# Generate Schema Command

> If you see unfamiliar ~~placeholders in this document, see [CONNECTORS.md](../CONNECTORS.md) for the tool category mapping.

A schema generation command that creates valid Schema.org JSON-LD structured data markup to enhance search visibility and enable rich results.

## Usage

```
/seo:generate-schema FAQ for our pricing page Q&As
/seo:generate-schema Product for [product details]
/seo:generate-schema Article for https://example.com/blog-post
/seo:generate-schema LocalBusiness for our main location page
/seo:generate-schema HowTo for installation guide
```

**Arguments:**
- Schema type (required): FAQ, HowTo, Article, Product, LocalBusiness, Organization, Breadcrumb, Review, Event, Video
- Content source: URL, pasted content, or description

## Workflow

### 1. Identify Content Type and Eligible Schemas

Analyze the content to determine:
- Primary schema type (based on user input or content analysis)
- Secondary schema opportunities (e.g., Article + FAQ, Product + Review)
- Schema combinations that maximize rich result eligibility

**If URL provided:**
- Fetch content via `~~web crawler`
- Extract relevant data automatically
- Suggest most appropriate schema types

**If content description provided:**
- Infer schema type from context
- Request necessary details interactively

### 2. Present Schema Options and Requirements

Show user a quick reference of what's needed:

| Schema Type | Use Case | Required Properties | Rich Result Eligible |
|------------|----------|---------------------|---------------------|
| **FAQ** | Question/answer content | questions (>=2), answers | Yes - FAQ rich snippets |
| **HowTo** | Step-by-step guides | name, steps (>=2), tools/supplies | Yes - HowTo rich snippets |
| **Article** | Blog posts, news | headline, author, datePublished, image | Yes - Article cards |
| **Product** | Product pages | name, image, description, offers | Yes - Product rich results |
| **LocalBusiness** | Physical locations | name, address, telephone, openingHours | Yes - Local business panel |
| **Organization** | Company info | name, logo, url, contactPoint | No - Knowledge graph |
| **Breadcrumb** | Navigation paths | itemListElement (>=2 items) | Yes - Breadcrumb trail |
| **Review** | Product/service reviews | itemReviewed, author, reviewRating | Yes - Review stars |
| **Event** | Events, webinars | name, startDate, location | Yes - Event listings |
| **Video** | Video content | name, description, thumbnailUrl, uploadDate | Yes - Video carousel |

**Prompt for missing required fields:**
- If critical data is missing, ask user to provide it
- Offer sensible defaults where appropriate
- Explain why each field matters for SEO

### 3. Gather Required Properties from User

For each schema type, collect mandatory and recommended fields:

#### FAQ Schema
**Required:**
- Minimum 2 questions and answers
- Each question text
- Each answer text (can be HTML)

**Recommended:**
- Related article/page context
- Author information

#### HowTo Schema
**Required:**
- Name/title of the how-to
- Minimum 2 steps with text
- Each step name and description

**Recommended:**
- Total time (ISO 8601 duration)
- Tools and supplies needed
- Images for each step
- Cost estimates

#### Article Schema
**Required:**
- Headline
- Author name
- Date published (ISO 8601)
- Featured image (1200x675px minimum)

**Recommended:**
- Date modified
- Publisher organization
- Article section/category
- Word count

#### Product Schema
**Required:**
- Product name
- Image (high resolution)
- Description
- Brand
- Offers (price, currency, availability)

**Recommended:**
- SKU/GTIN/MPN
- Aggregate rating (if reviews exist)
- Reviews
- Color, size, material variations

#### LocalBusiness Schema
**Required:**
- Business name
- Full address (streetAddress, addressLocality, postalCode, addressCountry)
- Telephone number
- URL

**Recommended:**
- Opening hours (structured format)
- Geo coordinates (latitude, longitude)
- Price range (e.g., "$$")
- Business type (Restaurant, Store, etc.)
- Images

#### Organization Schema
**Required:**
- Organization name
- Logo URL
- Website URL

**Recommended:**
- Social media profiles (sameAs array)
- Contact point
- Founder
- Founding date

#### Breadcrumb Schema
**Required:**
- Minimum 2 breadcrumb items
- Each item: name, URL, position

**Recommended:**
- Full navigation path from home to current page

#### Review Schema
**Required:**
- Item being reviewed (Product, Organization, etc.)
- Author name
- Review body
- Rating value (1-5 scale)

**Recommended:**
- Date published
- Publisher

#### Event Schema
**Required:**
- Event name
- Start date and time (ISO 8601)
- Location (Place or VirtualLocation)

**Recommended:**
- End date and time
- Description
- Image
- Organizer
- Offers (ticket pricing)

#### Video Schema
**Required:**
- Name/title
- Description
- Thumbnail URL (minimum 160x90px)
- Upload date (ISO 8601)

**Recommended:**
- Content URL
- Duration (ISO 8601)
- Embed URL
- Interaction statistics (views)

### 4. Generate Valid JSON-LD Markup

Create structured data following Schema.org specifications:

**Standard template structure:**
```json
{
  "@context": "https://schema.org",
  "@type": "SchemaType",
  "property": "value"
}
```

**Apply best practices:**
- Use specific types over generic ones (e.g., BlogPosting over Article)
- Include all recommended properties when data is available
- Nest related schemas (e.g., Organization within Article publisher)
- Use proper data types (ISO 8601 for dates, numeric for ratings)
- Escape special characters in JSON strings
- Format prices with decimal precision

**Example FAQ Schema:**
```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is your return policy?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "We offer a 30-day money-back guarantee on all products. Items must be in original condition with tags attached."
      }
    },
    {
      "@type": "Question",
      "name": "Do you offer international shipping?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, we ship to over 50 countries worldwide. Shipping costs and delivery times vary by destination."
      }
    }
  ]
}
```

### 5. Validate Against Schema.org Requirements

**Automated validation:**
- Use `~~schema validator` to check JSON-LD syntax
- Verify all required properties are present
- Check data type correctness (strings, numbers, dates, URLs)
- Ensure proper nesting and relationships

**Manual validation checklist:**
- JSON syntax is valid (no trailing commas, proper quotes)
- URLs are absolute, not relative
- Dates follow ISO 8601 format (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS)
- Images meet minimum size requirements
- Enum values match Schema.org vocabulary (e.g., ItemAvailability)

**Google-specific validation:**
- Test in Google Rich Results Test tool
- Check against Google's specific requirements for rich results
- Ensure compliance with quality guidelines (no hidden content, accurate data)

**Without Integrations:**
- Manually validate JSON at jsonlint.com
- Test in Google Rich Results Test: https://search.google.com/test/rich-results
- Verify against Schema.org documentation

### 6. Provide Implementation Instructions

**Where to place the markup:**
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Your Article Title"
}
</script>
```

**Placement guidelines:**
- Add to `<head>` section for best practice
- Can also place in `<body>` if needed
- One script block per schema object, or combine in array
- Place above closing `</head>` tag

**Multiple schemas on one page:**
```json
[
  {
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": "Article Title"
  },
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    "mainEntity": [...]
  }
]
```

**Testing after implementation:**
1. Deploy markup to live page
2. Test in Google Rich Results Test
3. Submit URL to Google Search Console for re-crawling
4. Monitor Search Console for schema-related errors
5. Wait 2-4 weeks for potential rich results to appear

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SCHEMA.ORG MARKUP GENERATOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SCHEMA TYPE: [SchemaType]
RICH RESULT ELIGIBLE: [Yes/No]
ESTIMATED SETUP TIME: [X minutes]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GENERATED MARKUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```json
[Complete JSON-LD markup here]
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VALIDATION RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ JSON syntax valid
✓ All required properties present
✓ Data types correct
✓ Google requirements met
✓ No errors in Schema.org validator

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IMPLEMENTATION INSTRUCTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Copy the JSON-LD markup above
2. Add to your page's <head> section:

<script type="application/ld+json">
[Paste markup here]
</script>

3. Test implementation:
   - Google Rich Results Test: https://search.google.com/test/rich-results
   - Schema Markup Validator: https://validator.schema.org/

4. Deploy and monitor:
   - Submit URL to Google Search Console
   - Monitor for schema errors in Search Console
   - Allow 2-4 weeks for rich results to potentially appear

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPTIMIZATION TIPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Schema-specific tips and best practices]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Tips

**Schema Selection Strategy:**
- Use the most specific schema type that matches your content
- Combine multiple schemas when appropriate (Article + FAQ, Product + Review)
- Prioritize schemas that enable rich results for your industry
- LocalBusiness is critical for multi-location businesses

**Common Pitfalls to Avoid:**
- Don't mark up content not visible on the page (violates Google guidelines)
- Don't use schema to mislead (fake reviews, inflated ratings)
- Don't duplicate content between schema and page
- Don't use overly generic types (Thing, CreativeWork) when specific types exist

**Rich Result Priorities by Content Type:**
- **E-commerce:** Product schema (enables price, availability, reviews)
- **Local business:** LocalBusiness + Review (enables map pack, business panel)
- **Content sites:** Article + FAQ (enables article cards, FAQ dropdowns)
- **Services:** Service + AggregateRating (enables service listings with ratings)
- **Events:** Event schema (enables event carousels, calendar integration)

**Maintenance:**
- Update schema when content changes (prices, dates, addresses)
- Monitor Search Console for schema errors weekly
- Re-validate after site migrations or template changes
- Review Google's schema guidelines quarterly for updates

**Without Integrations:**
- Manually test at https://search.google.com/test/rich-results
- Use https://validator.schema.org/ for Schema.org compliance
- Check Google Search Central documentation for latest requirements
- Join Google Search Central community for schema troubleshooting
