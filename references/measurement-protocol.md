# Measurement & Attribution Protocol (SEO / GEO)

> The honest answer to "how do we know a change worked?" — and, just as important, to
> "which questions can we answer in minutes, and which take weeks and a control group?"
> Without this discipline, every version is guesswork. This file is the SSOT for what is
> testable, how fast, and what each signal does and does NOT prove.

## The problem this exists to fix

SEO/GEO outcomes are **delayed** (a page change surfaces in an AI answer or a ranking only
after the engine re-crawls and re-indexes) and **confounded** (your number also moves because
the engine changed, a competitor changed, or the category shifted). So a raw before/after on
the final outcome is rarely attributable to your edit. The fix is not "measure faster" — some
things genuinely cannot be measured fast — it is to **separate the fast proxy from the slow
outcome, label which is which, and attribute the slow ones against a control.**

## The core distinction: proxy vs outcome, four latency layers

The single most common mistake (we made it ourselves) is collapsing two opposite-latency things
into one claim like "GEO is minute-level testable". It is not. It splits cleanly:

| Layer | What it measures | Latency | Proxy or outcome | How you test it | Tool |
|---|---|---|---|---|---|
| **1. Crawler access** | Can the AI/search bots even fetch and parse the page? | **Instant** | Precondition (neither) | Fetch-as-bot + robots eval + your server logs | `robots.py` (exists), `botlog.py` *(proposed)* |
| **2. Citability** | *Given the page is retrieved*, is it extractable / quotable / answer-shaped? | **Minutes** | **Proxy** for GEO | Hand the URL/content to a live-fetch engine, ask the target question, score the answer | `citations.py probe` *(proposed)* + `ledger.py` |
| **3. Surfacing** | Does an engine cite you for a bare query, *unprompted*? | **Days–weeks** | **Outcome** (GEO) | Ask a fixed query panel WITHOUT giving the URL; record citations over time vs a control | `citations.py surface` *(proposed)* + `ledger.py` |
| **4. Rankings / clicks** | Search position, impressions, CTR | **Weeks–months** | **Outcome** (SEO) | GSC / rank data snapshotted over time vs a control | `gsc.py` *(proposed)* + `ledger.py` |

> **⚠️ The error this table prevents:** never read a missing citation (layer 3) as "my content
> is bad" until layer 1 says the bot actually fetched a 200. "Not crawled yet" and "crawled but
> not chosen" look identical in the answer box and have completely different fixes. Check access
> first.

## Layer 1 — Crawler access (instant, fully in your control)

The cheapest, fastest signal, and a **precondition** for everything below: if the bot can't
fetch or render the page, no amount of content quality matters.

- **Test:** request the page as each relevant bot UA and confirm a `200` with the content present
  in the raw HTML (not JS-injected). Evaluate robots.txt for each UA group. Parse your own access
  logs for actual bot hits per URL.
- **Bots to check** (UA tokens drift — verify current values, do not hard-code blindly): training
  crawlers (GPTBot, ClaudeBot, PerplexityBot), live/user fetchers (ChatGPT-User, Claude-User,
  Perplexity-User), search-index crawlers (OAI-SearchBot, Claude-SearchBot), and Google
  (Googlebot powers AI Overviews; **Google-Extended is an opt-out *token*, not a separate crawler**,
  and does not change crawl timing).
- **What green here proves:** only that you are reachable. It is insurance against wasting two
  weeks discovering ClaudeBot was being 403'd — **not** evidence you will be cited.
- **robots caveat:** the live/user fetchers do not all obey robots.txt — `Perplexity-User`, in
  particular, behaves like a real-time browser and may fetch even when `PerplexityBot` (its
  background indexing crawler) is disallowed. So a robots.txt block reduces *surfacing* (L3, the
  index path) without necessarily stopping an explicit-URL *probe* (L2). Test access per UA, not in
  aggregate.

## Layer 2 — Citability: the fast loop (minutes, but a proxy)

**Why it *can* be fast — and the exception that bites:** when you hand the engine a **specific
URL**, a live-fetch path does a real HTTP GET at query time, so it sees the version you just
deployed and you bypass the crawl/index lag. This holds for **Perplexity-User** and **Claude's
`web_fetch`** (Claude-User UA). It does **not** hold universally: **ChatGPT, even with web access
on, preferentially answers from its own cached index rather than re-fetching**, and Claude's
`web_search` (as opposed to `web_fetch`) reads a search index, not your live page. So the
minutes-fast property belongs to the **explicit-URL live-fetch path**, not to "browsing" in
general — verify per engine, do not assume a universal bypass.

**What it actually measures:** extractability, quotable self-contained chunks, a direct answer
near the top, schema/structure the model can parse — i.e. **exactly what the build-phase GEO work
(`geo-content-optimizer`, schema, Q&A blocks) changes.** This is why iterating on those changes
*can* be fast.

**What it does NOT measure — state this every time:** whether the engine will *retrieve* you
unprompted. It tests "if retrieved, is it good," not "will it be retrieved." It is a **proxy** for
GEO, never the outcome.

**Method (probe):**
1. Define a fixed **prompt panel** of target questions (the queries you want to be cited for).
2. Run each prompt while supplying the URL/content — but **only trust the result as a test of your
   current page if a live fetch actually happened.** Confirm it: your access log should show the
   `Perplexity-User` / `Claude-User` hit during the probe. If no hit appears (ChatGPT cache,
   Claude `web_search`, any index path), you scored a *cached* copy — label it as such, do not call
   it a fresh-content test.
3. Score each answer: was the page cited? was a claim quoted verbatim? was the answer correct and
   attributable to your content? (binary per dimension is fine).
4. Because model output is **stochastic, sample** — run each prompt N times and record the **rate**,
   not a single yes/no. Snapshot the rates to `ledger.py` so successive content edits show a delta.

**Honest friction:** there is no clean, free API that reports "who did ChatGPT cite." Use the
Perplexity API where it exists; otherwise this layer is **semi-manual** (run the panel through each
engine's own interface/API). `ledger.py` structures the results; it does not automate the asking.

## Layer 3 — Surfacing: the slow loop (days–weeks, the real GEO outcome)

The thing users actually want — "does ChatGPT/AIO/Perplexity recommend me when someone asks" — is
**gated by each engine's own crawl + index refresh, which you cannot force.** There is no
"recrawl now" button for the AI-specific bots. Google's Search Console URL Inspection → Request
Indexing nudges *Google's* index only (rate-limited, no guarantee), and AI Overview inclusion is
decided separately on top of that. So surfacing is **as slow and confounded as SEO ranking.**

**Method (surface):**
1. Ask the fixed query panel **without supplying the URL**.
2. Record, per engine, whether your domain is cited / linked / named, and in what position.
3. Snapshot to `ledger.py` on a schedule (e.g. weekly).

**Attribution requires a control — this is non-negotiable for layers 3–4.** Your citation rate
moves for reasons that are not your edit (the engine retrained, a competitor published, the SERP
feature changed). So measure a **holdout in parallel**: an unchanged page of yours, a sibling URL,
or a competitor, run through the same panel. **Report delta-vs-control, not raw delta.** A raw
"+15% citations" means nothing if the whole category rose 15%.

**Horizon:** fix the measurement window *before* you start (e.g. 2–6 weeks) and do not react to
day-to-day noise inside it. Reading surfacing daily is reading noise.

## Layer 4 — SEO outcomes (weeks–months, same discipline)

Impressions / position / clicks via GSC (`gsc.py`, proposed) snapshotted to `ledger.py`, read
against a control and a horizon, accounting for seasonality. Mechanically identical to layer 3 —
just a different data source and a longer window.

## The loop (applies to layers 2–4)

1. **Baseline** — `ledger.py record` the relevant signal *before* the change.
2. **One attributable change** — make a single change, or a clearly labeled batch. Two changes at
   once destroy attribution.
3. **Wait the layer's latency** — minutes (L2), the fixed horizon (L3/L4). Re-snapshot.
4. **`ledger.py diff` / `trend` against the control**, not against zero.
5. **Label every number** — `Measured` / `Estimated` / `Proxy-for-<outcome>`. Never render a
   layer-2 proxy as if it were a layer-3 outcome. (This is the same labeling rule the skills already
   carry, applied to time-series.)

## What this protocol does NOT give you (read before trusting a number)

- **No certainty.** A proxy (L2) can improve while the outcome (L3) does not, and vice-versa.
  Citability is necessary, not sufficient, for surfacing.
- **No fast surfacing.** Layers 3–4 stay slow. Any claim of a minute-level "will I be cited /
  ranked" loop is false — we made that claim once and it was wrong.
- **No attribution without a control.** A raw before/after on a confounded outcome is a story,
  not evidence.
- **Single runs are noise.** L2 is stochastic; sample and report rates.
- **Collection is semi-manual.** The tools structure and diff the data; they do not, for the AI
  engines, automate the asking.

## Tooling map

| Tool | Status | Layer(s) | Role |
|---|---|---|---|
| `scripts/connectors/ledger.py` | **exists** | 2–4 | snapshot / diff / trend spine; per-target time series with collision guard |
| `scripts/golden-auditor-math.py` | **exists** | — | guards the *internal* consistency of the scoring math (not external validity) |
| `scripts/connectors/robots.py` | **exists** | 1 | robots.txt + AI-bot access check |
| `scripts/connectors/botlog.py` | *proposed* | 1 | parse server logs → per-URL AI-bot hit counts |
| `scripts/connectors/citations.py` | *proposed* | 2, 3 | `probe` (fast citability) + `surface` (slow unprompted-citation) modes, both → ledger |
| `scripts/connectors/gsc.py` | *proposed* | 4 | Google Search Console impressions/position/clicks |

## Relationship to CORE-EEAT / CITE

The framework scores are **internal heuristics**. `golden-auditor-math.py` guards their *internal*
consistency (weights sum, examples recompute) — it says nothing about **external validity**:
whether a high score actually predicts citability (L2) or surfacing (L3). That is itself a
measurement question this protocol lets you eventually answer with a **calibration study** —
correlate framework scores against *measured* citation rates across a corpus. Until that study
exists, present the scores as structured opinion, not as a predictor of outcomes.

See also: [CONNECTORS.md](../CONNECTORS.md) (the data recipes and the measurement-loop note),
[scripts/connectors/README.md](../scripts/connectors/README.md) (helper reference),
[state-model.md](state-model.md) (where snapshots live in `memory/`).
