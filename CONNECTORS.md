# Connectors

> If you see unfamiliar `~~placeholders` in a skill or command file, refer to this document. Each placeholder maps to a **tool category** — replace it with whichever tool your organization uses.

## Tool Category Mapping

| Category | Placeholder | Included Servers | Other Options |
|----------|-------------|-----------------|---------------|
| SEO Platform | `~~SEO tool` | — | Ahrefs, SEMrush, Moz, Sistrix, SE Ranking |
| Analytics | `~~analytics` | — | Google Analytics, Adobe Analytics, Plausible, Matomo |
| Search Console | `~~search console` | — | Google Search Console, Bing Webmaster Tools |
| AI Visibility | `~~AI monitor` | — | Otterly, Profound, Scrunch AI |
| Web Crawler | `~~web crawler` | — | Screaming Frog, Sitebulb, DeepCrawl, Lumar |
| Link Database | `~~link database` | — | Ahrefs, Majestic, Moz Link Explorer |
| CMS | `~~CMS` | — | WordPress, Webflow, Shopify, HubSpot CMS |
| CDN / Hosting | `~~CDN` | — | Cloudflare, Fastly, Vercel, Netlify |
| Page Speed | `~~page speed tool` | — | Google PageSpeed Insights, WebPageTest, GTmetrix |
| Schema Validator | `~~schema validator` | — | Google Rich Results Test, Schema.org Validator |
| Email Platform | `~~email platform` | — | Mailchimp, HubSpot, ConvertKit, Klaviyo |
| Content Platform | `~~content platform` | — | WordPress, Medium, Ghost, Substack |
| Social Analytics | `~~social analytics` | — | Hootsuite, Buffer, Sprout Social |
| Heatmap / UX | `~~heatmap tool` | — | Hotjar, Microsoft Clarity, FullStory |

## How Placeholders Work

Skills and commands use `~~category` placeholders instead of specific tool names. This makes every skill **tool-agnostic** — the same workflow adapts to any toolstack.

### Example

A skill might say:

```
Pull keyword rankings from ~~SEO tool and cross-reference with ~~search console impressions.
```

If your organization uses Ahrefs and Google Search Console, read it as:

```
Pull keyword rankings from Ahrefs and cross-reference with Google Search Console impressions.
```

## Progressive Enhancement Tiers

Skills are designed to work at three levels of tool integration:

| Tier | Integration Level | Experience |
|------|-------------------|------------|
| **Tier 1** | No integrations | Paste data, describe context manually. Skills still provide full analysis frameworks. |
| **Tier 2** | Basic MCP | Connect ~~search console or ~~analytics for automatic data retrieval. |
| **Tier 3** | Full integration | ~~SEO tool + ~~analytics + ~~search console + ~~web crawler for fully automated workflows. |

## Configuring Your Tools

To connect tools via MCP, add them to your `.mcp.json`:

```json
{
  "mcpServers": {
    "google-search-console": {
      "type": "http",
      "url": ""
    },
    "analytics": {
      "type": "http",
      "url": ""
    }
  }
}
```

Fill in the `url` field with the MCP endpoint for your specific tool. Leave empty for tools not yet configured — skills will fall back to manual data collection.

## Adding New Categories

To extend the placeholder system:

1. Add a new row to the mapping table above
2. Use the `~~new category` placeholder in your skills
3. Map it to the specific tool in your `.mcp.json`
