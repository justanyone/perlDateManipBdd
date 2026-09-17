#!/usr/bin/env python3
"""Check stored lifecycle evidence and its draft mapping without running Date-Manip."""
import hashlib
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/object-lifecycle-family"
FIXTURE = FAMILY / "cases.json"
OBSERVATIONS = FAMILY / "observations.json"
COVERAGE = FAMILY / "coverage.json"
FEATURE_DIR = ROOT / "spec/drafts/object-lifecycle"


def load(path):
    return json.loads(path.read_text(encoding="utf-8"))


fixture = load(FIXTURE)
observations = load(OBSERVATIONS)
coverage = load(COVERAGE)
fixture_hash = hashlib.sha256(FIXTURE.read_bytes()).hexdigest()

assert observations["repetitions"] == 2
assert observations["parallel_workers"] <= 4
assert observations["timeout_seconds"] == 15
assert observations["fresh_temporary_working_directory_per_attempt"] is True
assert observations["fixture_sha256"] == fixture_hash == coverage["fixture_sha256"]
assert observations["reference_assertions"] == fixture["reference"]

fixture_ids = [case["case_id"] for case in fixture["cases"]]
observation_ids = [row["case_id"] for row in observations["observations"]]
coverage_ids = [row["case_id"] for row in coverage["case_mappings"]]
assert len(fixture_ids) == len(set(fixture_ids)) == 20
assert observation_ids == fixture_ids
assert coverage_ids == fixture_ids

for row in observations["observations"]:
    assert row["repeatable"] is True
    assert row["research_status"] == "repeatable"
    assert row["exit_status"] == 0
    assert row["fixture_hash_matches"] is True
    assert row["stderr"] == ""
    assert row["json_decode_error"] is None
    record = row["observation"]
    assert record["case_id"] == row["case_id"]
    assert record["fixture_sha256"] == fixture_hash
    assert record["exception"] is None
    assert record["warnings"] == []
    assert record["call_stdout"] == ""
    assert record["raw_return"]["dependent_calls_executed"] is True

# Check the complete API catalogue, not just the values family's catalogue.
operation_ids = {row["id"] for row in load(ROOT / "docs/research/api/contract-map.json")["operations"]}
for case in fixture["cases"]:
    assert set(case["contract_ids"]) <= operation_ids, case["case_id"]
    assert case["operation_id"] in operation_ids, case["case_id"]
coverage_by_id = {row["case_id"]: row for row in coverage["case_mappings"]}
for case in fixture["cases"]:
    assert coverage_by_id[case["case_id"]]["contract_ids"] == case["contract_ids"], case["case_id"]
for path, digest in observations["sha256"].items():
    assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path
raw = {row["case_id"]: row["observation"]["raw_return"] for row in observations["observations"]}
for key, status, value, error in [
    ("success", 0, "2040020116:05:09", ""),
    ("individual_day_31", 0, "2040023116:05:09", ""),
    ("impossible_whole_date", 1, "", "[set] Invalid date argument"),
    ("unknown_field", 1, "", "[set] Invalid field"),
]:
    row = raw["OBJ-014-DATE-SET"][key]
    assert row["before"]["value"] == "2040022916:05:09"
    assert row["before"]["error_before"] == row["before"]["error_after"] == ""
    assert row["before"]["exception"] is None
    assert (row["status"], row["getter"]["value"], row["error_after_set"]) == (status, value, error)
    assert row["getter"]["error_before"] == error
    assert row["getter"]["error_after"] == ("[value] Object does not contain a date" if status else "")
for key, expected in [("success", "0:0:0:1:5:3:4"), ("invalid", "")]:
    row = raw["OBJ-015-DELTA-SET"][key]
    assert row["before"]["value"] == "0:0:0:1:2:3:4"
    assert row["before"]["error_before"] == row["before"]["error_after"] == ""
    assert row["before"]["exception"] is None
    assert row["getter"]["value"] == expected
for key in ("fresh", "valid"):
    row = raw["OBJ-013-RECUR-CARRIER-GETTERS"][key]
    assert row["basedate"]["value"] == [None, None]
    assert row["start"]["value"] is None and row["end"]["value"] is None
    assert row["modifiers"]["value"] == []

def check_config_call(call, kind):
    assert call["error_before"] == call["error_after"] == ""
    assert call["exception"] is None
    if kind == "delta":
        assert call["status_defined"] is True
        assert call["status"] is None
        assert call["status_reference_type"] == "HASH"
    else:
        assert call["status_defined"] is False
        assert call["status"] is None
        assert call["status_reference_type"] is None


def check_config_read(read, expected):
    assert read["defined"] is True and read["value"] == expected
    assert read["error_before"] == read["error_after"] == ""
    assert read["exception"] is None


for kind in ("date", "delta", "recur"):
    shared = raw["OBJ-006-CONFIG-SHARED-SAME-KIND"][kind]
    for name in ("initial_source_config", "child_change", "source_change"):
        check_config_call(shared[name], kind)
    for receiver in ("source", "child"):
        check_config_read(shared["after_child_change"][receiver], "non-US")
        check_config_read(shared["after_source_change"][receiver], "US")

    shortcuts = raw["OBJ-007-CONFIG-SHARED-SHORTCUTS"][kind]
    check_config_call(shortcuts["initial_source_config"], kind)
    check_config_call(shortcuts["child_change"], "date")
    check_config_read(shortcuts["observed"]["source"], "non-US")
    for child in shortcuts["observed"]["children"]:
        check_config_read(child, "non-US")

    row = raw["OBJ-008-CONFIG-ISOLATED-KINDS"][kind]
    assert (row["initial"]["source"]["value"], row["initial"]["child"]["value"]) == ("US", "non-US")
    assert (row["after_child_change"]["source"]["value"], row["after_child_change"]["child"]["value"]) == ("US", "US")
    assert (row["after_source_change"]["source"]["value"], row["after_source_change"]["child"]["value"]) == ("non-US", "US")
    for call in (row["initial_source_config"], row["child_change"], row["source_change"]):
        check_config_call(call, kind)
    for pair_name in ("initial", "after_child_change", "after_source_change"):
        for receiver in ("source", "child"):
            read = row[pair_name][receiver]
            check_config_read(read, read["value"])

for snapshot_name in ("after_range_and_base", "after_modifiers", "after_frequency_replace"):
    snapshot = raw["OBJ-020-RECUR-CARRIER-SET"][snapshot_name]
    for name in ("start", "end", "specified_base", "actual_base"):
        date = snapshot[name]
        if date["defined"]:
            assert date["error_before"] == date["error_after"] == ""
            assert date["exception"] is None

feature_text = "\n".join(
    path.read_text(encoding="utf-8") for path in sorted(FEATURE_DIR.glob("*.feature"))
)
mentioned_ids = re.findall(r'this is case "(OBJ-[^"]+)"', feature_text)
assert mentioned_ids == fixture_ids[:8] + ["OBJ-018-METHOD-CALLABILITY", "OBJ-019-INVALID-CONSTRUCTORS"] + fixture_ids[8:17] + ["OBJ-020-RECUR-CARRIER-SET"]
assert len(mentioned_ids) == len(set(mentioned_ids)) == 20

for mapping in coverage["case_mappings"]:
    path = FEATURE_DIR / mapping["feature"]
    text = path.read_text(encoding="utf-8")
    assert text.count(f'Scenario: {mapping["scenario"]}') == 1
    assert text.count(f'this is case "{mapping["case_id"]}"') == 1

assert 'losslessly rendering its six civil fields as "YYYY-MM-DD HH:MM:SS"' in feature_text
assert "normalized civil date-time" in feature_text
assert "the exact date values are" not in feature_text
assert "date scalar value is" not in feature_text
assert "retain their scalar values" not in feature_text


def normalized_civil(native):
    assert re.fullmatch(r"\d{8}\d{2}:\d{2}:\d{2}", native), native
    return f"{native[0:4]}-{native[4:6]}-{native[6:8]} {native[8:]}"


native_dates = [
    raw["OBJ-001-DIRECT-CONSTRUCTORS"]["date"]["scalar"]["value"],
    raw["OBJ-004-SHORTCUT-INITIAL-VALUES"]["recur_to_date"]["scalar"]["value"],
    raw["OBJ-005-CROSS-KIND-CLASS-NEW"]["delta_to_date"]["scalar"]["value"],
]
native_dates.extend(raw["OBJ-009-DATE-VALUE-CONTEXTS"][key]["scalar"]["value"] for key in ("omitted", "empty", "other", "local", "gmt"))
native_dates.extend(raw["OBJ-014-DATE-SET"][key]["getter"]["value"] for key in ("success", "individual_day_31"))
native_dates.extend(
    raw["OBJ-020-RECUR-CARRIER-SET"][snapshot][name]["value"]
    for snapshot, names in (("after_range_and_base", ("start", "end", "specified_base")), ("after_modifiers", ("start", "end")))
    for name in names
)
for native in native_dates:
    assert normalized_civil(native) in feature_text, native

value_feature = (FEATURE_DIR / "value-state-and-errors.feature").read_text(encoding="utf-8")
selector_at = value_feature.index("Scenario: Date value selectors preserve serialized text and ordered fields")
assert "@observed-compatibility" in value_feature[max(0, selector_at - 80):selector_at]
creation_feature = (FEATURE_DIR / "creation-and-context.feature").read_text(encoding="utf-8")
method_at = creation_feature.index("Scenario: Lifecycle method availability follows the public receiver surfaces")
assert "@reference-binding" in creation_feature[max(0, method_at - 80):method_at]

# High-risk literal distinctions found during manual evidence review.
required_literals = [
    '2040-02-31 16:05:09',
    '[set] Invalid date argument',
    '[set] Invalid field',
    '[set] Unknown option: bogus',
    '[value] Object does not contain a date',
    '[parse] Invalid date string',
    '[parse] Invalid delta string',
    '[parse] Invalid frequency string',
    '2040-02-29 21:05:09',
    '0:0:0:0:0:0:0',
    '0:0:0:2:0:0:0',
]
for literal in required_literals:
    assert literal in feature_text

print("checked20 repeatable cases,20 unique draft mappings, and selected mutation/absence literals")
