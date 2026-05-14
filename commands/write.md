---
name: write
description: "Write one SEO/GEO article, landing page, guide, comparison, FAQ, or product copy asset. Not sure? Use /aaron:auto."
argument-hint: "<brief-or-topic> [--type article|landing|faq|comparison]"
parameters:
  - name: input
    type: string
    required: true
    description: "Brief, keyword, topic, outline, or content request"
  - name: type
    type: string
    required: false
    description: "Content type when known"
---

# Write Command

Write one SEO/GEO article, landing page, guide, comparison, FAQ, or product copy asset.

## Route

- seo-content-writer
- geo-content-optimizer
- meta-tags-optimizer

## Rules

- Produce one asset by default; use `/aaron:series` for batches.
- Use provided research and brief evidence when available; ask for missing blocking inputs.
- Include SEO structure, GEO answer-ready elements, metadata suggestions, proof requirements, and open quality risks.
- Do not claim publish-ready status without `/aaron:audit` or `/aaron:publish` quality gate evidence.

## Output

Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
