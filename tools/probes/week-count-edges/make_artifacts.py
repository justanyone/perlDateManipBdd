#!/usr/bin/env python3
"""Render original week-count edge features and exact research mappings."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/week-count-edges"
FEATURES = ROOT / "spec/drafts/week-count-edges"
manifest = json.loads((FAMILY / "cases.json").read_text())
evidence = json.loads((FAMILY / "observations.json").read_text())
by_id = {row["case_id"]: row for row in evidence["observations"]}


def compact(value):
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def clean(value):
    return re.sub(r" at .*? line \d+\.?\n?$", "", value)


def native(call):
    if call is None:
        return "not called"
    if not call["call_completed"]:
        assert "return" not in call and "return_type" not in call
        return "no return because the call raises an exception"
    value = call["return"]
    return_type = call["return_type"]
    if return_type == "undefined":
        assert value is None
        return "completed with undefined scalar"
    if return_type == "ARRAY":
        assert isinstance(value, list)
        return "list " + compact(value)
    assert return_type == "scalar" and not isinstance(value, (dict, list))
    return "scalar " + compact(value)


def diagnostic(call):
    if call is None:
        return "not called"
    parts = []
    if call["warnings"]:
        parts.append("warnings " + compact([clean(w) for w in call["warnings"]]))
    if call["exception"]:
        parts.append("exception " + compact(clean(call["exception"].splitlines()[0])))
    return "; ".join(parts) if parts else "none"


single_rows = []
state_rows = []
binding_rows = []
def portable_step(step):
    if step["operation"] == "weeks_in_year":
        return {"request": "count configured weeks", "typed arguments": step["arguments"]}
    setting, value = step["arguments"]
    return {"request": ("set first weekday" if setting == "FirstDay" else "set week-one rule"),
            "value": value}


for case in manifest["cases"]:
    obs = by_id[case["case_id"]]
    count_trace = [step["scalar"]["return"] for step in obs["steps"]
                   if step["request"]["operation"] == "weeks_in_year"]
    config_requests = [portable_step(step["request"]) for step in obs["steps"]
                       if step["request"]["operation"] == "config"]
    if len(case["steps"]) == 1:
        single_rows.append({"case": case["case_id"],
                            "arguments": compact(case["steps"][0]["arguments"]),
                            "count": count_trace[0]})
    else:
        configuration_outcomes = []
        for step in obs["steps"]:
            if step["request"]["operation"] == "config":
                configuration_outcomes.append(
                    "rejected" if step["scalar"]["warnings"] else "accepted"
                )
        state_rows.append({"case": case["case_id"],
                           "sequence": compact([portable_step(step) for step in case["steps"]]),
                           "count trace": compact(count_trace),
                           "configuration requests": compact(config_requests),
                           "configuration outcome trace": compact(configuration_outcomes)})
    for index, step in enumerate(obs["steps"], 1):
        binding_rows.append({
            "binding step": f"{case['case_id']}-S{index:02d}",
            "case": case["case_id"], "step": index,
            "operation": step["request"]["operation"],
            "arguments": compact(step["request"]["arguments"]),
            "scalar outcome": native(step["scalar"]),
            "repeated outcome": native(step.get("repeated_scalar")),
            "list outcome": native(step.get("list")),
            "scalar diagnostic": diagnostic(step["scalar"]),
            "repeated diagnostic": diagnostic(step.get("repeated_scalar")),
            "list diagnostic": diagnostic(step.get("list")),
            "error before": compact(step["error_before"]),
            "error after": compact(step["error_after"]),
        })


def table(headers, rows):
    lines = ["      | " + " | ".join(headers) + " |"]
    for row in rows:
        lines.append("      | " + " | ".join(str(row[h]) for h in headers) + " |")
    return "\n".join(lines)


endpoints = [row for row in single_rows if row["case"] in {"WCE-YEAR1", "WCE-YEAR9999"}]
compatibility = [row for row in single_rows if row not in endpoints]

FEATURES.mkdir(parents=True, exist_ok=True)
(FEATURES / "endpoint-years.feature").write_text(f'''@portable @week-count @observed-reference
Feature: Configured week counts at supported year endpoints
  Week one contains January 4 and weeks begin on Monday.
  The count is a civil Gregorian result and does not depend on a reference clock.

  Scenario Outline: Count weeks at a supported endpoint year
    When I request calendar.weeks-in-year with typed arguments <arguments>
    Then the configured week count is <count>

    Examples:
{table(["case", "arguments", "count"], endpoints)}
''')

(FEATURES / "year-input-compatibility.feature").write_text(f'''@observed-compatibility @disputed @week-count
Feature: Week-count behavior outside the supported year domain
  These requests retain selected public outcomes without making their inputs valid years.
  Week one contains January 4 and weeks begin on Monday.

  Scenario Outline: Retain a selected unsupported year-input outcome
    When I request calendar.weeks-in-year with typed arguments <arguments>
    Then the observed configured week count is <count>
    But the input remains outside the portable supported-year domain

    Examples:
{table(["case", "arguments", "count"], compatibility)}
''')

(FEATURES / "configuration-state.feature").write_text(f'''@portable @observed-reference @week-count @configuration-state
Feature: Week-count state after configuration changes
  Every row gives the complete ordered public request sequence.
  The initial calendar profile starts weeks on Monday and puts January 4 in week one.
  These requests have no reference-clock input.

  Scenario Outline: Preserve counts across a reused calendar service
    When I execute the public request sequence <sequence>
    Then the calendar.weeks-in-year count trace is <count trace>
    And the attempted configuration requests are <configuration requests>
    And the configuration outcome trace is <configuration outcome trace>

    Examples:
{table(["case", "sequence", "count trace", "configuration requests", "configuration outcome trace"], state_rows)}
''')

(FEATURES / "perl-binding.feature").write_text(f'''@source-binding @perl-binding @excluded-from-portable-handoff
Feature: Native week-count edge traces
  These rows preserve every Perl return carrier, warning sequence, and public error snapshot.
  Repeated scalar and list calls are separate because cache hits can change warning counts.

  Background:
    Given Perl loads Date-Manip 7.00 from the pinned local installation
    And each case uses a fresh Base service, process, and temporary working directory
    And the requested Base configuration is the full object profile except ForceDate

  Scenario Outline: Preserve every executed step and diagnostic channel
    Given native step <binding step> belongs to case <case>
    When Perl invokes <operation> with arguments <arguments>
    Then its scalar outcome is <scalar outcome>
    And its repeated scalar outcome is <repeated outcome>
    And its list outcome is <list outcome>
    And its scalar diagnostic is <scalar diagnostic>
    And its repeated diagnostic is <repeated diagnostic>
    And its list diagnostic is <list diagnostic>
    And public error text is <error before> before and <error after> after the step

    Examples:
{table(["binding step", "case", "operation", "arguments", "scalar outcome", "repeated outcome", "list outcome", "scalar diagnostic", "repeated diagnostic", "list diagnostic", "error before", "error after"], binding_rows)}
''')

feature_map = []
for case in manifest["cases"]:
    cid = case["case_id"]
    if cid in {"WCE-YEAR1", "WCE-YEAR9999"}:
        feature = "spec/drafts/week-count-edges/endpoint-years.feature"
        partitions = ["calendar.weeks-in-year.p1", "calendar.weeks-in-year.p2"]
    elif len(case["steps"]) > 1:
        feature = "spec/drafts/week-count-edges/configuration-state.feature"
        partitions = (["calendar.weeks-in-year.p3"] if cid == "WCE-CONFIG-ABA"
                      else ["calendar.weeks-in-year.p4"])
    else:
        feature = "spec/drafts/week-count-edges/year-input-compatibility.feature"
        partitions = ["calendar.weeks-in-year.p4"]
    feature_map.append({
        "case_id": cid, "operation_id": "calendar.weeks-in-year",
        "portable_profile": {"first_weekday": 1, "first_weekday_name": "Monday", "week_one_rule": "jan4"},
        "reference_fixture": "oo with ForceDate deliberately omitted for the direct Base service",
        "request_steps": case["steps"],
        "partition_ids": partitions, "portable_feature": feature,
        "binding_steps": [row["binding step"] for row in binding_rows if row["case"] == cid],
        "binding_feature": "spec/drafts/week-count-edges/perl-binding.feature",
        "observation": "docs/research/week-count-edges/observations.json",
    })
(FAMILY / "feature-map.json").write_text(json.dumps({
    "schema_version": 1, "canonical_operation": "calendar.weeks-in-year",
    "case_map": feature_map,
}, indent=2, ensure_ascii=False) + "\n")

(FAMILY / "bindings.json").write_text(json.dumps({
    "schema_version": 1,
    "operation": {"operation_id": "calendar.weeks-in-year", "module": "Date::Manip::Base", "callable": "weeks_in_year", "call_shape": "(year)", "disposition": "public-oo-method"},
    "supporting_public_calls": [
        {"operation_id": "object.create", "binding": "Date::Manip::Base->new"},
        {"operation_id": "config.apply-settings", "binding": "Date::Manip::Base->config"},
        {"operation_id": "object.read-error", "binding": "Date::Manip::Base->err"},
    ],
    "fixture": "docs/automation/reference-profiles.json#oo with ForceDate deliberately omitted",
    "aliases": [],
}, indent=2) + "\n")

(FAMILY / "coverage-map.json").write_text(json.dumps({
    "schema_version": 1,
    "operation_id": "calendar.weeks-in-year",
    "partition_updates": [
        {"partition_id": "calendar.weeks-in-year.p1", "status": "supplemented-supported-endpoints", "case_ids": ["WCE-YEAR1", "WCE-YEAR9999"], "scope": "Direct endpoint results supplement the accepted valid configuration matrix."},
        {"partition_id": "calendar.weeks-in-year.p2", "status": "supplemented-supported-endpoints", "case_ids": ["WCE-YEAR1", "WCE-YEAR9999"], "scope": "Both endpoints produce an independently checked 52-week result under jan4/Monday."},
        {"partition_id": "calendar.weeks-in-year.p3", "status": "observed-selected-state-sequence", "case_ids": ["WCE-CONFIG-ABA"], "scope": "A jan4 to jan1 to jan4 sequence on the same service yields 52,53,52 and revisits cached configuration state."},
        {"partition_id": "calendar.weeks-in-year.p4", "status": "observed-selected-not-complete", "case_ids": [c["case_id"] for c in manifest["cases"] if c["case_id"] not in {"WCE-YEAR1", "WCE-YEAR9999", "WCE-CONFIG-ABA"}], "scope": "Selected unsupported year shapes and two invalid configuration attempts retain literal outcomes and diagnostics."},
    ],
    "branch_evidence": [
        "Repeated scalar/list reads expose the same-key cached result and its warning differences.",
        "The A-B-A rule sequence demonstrates configuration-keyed cache separation on a reused service.",
        "Year 9999 exercises a public supported endpoint whose calculation also needs the following year's week boundary.",
        "Invalid FirstDay and Week1ofYear attempts leave the prior valid week count observable.",
    ],
    "remaining_domains": [
        "Signed or whitespace-padded numeric text, scientific notation, extreme magnitudes, infinity, and NaN.",
        "Reference, mapping, blessed, overloaded, and other native carrier shapes.",
        "Missing or undefined configuration names/values and invalid settings beyond the two selected controls.",
        "Additional reused-service sequences that change FirstDay or combine invalid attempts with uncached years.",
        "Other Date-Manip and runtime versions.",
    ],
    "completion_statement": "This closes the selected edge/state batch only. It does not promote partition p4 to complete, approve portable expectations, or constitute an executable harness result.",
}, indent=2) + "\n")
print(f"wrote four features, {len(feature_map)} case mappings, and {len(binding_rows)} binding steps")
