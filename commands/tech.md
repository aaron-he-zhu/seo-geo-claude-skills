---
name: tech
description: "Check crawlability, indexing, Core Web Vitals, robots, sitemap, canonicals, redirects, and migration risk. Not sure? Use /aaron:auto."
argument-hint: "<url-or-domain>"
parameters:
  - name: target
    type: string
    required: true
    description: "URL, domain, crawl summary, or technical issue"
---

# Tech Command

Check crawlability, indexing, Core Web Vitals, robots, sitemap, canonicals, redirects, and migration risk.

## Route

- technical-seo-checker

## Rules

- Run technical SEO triage for crawl, indexation, speed, mobile, security, structured data exposure, robots, sitemap, canonical, redirect, and migration issues.
- Do not guess Core Web Vitals or crawl data; mark missing evidence and next checks.

## Output

Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
