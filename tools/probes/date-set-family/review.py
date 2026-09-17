#!/usr/bin/env python3
"""Review invariants for the stored public Date::Manip::Date::set evidence."""
import collections
import hashlib
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/date-set-family"
FEATURE_DIR = ROOT / "spec/drafts/date-set"
CASES_PATH = FAMILY / "cases.json"
OBS_PATH = FAMILY / "observations.json"
COVERAGE_PATH = FAMILY / "coverage.json"
INVENTORY_PATH = FAMILY / "signature-inventory.json"
CONTRACT_PATH = ROOT / "docs/research/api/contract-map.json"

BASE_CONTRACTS = [
    "object.create", "context.zone-service", "meta.zone-data-version",
    "meta.zone-rule-version", "config.apply-settings", "config.read-settings",
    "date.create",
]
TAIL_CONTRACTS = ["date.replace-field", "date.read-value", "error.read-state"]
ERROR_RECEIVER_CASES = {
    "DSET-ZONE-012-ERROR-RECEIVER",
    "DSET-ZDATE-014-ERROR-RECOVERY",
    "DSET-DATE-003-ERROR-RECOVERY",
    "DSET-TIME-016-ERROR-RECEIVER",
    "DSET-FIELD-026-ERROR-RECEIVER",
}
SUCCESS = {
    *(f"DSET-ZONE-{n:03d}-" for n in (1, 2, 5, 6, 7, 8, 13, 14, 15, 19)),
    *(f"DSET-ZDATE-{n:03d}-" for n in (1, 2, 4, 5, 6, 7, 13, 14)),
    *(f"DSET-DATE-{n:03d}-" for n in (1, 2, 3, 4, 5, 6, 14, 18)),
    *(f"DSET-TIME-{n:03d}-" for n in (1, 2, 3, 4, 5, 9, 14)),
    *(f"DSET-FIELD-{n:03d}-" for n in (*range(1, 7), *range(8, 18), 20, 27, 28, 29, 33, 34)),
}
EXCEPTION_PREFIX = {
    **{case: "Can't locate object method \"__zone\" via package \"Date::Manip::Base\"" for case in (
        "DSET-ZONE-003-OFFSET-TEXT", "DSET-ZONE-004-OFFSET-LIST",
        "DSET-ZONE-009-INVALID-ZONE", "DSET-ZONE-020-TWO-AS-SINGLE-ARG",
        "DSET-ZDATE-003-OFFSET-LIST", "DSET-ZDATE-010-INVALID-ZONE",
        "DSET-ZDATE-015-OFFSET-TEXT",
    )},
    "DSET-DATE-011-SCALAR": "Can't use string (\"2041010203:04:05\") as an ARRAY ref while \"strict refs\" in use",
    "DSET-TIME-011-SCALAR": "Can't use string (\"03:04:05\") as an ARRAY ref while \"strict refs\" in use",
}
WARNING_COUNTS = {
    "DSET-DATE-009-SHORT-ARRAY": 3,
    "DSET-TIME-010-SHORT-ARRAY": 1,
    "DSET-FIELD-007-YEAR-ZERO": 2,
    "DSET-FIELD-016-NONNUMERIC": 2,
    "DSET-FIELD-017-UNDEFINED": 10,
    "DSET-FIELD-023-OMITTED-NAME": 1,
}


def load(path):
    return json.loads(path.read_text(encoding="utf-8"))


def full_case_id(prefix, fixtures):
    matches = [c["case_id"] for c in fixtures if c["case_id"].startswith(prefix)]
    assert len(matches) == 1, (prefix, matches)
    return matches[0]


def normalize_native(value):
    match = re.fullmatch(r"(\d{4})(\d{2})(\d{2})(\d{2}):(\d{2}):(\d{2})", value or "")
    if not match:
        return value
    y, mo, d, h, mi, s = match.groups()
    return f"{y}-{mo}-{d} {h}:{mi}:{s}"


def feature_atom(value):
    if value is None:
        return "undefined"
    if isinstance(value, bool):
        return "boolean " + str(value).lower()
    if isinstance(value, (int, float)):
        return "number " + str(value)
    if isinstance(value, str):
        return 'text "' + value.replace('"', '\\"') + '"'
    if isinstance(value, list):
        return "list [" + ", ".join(feature_atom(item) for item in value) + "]"
    raise TypeError(value)


def feature_receiver(case):
    receiver = case["receiver"]
    if receiver["state"] == "valid":
        return f'valid "{receiver["text"]}"'
    if receiver["state"] == "unset":
        return "unset"
    return ('valid "2040-02-29 16:05:09 Etc/UTC", then parse "'
            + receiver["preparation_text"] + '"')


def feature_request(case):
    arguments = case["arguments"]
    if not arguments:
        return "selector omitted; arguments []"
    return ("selector " + feature_atom(arguments[0]) + "; arguments ["
            + ", ".join(feature_atom(item) for item in arguments[1:]) + "]")


def feature_case_rows(feature_texts, fixture_ids):
    rows = {}
    for text in feature_texts.values():
        header = None
        for line in text.splitlines():
            if line.lstrip().startswith("|"):
                cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
                if cells and cells[0] == "case":
                    header = cells
                elif header and cells and cells[0] in fixture_ids:
                    assert cells[0] not in rows, cells[0]
                    rows[cells[0]] = dict(zip(header, cells))
            else:
                header = None
    return rows


def canonical_ids(document):
    found = set()
    def walk(value):
        if isinstance(value, dict):
            if isinstance(value.get("id"), str):
                found.add(value["id"])
            for child in value.values():
                walk(child)
        elif isinstance(value, list):
            for child in value:
                walk(child)
    walk(document)
    return found


def main():
    cases_doc = load(CASES_PATH)
    fixtures = cases_doc["cases"]
    observations = load(OBS_PATH)
    coverage = load(COVERAGE_PATH)
    inventory = load(INVENTORY_PATH)
    contract_ids = canonical_ids(load(CONTRACT_PATH))
    case_ids = [case["case_id"] for case in fixtures]
    assert len(case_ids) == len(set(case_ids)) == 108

    fixture_hash = hashlib.sha256(CASES_PATH.read_bytes()).hexdigest()
    assert observations["fixture_sha256"] == coverage["fixture_sha256"] == fixture_hash
    assert observations["repetitions"] == 2
    assert observations["timeout_seconds"] == 15
    assert observations["parallel_workers"] == 4
    assert observations["fresh_temporary_working_directory_per_attempt"] is True
    assert observations["reference_assertions"] == cases_doc["reference"]
    assert inventory["reference"]["distribution_version"] == "7.00"
    for relative, digest in observations["sha256"].items():
        assert hashlib.sha256((ROOT / relative).read_bytes()).hexdigest() == digest, relative

    feature_texts = {
        path.name: path.read_text(encoding="utf-8")
        for path in sorted(FEATURE_DIR.glob("*.feature"))
    }
    all_feature_text = "\n".join(feature_texts.values())
    mentions = re.findall(r"DSET-(?:ZONE|ZDATE|DATE|TIME|FIELD)-[A-Z0-9-]+", all_feature_text)
    assert collections.Counter(mentions) == collections.Counter(case_ids)
    request_rows = feature_case_rows(feature_texts, set(case_ids))
    assert set(request_rows) == set(case_ids)
    for case in fixtures:
        row = request_rows[case["case_id"]]
        assert row["initial receiver"] == feature_receiver(case), case["case_id"]
        assert row["exact request"] == feature_request(case), case["case_id"]
    assert "@reference-binding @excluded-from-portable-handoff @DSET-BIND-SHORT-LISTS\n  Scenario: Perl reports each missing field" in all_feature_text
    assert "@reference-binding @excluded-from-portable-handoff @DSET-BIND-FIELD-WARNINGS\n  Scenario: Perl reports binding warnings" in all_feature_text

    for binding in coverage["binding_assertions"]:
        assert set(binding["source_case_ids"]) <= set(case_ids)
        assert all_feature_text.count("@" + binding["assertion_id"]) == 1
    assert len(coverage["binding_assertions"]) == 2
    mappings = coverage["case_mappings"]
    assert [row["case_id"] for row in mappings] == case_ids
    canonical_needed = set(BASE_CONTRACTS + TAIL_CONTRACTS) | {"date.parse-text"}
    assert canonical_needed <= contract_ids
    for row in mappings:
        expected_contracts = BASE_CONTRACTS + (["date.parse-text"] if row["case_id"] in ERROR_RECEIVER_CASES else []) + TAIL_CONTRACTS
        assert row["contract_ids"] == expected_contracts, row["case_id"]
        assert row["feature"] in feature_texts
        assert f"Scenario: {row['scenario']}" in feature_texts[row["feature"]]
    assert coverage["contract_mapping_gaps"] == []

    rows = observations["observations"]
    assert [row["case_id"] for row in rows] == case_ids
    success_ids = {full_case_id(prefix, fixtures) for prefix in SUCCESS}
    assert len(success_ids) == 55
    exception_ids = set(EXCEPTION_PREFIX)
    failure_ids = set(case_ids) - success_ids - exception_ids
    assert len(exception_ids) == 9 and len(failure_ids) == 44

    expected_errors = {}
    def assign(ids, error):
        for case_id in ids:
            assert case_id not in expected_errors
            expected_errors[case_id] = error
    assign({"DSET-ZONE-010-EXTRA-ARGUMENT", "DSET-ZDATE-011-OMITTED-DATE",
            "DSET-ZDATE-012-EXTRA-ARGUMENT", "DSET-DATE-012-OMITTED-DATE",
            "DSET-DATE-013-EXTRA-ARGUMENT", "DSET-TIME-012-OMITTED-TIME",
            "DSET-TIME-013-EXTRA-ARGUMENT", "DSET-FIELD-018-OMITTED-VALUE",
            "DSET-FIELD-019-EXTRA-ARGUMENT", "DSET-FIELD-024-MULTIPLE-FIELDS"}, "[set] Invalid arguments")
    assign({"DSET-ZONE-011-UNSET-RECEIVER", "DSET-TIME-015-UNSET-RECEIVER",
            "DSET-FIELD-025-UNSET-RECEIVER"}, "")
    assign({"DSET-ZONE-012-ERROR-RECEIVER", "DSET-TIME-016-ERROR-RECEIVER",
            "DSET-FIELD-026-ERROR-RECEIVER"}, "[parse] Invalid date string")
    assign({"DSET-ZONE-016-GAP-DEFAULT", "DSET-ZONE-017-GAP-STANDARD",
            "DSET-ZONE-018-GAP-DAYLIGHT", "DSET-ZDATE-008-GAP",
            "DSET-DATE-007-GAP", "DSET-DATE-010-LONG-ARRAY",
            "DSET-TIME-006-GAP-DEFAULT", "DSET-TIME-007-GAP-STANDARD",
            "DSET-TIME-008-GAP-DAYLIGHT", "DSET-FIELD-007-YEAR-ZERO",
            "DSET-FIELD-030-GAP-DEFAULT", "DSET-FIELD-031-GAP-STANDARD",
            "DSET-FIELD-032-GAP-DAYLIGHT"}, "[set] Invalid date/timezone")
    assign({"DSET-ZDATE-009-INVALID-DATE", "DSET-DATE-008-INVALID-DATE",
            "DSET-DATE-009-SHORT-ARRAY", "DSET-DATE-015-YEAR-ZERO",
            "DSET-DATE-016-MONTH-ZERO", "DSET-DATE-017-DAY-ZERO",
            "DSET-DATE-019-HOUR-24-NONZERO"}, "[set] Invalid date argument")
    assign({"DSET-TIME-010-SHORT-ARRAY", "DSET-TIME-017-MINUTE-60",
            "DSET-TIME-018-SECOND-60", "DSET-TIME-019-HOUR-24-NONZERO",
            "DSET-TIME-020-NEGATIVE-HOUR"}, "[set] Invalid time argument")
    assign({"DSET-FIELD-021-UNKNOWN", "DSET-FIELD-022-EMPTY-NAME",
            "DSET-FIELD-023-OMITTED-NAME"}, "[set] Invalid field")
    assert set(expected_errors) == failure_ids

    for row in rows:
        case_id = row["case_id"]
        assert row["repeatable"] is True and row["research_status"] == "repeatable"
        assert row["exit_status"] == 0 and row["fixture_hash_matches"] is True
        assert row["stderr"] == "" and row["json_decode_error"] is None
        observation = row["observation"]
        expected_contracts = BASE_CONTRACTS + (["date.parse-text"] if case_id in ERROR_RECEIVER_CASES else []) + TAIL_CONTRACTS
        assert observation["contract_ids"] == expected_contracts
        assert observation["operation_id"] == "date.replace-field"
        assert observation["exception"] is None and observation["call_stdout"] == ""
        assert observation["raw_return"]["dependent_calls_executed"] is True
        setup = observation["setup"]
        assert setup["class"] == "Date::Manip::Date" and setup["error_after"] == ""
        assert setup["config"] == {"error_before": "", "value": None, "value_defined": False,
                                   "value_reference_type": None, "error_after": "", "exception": None}
        reference = setup["reference"]
        assert reference["constructor"] == {"returned_reference_type": "Date::Manip::Date",
                                             "error_after": "", "exception": None}
        assert reference["zone_service"] == {"error_before": "", "value_defined": True,
                                              "value_reference_type": "Date::Manip::TZ",
                                              "error_after": "", "exception": None}
        for name, expected in (("tzdata", "tzdata2026c"), ("tzcode", "tzcode2026c")):
            call = reference[name]
            assert call["value"] == expected and call["value_defined"] is True
            assert call["value_reference_type"] is None
            assert call["error_before"] == call["error_after"] == "" and call["exception"] is None
        for name, expected in (("language", "English"), ("encoding", "ASCII"), ("dateformat", "non-US")):
            call = setup["effective"][name]
            assert call["value"] == expected and call["value_defined"] is True
            assert call["error_before"] == call["error_after"] == "" and call["exception"] is None

        raw = observation["raw_return"]
        receiver = raw["receiver"]
        assert receiver["class"] == receiver["creation"]["returned_reference_type"] == "Date::Manip::Date"
        assert receiver["creation"]["anchor_error_before"] == receiver["creation"]["anchor_error_after"] == ""
        assert receiver["creation"]["exception"] is None
        fixture = next(case for case in fixtures if case["case_id"] == case_id)
        if fixture["receiver"]["state"] == "valid":
            assert raw["before"] is not None
            assert raw["before"]["scalar"]["error_before"] == raw["before"]["scalar"]["error_after"] == ""
            assert raw["before"]["list"]["error_before"] == raw["before"]["list"]["error_after"] == ""
            assert raw["before"]["list"]["count"] == 6
        else:
            assert raw["before"] is None
        if case_id in ERROR_RECEIVER_CASES:
            preparation = receiver["error_preparation"]
            assert preparation["value"] == 1 and preparation["value_defined"] is True
            assert preparation["error_before"] == "" and preparation["error_after"] == "[parse] Invalid date string"
            assert preparation["exception"] is None
        else:
            assert receiver["error_preparation"] is None

        call = raw["call"]
        after = raw["after"]
        feature_row = request_rows[case_id]
        for column, observer in (("wall result", "scalar"), ("GMT result", "gmt")):
            if column in feature_row:
                assert feature_row[column] == normalize_native(after[observer]["value"]), (case_id, column)
        if "native scalar" in feature_row:
            assert feature_row["native scalar"] == after["scalar"]["value"], case_id
        for column in ("fields", "returned fields"):
            if column in feature_row:
                fields = ", ".join("undefined" if value is None else str(value) for value in after["list"]["value"])
                assert feature_row[column] == fields, (case_id, column)
        if "status" in feature_row:
            assert feature_row["status"] == str(call["status"]), case_id
        for column, channel in (("call error", "error_after"), ("call error after", "error_after"), ("call error before", "error_before")):
            if column in feature_row:
                assert feature_row[column] == (call[channel] or "empty"), (case_id, column)
        if "warning count" in feature_row:
            assert int(feature_row["warning count"]) == len(observation["warnings"]), case_id
        if case_id in success_ids:
            assert call["status"] == 0 and call["status_defined"] is True
            assert call["exception"] is None and call["error_after"] == ""
            assert after["scalar"]["value_defined"] is True and after["scalar"]["value"] != ""
            assert after["list"]["count"] == 6
            for observer in ("scalar", "list", "local", "gmt"):
                assert after[observer]["error_before"] == after[observer]["error_after"] == ""
                assert after[observer]["exception"] is None
            scalar_literal = normalize_native(after["scalar"]["value"])
            gmt_literal = normalize_native(after["gmt"]["value"])
            assert scalar_literal in all_feature_text or after["scalar"]["value"] in all_feature_text, case_id
            assert gmt_literal in all_feature_text, case_id
        else:
            assert call["status"] is None if case_id in exception_ids else call["status"] == 1
            assert call["status_defined"] is (case_id not in exception_ids)
            if case_id in exception_ids:
                assert call["exception"].startswith(EXCEPTION_PREFIX[case_id])
                assert call["error_after"] == ""
            else:
                assert call["exception"] is None
                assert call["error_after"] == expected_errors[case_id]
            assert after["scalar"]["value"] == "" and after["scalar"]["value_defined"] is True
            assert after["scalar"]["error_before"] == call["error_after"]
            assert after["scalar"]["error_after"] == "[value] Object does not contain a date"
            assert after["list"]["value"] == [] and after["list"]["count"] == 0
            for observer in ("list", "local", "gmt"):
                assert after[observer]["error_before"] == after[observer]["error_after"] == "[value] Object does not contain a date"
                assert after[observer]["exception"] is None
        assert len(observation["warnings"]) == WARNING_COUNTS.get(case_id, 0), case_id

    by_id = {row["case_id"]: row["observation"]["raw_return"] for row in rows}
    assert by_id["DSET-ZONE-013-OVERLAP-DEFAULT"]["after"]["gmt"]["value"] == "2024110306:30:00"
    assert by_id["DSET-TIME-003-OVERLAP-DEFAULT"]["after"]["gmt"]["value"] == "2024110305:30:00"
    assert by_id["DSET-FIELD-027-OVERLAP-DEFAULT"]["after"]["gmt"]["value"] == "2024110305:30:00"
    malformed = by_id["DSET-FIELD-016-NONNUMERIC"]["after"]
    assert malformed["scalar"]["value"] == "204002nope16:05:09"
    assert malformed["list"]["value"] == [2040, 2, "nope", 16, 5, 9]
    undefined = by_id["DSET-FIELD-017-UNDEFINED"]["after"]
    assert undefined["scalar"]["value"] == "20400216:05:09"
    assert undefined["list"]["value"] == [2040, 2, None, 16, 5, 9]
    assert "@reference-binding @observed-compatibility @disputed" in all_feature_text
    print("reviewed 108 Date set cases, exact requests, mappings, observer boundaries, and feature literals")


if __name__ == "__main__":
    main()
