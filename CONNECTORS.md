# Connectors

> Skills use `~~category` placeholders instead of specific tool names. **Every skill runs at Tier 1 with zero external dependencies** — paste data manually, or pull it yourself from the free/public sources below. MCP servers (further down) are an optional Tier 2/3 convenience, never required.

All endpoints below were verified against primary vendor/source docs (2026-05). If a call 404s, re-check the linked doc — vendors move endpoints.

## Bundled helpers — run the data fetch locally (zero-dependency)

For the bundle-able categories the repo ships small **Python-3-stdlib** helpers under [`scripts/connectors/`](scripts/connectors/README.md) — no `pip`, no key (except where noted). They turn the recipes below into one command, so a skill can pull real data itself instead of asking you to paste it. Run from the repo root:

| Capability | Helper | Needs |
|---|---|---|
| Crawl a site (→ page records) | `crawl.py <url>` | — |
| On-page audit (title/meta/headings/canonical/JSON-LD) | `onpage.py <url>` | — |
| robots.txt eval + AI-bot check | `robots.py <url> --check-ai-bots` | — |
| sitemap / sitemap-index / llms.txt | `sitemap.py <url>` | — |
| Internal-link graph (orphans / depth / internal PageRank) | `crawl.py … \| linkgraph.py -` | — |
| Page speed + Core Web Vitals | `psi.py <url>` | free key for automation |
| Structured-data extract + validate (+ FAQ/HowTo deprecation) | `schema_lint.py <url>` | — |
| Entity → Wikidata QID + claims | `kg.py reconcile "<name>"` | — |
| Archive history / change tracking | `wayback.py <url>` | — |
| Domain-authority signal | `openpagerank.py <domain> --key …` | free key |
| Keyword ideas (⚠️ unofficial endpoint) | `suggest.py "<seed>" --expand` | — |
| Brand / mention RSS | `rss_monitor.py <feed-url>` | — |
| Before/after deltas (measurement loop) | `… \| ledger.py record <target> --source <name>` → `ledger.py diff <target> --source <name>` | — |

See [scripts/connectors/README.md](scripts/connectors/README.md) for the full list, the safety contract, and what intentionally stays external (proprietary / own-data → MCP/API).

**Measurement loop.** Most helpers above are point-in-time. Pipe any of them into `ledger.py record` to keep a local, git-diffable time series per target, then `ledger.py diff` / `ledger.py trend` to compute real movement — so a skill reports a measured delta instead of an estimated one. This is the spine the monitor-phase skills (rank-tracker, performance-reporter) and technical-seo-checker read for baselines. **Before trusting any movement, read [references/measurement-protocol.md](references/measurement-protocol.md)** — it defines which signals are minute-level proxies vs week-scale outcomes, and why outcome deltas need a control group to attribute.

## Free & public data sources (no paid tool, no MCP)

The fastest way to keep a skill zero-dependency is to feed it data from a free, first-party, or keyless public endpoint, then paste the response when the skill asks for the matching `~~category` data.

### Your own site — first-party, free

| Need (`~~category`) | Source | Endpoint / how | Auth | Free limit |
|---|---|---|---|---|
| Keywords + rankings (`~~SEO tool`, `~~search console`) | Google Search Console Search Analytics API | `POST https://www.googleapis.com/webmasters/v3/sites/{siteUrl}/searchAnalytics/query` (URL-encode siteUrl, or use `sc-domain:example.com`) | OAuth 2.0, scope `https://www.googleapis.com/auth/webmasters.readonly` | 1,200 queries/min per site |
| Keywords + rankings on Bing | Bing Webmaster Tools API | REST API; key from BWT → Settings → API Access | `apikey` query param **or** OAuth Bearer (token `https://www.bing.com/webmasters/oauth/token`) | free account |
| Traffic & behavior (`~~analytics`) | Google Analytics Data API (GA4) | `POST https://analyticsdata.googleapis.com/v1beta/{property=properties/*}:runReport` | OAuth 2.0, scope `https://www.googleapis.com/auth/analytics.readonly` | 200,000 tokens/property/day |
| Backlinks to your site (`~~link database`) | GSC Links report | Search Console UI → Links → Export top linking sites | GSC login | free |

### Public / keyless — any site

| Need (`~~category`) | Source | Endpoint / how | Auth | Limit |
|---|---|---|---|---|
| Keyword ideas / autocomplete (`~~SEO tool`) | Google Suggest — **⚠️ unofficial, undocumented** | `https://suggestqueries.google.com/complete/search?client=chrome&q=QUERY&hl=en&gl=US` | none | undocumented; backoff on 429/503, may change without notice |
| Domain authority signal (`~~link database`) | Open PageRank | `GET https://openpagerank.com/api/v1.0/getPageRank?domains[]=example.com` | free key in header `API-OPR: KEY` | 10,000 calls/hr, ≤100 domains/call (domain-rank scores, not raw link lists) |
| Inbound links / web graph (`~~link database`, `~~web crawler`) | Common Crawl CDX index | `https://index.commoncrawl.org/CC-MAIN-YYYY-WW-index?url=URL&output=json` — crawl list at `https://index.commoncrawl.org/collinfo.json` | none | shared server, keep < 10 req/s (expect `503 SlowDown`) |
| Historical pages / change tracking (`~~competitive intel`) | Wayback Machine CDX API | `http://web.archive.org/cdx/search/cdx?url=URL&output=json` (matchType `exact`/`prefix`/`host`/`domain`) | none | be gentle |
| Entity / knowledge-graph facts (`~~knowledge graph`) | Wikidata SPARQL | `https://query.wikidata.org/sparql?query=...&format=json` (GET or POST) | none — **descriptive User-Agent required** | ~60s query CPU per 60s per IP (429 on excess) |
| Entity lookup via Google (`~~knowledge graph`) | Google Knowledge Graph Search API — **⚠️ soft-migrating to Cloud Enterprise KG** | `GET https://kgsearch.googleapis.com/v1/entities:search?query=...&key=KEY` | API key | 100,000 calls/day (no sunset date announced; prefer Wikidata for durable keyless access) |

### Page speed / Core Web Vitals — free (`~~page speed tool`)

| Data | Source | Endpoint | Auth | Limit |
|---|---|---|---|---|
| Lab Lighthouse score | PageSpeed Insights API v5 | `GET https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=URL&strategy=mobile` | key optional (recommended for automation) | — |
| Real-user field CWV | Chrome UX Report (CrUX) API | `POST https://chromeuxreport.googleapis.com/v1/records:queryRecord?key=KEY` | Google Cloud API key (query param) | 150 queries/min (free; no paid increase) |
| Local lab run | Lighthouse CLI | `npx lighthouse URL --output json --output-path=./lh.json` | none | — |

### Open-source / self-host / DIY

| Need (`~~category`) | Tool | How |
|---|---|---|
| Crawl, robots.txt, sitemaps, SERP, logs (`~~web crawler`) | **advertools** (Python, OSS) | `pip install advertools` — site crawl, `sitemap_to_df`, `robotstxt_test`, SERP analysis, log-file parsing |
| Desktop crawl (`~~web crawler`) | Screaming Frog SEO Spider | free tier ≤ 500 URLs |
| Privacy analytics you own (`~~analytics`) | **Plausible** / **Matomo** (OSS, self-host) | Plausible Stats API v2: `POST https://plausible.io/api/v2/query` (`Authorization: Bearer KEY`, 600 req/hr); self-host uses the same path on your host |
| Schema / structured-data check (`~~schema validator`) | validator.schema.org · Google Rich Results Test | **UI only — paste markup; no public API** |
| Brand / mention monitoring (`~~brand monitor`) | Google Alerts (RSS) · F5Bot | free email/RSS alerts on brand or keyword mentions |
| AI-answer citation check (`~~AI monitor`) | Manual prompt-testing (ChatGPT / Perplexity / Google AI Overviews) · OSS GEO trackers | **no free API** — run target prompts, record which sources each engine cites, track over time |

**Zero-tool DIY pattern:** for most technical and content checks you need nothing but `fetch` — pull `robots.txt`, `sitemap.xml`, `llms.txt`, and the page HTML directly, and paste them in.

## Tool Categories (placeholder → tools)

| Category | Placeholder | Example paid tools | Free alternative (above) |
|----------|-------------|--------------------|--------------------------|
| SEO Platform | `~~SEO tool` | Ahrefs, Semrush, Moz, SISTRIX, SE Ranking | GSC + Google Suggest |
| Analytics | `~~analytics` | GA, Adobe Analytics, Plausible, Matomo | GA4 Data API / self-host Plausible |
| Search Console | `~~search console` | Google Search Console, Bing Webmaster | GSC + Bing WMT APIs |
| AI Visibility | `~~AI monitor` | Otterly, Profound, Scrunch AI | manual prompt-testing |
| Web Crawler | `~~web crawler` | Screaming Frog, Sitebulb, Lumar | advertools / Screaming Frog free / DIY fetch |
| Link Database | `~~link database` | Ahrefs, Majestic, Moz | Open PageRank + Common Crawl + GSC Links |
| Competitive Intel | `~~competitive intel` | SimilarWeb, SpyFu, Semrush | Wayback CDX + Common Crawl |
| Page Speed | `~~page speed tool` | GTmetrix, WebPageTest | PSI / CrUX / Lighthouse |
| Schema Validator | `~~schema validator` | — | validator.schema.org / Rich Results Test |
| Knowledge Graph | `~~knowledge graph` | Google KG API, CrunchBase | Wikidata SPARQL |
| Brand Monitor | `~~brand monitor` | Brand24, Mention, Brandwatch | Google Alerts / F5Bot |
| CRM / Marketing | `~~CRM` | HubSpot, Salesforce, Marketo | — |
| Content / CMS | `~~content platform` / `~~CMS` | WordPress, Webflow, Contentful, Sanity, Notion | — |
| Communication | `~~team chat` | Slack, Teams, Discord | — |
| Reporting | `~~reporting` | Looker Studio, Tableau, Power BI | — |

## How placeholders work

A skill might say: *"Pull keyword rankings from `~~SEO tool` and cross-reference with `~~search console` impressions."* If you use Ahrefs + Google Search Console, read it as Ahrefs + GSC. If you use no paid tool, read it as "the Search Console Search Analytics API (above)" — or just paste the data.

## Optional MCP servers (Tier 2/3 automation)

`.mcp.json` is a **copy-paste reference** of official remote HTTP MCP endpoints (plus one self-hosted entry, OpenSEO) — it is **opt-in, not auto-registered**. The plugin no longer wires `.mcp.json` into `plugin.json`, so installing the plugin does NOT add 15 servers to your `/mcp` list or trigger any auth prompts. To enable any of these, copy the entries you want into your own host/user MCP config; auth happens interactively on first use. MCP automates retrieval but is never required — the free sources above cover the same data.

**SEO data** (endpoints verified 2026-05):

| Vendor | Endpoint (`.mcp.json`) | Transport | Auth | Cost model | Sample tools |
|--------|------------------------|-----------|------|------------|--------------|
| Ahrefs | `https://api.ahrefs.com/mcp/mcp` | streamable HTTP | API key (MCP scope; Lite+ plan) | subscription | keyword & backlink data, site audit |
| Semrush | `https://mcp.semrush.com/v1/mcp` | streamable HTTP | OAuth, or `Authorization: Apikey KEY` | subscription | `organic_research`, `keyword_research`, `backlink_research` |
| SE Ranking | `https://api.seranking.com/mcp` | streamable HTTP | OAuth or API key (`X-Api-Key`) | subscription | keyword/backlink/domain, AI-search visibility (160+ tools) |
| SISTRIX | `https://api.sistrix.com/mcp/` | HTTP | OAuth / Bearer / `X-API-Key` | subscription | `domain`, `keyword`, `links`, `ai` modules |
| SimilarWeb | `https://mcp.similarweb.com` | HTTP | OAuth / key | subscription | traffic estimates, competitive intel |
| OpenSEO (self-hosted) | `https://<your-host>/mcp` (edit `.mcp.json`) | streamable HTTP | none (local Docker) / OAuth (Cloudflare) | **free app + pay-as-you-go data** | `research_keywords`, `get_ranked_keywords`, `get_serp_results`, `find_serp_competitors`, `get_domain_overview`, `get_backlinks_overview`, `get_search_console_performance`, local-SERP/Maps tools |

**Cost model — read before enabling.** The five vendors above are **subscription** (flat monthly fee for plan-gated API access). OpenSEO is the one **pay-as-you-go** option: the app is free and self-hosted, and it bills only the underlying [DataForSEO](https://dataforseo.com) API calls you actually make — so it fits the free/keyless-first ethos better than a subscription suite while still returning real SERP/keyword/backlink data.

**OpenSEO — self-hosted full SEO suite ([github.com/every-app/open-seo](https://github.com/every-app/open-seo), open source).** Run it via Docker (single-user, no auth — local only) or Cloudflare Workers (OAuth, team-ready, free plan compatible), connect your own DataForSEO key, and the app exposes an MCP server at `/<host>/mcp`. Set the host in your `.mcp.json` `openseo` entry (placeholder ships as `your-openseo-host.example`). It natively reads Google Search Console (`get_search_console_performance`), which makes the [keyword-research](research/keyword-research/SKILL.md) striking-distance loop and rank tracking first-party. Indicative DataForSEO spend (vendor pay-as-you-go pricing, verify current rates — $1 free starter credit, $50 min top-up as of early 2026):

| Task (×100 requests) | Approx. cost |
|---|---|
| Keyword research, 150 results/seed | ~$3.50 |
| Keyword research, 500 results/seed | ~$7.00 |
| Domain overview (200 ranked keywords) | ~$4.01 |
| Backlinks domain search | ~$6.34 |
| Track 100 keywords weekly at depth 50 | ~$1.20 / month |

**Free Google data via MCP** (not shipped in `.mcp.json` — these run locally and need your own Google credentials):

- **Google Analytics** — official ([github.com/googleanalytics/google-analytics-mcp](https://github.com/googleanalytics/google-analytics-mcp)): `pipx run analytics-mcp`, stdio, ADC scope `analytics.readonly`; tools `run_report`, `run_realtime_report`, `get_account_summaries`.
- **Google Search Console** — community ([github.com/AminForou/mcp-gsc](https://github.com/AminForou/mcp-gsc), MIT): `uvx mcp-search-console`, stdio, OAuth or service account; tools `get_search_analytics`, `inspect_url_enhanced`, `list_properties`.

**Infra / CMS / CRM / comms** (listed in `.mcp.json` as opt-in references, official remote endpoints, OAuth on first use): Cloudflare, Vercel, HubSpot, Amplitude, Notion, Webflow, Sanity, Contentful, Slack. See each vendor's MCP docs for its current tool list.

To enable a server, copy its `.mcp.json` entry into your host/user MCP config. The project `.mcp.json` is a curated catalog, not an active registration — keep it in sync only when contributing a new default endpoint.

## Progressive enhancement tiers

| Tier | Integration | Experience |
|------|-------------|------------|
| **Tier 1** | None | Paste data, or pull it from the free sources above. Skills provide the full analysis framework. |
| **Tier 2** | A free first-party API or one MCP | Automatic retrieval of your own GSC/GA4/CWV data. |
| **Tier 3** | Full MCP set | Fully automated multi-source workflows. |

Every skill works at Tier 1. Connecting tools only automates data retrieval.

## Environment variables

Soft dependencies — everything works without them. These are the only env vars the **bundled
stdlib connectors** actually read (both optional; the connectors fall back to keyless/lower-quota mode):

| Variable | Read by | Purpose |
|----------|---------|---------|
| `OPENPAGERANK_API_KEY` | `scripts/connectors/openpagerank.py` | Open PageRank domain-rank lookups (free key) |
| `PAGESPEED_API_KEY` | `scripts/connectors/psi.py` | Higher PageSpeed Insights quota (works keyless at low volume) |

The opt-in MCP servers do not use env vars here: most (Semrush, SE Ranking, SISTRIX, SimilarWeb, Cloudflare, Vercel, Webflow, Sanity, Contentful) use **OAuth** at first use; Ahrefs uses an in-client MCP key. The free Google APIs use OAuth (GSC/GA4) or a key (PSI/CrUX/Knowledge Graph) you supply at call time.

## Freshness & caveats

- **Google Knowledge Graph Search API** is in soft-migration to Cloud Enterprise Knowledge Graph (no sunset date). Prefer **Wikidata SPARQL** for durable, keyless entity data.
- **Google Suggest/autocomplete** is unofficial and undocumented — it may change or rate-limit without notice; add exponential backoff.
- **Common Crawl**'s shared index server has been rate-limited since Nov 2023 — expect `503 SlowDown`; run your own index for heavy use (data is free on AWS S3 `commoncrawl`).
- **Google Rich Results Test** and **validator.schema.org** expose no public API — paste markup into the UI.
- **AI-citation visibility** has no free API from any engine — the realistic free method is manual prompt-testing recorded over time.
