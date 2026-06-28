#!/usr/bin/env python3
"""Golden math check for the auditor scoring frameworks — Python 3 stdlib only.

The auditor *scores* are computed by an LLM reading the runbook, but the
arithmetic those scores depend on is fully deterministic and therefore testable.
This guards the two regression classes that have actually bitten this repo:

  1. A weight table column that no longer sums to 100% (or the CITE weights that
     no longer sum to 1.0) — a silent scoring bug.
  2. A worked example whose stated raw_overall no longer matches the weighted
     arithmetic of its own inputs — i.e. someone edited the numbers wrong, or a
     release-bump corrupted them.

Run: python3 scripts/golden-auditor-math.py   (exit 0 = pass, 1 = fail)
Wired into CI alongside validate-skill.sh.
"""
from __future__ import annotations

import math
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CORE = os.path.join(ROOT, "references", "core-eeat-benchmark.md")
CITE = os.path.join(ROOT, "references", "cite-domain-rating.md")
CQA = os.path.join(ROOT, "cross-cutting", "content-quality-auditor", "SKILL.md")
DAA = os.path.join(ROOT, "cross-cutting", "domain-authority-auditor", "SKILL.md")

fails = []
def check(cond, msg):
    print(("  ok  " if cond else "FAIL  ") + msg)
    if not cond:
        fails.append(msg)


def parse_core_weight_table(path):
    """Return {content_type: {dim: weight_fraction}} from the §Content-Type Weight Table."""
    text = open(path, encoding="utf-8").read()
    lines = text.splitlines()
    # find the header row that names the content types
    hdr_i = next((i for i, l in enumerate(lines)
                  if l.startswith("| Dim ") and "Product Review" in l), None)
    if hdr_i is None:
        return {}
    cols = [c.strip() for c in lines[hdr_i].strip("|").split("|")][1:]  # drop 'Dim'
    table = {c: {} for c in cols}
    for l in lines[hdr_i + 2:]:                # skip the |---| separator
        if not l.startswith("|"):
            break
        cells = [c.strip() for c in l.strip("|").split("|")]
        dim = cells[0]
        for c, val in zip(cols, cells[1:]):
            m = re.match(r"(\d+)%", val)
            if m:
                table[c][dim] = int(m.group(1)) / 100.0
    return table


def weighted(dims, weights):
    return math.floor(sum(dims[d] * weights[d] for d in dims))


print("== CORE-EEAT weight table: every content-type column sums to 100% ==")
core = parse_core_weight_table(CORE)
check(len(core) == 9, "parsed 9 content-type columns (got %d)" % len(core))
for ctype, w in core.items():
    total = round(sum(w.values()) * 100)
    check(total == 100 and len(w) == 8, "%s: 8 dims summing to 100%% (got %d dims, %d%%)" % (ctype, len(w), total))

print("== CORE-EEAT worked examples recompute to their stated raw_overall ==")
# Example 1 — Product Review (from content-quality-auditor §2)
ex1 = {"C": 75, "O": 77, "R": 80, "E": 75, "Exp": 78, "Ept": 77, "A": 77, "T": 85}
if "Product Review" in core:
    check(weighted(ex1, core["Product Review"]) == 78,
          "CORE ex1 (Product Review) weighted == 78 (got %d)" % weighted(ex1, core["Product Review"]))
# Example 2 — FAQ Page
ex2 = {"C": 55, "O": 75, "R": 88, "E": 80, "Exp": 80, "Ept": 75, "A": 82, "T": 85}
if "FAQ Page" in core:
    check(weighted(ex2, core["FAQ Page"]) == 73,
          "CORE ex2 (FAQ Page) weighted == 73 (got %d)" % weighted(ex2, core["FAQ Page"]))

print("== CITE default weights sum to 1.0 and worked examples recompute ==")
cite_text = open(CITE, encoding="utf-8").read()
m = re.search(r"C\s*×\s*([\d.]+)\s*\+\s*I\s*×\s*([\d.]+)\s*\+\s*T\s*×\s*([\d.]+)\s*\+\s*E\s*×\s*([\d.]+)", cite_text)
check(m is not None, "found CITE default-weight formula")
if m:
    wC, wI, wT, wE = (float(x) for x in m.groups())
    check(abs((wC + wI + wT + wE) - 1.0) < 1e-9, "CITE weights sum to 1.0 (got %.2f)" % (wC + wI + wT + wE))
    cw = {"C": wC, "I": wI, "T": wT, "E": wE}
    c1 = weighted({"C": 80, "I": 70, "T": 85, "E": 75}, cw)
    check(c1 == 78, "CITE ex1 (C80 I70 T85 E75) weighted == 78 (got %d)" % c1)
    c2 = weighted({"C": 55, "I": 70, "T": 58, "E": 72}, cw)
    check(c2 == 62, "CITE ex2 (C55 I70 T58 E72) weighted == 62 (got %d)" % c2)

print("== the worked-example INPUTS and stated results still appear in the auditor bodies ==")
cqa, daa = open(CQA, encoding="utf-8").read(), open(DAA, encoding="utf-8").read()
# Input-vector presence closes the false-pass gap: if a SKILL example's dimension
# numbers drift away from what this test recomputes, the test must notice.
check("C=75 O=77 R=80 E=75 Exp=78 Ept=77 A=77 T=85" in cqa, "CORE ex1 input vector present in content-quality-auditor")
check("C=55 O=75 R=88 E=80 Exp=80 Ept=75 A=82 T=85" in cqa, "CORE ex2 input vector present in content-quality-auditor")
check("C=80 I=70 T=85 E=75" in daa, "CITE ex1 input vector present in domain-authority-auditor")
check("C=55 I=70 T=58 E=72" in daa, "CITE ex2 input vector present in domain-authority-auditor")
check("raw_overall = 78" in cqa and "raw_overall = 73" in cqa, "CORE stated results 78 & 73 present in content-quality-auditor")
check("raw_overall = 78" in daa and "raw_overall = 62" in daa, "CITE stated results 78 & 62 present in domain-authority-auditor")
# guard against the old framework-crossed defect re-appearing
check("624 / 8" not in daa and "O=77" not in daa, "no CORE-EEAT 8-dim arithmetic leaked into the CITE auditor")

print()
if fails:
    print("GOLDEN MATH FAILED — %d check(s):" % len(fails))
    for f in fails:
        print("  - " + f)
    sys.exit(1)
print("All auditor golden-math checks passed.")
sys.exit(0)
