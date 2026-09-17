#!/usr/bin/env python3
"""Generate the bounded p4/p5 public week-number request manifest."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / "docs/research/week-rules-edges/cases.json"
cases = []


def add(case_id, partition, profile, family, classification, configuration, request):
    cases.append({"case_id": case_id, "operation_id": "calendar.week-number",
                  "partition_id": partition, "profile": profile, "family": family,
                  "classification": classification, "configuration": configuration,
                  "request": request})


default = {"first_day": 1, "week1_of_year": "jan4"}
for label, year, week, classification in [
    ("WEEK-0", 2040, 0, "observed-compatibility"),
    ("WEEK-NEG1", 2040, -1, "observed-compatibility"),
    ("WEEK-52", 2040, 52, "documented"),
    ("WEEK-53", 2040, 53, "observed-compatibility"),
    ("WEEK-54", 2040, 54, "observed-compatibility"),
    ("WEEK-UNDEFINED", 2040, None, "observed-compatibility"),
    ("WEEK-TEXT", 2040, "two", "observed-compatibility"),
    ("YEAR-UNDEFINED", None, 1, "observed-compatibility"),
    ("YEAR-NEG1", -1, 1, "observed-compatibility"),
    ("YEAR-0", 0, 1, "observed-compatibility"),
    ("YEAR-1", 1, 1, "documented-boundary"),
    ("YEAR-9999", 9999, 1, "documented-boundary"),
    ("YEAR-10000", 10000, 1, "observed-compatibility"),
    ("YEAR-TEXT", "year", 1, "observed-compatibility"),
]:
    add("WRE-BASE-INVERSE-" + label, "calendar.week-number.p4", "base",
        "base-call", classification, default,
        {"shape": "inverse", "method_arguments": [year, week]})

forward = [
    ("DATE-VALID", "date-list", [2040, 1, 1], "documented-control"),
    ("DATE-EMPTY", "date-list", [], "observed-compatibility"),
    ("DATE-YEAR", "date-list", [2040], "observed-compatibility"),
    ("DATE-YEAR-MONTH", "date-list", [2040, 1], "observed-compatibility"),
    ("DATE-EXTRA", "date-list", [2040, 1, 1, 12], "observed-compatibility"),
    ("DATE-MONTH-0", "date-list", [2040, 0, 1], "observed-compatibility"),
    ("DATE-MONTH-13", "date-list", [2040, 13, 1], "observed-compatibility"),
    ("DATE-DAY-0", "date-list", [2040, 1, 0], "observed-compatibility"),
    ("DATE-DAY-32", "date-list", [2040, 1, 32], "observed-compatibility"),
    ("DATE-FEB-30", "date-list", [2040, 2, 30], "observed-compatibility"),
    ("DATE-YEAR-NEG1", "date-list", [-1, 1, 1], "observed-compatibility"),
    ("DATE-YEAR-0", "date-list", [0, 1, 1], "observed-compatibility"),
    ("DATE-YEAR-1", "date-list", [1, 1, 1], "documented-boundary"),
    ("DATE-YEAR-9999", "date-list", [9999, 1, 1], "documented-boundary"),
    ("DATE-YEAR-10000", "date-list", [10000, 1, 1], "observed-compatibility"),
    ("DATE-TEXT-YEAR", "date-list", ["year", 1, 1], "observed-compatibility"),
    ("DATE-TEXT-MONTH", "date-list", [2040, "month", 1], "observed-compatibility"),
    ("DATE-TEXT-DAY", "date-list", [2040, 1, "day"], "observed-compatibility"),
    ("ARG-UNDEFINED", "undefined", None, "binding-failure"),
    ("ARG-TEXT", "text", "2040-01-01", "binding-failure"),
    ("ARG-HASH", "hash", {"year": 2040, "month": 1, "day": 1}, "binding-failure"),
]
for label, carrier, value, classification in forward:
    request = {"shape": "forward", "argument_carrier": carrier}
    if carrier != "undefined": request["argument_value"] = value
    add("WRE-BASE-FORWARD-" + label, "calendar.week-number.p4", "base",
        "base-call", classification, default, request)
for label, args in [("NO-ARGUMENTS", []), ("ONE-SCALAR", [2040]),
                    ("THREE-SCALARS", [2040, 1, 1]),
                    ("FOUR-SCALARS", [2040, 1, 1, 12])]:
    add("WRE-BASE-ARITY-" + label, "calendar.week-number.p4", "base",
        "base-call", "binding-failure", default,
        {"shape": "raw-arguments", "method_arguments": args})

config_requests = [
    ("FIRSTDAY-0", "FirstDay", "value", 0, "invalid"),
    ("FIRSTDAY-8", "FirstDay", "value", 8, "invalid"),
    ("FIRSTDAY-NEG1", "FirstDay", "value", -1, "invalid"),
    ("FIRSTDAY-EMPTY", "FirstDay", "value", "", "invalid"),
    ("FIRSTDAY-UNDEFINED", "FirstDay", "undefined", None, "invalid"),
    ("FIRSTDAY-MISSING", "FirstDay", "missing", None, "invalid"),
    ("FIRSTDAY-NAME", "FirstDay", "value", "Monday", "invalid"),
    ("FIRSTDAY-FRACTION", "FirstDay", "value", 1.5, "invalid"),
    ("WEEKRULE-JAN0", "Week1ofYear", "value", "jan0", "invalid"),
    ("WEEKRULE-JAN8", "Week1ofYear", "value", "jan8", "invalid"),
    ("WEEKRULE-DOW0", "Week1ofYear", "value", "dow0", "invalid"),
    ("WEEKRULE-DOW8", "Week1ofYear", "value", "dow8", "invalid"),
    ("WEEKRULE-EMPTY", "Week1ofYear", "value", "", "invalid"),
    ("WEEKRULE-UNDEFINED", "Week1ofYear", "undefined", None, "invalid"),
    ("WEEKRULE-MISSING", "Week1ofYear", "missing", None, "invalid"),
    ("WEEKRULE-FIRST-DAY", "Week1ofYear", "value", "first-day", "invalid"),
    ("WEEKRULE-UPPERCASE", "Week1ofYear", "value", "JAN4", "valid-control"),
]
for label, setting, shape, value, validity in config_requests:
    request = {"shape": "configuration", "setting": setting,
               "value_shape": shape, "expected_domain": validity}
    if shape == "value": request["value"] = value
    add("WRE-BASE-CONFIG-" + label, "calendar.week-number.p4", "base",
        "base-config", "documented" if validity == "valid-control" else "observed-compatibility",
        default, request)

overrides = [("OMITTED", "omitted", None), ("UNDEFINED", "undefined", None)]
overrides += [(str(day), "value", day) for day in range(1, 8)]
overrides += [("0", "value", 0), ("8", "value", 8), ("NEG1", "value", -1),
              ("EMPTY", "value", ""), ("NAME", "value", "Monday"),
              ("FRACTION", "value", 1.5)]
for profile in ("oo", "dm6", "dm5"):
    for rule in ("jan4", "jan1"):
        for first_day in (1, 7):
            config = {"first_day": first_day, "week1_of_year": rule}
            for label, shape, value in overrides:
                request = {"shape": "legacy-number", "civil_date": [2040, 1, 1],
                           "override_shape": shape}
                if shape == "value": request["first_weekday"] = value
                classification = ("documented" if shape == "value" and isinstance(value, int) and value in range(1, 8)
                                  else "observed-compatibility")
                add(f"WRE-{profile.upper()}-{rule.upper()}-F{first_day}-{label}",
                    "calendar.week-number.p5", profile, "facade-call",
                    classification, config, request)

document = {"schema_version": 2,
            "status": "bounded p4/p5 public request manifest; no expected results",
            "reference": "Date-Manip 7.00", "operation_id": "calendar.week-number",
            "scope": {"base": "inverse invalid/missing values, malformed forward carriers and fields, year limits, and invalid rule settings",
                      "facades": "Date, DM6, and DM5 across jan4/jan1 and configured first weekdays 1/7, with omission, explicit undefined, overrides 1..7, and malformed overrides"},
            "cases": cases}
OUT.write_text(json.dumps(document, indent=2, sort_keys=True, ensure_ascii=False) + "\n")
print(f"wrote {len(cases)} cases to {OUT.relative_to(ROOT)}")
