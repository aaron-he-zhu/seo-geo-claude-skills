import pathlib
import sys
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts" / "connectors"))

import onpage  # noqa: E402
import linkgraph  # noqa: E402
import schema_lint  # noqa: E402
import robots  # noqa: E402
import psi  # noqa: E402
import ledger  # noqa: E402
import openpagerank  # noqa: E402


class OnPageParserTests(unittest.TestCase):
    def test_word_count_excludes_non_visible_head_and_script_text(self):
        html = """<!doctype html>
        <html>
          <head>
            <title>Invisible title</title>
            <style>.hidden words should not count</style>
            <script>var fake = "many invisible words here";</script>
          </head>
          <body>
            <h1>Hello world</h1>
            <p>Visible text only.</p>
          </body>
        </html>"""

        result = onpage.analyze(html)

        self.assertEqual(result["title"], "Invisible title")
        self.assertEqual(result["headings"]["h1"], ["Hello world"])
        self.assertEqual(result["word_count"], 5)


class LinkGraphTests(unittest.TestCase):
    def test_analyze_deduplicates_internal_links_and_reports_orphans(self):
        pages = [
            {
                "url": "https://example.com/",
                "depth": 0,
                "title": "Home",
                "links_out": [
                    "https://example.com/a",
                    "https://example.com/a",
                    "https://external.test/",
                ],
            },
            {
                "url": "https://example.com/a",
                "depth": 1,
                "title": "A",
                "links_out": [],
            },
            {
                "url": "https://example.com/orphan",
                "depth": 2,
                "title": "Orphan",
                "links_out": [],
            },
        ]

        result = linkgraph.analyze(pages)

        self.assertEqual(result["summary"]["total_internal_links"], 1)
        self.assertEqual(result["degrees"]["https://example.com/a"]["in"], 1)
        self.assertEqual(result["orphans"], ["https://example.com/orphan"])


class SchemaLintTests(unittest.TestCase):
    def test_lint_html_reports_required_schema_errors(self):
        html = """<script type="application/ld+json">
        {"@context":"https://schema.org","@type":"Article"}
        </script>"""

        result = schema_lint.lint_html(html, source="<test>")

        self.assertEqual(result["summary"]["errors"], 1)
        self.assertEqual(result["objects"][0]["@type"], "Article")
        self.assertEqual(result["objects"][0]["missing_required"], ["headline"])


class RobotsTxtTests(unittest.TestCase):
    def _parse(self, text):
        return robots.RobotsTxt.parse(text, "https://example.com/robots.txt", 200, None)

    def test_longest_match_wins_and_allow_beats_disallow(self):
        r = self._parse("User-agent: *\nDisallow: /admin\nAllow: /admin/public\n")
        # shorter Disallow /admin blocks a path with no longer match
        self.assertFalse(r.can_fetch("mybot", "/admin/secret")[0])
        # longer Allow /admin/public wins over the shorter Disallow
        self.assertTrue(r.can_fetch("mybot", "/admin/public/page")[0])
        # no rule matches -> default-allow
        self.assertTrue(r.can_fetch("mybot", "/blog/post")[0])

    def test_wildcard_and_end_anchor(self):
        r = self._parse("User-agent: *\nDisallow: /*.pdf$\n")
        self.assertFalse(r.can_fetch("mybot", "/files/report.pdf")[0])
        # the $ anchor means a query-suffixed path no longer matches -> allowed
        self.assertTrue(r.can_fetch("mybot", "/files/report.pdf?x=1")[0])


class PsiGradeTests(unittest.TestCase):
    def test_lcp_threshold_boundaries(self):
        self.assertEqual(psi.grade("LCP_ms", 2500.0), "good")            # <= good_max
        self.assertEqual(psi.grade("LCP_ms", 2500.1), "needs-improvement")
        self.assertEqual(psi.grade("LCP_ms", 4000.0), "needs-improvement")  # <= ni_max
        self.assertEqual(psi.grade("LCP_ms", 4000.1), "poor")

    def test_cls_none_and_unknown_metric(self):
        self.assertEqual(psi.grade("CLS", 0.1), "good")
        self.assertEqual(psi.grade("CLS", 0.26), "poor")
        self.assertIsNone(psi.grade("LCP_ms", None))
        self.assertIsNone(psi.grade("not_a_metric", 1.0))


class LedgerTests(unittest.TestCase):
    def test_slugify_normalizes_collapses_and_defaults(self):
        self.assertEqual(ledger.slugify("https://www.Example.com/path/"), "www.example.com-path")
        self.assertEqual(ledger.slugify("HTTP://a//b"), "a-b")
        self.assertEqual(ledger.slugify("   "), "unnamed")

    def test_flatten_dotted_keys_and_list_indices(self):
        flat = ledger.flatten({"a": {"b": 1}, "c": [10, 20]})
        self.assertEqual(flat["a.b"], 1)
        self.assertEqual(flat["c[0]"], 10)
        self.assertEqual(flat["c[1]"], 20)


class OpenPageRankTests(unittest.TestCase):
    def test_normalize_domain(self):
        self.assertEqual(openpagerank.normalize_domain("https://www.Example.com/path"), "www.example.com")
        self.assertEqual(openpagerank.normalize_domain("Example.com/foo"), "example.com")
        self.assertEqual(openpagerank.normalize_domain(""), "")

    def test_parse_response_maps_onto_requested_order(self):
        payload = {"status_code": 200, "response": [
            {"domain": "b.com", "page_rank_decimal": 5.1, "page_rank_integer": 5,
             "rank": "100", "status_code": 200},
        ]}
        rows = openpagerank.parse_response(payload, ["a.com", "b.com"])
        self.assertEqual([r["domain"] for r in rows], ["a.com", "b.com"])
        self.assertFalse(rows[0]["found"])   # a.com absent from response
        self.assertTrue(rows[1]["found"])    # b.com present with status 200
        self.assertEqual(rows[1]["page_rank_decimal"], 5.1)


if __name__ == "__main__":
    unittest.main()
