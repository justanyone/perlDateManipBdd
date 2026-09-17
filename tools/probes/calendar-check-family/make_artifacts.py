#!/usr/bin/env python3
"""Freeze calendar validation features and research mappings."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/calendar-check-family"
FEATURES = ROOT / "spec/drafts/calendar-checks"
manifest = json.loads((FAMILY / "cases.json").read_text())
evidence = json.loads((FAMILY / "observations.json").read_text())
by_id = {row["case_id"]: row["observation"] for row in evidence["observations"]}


def compact(value):
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def clean_diagnostic(value):
    return re.sub(r" at .*? line \d+\.?\n?$", "", value)


def native(call):
    if not call["call_completed"]:
        return "no return"
    if call["return_type"] == "list":
        return "list " + compact(call["return"])
    if call["return_type"] == "undefined":
        return "undefined scalar"
    return "scalar " + compact(call["return"])


def diagnostics(call):
    parts = []
    if call["warnings"]:
        parts.append("warnings " + compact([clean_diagnostic(x) for x in call["warnings"]]))
    if call["exception"]:
        parts.append("exception " + compact(clean_diagnostic(call["exception"].splitlines()[0])))
    return "; ".join(parts) if parts else "none"


rows = []
for case in manifest["cases"]:
    obs = by_id[case["case_id"]]
    scalar, listed = obs["calls"]
    rows.append({
        **case,
        "input_text": compact(case["input"]),
        "fields_text": compact(case["input"].get("fields")),
        "outcome": ("no result because the request fails" if not scalar["call_completed"]
                    else ("valid" if scalar["return"] == 1 else "invalid")),
        "scalar_native": native(scalar),
        "list_native": native(listed),
        "scalar_diagnostic": diagnostics(scalar),
        "list_diagnostic": diagnostics(listed),
        "scalar_error_after": compact(scalar["error_observer"]["after"]),
        "list_error_after": compact(listed["error_observer"]["after"]),
    })


def table(headers, selected):
    lines = ["      | " + " | ".join(headers) + " |"]
    for row in selected:
        values = {
            "case": row["case_id"], "operation": row["operation_id"],
            "fields": row["fields_text"], "input": row["input_text"],
            "outcome": row["outcome"], "reason": row["note"],
            "scalar native": row["scalar_native"], "list native": row["list_native"],
            "scalar diagnostic": row["scalar_diagnostic"],
            "list diagnostic": row["list_diagnostic"],
            "scalar error after": row["scalar_error_after"],
            "list error after": row["list_error_after"],
        }
        lines.append("      | " + " | ".join(str(values[h]) for h in headers) + " |")
    return "\n".join(lines)


documented_time = [r for r in rows if r["operation_id"] == "calendar.validate-time" and r["disposition"] == "documented"]
documented_date = [r for r in rows if r["operation_id"] == "calendar.validate-date" and r["disposition"] == "documented"]
compatibility = [r for r in rows if r["disposition"] == "observed-compatibility"]

FEATURES.mkdir(parents=True, exist_ok=True)
(FEATURES / "time-validation.feature").write_text(f'''@portable @calendar-validation @observed-reference
Feature: Validate civil clock fields
  The request is an ordered hour, minute, second collection.
  Validation is independent of time zone and daylight-saving transitions.

  Background:
    Given the calendar uses the fixed current object profile
    And the calendar zone is "Etc/UTC" with reference clock "2040-02-28 10:20:30"

  Scenario Outline: Classify documented clock values and boundaries
    When I validate civil clock fields <fields>
    Then the calendar.validate-time outcome is <outcome>

    Examples:
{table(["case", "fields", "outcome"], documented_time)}
''')

(FEATURES / "date-validation.feature").write_text(f'''@portable @calendar-validation @observed-reference
Feature: Validate civil date-time fields
  The request is an ordered year, month, day, hour, minute, second collection.
  Validation uses civil Gregorian fields without resolving a time zone.

  Background:
    Given the calendar uses the fixed current object profile
    And the calendar zone is "Etc/UTC" with reference clock "2040-02-28 10:20:30"

  Scenario Outline: Classify documented date-time values and boundaries
    When I validate civil date-time fields <fields>
    Then the calendar.validate-date outcome is <outcome>

    Examples:
{table(["case", "fields", "outcome"], documented_date)}
''')

(FEATURES / "input-shape-compatibility.feature").write_text(f'''@observed-compatibility @disputed @calendar-validation
Feature: Calendar validation input representation compatibility
  These rows preserve public outcomes for representations outside the documented field domain.
  They do not make fractional, whitespace-padded, missing, absent, or extra fields portable valid inputs.

  Background:
    Given the calendar uses the fixed current object profile
    And the calendar zone is "Etc/UTC" with reference clock "2040-02-28 10:20:30"

  Scenario Outline: Retain each observed ordered-field compatibility outcome
    When I perform <operation> with typed input <input>
    Then the observed validation outcome is <outcome>
    But the request remains disputed because it contains <reason>

    Examples:
{table(["case", "operation", "input", "outcome", "reason"], compatibility)}
''')

(FEATURES / "perl-binding.feature").write_text(f'''@source-binding @perl-binding @excluded-from-portable-handoff
Feature: Native Base calendar validation carriers and diagnostics
  These scenarios preserve Perl context, warnings, exceptions, and error-observer reads.
  They are not requirements for another language implementation.

  Background:
    Given Perl loads Date-Manip 7.00 from the pinned local installation
    And each case uses a fresh process and temporary working directory
    And the configured Base error observer is cleared before each native call

  Scenario Outline: Preserve scalar and list context results without inventing returns
    Given the native request for <operation> has typed input <input>
    When Perl invokes the public method once in scalar context and once in list context
    Then the scalar native outcome is <scalar native>
    And the list native outcome is <list native>
    And the scalar diagnostic is <scalar diagnostic>
    And the list diagnostic is <list diagnostic>
    And the public error text after each call is <scalar error after> and <list error after>

    Examples:
{table(["case", "operation", "input", "scalar native", "list native", "scalar diagnostic", "list diagnostic", "scalar error after", "list error after"], rows)}
''')

feature_for = {}
for row in documented_time:
    feature_for[row["case_id"]] = "spec/drafts/calendar-checks/time-validation.feature"
for row in documented_date:
    feature_for[row["case_id"]] = "spec/drafts/calendar-checks/date-validation.feature"
for row in compatibility:
    feature_for[row["case_id"]] = "spec/drafts/calendar-checks/input-shape-compatibility.feature"

case_map = []
for row in rows:
    case_map.append({
        "case_id": row["case_id"], "operation_id": row["operation_id"],
        "profile": row["profile"], "input": row["input"],
        "partition_id": row["partition_id"], "disposition": row["disposition"],
        "portable_feature": feature_for.get(row["case_id"]),
        "binding_feature": "spec/drafts/calendar-checks/perl-binding.feature",
        "observation": "docs/research/calendar-check-family/observations.json",
    })

(FAMILY / "feature-map.json").write_text(json.dumps({
    "schema_version": 1,
    "canonical_operations": ["calendar.validate-time", "calendar.validate-date"],
    "case_map": case_map,
}, indent=2, ensure_ascii=False) + "\n")

(FAMILY / "bindings.json").write_text(json.dumps({
    "schema_version": 1,
    "bindings": [
        {"operation_id": "calendar.validate-time", "module": "Date::Manip::Base", "callable": "check_time", "call_shape": "one ordered time-field array reference", "profile": "oo"},
        {"operation_id": "calendar.validate-date", "module": "Date::Manip::Base", "callable": "check", "call_shape": "one ordered date-time-field array reference", "profile": "oo"},
    ],
    "setup": {"public_calls": ["Date::Manip::Date->new", "Date::Manip::Date->config", "Date::Manip::Date->base"], "fixture": "docs/automation/reference-profiles.json#oo"},
    "metadata": {"version": "Date::Manip::Base->version", "error": "Date::Manip::Base->err"},
    "aliases": [],
}, indent=2) + "\n")

(FAMILY / "coverage-map.json").write_text(json.dumps({
    "schema_version": 1,
    "operation_partitions": [
        {"partition_id": "calendar.validate-time.p1", "status": "observed-partial", "evidence": ["numeric and padded midnight", "23:59:59"]},
        {"partition_id": "calendar.validate-time.p2", "status": "observed-partial", "evidence": ["24:00:00"]},
        {"partition_id": "calendar.validate-time.p3", "status": "observed-partial", "evidence": ["hour 24 remainder", "hour 25", "minute 60", "second 60"]},
        {"partition_id": "calendar.validate-time.p4", "status": "observed-partial", "evidence": ["signed", "fractional", "whitespace", "nonnumeric", "missing", "undefined", "extra fields"]},
        {"partition_id": "calendar.validate-date.p1", "status": "observed-partial", "evidence": ["ordinary date", "leap day"]},
        {"partition_id": "calendar.validate-date.p2", "status": "observed-partial", "evidence": ["years 1 and 9999", "30-day month end", "24:00:00"]},
        {"partition_id": "calendar.validate-date.p3", "status": "observed-partial", "evidence": ["year/month/day lower and upper bounds", "common February 29", "April 31", "invalid clock"]},
        {"partition_id": "calendar.validate-date.p4", "status": "observed-partial", "evidence": ["fractional, whitespace and nonnumeric year", "missing, undefined and extra fields", "malformed scalar carrier"]},
    ],
    "remaining_domains": [
        "Other field positions containing fractional, signed, whitespace-padded, nonnumeric, or undefined values.",
        "Other native carriers such as mappings, nested collections, blessed values, overloads, infinity, NaN, and Unicode numeric text.",
        "Every arity beyond the selected missing and one-extra controls.",
        "Runtime and Date-Manip releases other than the pinned reference.",
    ],
    "measurement_note": 'Public observations exercise valid and invalid results, but Devel::Cover1.52 on Perl5.40.1 recorded zero hits for all6 target branch outcomes while all10 target statements executed. Branch completeness is unproven; investigate tool behavior, do not exclude these branches.',
    "scope_note": "No additional numeric civil branch is known from the reviewed 7.00 implementation; remaining items are representation and binding cross-products.",
}, indent=2) + "\n")
print(f"wrote features and maps for {len(rows)} cases")
