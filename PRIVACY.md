# Privacy Policy

## Overview

The SEO & GEO Skills Library is a collection of markdown-based skill files that run locally within your Claude Code environment. This project does not collect, store, or transmit any user data by itself. When users invoke certain skills, those skills may fetch URLs or call connected MCP servers — the specifics are documented below.

## Data Transmission (accurate as of 2026-04)

### Default behavior
By default, this library:
- **Does NOT** transmit any data to external servers
- **Does NOT** include telemetry or analytics
- **Does NOT** push `memory/` contents to external services by itself; hooks may read selected memory into the active session context

### When data DOES leave your machine (user-initiated)

**1. WebFetch-enabled skills** (`content-quality-auditor`, `on-page-seo-auditor`, `technical-seo-checker`, `schema-markup-generator`, `serp-analysis`):
- These skills fetch URLs you provide
- Your request headers (IP, User-Agent) reach the target server
- Fetched page content re-enters your Claude session as context
- Caveat: fetched content is treated as **untrusted data** (see each skill's Security boundary note), not instructions

**2. Bundled stdlib connectors** (`scripts/connectors/*.py`, run only when a skill or the user invokes them):
- Make outbound HTTP(S) requests to public endpoints — Google Autocomplete (`suggest.py`), PageSpeed Insights (`psi.py`), Wikidata (`kg.py`), the Wayback CDX API (`wayback.py`), Open PageRank (`openpagerank.py`), and any site URL you point `crawl.py`/`onpage.py`/`sitemap.py`/`schema_lint.py` at
- Your IP and a project-identifying User-Agent reach those endpoints; only `http(s)` URLs are ever fetched (scheme-guarded)
- Optional API keys (Open PageRank, PageSpeed) are read from your environment at call time and never stored

**3. MCP connectors** (catalogued in `.mcp.json`, **opt-in — not auto-registered**):
- Installing the plugin does NOT register these; you enable a connector by copying its entry into your own MCP config
- Each enabled connector sends data to its vendor per the vendor's privacy policy
- Connectors: Ahrefs, Semrush, SE Ranking, SISTRIX, SimilarWeb, Cloudflare, Vercel, HubSpot, Amplitude, Notion, Webflow, Sanity, Contentful, Slack (14 total, all HTTPS)
- **No connector is enabled without explicit OAuth / API key setup**

**4. Memory files contain third-party data**:
- `memory/audits/` may contain competitor URLs, target keywords, audit findings
- `memory/entities/` may contain third-party brand/person names
- Session hooks may read `memory/hot-cache.md` into model context; users should be aware when committing repo to public Git, sharing with AI agents, using cloud-hosted model sessions, or syncing across devices
- See [memory-management SKILL.md §GDPR / Privacy Compliance](cross-cutting/memory-management/SKILL.md) for retention + deletion guidance

### In scope for security review
- Memory poisoning across sessions (malicious content written to `memory/` affecting future sessions)
- WebFetch-injected instructions (prompt injection via target page HTML/meta)
- Cross-session trust boundary (memory writes require explicit user request, memory-management invocation, auditor save confirmation, or the documented auditor veto hot-cache exception; command-backed hooks may read capped project records and perform deterministic checks, but Stop only allows completion and never initiates writes)

See [SECURITY.md](SECURITY.md) for responsible disclosure.

## Third-Party Services

This project references but does not bundle or depend on:

- **skills.sh**: Skill distribution platform (its privacy policy applies during installation)
- **GitHub**: Source code hosting (GitHub's privacy policy applies)

## Contact

For privacy-related questions: **hello@zhuhe.io**

## Changes

This privacy policy may be updated as the project evolves. Changes will be documented in commit history.

*Last updated: 2026-06-10*
