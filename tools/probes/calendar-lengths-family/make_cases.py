#!/usr/bin/env python3
"""Build the original bounded request manifest for calendar-length observations."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / "docs/research/calendar-lengths-family/cases.json"

routes = ("base", "dm6", "dm5")
cases = []


def add(case_id, route, operation_id, arguments, partition, context="scalar",
        yytoyyyy=None, portable=True, note=None):
    row = {
        "case_id": case_id,
        "route": route,
        "profile": "oo" if route == "base" else route,
        "operation_id": operation_id,
        "arguments": arguments,
        "return_context": context,
        "partition": partition,
        "portable_behavior": portable,
    }
    if yytoyyyy is not None:
        row["yytoyyyy"] = yytoyyyy
    if note:
        row["note"] = note
    cases.append(row)


for route in routes:
    tag = route.upper()
    for year, year_class in ((2039, "common"), (2040, "leap")):
        for month in range(1, 13):
            args = [year, month] if route == "base" else [month, year]
            add(f"CL-{tag}-M-{year}-{month:02d}", route,
                "calendar.days-in-month", args,
                f"all-months-{year_class}")

    for year, label in ((1900, "century-common"), (2000, "century-leap"),
                        (2039, "ordinary-common"), (2040, "ordinary-leap"),
                        (2100, "century-common")):
        add(f"CL-{tag}-Y-{year}", route, "calendar.days-in-year", [year],
            label)

    # Month zero is documented as a Base list form. Functional results and
    # every scalar-context collapse are retained only as binding evidence.
    for year in (2039, 2040):
        args = [year, 0] if route == "base" else [0, year]
        add(f"CL-{tag}-M0-{year}-LIST", route, "calendar.days-in-month",
            args, "month-zero-list", context="list", portable=(route == "base"))
        add(f"CL-{tag}-M0-{year}-SCALAR", route, "calendar.days-in-month",
            args, "month-zero-scalar", context="scalar", portable=False)

    # 00 distinguishes direct arithmetic (Base/DM6) from DM5 short-year
    # expansion: default and C20 select 2000, while C19 selects 1900.
    for setting, label in ((None, "default"), ("C19", "c19"), ("C20", "c20")):
        suffix = label.upper()
        month_args = ["00", 2] if route == "base" else [2, "00"]
        add(f"CL-{tag}-SHORT-M-{suffix}", route, "calendar.days-in-month",
            month_args, "short-year", yytoyyyy=setting,
            portable=(route == "dm5"), note="two-digit text year 00")
        add(f"CL-{tag}-SHORT-Y-{suffix}", route, "calendar.days-in-year",
            ["00"], "short-year", yytoyyyy=setting,
            portable=(route == "dm5"), note="two-digit text year 00")

    def margs(year, month):
        return [year, month] if route == "base" else [month, year]

    invalid_months = (
        ("OMITTED", [], "all arguments omitted"),
        ("UNDEFINED", margs(2040, None), "month explicitly undefined"),
        ("TEXT", margs(2040, "x"), "month is nonnumeric text"),
        ("FRACTION", margs(2040, 2.5), "month is fractional"),
        ("NEGATIVE", margs(2040, -1), "month is below range"),
        ("HIGH", margs(2040, 13), "month is above range"),
    )
    for suffix, args, note in invalid_months:
        add(f"CL-{tag}-INVALID-M-{suffix}", route, "calendar.days-in-month",
            args, "invalid-month", portable=False, note=note)

    invalid_month_years = (
        ("YEAR-OMITTED", [2040] if route == "base" else [2], "year omitted from month request"),
        ("YEAR-UNDEFINED", margs(None, 2), "year explicitly undefined"),
        ("YEAR-TEXT", margs("x", 2), "year is nonnumeric text"),
        ("YEAR-NEGATIVE", margs(-1, 2), "year is negative"),
        ("YEAR-HIGH", margs(10000, 2), "year is outside four digits"),
    )
    for suffix, args, note in invalid_month_years:
        add(f"CL-{tag}-INVALID-M-{suffix}", route, "calendar.days-in-month",
            args, "invalid-year-for-month", portable=False, note=note)

    invalid_years = (
        ("OMITTED", [], "year omitted"),
        ("UNDEFINED", [None], "year explicitly undefined"),
        ("TEXT", ["x"], "year is nonnumeric text"),
        ("FRACTION", [2040.5], "year is fractional"),
        ("ZERO", [0], "year is zero"),
        ("NEGATIVE", [-1], "year is negative"),
        ("HIGH", [10000], "year is outside four digits"),
    )
    for suffix, args, note in invalid_years:
        add(f"CL-{tag}-INVALID-Y-{suffix}", route, "calendar.days-in-year",
            args, "invalid-year", portable=False, note=note)

manifest = {
    "schema_version": 1,
    "purpose": "Original public calendar month/year length requests for Date-Manip 7.00.",
    "canonical_operations": ["calendar.days-in-month", "calendar.days-in-year"],
    "cases": cases,
}
OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
print(f"wrote {len(cases)} cases to {OUT}")
