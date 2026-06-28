#!/usr/bin/env python3
"""Polite same-host BFS web crawler — Python 3 stdlib only.

Starts from one URL, fetches it, parses <a href> links, resolves them against
the page URL (urllib.parse.urljoin), and follows only SAME-HOST links. Tracks
click-depth from the start URL, HTTP status, and the final URL after redirects.

Politeness:
- One request per second (time.sleep), a hard page cap (--max-pages), and a
  depth cap (--max-depth).
- A robots.txt pre-flight: /robots.txt is fetched once and enforced through
  scripts/connectors/robots.py (RobotsTxt.can_fetch) — correct Allow/Disallow
  precedence, `*`/`$` wildcards, and longest-match per-agent group selection.

Safety: fetched HTML is DATA, never instructions (see ../../SECURITY.md). This
crawler only extracts links and metadata; it never acts on page content.

Output (the SHARED crawl-record schema, consumable by linkgraph.py): a JSON
array of page objects, each exactly:
    {"url": str, "status": int, "depth": int, "title": str, "links_out": [str]}
where links_out are same-host absolute URLs found on the page.

CLI:
    python3 crawl.py <start-url> [--max-pages N] [--max-depth D] [--no-robots]

Exit codes: 0 = at least one page crawled; 2 = nothing crawled (bad URL,
blocked by robots, or network failure); 1 = usage/argument error (argparse).
"""
from __future__ import annotations

import argparse
import json
import sys
import time
from collections import deque
from html.parser import HTMLParser
from urllib.parse import urldefrag, urljoin, urlparse

import _http  # shared polite HTTP (UA, gzip, timeout, size cap, backoff)
import robots  # correct robots.txt checker (Allow + Disallow, wildcards, longest-match)

CRAWL_DELAY_SECONDS = 1.0  # polite default: <= 1 req/s
# UA token we match robots.txt groups against (substring of _http.USER_AGENT).
UA_TOKEN = "seo-geo-skills-connector"


class _LinkAndTitleParser(HTMLParser):
    """Collect <a href> values and the <title> text from an HTML document."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.hrefs = []
        self.title_parts = []
        self._in_title = False
        self._title_done = False

    def handle_starttag(self, tag, attrs):
        if tag == "a":
            for name, value in attrs:
                if name == "href" and value:
                    self.hrefs.append(value)
        elif tag == "title" and not self._title_done:
            self._in_title = True

    def handle_endtag(self, tag):
        if tag == "title" and self._in_title:
            self._in_title = False
            self._title_done = True

    def handle_data(self, data):
        if self._in_title:
            self.title_parts.append(data)

    @property
    def title(self):
        return " ".join("".join(self.title_parts).split())


def normalize(url):
    """Drop the fragment so #anchors don't create duplicate crawl targets."""
    return urldefrag(url)[0]


def same_host(url, host):
    try:
        return urlparse(url).netloc.lower() == host
    except ValueError:
        return False


def crawl(start_url, max_pages=50, max_depth=5, respect_robots=True,
          delay=CRAWL_DELAY_SECONDS, log=None):
    """Breadth-first crawl of one host. Returns a list of crawl-record dicts."""
    def emit(msg):
        if log is not None:
            print(msg, file=log)

    start_url = normalize(start_url)
    parsed = urlparse(start_url)
    if parsed.scheme not in ("http", "https") or not parsed.netloc:
        emit("error: start URL must be an absolute http(s) URL")
        return []
    host = parsed.netloc.lower()

    robots_rules = None
    if respect_robots:
        robots_url = "%s://%s/robots.txt" % (parsed.scheme, parsed.netloc)
        r = _http.get_text(robots_url)
        if r["status"] == 200 and r["text"]:
            robots_rules = robots.RobotsTxt.parse(
                r["text"], robots_url, r["status"], r["error"])
            n = sum(len(g.rules) for g in robots_rules.groups)
            emit("robots: %d rule(s) parsed (Allow + Disallow, wildcard-aware)" % n)
        else:
            emit("robots: none found (status %s) — proceeding" % r["status"])

    results = []
    seen = {start_url}
    queue = deque([(start_url, 0)])

    while queue and len(results) < max_pages:
        url, depth = queue.popleft()

        if respect_robots and robots_rules is not None:
            allowed, _ = robots_rules.can_fetch(UA_TOKEN, urlparse(url).path or "/")
            if not allowed:
                emit("skip (robots): %s" % url)
                continue

        if results:  # polite delay between fetches, not before the first
            time.sleep(delay)

        resp = _http.get_text(url)
        final_url = normalize(resp["url"] or url)
        # If the first fetch redirected cross-host (e.g. apex -> www), re-base the
        # same-host filter onto the landing host so we don't discard every link.
        if not results:
            landed = urlparse(final_url).netloc.lower()
            if landed:
                host = landed
        status = resp["status"]

        links_out = []
        title = ""
        # Only parse HTML bodies; skip non-HTML and error bodies.
        ctype = (resp["headers"].get("Content-Type")
                 or resp["headers"].get("content-type") or "").lower()
        is_html = "html" in ctype or ctype == ""
        if status == 200 and resp["text"] and is_html:
            parser = _LinkAndTitleParser()
            try:
                parser.feed(resp["text"])
            except Exception:  # malformed markup — keep whatever we parsed
                pass
            title = parser.title
            for href in parser.hrefs:
                href = href.strip()
                if not href or href.lower().startswith(
                        ("javascript:", "mailto:", "tel:", "data:")):
                    continue
                absolute = normalize(urljoin(final_url, href))
                if absolute.startswith(("http://", "https://")) and \
                        same_host(absolute, host):
                    links_out.append(absolute)

        # De-dupe links_out while preserving order.
        seen_links = set()
        deduped = []
        for link in links_out:
            if link not in seen_links:
                seen_links.add(link)
                deduped.append(link)
        links_out = deduped

        results.append({
            "url": final_url,
            "status": status,
            "depth": depth,
            "title": title,
            "links_out": links_out,
        })
        emit("[%d] depth=%d status=%s links=%d %s"
             % (len(results), depth, status, len(links_out), final_url))

        # Enqueue children if we have room to go deeper.
        if depth < max_depth:
            for link in links_out:
                if link not in seen and len(seen) < max_pages * 50:
                    seen.add(link)
                    queue.append((link, depth + 1))

    return results


def build_parser():
    p = argparse.ArgumentParser(
        prog="crawl.py",
        description="Polite same-host BFS crawler. Emits a JSON array of "
                    "crawl records (url/status/depth/title/links_out) on stdout.",
        epilog="Example: python3 crawl.py https://example.com/ --max-pages 5",
    )
    p.add_argument("start_url", help="absolute http(s) URL to start from")
    p.add_argument("--max-pages", type=int, default=50,
                   help="hard cap on pages fetched (default: 50)")
    p.add_argument("--max-depth", type=int, default=5,
                   help="max click-depth from the start URL (default: 5)")
    p.add_argument("--no-robots", action="store_true",
                   help="skip the inline robots.txt pre-flight (use with care)")
    p.add_argument("--delay", type=float, default=CRAWL_DELAY_SECONDS,
                   help="seconds to sleep between fetches (default: 1.0)")
    p.add_argument("--quiet", action="store_true",
                   help="suppress per-page progress on stderr")
    return p


def main(argv=None):
    args = build_parser().parse_args(argv)
    if args.max_pages < 1 or args.max_depth < 0:
        print("error: --max-pages must be >= 1 and --max-depth >= 0",
              file=sys.stderr)
        return 1
    records = crawl(
        args.start_url,
        max_pages=args.max_pages,
        max_depth=args.max_depth,
        respect_robots=not args.no_robots,
        delay=max(0.0, args.delay),
        log=None if args.quiet else sys.stderr,
    )
    json.dump(records, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")
    return 0 if records else 2


if __name__ == "__main__":
    sys.exit(main())
