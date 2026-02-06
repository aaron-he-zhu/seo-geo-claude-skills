---
description: Configure monitoring alerts for critical SEO and GEO metrics
argument-hint: "<metric type> <threshold>"
---

# Setup Alert Command

> If you see unfamiliar ~~placeholders in this document, see [CONNECTORS.md](../CONNECTORS.md) for the tool category mapping.

An alert configuration command that helps you proactively monitor critical SEO and GEO metrics, define intelligent thresholds, and establish response playbooks for when issues occur.

## Usage

```
/seo:setup-alert ranking-drop threshold=-5 keywords="primary keywords"
/seo:setup-alert traffic-change threshold=-20%
/seo:setup-alert indexing-issue
/seo:setup-alert backlink-change threshold=lost-domain-rating-70+
/seo:setup-alert geo-visibility threshold=-30%
/seo:setup-alert core-web-vitals threshold=poor
/seo:setup-alert all-critical (sets up standard alert package)
```

**Arguments:**
- Alert type (required): See available categories below
- `threshold=X` (required for some types): Numeric or percentage threshold
- `keywords="list"` (optional): Specific keywords to monitor
- `pages="list"` (optional): Specific pages/URLs to monitor
- `severity=high|medium|low` (optional): Alert priority level
- `notification=email|slack|sms` (optional): Delivery method

## Workflow

### 1. Present Available Alert Categories

Show user all alert types with descriptions:

#### A. Ranking Drop Alerts
**Purpose:** Detect when keyword rankings decline significantly

**Trigger conditions:**
- Single keyword drops >X positions (configurable, default: 5)
- Multiple keywords decline simultaneously (potential algorithm update)
- Loss of position 1-3 ranking (critical visibility loss)
- Loss of SERP features (featured snippet, local pack, etc.)

**Recommended thresholds:**
- Critical keywords: -3 positions
- Secondary keywords: -5 positions
- Long-tail keywords: -10 positions

**Data source:** `~~SEO tool`

#### B. Traffic Change Alerts
**Purpose:** Identify unusual traffic patterns indicating issues or opportunities

**Trigger conditions:**
- Organic traffic drops >X% day-over-day (default: 20%)
- Organic traffic drops >X% week-over-week (default: 15%)
- Sudden traffic spike >X% (may indicate viral content or data anomaly)
- Specific landing page traffic drops >X% (default: 30%)
- Seasonal deviation beyond expected range

**Recommended thresholds:**
- Overall traffic: -20% (daily), -15% (weekly)
- High-value pages: -25%
- Homepage: -30%

**Data source:** `~~analytics`

#### C. Indexing Issue Alerts
**Purpose:** Catch pages being deindexed or blocked from indexing

**Trigger conditions:**
- Indexed page count drops >X% (default: 5%)
- Critical pages removed from index
- Increase in "noindex" tagged pages
- Robots.txt blocking important sections
- XML sitemap errors
- Increase in "Discovered - not indexed" status in Search Console

**Recommended thresholds:**
- Any decrease in indexed pages for small sites (<100 pages)
- >5% decrease for medium sites (100-1000 pages)
- >10% decrease for large sites (1000+ pages)

**Data source:** `~~search console`, `~~web crawler`

#### D. Backlink Change Alerts
**Purpose:** Monitor backlink profile for gains and losses

**Trigger conditions:**
- Lost backlinks from high-authority domains (DR/DA >X)
- Sudden increase in toxic backlinks (spam score >X%)
- Total referring domains decreases >X%
- Gain of high-value backlink (DR >80)
- Competitor gains backlink from industry authority

**Recommended thresholds:**
- Lost domain with DR >70: Immediate alert
- Lost domains >10 in one week: Alert
- Toxic backlink ratio >15%: Alert

**Data source:** `~~SEO tool`

#### E. GEO Visibility Shift Alerts
**Purpose:** Track changes in AI platform citations and visibility

**Trigger conditions:**
- Citation count drops >X% on any AI platform (default: 25%)
- Zero citations for previously cited topics
- Competitor overtakes your citation position
- New AI platform launches without any brand presence
- Negative sentiment in AI citations

**Recommended thresholds:**
- ChatGPT citations: -30% week-over-week
- Any platform: Zero citations where previously cited
- Citation position: Drop from top 3 to outside top 5

**Data source:** `~~AI monitor`

#### F. Core Web Vitals Alerts
**Purpose:** Detect page speed and user experience degradation

**Trigger conditions:**
- LCP (Largest Contentful Paint) exceeds 2.5s
- FID (First Input Delay) exceeds 100ms
- CLS (Cumulative Layout Shift) exceeds 0.1
- % of URLs with "Good" status drops below 75%
- Critical pages move from "Good" to "Needs Improvement"

**Recommended thresholds:**
- Any critical page falling below "Good" status
- >20% of URLs transitioning to "Poor" status

**Data source:** `~~search console`, `~~web crawler`

#### G. Technical SEO Error Alerts
**Purpose:** Identify critical technical issues immediately

**Trigger conditions:**
- Increase in 404 errors >X (default: 10 new 404s)
- Server errors (5xx) detected on critical pages
- Duplicate content instances >X% increase
- Broken internal links >X (default: 20)
- Schema markup errors on critical pages
- Mobile usability issues detected

**Recommended thresholds:**
- Any 5xx error on homepage or conversion pages: Immediate
- 404 errors: >10 new errors
- Broken links: >15 newly broken

**Data source:** `~~web crawler`, `~~search console`

#### H. Conversion Rate Alerts
**Purpose:** Monitor SEO traffic's business impact

**Trigger conditions:**
- Organic conversion rate drops >X% (default: 15%)
- Conversion rate drop on specific landing pages
- Goal completion rate decreases
- Revenue per organic session declines

**Recommended thresholds:**
- Overall organic conversion rate: -15%
- High-value landing pages: -20%

**Data source:** `~~analytics`

### 2. Help User Define Thresholds and Severity Levels

Guide threshold setting based on business context:

**Threshold-setting framework:**

| Business Context | Conservative | Balanced | Aggressive |
|-----------------|--------------|----------|------------|
| **Enterprise/High-stakes** | Tight thresholds (catch small issues early) | Medium thresholds | Loose thresholds |
| **SMB/Standard** | Loose thresholds (reduce noise) | Medium thresholds | Tight thresholds |
| **Startup/Experimental** | Loose thresholds | Tight thresholds | Very tight |

**Examples:**
```
Enterprise e-commerce site:
- Ranking drop: -3 positions (tight - every position matters)
- Traffic drop: -15% (tight - revenue impact)
- Indexing issue: -2% (tight - large inventory)

SMB service business:
- Ranking drop: -5 positions (medium)
- Traffic drop: -25% (loose - expect more volatility)
- Indexing issue: Any decrease (tight - small site)
```

**Severity level definitions:**

**CRITICAL (Immediate notification):**
- Homepage deindexed
- Primary keyword drops out of top 10
- Site-wide technical error (5xx)
- Traffic drops >50%
- Core Web Vitals fail on conversion pages

**HIGH (Notify within 1 hour):**
- Important keyword drops >5 positions
- Traffic drops 20-50%
- Lost backlink from DR >80 domain
- GEO citations drop >30%
- Indexing issues affecting >10% of pages

**MEDIUM (Daily digest):**
- Secondary keyword ranking changes
- Traffic drops 10-20%
- Minor technical issues
- Backlink fluctuations
- Competitor ranking gains

**LOW (Weekly summary):**
- Long-tail keyword changes
- Traffic fluctuations <10%
- Opportunities (new keyword rankings)
- Minor optimization suggestions

### 3. Generate Alert Configuration

Create structured alert setup:

**Alert configuration template:**
```yaml
Alert Name: [Descriptive name]
Type: [Alert category]
Severity: [Critical/High/Medium/Low]

Trigger Conditions:
  - Metric: [Specific metric to monitor]
  - Threshold: [Numeric threshold]
  - Timeframe: [Evaluation period]
  - Scope: [Specific pages/keywords or site-wide]

Data Sources:
  - Primary: [Tool/platform]
  - Backup: [Alternative if primary unavailable]

Notification:
  - Method: [Email/Slack/SMS/Dashboard]
  - Recipients: [Who gets notified]
  - Frequency: [Immediate/Hourly/Daily/Weekly]

False Positive Filters:
  - [Conditions to ignore to reduce noise]

Auto-Resolution:
  - [When to automatically mark as resolved]
```

**Example configuration:**
```yaml
Alert Name: "Primary Keyword Ranking Drop"
Type: Ranking Drop Alert
Severity: Critical

Trigger Conditions:
  - Metric: Keyword position
  - Threshold: Drop of 3 or more positions
  - Timeframe: Daily check
  - Scope: Keywords tagged as "primary" (12 keywords)

Data Sources:
  - Primary: ~~SEO tool (daily rank tracking)
  - Backup: Manual Google Search Console check

Notification:
  - Method: Email + Slack (#seo-alerts channel)
  - Recipients: SEO Manager, Marketing Director
  - Frequency: Immediate (within 15 minutes of detection)

False Positive Filters:
  - Ignore position changes on weekends (rank tracking can be unstable)
  - Ignore if SERP layout changes (featured snippet added/removed)
  - Require 2 consecutive days of decline before alerting

Auto-Resolution:
  - Alert resolves when ranking recovers to within 1 position of pre-drop level
  - Or after 30 days (move to "ongoing monitoring")
```

### 4. Define Response Playbooks for Each Alert Type

Establish clear action plans when alerts trigger:

#### Ranking Drop Response Playbook

**Immediate Actions (Within 1 hour):**
1. Verify ranking drop via manual search
2. Check for SERP layout changes (new features, AI Overviews)
3. Review Google Search Console for manual actions or messages
4. Check if algorithm update occurred (industry news, sensors)
5. Analyze competitor pages now ranking above you

**Investigation (Within 24 hours):**
1. Compare current page content vs top-ranking pages
2. Review backlink profile for lost links
3. Check technical health (page speed, mobile usability)
4. Analyze on-page optimization vs competitors
5. Review recent site changes that may have impacted page

**Recovery Actions (Within 1 week):**
1. Refresh content to match or exceed top-ranking content quality
2. Optimize title tag and meta description for better CTR
3. Build 3-5 high-quality backlinks to the page
4. Fix any technical issues identified
5. Improve internal linking to the affected page

**Escalation:**
- If ranking doesn't recover within 2 weeks: Full content overhaul
- If site-wide ranking decline: Consult SEO specialist for algorithm update analysis

#### Traffic Drop Response Playbook

**Immediate Actions (Within 1 hour):**
1. Verify drop in Google Analytics (not a tracking issue)
2. Check Google Search Console for indexing issues
3. Review server logs for downtime or errors
4. Check for robots.txt or sitemap changes
5. Verify no manual penalty in Search Console

**Investigation (Within 24 hours):**
1. Segment traffic drop (device, country, landing page)
2. Compare impressions vs clicks (ranking vs CTR issue?)
3. Review recent site changes or deployments
4. Check for competitor content launches
5. Analyze seasonality and trends

**Recovery Actions:**
- If indexing issue: Submit to Search Console, fix technical cause
- If ranking drop: Follow ranking drop playbook
- If CTR drop: Optimize meta tags, test new titles
- If technical issue: Coordinate with dev team for immediate fix

#### Indexing Issue Response Playbook

**Immediate Actions (Within 30 minutes):**
1. Identify which pages were deindexed via Search Console
2. Check robots.txt and meta robots tags
3. Verify XML sitemap is accessible and current
4. Review server logs for crawl errors
5. Check for manual actions or security issues in Search Console

**Investigation (Within 2 hours):**
1. Crawl site via `~~web crawler` to identify issues
2. Compare deindexed pages for common characteristics
3. Review recent template changes or CMS updates
4. Check canonical tag implementation
5. Verify no accidental noindex tags deployed

**Recovery Actions:**
1. Fix identified technical issues immediately
2. Request re-indexing via Search Console for critical pages
3. Submit updated XML sitemap
4. Monitor re-indexing progress daily
5. Document issue and prevention measures

#### GEO Visibility Drop Response Playbook

**Immediate Actions (Within 24 hours):**
1. Verify citation drop across multiple AI platforms
2. Review recent content changes on cited pages
3. Check if competitors increased their content quality
4. Analyze topic relevance and depth vs competitor content

**Investigation (Within 1 week):**
1. Identify which topics/queries lost citations
2. Review competitor content strategy
3. Analyze AI platform preference changes
4. Check for brand mention sentiment shifts

**Recovery Actions:**
1. Enhance content depth and expertise signals on affected topics
2. Add authoritative sources and citations
3. Improve E-E-A-T signals (author bios, credentials)
4. Create new comprehensive content on adjacent topics
5. Monitor via `~~AI monitor` for recovery

### 5. Set Up Notification Preferences

Configure delivery channels and recipients:

**Notification channels:**

| Channel | Use Case | Response Time | Best For |
|---------|----------|---------------|----------|
| **Email** | Standard alerts | Hours | Non-urgent, detailed reports |
| **Slack** | Team collaboration | Minutes | Team-wide awareness |
| **SMS** | Critical only | Immediate | After-hours emergencies |
| **Dashboard** | All alerts | On-demand | Historical review |
| **PagerDuty** | Enterprise critical | Immediate | Mission-critical sites |

**Notification formatting:**

**Subject line template:**
`[SEVERITY] [ALERT TYPE]: [BRIEF DESCRIPTION]`

**Example:**
`[CRITICAL] Ranking Drop: "Primary Keyword" fell from #2 to #8`

**Body template:**
```
ALERT: [Alert Name]
Severity: [Level]
Triggered: [Timestamp]

ISSUE:
[Clear description of what happened]

IMPACT:
[Business impact - traffic loss, revenue impact, etc.]

CURRENT STATUS:
[Relevant metrics]

RECOMMENDED ACTIONS:
1. [Immediate action]
2. [Follow-up action]
3. [Investigation needed]

VIEW DETAILS: [Link to dashboard or full report]

PLAYBOOK: [Link to response playbook]

---
This alert was configured via /seo:setup-alert
```

**Digest options:**
- **Immediate:** Send alert as soon as triggered (critical/high)
- **Hourly digest:** Batch alerts from past hour (medium)
- **Daily digest:** Summary of all alerts from past 24 hours (low)
- **Weekly summary:** All activity including resolved alerts (all levels)

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALERT CONFIGURATION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Successfully configured [X] alert(s) for example.com

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ACTIVE ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. PRIMARY KEYWORD RANKING DROP
   Type: Ranking Drop
   Severity: CRITICAL
   Threshold: -3 positions
   Scope: 12 primary keywords
   Notification: Email + Slack (immediate)
   Status: Active ✓

2. ORGANIC TRAFFIC DECLINE
   Type: Traffic Change
   Severity: HIGH
   Threshold: -20% day-over-day
   Scope: Site-wide
   Notification: Email + Slack (immediate)
   Status: Active ✓

3. INDEXING ISSUES
   Type: Indexing
   Severity: CRITICAL
   Threshold: Any decrease in indexed pages
   Scope: All pages
   Notification: Email + SMS (immediate)
   Status: Active ✓

4. HIGH-AUTHORITY BACKLINK LOSS
   Type: Backlink Change
   Severity: HIGH
   Threshold: Lost domain DR >70
   Scope: All backlinks
   Notification: Email (daily digest)
   Status: Active ✓

5. GEO VISIBILITY DROP
   Type: GEO
   Severity: MEDIUM
   Threshold: -30% citations
   Scope: ChatGPT, Perplexity, Claude
   Notification: Email (weekly summary)
   Status: Active ✓

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTIFICATION SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Email Recipients:
- seo@example.com (all alerts)
- marketing-director@example.com (critical + high only)

Slack Integration:
- Channel: #seo-alerts
- Alerts: Critical + High

SMS (Emergency Only):
- +1-555-123-4567 (on-call SEO)
- Alerts: Critical only, outside business hours

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RESPONSE PLAYBOOKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All alerts have associated response playbooks stored at:
/playbooks/seo-alerts/

Quick Access:
- Ranking Drop: /playbooks/ranking-drop-response.md
- Traffic Drop: /playbooks/traffic-drop-response.md
- Indexing Issue: /playbooks/indexing-issue-response.md
- Backlink Loss: /playbooks/backlink-loss-response.md
- GEO Visibility: /playbooks/geo-visibility-response.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TESTING & VALIDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Recommended next steps:

1. Send test alert to verify notification delivery
2. Review playbooks with team members
3. Schedule monthly alert threshold review
4. Document escalation procedures
5. Set calendar reminder to review alert effectiveness in 30 days

Test Alert Command:
/seo:test-alert ranking-drop

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MONITORING DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

View all active alerts and historical triggers:
[Dashboard URL]

Alert History (Last 30 Days):
- Total alerts triggered: 0 (newly configured)
- Critical: 0
- High: 0
- Medium: 0
- Low: 0

Average response time: N/A (no alerts yet)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Tips

**Alert Fatigue Prevention:**
- Start with conservative (loose) thresholds and tighten over time
- Use digest notifications for non-critical alerts
- Implement auto-resolution to clear alerts once issues are fixed
- Review alert effectiveness monthly and disable low-value alerts
- Set "quiet hours" for non-critical alerts (e.g., no alerts 10pm-7am)

**Threshold Optimization:**
- Analyze historical volatility to set realistic thresholds
- Different thresholds for weekends vs weekdays if traffic patterns differ
- Seasonal adjustment (looser thresholds during expected slow periods)
- Tighter thresholds during critical business periods (Black Friday, product launches)

**Team Coordination:**
- Document who responds to each alert type
- Set up alert rotation for after-hours coverage
- Create shared Slack channel for alert discussion
- Integrate alerts with project management tools (create tasks automatically)

**Common Alert Configurations:**

**Small Business (5-10 alerts):**
- Critical keyword ranking drops
- Site-wide traffic drops >25%
- Any indexing issues
- Core Web Vitals failures
- Lost backlinks from DR >60

**Mid-size Business (10-20 alerts):**
- Above + category-specific keyword groups
- Landing page specific traffic drops
- Competitor ranking gains
- Backlink velocity changes
- GEO citation tracking

**Enterprise (20+ alerts):**
- Above + granular page-level monitoring
- International site monitoring (by country)
- Multiple conversion funnel alerts
- Advanced technical monitoring
- Brand mention sentiment tracking

**Without Integrations:**
- Set up manual weekly/monthly check-ins
- Create spreadsheet-based monitoring templates
- Use Google Alerts for brand mentions
- Set calendar reminders for manual rank checks
- Document manual alert workflow and thresholds
