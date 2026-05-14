---
name: discover
description: "Find keyword demand, SERP intent, market demand, and topic clusters. Not sure? Use /aaron:auto."
argument-hint: "<topic-or-market>"
parameters:
  - name: topic
    type: string
    required: true
    description: "Seed topic, product, market, or niche"
  - name: market
    type: string
    required: false
    description: "Country, language, city, or segment"
---

# Discover Command

Find keyword demand, SERP intent, market demand, and topic clusters.

## Route

- keyword-research
- serp-analysis
- content-gap-analysis

## Rules

- Discover search demand, SERP intent, topic clusters, and content opportunities.
- Keep AI answer inclusion diagnosis in `/aaron:visibility`; use this command for demand and SERP/topic opportunity.

## Output

Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
