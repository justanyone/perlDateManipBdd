#!/usr/bin/env python3
"""Freeze original Gherkin and research mappings from reviewed observations."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/calendar-lengths-family"
FEATURES = ROOT / "spec/drafts/calendar-lengths"
manifest = json.loads((FAMILY / "cases.json").read_text())
evidence = json.loads((FAMILY / "observations.json").read_text())
by_id = {r["case_id"]: r["observation"] for r in evidence["observations"]}


def compact(value):
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def generic_result(call):
    if not call["call_completed"]:
        return "no result because the request fails"
    value = call["return"]
    if call["return_type"] == "undefined":
        return "an absent value"
    if call["return_type"] == "list":
        return "ordered numbers " + compact(value)
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        return "number " + str(value)
    return "text " + compact(value)


def native_result(call):
    if not call["call_completed"]:
        return "no return because the call raises an exception"
    if call["return_type"] == "undefined":
        return "undefined scalar"
    if call["return_type"] == "list":
        return "list " + compact(call["return"])
    return "scalar " + compact(call["return"])


def clean_warning(value):
    return re.sub(r" at .*? line \d+\.?\n?$", "", value)


def diagnostic(call):
    if call["exception"] is not None:
        return "exception " + compact(call["exception"].splitlines()[0])
    if not call["warnings"]:
        return "no warning or exception"
    return "warnings " + compact([clean_warning(w) for w in call["warnings"]])


profile_name = {
    "base": "current calendar arithmetic profile",
    "dm6": "current functional profile",
    "dm5": "legacy functional profile",
}

rows = []
for case in manifest["cases"]:
    obs = by_id[case["case_id"]]
    rows.append({
        **case,
        "profile_label": profile_name[case["route"]],
        "arguments_text": compact(case["arguments"]),
        "configuration_label": case.get("yytoyyyy", "pinned default"),
        "generic_result": generic_result(obs["call"]),
        "native_result": native_result(obs["call"]),
        "diagnostic": diagnostic(obs["call"]),
        "observer_action": ("cleared and read before and after" if case["route"] == "base"
                            else "not called because the facade exposes none"),
        "error_before": compact(obs["call"]["error_observer"].get("before")),
        "error_after": compact(obs["call"]["error_observer"].get("after")),
    })

normal_month = [r for r in rows if r["partition"].startswith("all-months-")]
normal_year = [r for r in rows if r["partition"] in {
    "century-common", "century-leap", "ordinary-common", "ordinary-leap"}]
documented_list = [r for r in rows if r["route"] == "base" and
                   r["partition"] == "month-zero-list"]
legacy_short = [r for r in rows if r["route"] == "dm5" and
                r["partition"] == "short-year"]
primary = {r["case_id"] for r in normal_month + normal_year + documented_list + legacy_short}
compatibility = [r for r in rows if r["case_id"] not in primary]


def table(headers, selected):
    out = ["      | " + " | ".join(headers) + " |"]
    for row in selected:
        def field(key):
            if key == "case": return row["case_id"]
            if key == "profile": return row["profile_label"]
            if key == "year":
                if row["operation_id"] == "calendar.days-in-year": return row["arguments"][0]
                return row["arguments"][0] if row["route"] == "base" else row["arguments"][1]
            if key == "month": return row["arguments"][1] if row["route"] == "base" else row["arguments"][0]
            values = {
                "arguments": row["arguments_text"], "result": row["generic_result"],
                "configuration": row["configuration_label"],
                "operation": row["operation_id"], "partition": row["partition"],
                "context": row["return_context"], "native result": row["native_result"],
                "diagnostic": row["diagnostic"], "error before": row["error_before"],
                "error after": row["error_after"], "route": row["route"],
                "observer action": row["observer_action"],
            }
            return values[key]
        values = []
        for key in headers:
            values.append(str(field(key)))
        out.append("      | " + " | ".join(values) + " |")
    return "\n".join(out)


FEATURES.mkdir(parents=True, exist_ok=True)
(FEATURES / "month-lengths.feature").write_text(f'''@portable @calendar-lengths @observed-reference
Feature: Length of each Gregorian month
  Each row is one concrete calendar.days-in-month request with a numeric year and month.
  The profile names describe portable behavioral profiles; research mappings bind them to source calls.

  Background:
    Given the calendar zone is "Etc/UTC" and the reference clock is "2040-02-28 10:20:30"
    And the calendar uses the proleptic Gregorian leap-year rule

  Scenario Outline: Report every month in representative common and leap years
    Given I use the <profile>
    When I request the length of month <month> in year <year>
    Then the calendar.days-in-month result is <result>

    Examples:
{table(["case", "profile", "year", "month", "result"], normal_month)}
''')

(FEATURES / "year-lengths.feature").write_text(f'''@portable @calendar-lengths @observed-reference
Feature: Length of Gregorian years
  Century controls distinguish divisibility by 100 from divisibility by 400.

  Background:
    Given the calendar zone is "Etc/UTC" and the reference clock is "2040-02-28 10:20:30"
    And the calendar uses the proleptic Gregorian leap-year rule

  Scenario Outline: Report ordinary and century year lengths
    Given I use the <profile>
    When I request the length of year <year>
    Then the calendar.days-in-year result is <result>

    Examples:
{table(["case", "profile", "year", "result"], normal_year)}
''')

(FEATURES / "all-months-and-short-years.feature").write_text(f'''@portable @calendar-lengths @observed-reference
Feature: Ordered month lengths and configured legacy short years
  An all-month request returns January through December in order.
  A legacy short-year configuration selects the hundred-year window before Gregorian classification.

  Background:
    Given the calendar zone is "Etc/UTC" and the reference clock is "2040-02-28 10:20:30"
    And the calendar uses the proleptic Gregorian leap-year rule

  Scenario Outline: Return all month lengths in calendar order
    Given I use the <profile>
    When I request all month lengths for year <year>
    Then the calendar.days-in-month result is <result>

    Examples:
{table(["case", "profile", "year", "result"], documented_list)}

  Scenario Outline: Apply the configured legacy short-year window
    Given I use the <profile> with short-year setting <configuration>
    When I perform <operation> with arguments <arguments>
    Then the result is <result>

    Examples:
{table(["case", "profile", "configuration", "operation", "arguments", "result"], legacy_short)}
''')

(FEATURES / "observed-compatibility.feature").write_text(f'''@observed-compatibility @calendar-lengths @disputed-invalid-inputs
Feature: Calendar length compatibility outside the portable valid domain
  These rows retain every observed public result for undocumented carriers, short-year handling,
  and invalid values. They do not define those values as valid calendar requests.

  Background:
    Given the calendar zone is "Etc/UTC" and the reference clock is "2040-02-28 10:20:30"

  Scenario Outline: Retain the generic public outcome of each compatibility request
    Given I use the <profile> with short-year setting <configuration>
    When I perform <operation> with arguments <arguments>
    Then the observed public result is <result>
    But partition <partition> remains outside the portable valid calendar domain

    Examples:
{table(["case", "profile", "configuration", "operation", "arguments", "result", "partition"], compatibility)}
''')

(FEATURES / "perl-binding.feature").write_text(f'''@source-binding @perl-binding @excluded-from-portable-handoff
Feature: Perl carriers and diagnostics for calendar length calls
  These rows preserve Perl calling context, warnings, exceptions, and the Base error observer.
  They are source-binding evidence and are not requirements for another implementation.

  Background:
    Given the Perl process uses Date-Manip 7.00 with PATH "/usr/bin:/bin"
    And each request runs in a fresh process and temporary working directory

  Scenario Outline: Preserve setup returns and module-load diagnostics
    When Perl loads and configures binding route <setup route>
    Then the configuration return is <setup return>
    And the module-load diagnostic is <load diagnostic>

    Examples:
      | setup route | setup return | load diagnostic |
      | base | undefined scalar | no warning |
      | dm6 | empty text | no warning |
      | dm5 | undefined scalar | warning "Date::Manip::DM5 is deprecated and will be removed from the Date::Manip package starting in version 7.00" |

  Scenario Outline: Preserve the native outcome and diagnostic channels
    Given binding route <route> receives arguments <arguments>
    When Perl invokes <operation> in <context> context
    Then its native outcome is <native result>
    And its call diagnostic is <diagnostic>
    And the public error observer is <observer action>

    Examples:
{table(["case", "route", "operation", "arguments", "context", "native result", "diagnostic", "observer action"], rows)}

  Scenario Outline: Preserve the Base error clear and read sequence
    Given binding route base receives the request identified by <case>
    When the inherited public error observer is cleared before the request
    Then it reads <error before> before and <error after> after the request

    Examples:
{table(["case", "error before", "error after"], [row for row in rows if row["route"] == "base"])}
''')

case_map = []
for row in rows:
    if row["case_id"] in {r["case_id"] for r in normal_month}:
        feature = "spec/drafts/calendar-lengths/month-lengths.feature"
    elif row["case_id"] in {r["case_id"] for r in normal_year}:
        feature = "spec/drafts/calendar-lengths/year-lengths.feature"
    elif row["case_id"] in {r["case_id"] for r in documented_list + legacy_short}:
        feature = "spec/drafts/calendar-lengths/all-months-and-short-years.feature"
    else:
        feature = "spec/drafts/calendar-lengths/observed-compatibility.feature"
    case_map.append({
        "case_id": row["case_id"], "operation_id": row["operation_id"],
        "profile": row["profile"], "route": row["route"],
        "arguments": row["arguments"], "return_context": row["return_context"],
        "partition": row["partition"], "feature": feature,
        "binding_feature": "spec/drafts/calendar-lengths/perl-binding.feature",
        "observation": "docs/research/calendar-lengths-family/observations.json",
    })

feature_map = {
    "schema_version": 1,
    "canonical_operations": ["calendar.days-in-month", "calendar.days-in-year"],
    "source_binding": {
        "calendar.days-in-month": [
            "Date::Manip::Base->days_in_month(year,month)",
            "Date::Manip::DM6::Date_DaysInMonth(month,year)",
            "Date::Manip::DM5::Date_DaysInMonth(month,year)",
        ],
        "calendar.days-in-year": [
            "Date::Manip::Base->days_in_year(year)",
            "Date::Manip::DM6::Date_DaysInYear(year)",
            "Date::Manip::DM5::Date_DaysInYear(year)",
        ],
    },
    "aliases": [],
    "case_map": case_map,
    "remaining_domains": [
        "Other proleptic years beyond the selected ordinary and century controls.",
        "Numeric YYtoYYYY windows and C or C#### spellings beyond C19 and C20.",
        "Reference values, arrays, hashes, overloaded values, infinities, and NaN in Perl binding calls.",
        "Runtime versions and Date-Manip releases other than the pinned observations.",
    ],
}
(FAMILY / "feature-map.json").write_text(json.dumps(feature_map, indent=2, ensure_ascii=False) + "\n")

bindings = {
    "schema_version": 1,
    "operations": [
        {
            "operation_id": "calendar.days-in-month",
            "bindings": [
                {"route": "base", "module": "Date::Manip::Base", "callable": "days_in_month", "arguments": ["year", "month"], "carrier": "scalar for one month; list for documented month zero"},
                {"route": "dm6", "module": "Date::Manip::DM6", "callable": "Date_DaysInMonth", "arguments": ["month", "year"], "carrier": "Perl scalar or list context recorded per case"},
                {"route": "dm5", "module": "Date::Manip::DM5", "callable": "Date_DaysInMonth", "arguments": ["month", "year"], "carrier": "Perl scalar or list context recorded per case"},
            ],
        },
        {
            "operation_id": "calendar.days-in-year",
            "bindings": [
                {"route": "base", "module": "Date::Manip::Base", "callable": "days_in_year", "arguments": ["year"], "carrier": "scalar"},
                {"route": "dm6", "module": "Date::Manip::DM6", "callable": "Date_DaysInYear", "arguments": ["year"], "carrier": "scalar"},
                {"route": "dm5", "module": "Date::Manip::DM5", "callable": "Date_DaysInYear", "arguments": ["year"], "carrier": "scalar"},
            ],
        },
    ],
    "aliases": [],
    "setup": {
        "base": "Date::Manip::Date->new; configure pinned oo profile; obtain public base receiver",
        "dm6": "Date::Manip::DM6::Date_Init with pinned dm6 profile",
        "dm5": "Date::Manip::DM5::Date_Init with pinned dm5 profile",
    },
    "metadata_operations": {
        "base": "Date::Manip::Base->version and inherited err",
        "dm6": "Date::Manip::DM6::DateManipVersion",
        "dm5": "Date::Manip::DM5::DateManipVersion",
    },
}
(FAMILY / "bindings.json").write_text(json.dumps(bindings, indent=2) + "\n")
print(f"wrote five features and mappings for {len(rows)} requests")
