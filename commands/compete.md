---
name: compete
description: "Analyze competitor SEO/GEO gaps, content, backlinks, and share-of-voice opportunities. Not sure? Use /aaron:auto."
argument-hint: "<domain> --competitors <domains>"
parameters:
  - name: domain
    type: string
    required: true
    description: "Your domain or brand"
  - name: competitors
    type: string
    required: true
    description: "Competitor domains or brands"
---

# Compete Command

Analyze competitor SEO/GEO gaps, content, backlinks, and share-of-voice opportunities.

## Route

- competitor-analysis
- backlink-analyzer
- content-gap-analysis

## Rules

- Compare competitors across rankings, content coverage, backlinks, authority, and AI citation visibility.
- Return battlecard, gaps, priority opportunities, evidence mode, and next command.

## Output

Return inline artifacts by default. Files may be written only when the user explicitly asks and the runtime can write.
