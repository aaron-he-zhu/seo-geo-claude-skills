# Tracked Planning Docs

Most `.docs/` files are local planning notes and are ignored by default. Any
authoritative proposal that should appear in GitHub review must be:

1. listed here;
2. allowlisted in `.gitignore`;
3. linked from a counted reference page when it affects repo behavior.

Tracked proposals:

- [proposal-aaron-command-architecture-v2.md](proposal-aaron-command-architecture-v2.md) - behavior-changing Aaron command architecture v2 proposal; must be present in `git ls-files` before PR review.
- [host-namespace-smoke.md](host-namespace-smoke.md) - parser-checked host command-surface evidence for the `/aaron:` breaking rename.
- [slashaaron-product-proposal.md](slashaaron-product-proposal.md) - comprehensive slashaaron.com / slash-aaron product, repository, and anchor-pack strategy.
- [seo-geo-anchor-pack-implementation-plan.md](seo-geo-anchor-pack-implementation-plan.md) - current-repo-only plan for making this project the SEO/GEO anchor capability pack.
- [seo-geo-anchor-pack-acceptance.md](seo-geo-anchor-pack-acceptance.md) - implementation, review, repair, and acceptance record for the anchor-pack plan.
