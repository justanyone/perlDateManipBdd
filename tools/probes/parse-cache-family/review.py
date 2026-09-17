#!/usr/bin/env python3
"""Review parse/value-history features directly against frozen public observations."""
from collections import Counter
import hashlib
import json
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/parse-cache-family"
FEATURE_DIR = ROOT / "spec/drafts/parse-cache"
PORTABLE = ("partial-mutation-cache.feature", "full-parse-reset.feature")
CARRIERS = {"parsed": "parsed-zone", "local": "fixed-local", "gmt": "UTC"}


def load(path):
    return json.loads(path.read_text())


def public_sequence(actions):
    rendered = []
    for action in actions:
        name, *arguments = action
        if name == "parse":
            rendered.append(f'parse complete text "{arguments[0]}"')
        elif name == "parse_date":
            rendered.append(f'parse date-only text "{arguments[0]}"')
        elif name == "parse_time":
            rendered.append(f'parse time-only text "{arguments[0]}"')
        elif name == "clear_error":
            rendered.append("clear error")
        elif name == "value":
            carrier, context = arguments
            presentation = "serialized value" if context == "scalar" else "ordered fields"
            rendered.append(f"read {CARRIERS[carrier]} {presentation}")
        else:
            raise AssertionError(name)
    return "; ".join(rendered)


def scenario_blocks(text):
    matches = list(re.finditer(r"^  Scenario(?: Outline)?: (.+)$", text, re.M))
    for index, match in enumerate(matches):
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        title = match.group(1).removesuffix(" for <case>")
        yield title, text[match.start():end]


def table_rows(block, id_header):
    header = None
    rows = []
    for line in block.splitlines():
        if not line.lstrip().startswith("|"):
            header = None
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if cells and cells[0] == id_header:
            header = cells
        elif header:
            rows.append(dict(zip(header, cells)))
    return rows


def portable_cases(feature_texts):
    found = {}
    for feature, text in feature_texts.items():
        for title, block in scenario_blocks(text):
            rows = table_rows(block, "case")
            if rows:
                for row in rows:
                    case_id = row["case"]
                    rendered = block
                    for key, value in row.items():
                        rendered = rendered.replace(f"<{key}>", value)
                    found[case_id] = {
                        "feature": feature,
                        "scenario": title,
                        "sequence": row["exact public action sequence"],
                        "rendered": rendered,
                    }
                continue
            ids = re.findall(r'case "(PC-[A-Z0-9-]+)"', block)
            assert len(ids) == 1, (feature, title, ids)
            sequence = re.search(r'exact public action sequence is "(.*)"$', block, re.M)
            assert sequence, ids[0]
            found[ids[0]] = {
                "feature": feature,
                "scenario": title,
                "sequence": sequence.group(1).replace(r'\"', '"'),
                "rendered": block.replace(r'\"', '"'),
            }
    return found


def normalized_text(value):
    match = re.fullmatch(r"(\d{4})(\d{2})(\d{2})(\d{2}):(\d{2}):(\d{2})", value)
    assert match, value
    return f"{match[1]}-{match[2]}-{match[3]} {match[4]}:{match[5]}:{match[6]}"


def stable_warning(warning):
    return warning.split(" at /home/", 1)[0]


def binding_rows(text):
    rows = {}
    for _, block in scenario_blocks(text):
        for row in table_rows(block, "binding case"):
            assert row["binding case"] not in rows
            rows[row["binding case"]] = row
    return rows


def main():
    corpus = load(FAMILY / "cases.json")
    cases = corpus["cases"]
    case_by_id = {case["case_id"]: case for case in cases}
    evidence = load(FAMILY / "observations.json")
    observations = {row["case_id"]: row for row in evidence["observations"]}
    mapping = load(FAMILY / "feature-map.json")
    bindings = load(FAMILY / "bindings.json")
    assert len(cases) == len(case_by_id) == len(observations) == 30

    for path, digest in evidence["sha256"].items():
        assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest, path
    assert evidence["execution"] == {
        "repetitions": 2,
        "timeout_seconds": 15,
        "parallel_workers": 4,
        "fresh_temporary_working_directory_per_case": True,
        "environment": {
            "PATH": "/usr/bin:/bin",
            "PERL5LIB": str(ROOT / "local/date-manip-7.00/lib/perl5"),
            "TZ": "Etc/UTC", "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8",
        },
    }

    contract_ids = {
        operation["id"]
        for operation in load(ROOT / "docs/research/api/contract-map.json")["operations"]
    }
    assert all(binding["operation_id"] in contract_ids for binding in bindings["bindings"])

    feature_texts = {name: (FEATURE_DIR / name).read_text() for name in PORTABLE}
    portable_text = "\n".join(feature_texts.values())
    text_without_ids = re.sub(r"PC-[A-Z0-9-]+", "", portable_text)
    for forbidden in ("Perl", "Date::Manip", "ARRAY reference", "warning", "exception"):
        assert forbidden not in text_without_ids, forbidden
    assert not re.search(r"\bscalar\b|\blist context\b", text_without_ids, re.I)
    for text in feature_texts.values():
        assert 'Date-Manip 7.00 with tzdata "tzdata2026c"' in text
        assert "English ASCII context with US numeric-date order and default time midnight" in text
        assert 'fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"' in text
        assert 'configured local zone is "Etc/UTC"' in text
        assert "every error boundary not stated as nonempty is empty" in text
        assert "clearing an error produces no application value and leaves the error empty" in text
    for _, block in scenario_blocks(portable_text):
        assert "cache" not in block.splitlines()[0].lower()
    full_text = feature_texts["full-parse-reset.feature"]
    assert "not requested" not in full_text and "| none" not in full_text

    mentions = re.findall(r"PC-(?:DATE|TIME|PARSE)-[A-Z0-9-]+", portable_text)
    assert Counter(mentions) == Counter(case_by_id.keys()), Counter(mentions)
    feature_cases = portable_cases(feature_texts)
    assert set(feature_cases) == set(case_by_id)

    legacy_ids = [case_id for group in mapping["features"].values() for case_id in group]
    assert len(legacy_ids) == len(set(legacy_ids)) == 30
    assert set(legacy_ids) == set(case_by_id)
    case_mappings = mapping["case_mappings"]
    assert [row["case_id"] for row in case_mappings] == [case["case_id"] for case in cases]
    for mapped in case_mappings:
        case_id = mapped["case_id"]
        feature_case = feature_cases[case_id]
        assert mapped["feature"] == feature_case["feature"]
        assert mapped["scenario"] == feature_case["scenario"]
        assert mapped["operation_ids"] == observations[case_id]["observation"]["operation_ids"]

    interrupted_calls = []
    completed_absent_calls = []
    for case in cases:
        case_id = case["case_id"]
        feature_case = feature_cases[case_id]
        assert feature_case["sequence"] == public_sequence(case["actions"]), case_id
        row = observations[case_id]
        assert row["research_status"] == "repeatable" and row["process_stderr"] == ""
        observation = row["observation"]
        assert observation["request"] == case
        assert observation["exception"] is None and observation["call_stdout"] == ""
        assert observation["configuration_status"] is None
        assert observation["configuration_error"] == ""
        assert observation["distribution_version"] == observation["backend_version"] == "7.00"
        assert observation["tzdata"] == "tzdata2026c"
        sequence = observation["sequence"]
        assert sequence[0]["action"] == "initialize"
        assert sequence[0]["input"] == corpus["initial_text"]
        assert sequence[0]["call_completed"] is True
        assert sequence[0]["action_exception"] is None
        assert sequence[0]["result"] == 0 and sequence[0]["error_after"] == ""
        assert len(sequence) == len(case["actions"]) + 1
        rendered = feature_case["rendered"]
        for requested, actual in zip(case["actions"], sequence[1:]):
            assert [actual["action"], *actual["arguments"]] == requested
            assert actual["error_before"] in rendered or actual["error_before"] == ""
            assert actual["error_after"] in rendered or actual["error_after"] == ""
            if actual["call_completed"] is False:
                assert actual["action_exception"]
                assert "result" not in actual and "result_type" not in actual
                assert actual["action"] == "value"
                assert "fails without producing a serialized value" in rendered
                interrupted_calls.append((case_id, actual["index"]))
                continue
            assert actual["call_completed"] is True
            assert actual["action_exception"] is None
            assert "result" in actual and "result_type" in actual
            if actual["result"] is None:
                completed_absent_calls.append((case_id, actual["index"]))
            if actual["action"] in ("parse", "parse_date", "parse_time"):
                assert re.search(fr"status(?: is)? {actual['result']}\b", rendered), (
                    case_id, actual["action"], actual["result"]
                )
            elif actual["action"] == "value":
                result = actual["result"]
                if isinstance(result, str) and result:
                    assert normalized_text(result) in rendered, (case_id, result)
                elif isinstance(result, list):
                    assert "[" + ", ".join(map(str, result)) + "]" in rendered, (case_id, result)
                elif result == "":
                    assert "empty text" in rendered, case_id
                else:
                    assert "no serialized value" in rendered, case_id
            elif actual["action"] == "clear_error":
                assert actual["result"] is None and actual["result_type"] == "absent"
                assert actual["error_after"] == ""
        assert sum((step["warnings"] for step in sequence[1:]), []) == observation["warnings"]

    assert interrupted_calls == [
        ("PC-PARSE-FAIL-LOCAL-OBSERVER", 3),
        ("PC-PARSE-FAIL-GMT-OBSERVER", 3),
    ]
    assert len(completed_absent_calls) == 8

    binding_text = (FEATURE_DIR / "perl-binding.feature").read_text()
    assert binding_text.startswith(
        "@draft @reference-dm700 @parse-cache @source-binding @perl-binding @excluded-from-portable-handoff"
    )
    rows = binding_rows(binding_text)
    assert set(rows) == {row["binding_case_id"] for row in mapping["binding_case_mappings"]}
    source_operations = {row["case_id"]: row["operation_ids"] for row in case_mappings}
    for binding_mapping in mapping["binding_case_mappings"]:
        assert binding_mapping["operation_ids"] == source_operations[binding_mapping["source_case_id"]]
    exception_prefix = "Can't use an undefined value as an ARRAY reference"
    warning_cases = {"PC-PARSE-FAIL-LOCAL-OBSERVER", "PC-PARSE-FAIL-GMT-OBSERVER"}
    for suffix, source_case, selector in (
        ("LOCAL", "PC-PARSE-FAIL-LOCAL-OBSERVER", "local"),
        ("GMT", "PC-PARSE-FAIL-GMT-OBSERVER", "gmt"),
    ):
        sequence = observations[source_case]["observation"]["sequence"]
        failed = next(step for step in sequence if step.get("action_exception"))
        exception_row = rows[f"PC-BIND-EXCEPTION-{suffix}"]
        assert exception_row["source case"] == source_case
        assert exception_row["native value request"] == f'value("{selector}") in scalar context'
        assert exception_row["exception prefix"] == exception_prefix
        exception_mapping = next(
            item for item in mapping["binding_case_mappings"]
            if item["binding_case_id"] == f"PC-BIND-EXCEPTION-{suffix}"
        )
        assert exception_mapping["call_completed"] is False
        assert exception_mapping["return_fields"] == "omitted"
        assert failed["action_exception"].startswith(exception_prefix)
        assert failed["call_completed"] is False
        assert "result" not in failed and "result_type" not in failed
        assert failed["error_before"] == failed["error_after"] == ""
        assert exception_row["recovery result"] == sequence[-1]["result"]

        warning_row = rows[f"PC-BIND-WARNINGS-{suffix}"]
        warnings = observations[source_case]["observation"]["warnings"]
        assert warning_row["source case"] == source_case
        assert int(warning_row["warning count"]) == len(warnings) == 8
        assert warning_row["ordered warning prefixes"] == "; ".join(map(stable_warning, warnings))
    assert all(
        not row["observation"]["warnings"]
        for case_id, row in observations.items() if case_id not in warning_cases
    )

    assertions = mapping["binding_assertions"]
    assert mapping["observation_schema"] == {
        "call_completed_true": (
            "result and result_type record the completed public call, including an absent value"
        ),
        "call_completed_false": (
            "action_exception records interruption; result and result_type are omitted because no value returned"
        ),
        "interrupted_source_case_ids": [
            "PC-PARSE-FAIL-LOCAL-OBSERVER", "PC-PARSE-FAIL-GMT-OBSERVER"
        ],
    }
    assert len(assertions) == 2 and len(mapping["binding_case_mappings"]) == 4
    for assertion in assertions:
        assert binding_text.count("@" + assertion["assertion_id"]) == 1
        assert f"Scenario: {assertion['scenario']}" in binding_text
        assert set(assertion["source_case_ids"]) <= set(case_by_id)
        if assertion["assertion_id"] == "PC-BIND-EXCEPTIONS":
            assert assertion["return_semantics"] == (
                "the public value call is interrupted; it has no returned value or return-type field"
            )
    assert mapping["mapping_gaps"] == []
    print("reviewed 30 parse/value sequences, 30 exact portable rows, 2 interrupted calls without return fields, and 4 excluded binding rows")


if __name__ == "__main__":
    main()
