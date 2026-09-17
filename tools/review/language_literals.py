#!/usr/bin/env python3
"""Check language feature rows, source separation, mappings, and frozen evidence."""
from collections import Counter
import hashlib
import json
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[2]
FAMILY = ROOT / "docs/research/language-family"
FEATURES = ROOT / "spec/drafts/languages"


def load(path):
    return json.loads(path.read_text())


def table_rows(block, id_header="case"):
    header = None
    rows = []
    for line in block.splitlines():
        if not line.strip().startswith("|"):
            header = None
            continue
        cells = [cell.strip() for cell in re.split(r"(?<!\\)\|", line.strip())[1:-1]]
        if cells and cells[0] == id_header:
            header = cells
        elif header:
            assert len(header) == len(cells), (header, cells)
            rows.append(dict(zip(header, cells)))
    return rows


def scenario_rows(path, id_header="case"):
    text = path.read_text()
    matches = list(re.finditer(r"^  Scenario(?: Outline)?: (.+)$", text, re.M))
    found = []
    for index, match in enumerate(matches):
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        title = match.group(1).removesuffix(" for <case>")
        for row in table_rows(text[match.start():end], id_header):
            found.append((title, row))
    return found


def civil(value):
    if value is None:
        return "no date-time result"
    if value == "":
        return "empty text"
    match = re.fullmatch(r"(\d{4})(\d{2})(\d{2})(\d{2}:\d{2}:\d{2})", value)
    assert match, value
    year, month, day, clock = match.groups()
    return f"{year}-{month}-{day} {clock}"


def rendered(value):
    if value == "empty text":
        return ""
    return "\u009croda" if value == 'U+009C followed by "roda"' else value


def warning_class(warnings):
    extras = [warning.split(" at /home/", 1)[0] for warning in warnings[1:]]
    if not extras:
        return "deprecation only"
    if all("uninitialized value $f" in warning and "concatenation" in warning for warning in extras):
        return "uninitialized month concatenation"
    if all("Unescaped left brace in regex" in warning for warning in extras):
        return "unescaped-left-brace regex warnings"
    if all("uninitialized value $add in addition" in warning for warning in extras):
        return "uninitialized addition"
    raise AssertionError(extras)


records = {}
for backend in ("dm6", "dm5"):
    corpus = load(FAMILY / f"{backend}-observations.json")
    assert len(corpus["observations"]) == 32
    assert corpus["repetitions"] == 2 and corpus["parallel_workers"] == 4
    assert corpus["timeout_seconds"] == 15
    assert corpus["fresh_temporary_working_directory_per_attempt"] is True
    for name, digest in corpus["sha256"].items():
        assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest, name
    for wrapper in corpus["observations"]:
        assert wrapper["repeatable"] and wrapper["exit_status"] == 0
        assert wrapper["stderr"] == "" and wrapper["fixture_hash_matches"]
        assert wrapper["json_decode_error"] is None
        record = wrapper["observation"]
        assert record["fixture_sha256"] == corpus["fixture_sha256"]
        assert record["distribution_version"] == "7.00"
        assert record["call_stdout"] == ""
        records[record["case_id"]] = record
assert len(records) == 64


current_path = FEATURES / "canonical-dm6.feature"
legacy_path = FEATURES / "dm5-comparisons.feature"
binding_path = FEATURES / "perl-binding.feature"
portable_text = current_path.read_text() + "\n" + legacy_path.read_text()
portable_without_ids = re.sub(r"LANG-DM[56]-[A-Za-z0-9-]+", "", portable_text)
for forbidden in ("DM5", "DM6", "Date::Manip", "Perl", "warning", "exception", "not applicable"):
    assert forbidden not in portable_without_ids, forbidden
assert "@current-language-profile" in current_path.read_text()
assert "@legacy-language-profile" in legacy_path.read_text()


portable_cases = {}
expected_sequences = {}
current_rows = scenario_rows(current_path)
assert all(value != "" for _, row in current_rows for value in row.values())
for scenario, row in current_rows:
    case_id = row["case"]
    assert case_id not in portable_cases
    portable_cases[case_id] = ("canonical-dm6.feature", scenario, row)
    source_id = case_id.removesuffix("-PREPROCESS")
    record = records[source_id]
    assert record["profile"] == "dm6"
    assert row["language"] == record["canonical_language"]
    result = record["raw_return"]
    if case_id.endswith("-PREPROCESS"):
        assert scenario == "Declared language preprocessing accepts one concrete phrase"
        value = result["special_preprocessing"]
        assert record["mode"] == "utf8" and value["case_id"] == case_id
        assert row["input"] == value["input"]
        assert value["status"] == 0 and value["error"] == ""
        assert value["exception"] is None and civil(value["value"]) == "2040-02-29 00:00:00"
        expected_sequences[case_id] = ["configure fresh profile and parse special preprocessing phrase"]
        continue
    expected_scenario = (
        "A localized leap date, its weekday, tomorrow, and localized names agree"
        if record["mode"] == "utf8"
        else "Forced ASCII uses the selected ASCII phrase with its observed result"
    )
    assert scenario == expected_scenario
    for input_column, output_column, key in (
        ("full date", "full result", "full_date"),
        ("weekday date", "weekday result", "matching_weekday"),
        ("tomorrow", "tomorrow result", "tomorrow"),
    ):
        value = result[key]
        assert row[input_column] == value["input"], case_id
        expected = row.get(output_column, "2040-02-29 00:00:00")
        assert civil(value["value"]) == expected, case_id
        expected_error = "" if row.get("error", "empty text") == "empty text" else row["error"]
        assert value["error"] == expected_error and value["exception"] is None, case_id
        assert value["setup"]["exception"] is None and value["setup"]["status"] is None
        assert value["setup"]["effective"] == {
            "language": record["canonical_language"],
            "encoding": "UTF-8" if record["mode"] == "utf8" else "ASCII",
            "date_format": "non-US",
        }
    assert result["rendering"]["value"] == row["weekday rendering"] + "|" + rendered(row["month rendering"])
    assert result["rendering"]["parse_status"] == 0
    assert result["rendering"]["error"] == "" and result["rendering"]["exception"] is None
    expected_sequences[case_id] = [
        "configure fresh profile and parse full date",
        "configure fresh profile and parse weekday-bearing date",
        "configure fresh profile and parse relative date",
        "configure fresh profile, parse render source, and render %A|%B",
    ]
assert len(current_rows) == 36


legacy_rows = scenario_rows(legacy_path)
assert all(value != "" for _, row in legacy_rows for value in row.values())
legacy_counts = Counter()
for scenario, row in legacy_rows:
    case_id = row["case"]
    assert case_id not in portable_cases
    portable_cases[case_id] = ("dm5-comparisons.feature", scenario, row)
    record = records[case_id]
    result = record["raw_return"]
    assert record["profile"] == "dm5"
    assert row["language"] == record["canonical_language"]
    assert "legacy-" + row["mode"] == record["mode"]
    if scenario == "A legacy profile that cannot initialize performs no dependent operation":
        legacy_counts["failure"] += 1
        assert result["setup"]["call_completed"] is False
        assert "status" not in result["setup"] and result["setup"]["exception"] is not None
        assert not result["dependent_operations_executed"]
        for key in ("full_date", "matching_weekday", "tomorrow", "rendering", "special_preprocessing"):
            assert result[key] is None
        expected_sequences[case_id] = ["initialize legacy language profile"]
        continue
    assert result["setup"]["call_completed"] is True
    assert result["setup"]["status"] is None and result["setup"]["exception"] is None
    assert result["dependent_operations_executed"]
    special = result["special_preprocessing"]
    if scenario == "An initialized legacy profile also executes a special preprocessing request":
        legacy_counts["special"] += 1
        assert special is not None
        assert row["special input"] == special["input"]
        assert row["special result"] == civil(special["value"])
        assert special["exception"] is None
        expected_sequences[case_id] = [
            "initialize legacy language profile", "render %A|%B",
            "parse special preprocessing input", "parse full date",
            "parse weekday-bearing date", "parse relative date",
        ]
    else:
        legacy_counts["ordinary"] += 1
        assert scenario == "An initialized legacy profile renders and parses ordinary inputs"
        assert special is None
        assert "special input" not in row and "special result" not in row
        expected_sequences[case_id] = [
            "initialize legacy language profile", "render %A|%B",
            "parse full date", "parse weekday-bearing date", "parse relative date",
        ]
    for input_column, output_column, key in (
        ("full date", "full result", "full_date"),
        ("weekday date", "weekday result", "matching_weekday"),
        ("tomorrow input", "tomorrow result", "tomorrow"),
    ):
        value = result[key]
        assert row[input_column] == value["input"], case_id
        assert row[output_column] == civil(value["value"]), case_id
        assert value["exception"] is None
    assert result["rendering"]["value"] == rendered(row["weekday rendering"]) + "|" + rendered(row["month rendering"])
    assert result["rendering"]["exception"] is None
assert legacy_counts == {"ordinary": 20, "special": 6, "failure": 6}
assert len(legacy_rows) == 32 and len(portable_cases) == 68


mapping = load(FAMILY / "portability-map.json")
assert mapping["mapping_gaps"] == []
assert mapping["interrupted_call_policy"] == (
    "A thrown binding call has no return value; an unassigned capture variable is never mapped as an absent result."
)
legacy_binding = next(
    binding for binding in mapping["source_bindings"]
    if binding["portable_profile"] == "legacy-language-profile"
)
assert legacy_binding["configuration_return_capture"] == (
    "completed Date_Init calls record status (including native undefined); "
    "interrupted calls record call_completed false and omit status"
)
case_mappings = mapping["case_mappings"]
assert len(case_mappings) == len({row["case_id"] for row in case_mappings}) == 68
assert {row["case_id"] for row in case_mappings} == set(portable_cases)
for mapped in case_mappings:
    feature, scenario, _ = portable_cases[mapped["case_id"]]
    source = records[mapped["source_observation_case_id"]]
    assert mapped["feature"] == feature and mapped["scenario"] == scenario
    assert mapped["contract_ids"] == source["contract_ids"]
    assert mapped["executed_sequence"] == expected_sequences[mapped["case_id"]]


binding_text = binding_path.read_text()
assert binding_text.startswith(
    "@draft @languages @reference-dm700 @source-binding @perl-binding @excluded-from-portable-handoff"
)
assert "each of the 26 completed Date_Init calls returns native undefined status" in binding_text
binding_rows = {}
for scenario, row in scenario_rows(binding_path, "binding case"):
    assert row["binding case"] not in binding_rows
    binding_rows[row["binding case"]] = (scenario, row)
assert len(binding_rows) == 38


failed_ids = {
    case_id for case_id, record in records.items()
    if record["profile"] == "dm5" and record["raw_return"]["setup"]["exception"] is not None
}
assert len(failed_ids) == 6
for source_id in failed_ids:
    suffix = source_id.removeprefix("LANG-DM5-")
    _, row = binding_rows["LANG-BIND-EXCEPTION-" + suffix]
    record = records[source_id]
    setup = record["raw_return"]["setup"]
    expected_prefix = (
        "Can't use an undefined value as an ARRAY reference"
        if record["canonical_language"] == "Catalan"
        else "ERROR: Unknown language in Date::Manip."
    )
    assert row["source case"] == source_id
    assert row["language"] == record["canonical_language"]
    assert row["IntCharSet"] == ("1" if record["mode"] == "legacy-international" else "0")
    assert setup["call_completed"] is False and "status" not in setup
    assert row["exception prefix"] == expected_prefix and setup["exception"].startswith(expected_prefix)


dm5_ids = {case_id for case_id, record in records.items() if record["profile"] == "dm5"}
for source_id in dm5_ids:
    suffix = source_id.removeprefix("LANG-DM5-")
    _, row = binding_rows["LANG-BIND-WARNING-" + suffix]
    warnings = records[source_id]["warnings"]
    assert row["source case"] == source_id
    assert int(row["warning count"]) == len(warnings)
    assert row["warning class"] == warning_class(warnings)
    assert warnings[0].startswith("Date::Manip::DM5 is deprecated")


assert len(mapping["binding_assertions"]) == 3
assert len(mapping["binding_case_mappings"]) == 38
mapped_binding_ids = {row["binding_case_id"] for row in mapping["binding_case_mappings"]}
assert mapped_binding_ids == set(binding_rows)
source_contracts = {row["case_id"]: row["contract_ids"] for row in case_mappings if row["case_id"] in dm5_ids}
for row in mapping["binding_case_mappings"]:
    assert row["contract_ids"] == source_contracts[row["source_case_id"]]
for assertion in mapping["binding_assertions"]:
    assert binding_text.count("@" + assertion["assertion_id"]) == 1
    assert f"Scenario: {assertion['scenario']}" in binding_text
    assert set(assertion["source_case_ids"]) <= dm5_ids


coverage = load(FAMILY / "coverage.json")
assert coverage["canonical_languages"]["portable_runtime_rows"] == 68
assert coverage["canonical_languages"]["legacy_initialized_ordinary_rows"] == 20
assert coverage["canonical_languages"]["legacy_initialized_special_rows"] == 6
assert coverage["canonical_languages"]["legacy_initialization_failure_rows"] == 6
assert coverage["binding_accounting"] == {
    "feature": "spec/drafts/languages/perl-binding.feature",
    "warning_rows": 32, "exception_rows": 6, "binding_assertions": 3,
    "excluded_from_portable_handoff": True,
}


# Preserve the independent 45-selector feature and evidence checks.
selector_document = load(FAMILY / "selector-observations.json")
for path, digest in selector_document["sha256"].items():
    assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path
selectors = {row["selector"]: row for row in selector_document["observations"]}
selector_map = load(FAMILY / "selector-feature-map.json")
by_case = {row["case_id"]: row for row in selector_map["cases"]}
assert len(selectors) == len(by_case) == 45
selector_count = 0
for _, row in scenario_rows(FEATURES / "selectors.feature"):
    selector_count += 1
    mapped = by_case[row["case"]]
    assert mapped["selector"] == row["selector"]
    wrapper = selectors[row["selector"]]
    observation = wrapper["observation"]
    assert wrapper["repeatable"] and wrapper["exit_status"] == 0 and wrapper["stderr"] == ""
    assert observation["exception"] is None and observation["warnings"] == []
    assert observation["call_stdout"] == ""
    assert observation["canonical"] == row["language"]
    assert observation["selected_language"] == row["selector"]
    assert observation["request"] == {"text": row["input"], "pattern": "%A|%B"}
    assert observation["parse_status"] == 0
    assert observation["parse_error"] == observation["error_after_value"] == observation["error_after_render"] == ""
    assert observation["configuration_return"] is None and observation["configuration_error"] == ""
    assert observation["dependent_reads_executed"] and observation["value"] == "2040022900:00:00"
    assert observation["rendered"] == row["weekday"] + "|" + row["month"]
assert selector_count == 45


print(json.dumps({
    "reference_records_checked": len(records),
    "portable_runtime_rows_checked": len(portable_cases),
    "binding_rows_checked": len(binding_rows),
    "selector_rows_checked": selector_count,
    "approved_specification_cases": 0,
}, indent=2))
