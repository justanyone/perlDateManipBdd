#!/usr/bin/env python3
"""Reject changed public-call evidence or a feature detached from its rows."""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CASES = json.loads((ROOT / "docs/research/replace-time-family/cases.json").read_text())["cases"]
SOURCE_FEATURE = ROOT / "spec/drafts/replace-time/replace-time.feature"
PORTABLE_FEATURE = ROOT / "spec/drafts/replace-time/replace-time-portable.feature"
PORTABLE_MAP = json.loads((ROOT / "docs/research/replace-time-family/portable-case-map.json").read_text())
BINDINGS = json.loads((ROOT / "docs/research/replace-time-family/bindings.json").read_text())

SHARED = {
    "FIELDS-ORDINARY": "2040022907:08:09", "TEXT-HOUR": "2040022905:00:00",
    "TEXT-MINUTE": "2040022905:06:00", "TEXT-SECOND": "2040022905:06:07",
    "FIELDS-LOWER": "2040022900:00:00", "FIELDS-UPPER": "2040022923:59:59",
    "FIELDS-BAD-MINUTE": "", "FIELDS-NEGATIVE-HOUR": "", "BAD-DATE": "",
    "FIELDS-TWO": "2040022907:08:00",
}
DM5 = {"FIELDS-24":"", "TEXT-MERIDIAN":"", "TEXT-EXTRA-FIELD":"2040022905:06:07"}
DM6 = {"FIELDS-24":"2040022924:00:00"}
EXCEPTION_PREFIX = "Can't use an undefined value as an ARRAY reference"

def scalar_text(value: str) -> dict:
    return {"return":{"defined":True, "type":"text", "value":value}, "exception":None}

def expected(case_id: str, binding_file: str) -> dict:
    _, backend, suffix = case_id.split("-", 2)
    if backend == "DM5":
        value = DM5.get(suffix, SHARED.get(suffix))
        if value is None: raise AssertionError(f"no expected DM5 value for {case_id}")
        return scalar_text(value)
    if suffix in ("TEXT-MERIDIAN", "TEXT-EXTRA-FIELD"):
        return {"exception":f"{EXCEPTION_PREFIX} at {binding_file} line 551.\n"}
    value = DM6.get(suffix, SHARED.get(suffix))
    if value is None: raise AssertionError(f"no expected DM6 value for {case_id}")
    return scalar_text(value)

def extract_feature_rows(path: Path) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    header: list[str] | None = None
    for line in path.read_text().splitlines():
        if not line.strip().startswith("|"):
            header = None
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if header is None:
            header = cells
            continue
        if len(cells) != len(header): raise AssertionError(f"feature malformed row: {line}")
        row = dict(zip(header, cells))
        if "case" in row:
            if row["case"] in rows: raise AssertionError(f"feature repeats {row['case']}")
            rows[row["case"]] = row
    return rows

def render_time(arguments: list[object]) -> str:
    values = arguments[1:]
    if len(values) == 1:
        return f'time text "{values[0]}"'
    return "ordered fields [" + ", ".join(str(value) for value in values) + "]"

def render_scalar(context: dict) -> str:
    if context["exception"]:
        if "return" in context: raise AssertionError("exception context invented a return")
        return f'no return; exception prefix "{EXCEPTION_PREFIX}"'
    value = context["return"]
    if value == {"defined":True, "type":"text", "value":""}: return "defined empty text"
    return f'text "{value["value"]}"'

def render_list(context: dict) -> str:
    if context["exception"]:
        if "items" in context: raise AssertionError("exception list context invented items")
        return "no returned items; same exception prefix"
    items = context["items"]
    if items == [{"defined":True, "type":"text", "value":""}]: return "one defined empty text"
    if len(items) != 1: raise AssertionError(f"unexpected returned list {items!r}")
    return f'one text "{items[0]["value"]}"'

def expected_diagnostic(backend: str) -> str:
    tail = "no warning" if backend == "dm6" else "one DM5 module-load deprecation warning"
    return f"no call stdout; no process stderr; {tail}"

def generic_result(context: dict) -> str:
    if context["exception"]: raise AssertionError("portable map includes exception case")
    value = context["return"]
    return "empty text" if value["value"] == "" else f'text "{value["value"]}"'

def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def verify_provenance(result: dict, observations: list[dict]) -> None:
    for relative, expected_hash in result["sha256"].items():
        path = ROOT / relative
        if not path.is_file() or digest(path) != expected_hash:
            raise AssertionError(f"artifact hash differs: {relative}")
    for backend, expected_hashes in result["loaded_module_sha256_by_backend"].items():
        source = next(row for row in observations if row["request"]["backend"] == backend)
        paths = source["loaded_module_paths"]
        if set(paths) != set(expected_hashes):
            raise AssertionError(f"{backend}: module hash set differs")
        for module, expected_hash in expected_hashes.items():
            path = Path(paths[module])
            if not path.is_file() or digest(path) != expected_hash:
                raise AssertionError(f"{backend}: module hash differs for {module}")

def main() -> None:
    if len(sys.argv) != 2: raise SystemExit("usage: review.py RESULT.json")
    result = json.loads(Path(sys.argv[1]).read_text())
    observations = result["observations"]
    source_rows = extract_feature_rows(SOURCE_FEATURE)
    portable_rows = extract_feature_rows(PORTABLE_FEATURE)
    if "@excluded-from-portable-handoff" not in SOURCE_FEATURE.read_text():
        raise AssertionError("native source-binding feature lacks exclusion tag")
    portable_text = PORTABLE_FEATURE.read_text()
    if "@portable" not in portable_text or any(word in portable_text.lower() for word in ("scalar", "list", "warning", "stderr", "perl")):
        raise AssertionError("portable feature contains native-channel assertions")
    binding_diagnostics = BINDINGS["reference_binding_diagnostic_cases"]
    if [row["case_id"] for row in binding_diagnostics] != ["RT-DM6-TEXT-MERIDIAN", "RT-DM6-TEXT-EXTRA-FIELD"]:
        raise AssertionError("binding diagnostic case map differs")
    for diagnostic in binding_diagnostics:
        if diagnostic["scalar_context"] != "no return" or diagnostic["list_context"] != "no returned items" or diagnostic["exception_prefix"] != EXCEPTION_PREFIX:
            raise AssertionError(f"{diagnostic['case_id']}: binding diagnostic mapping differs")
    expected_ids = [case["case_id"] for case in CASES]
    if [row["case_id"] for row in observations] != expected_ids:
        raise AssertionError("case set/order differs from reviewed corpus")
    if set(source_rows) != set(expected_ids):
        raise AssertionError("feature rows do not map one-to-one to evidence cases")
    portable_pairs = PORTABLE_MAP["cases"]
    portable_ids = [pair["portable_case_id"] for pair in portable_pairs]
    observed_ids = [pair["observation_case_id"] for pair in portable_pairs]
    expected_portable = [case["case_id"] for case in CASES if case["classification"] == "portable"]
    if set(portable_rows) != set(portable_ids) or observed_ids != expected_portable or len(portable_ids) != 18:
        raise AssertionError("portable case map does not cover the 18 documented rows")
    verify_provenance(result, observations)
    portable_by_observation = {pair["observation_case_id"]: portable_rows[pair["portable_case_id"]] for pair in portable_pairs}
    for row, case in zip(observations, CASES):
        cid = case["case_id"]
        if row["request"] != case: raise AssertionError(f"{cid}: stored request differs")
        expected_configuration_return = {"defined":True, "type":"text", "value":""}
        expected_zone = "etc/utc"
        if case["backend"] == "dm5":
            expected_configuration_return = {"defined":True, "type":"text", "value":"IgnoreGlobalCnf=1"}
            expected_zone = "UTC"
        if row["configuration_return"] != expected_configuration_return or row["configured_zone"] != expected_zone:
            raise AssertionError(f"{cid}: configuration provenance differs")
        want = expected(cid, row["loaded_binding_file"])
        if row["scalar_context"] != want: raise AssertionError(f"{cid}: scalar observation differs")
        list_want = {"exception":want["exception"]}
        if want["exception"] is None: list_want["items"] = [want["return"]]
        if row["list_context"] != list_want: raise AssertionError(f"{cid}: list observation differs")
        if row["call_stdout"] or row["exception"] is not None or row["process_runs"] != [{"exit_code":0,"stderr":""}]*2:
            raise AssertionError(f"{cid}: unexpected process behavior")
        warnings = row["warnings"]
        if case["backend"] == "dm6" and warnings: raise AssertionError(f"{cid}: unexpected DM6 warnings")
        if case["backend"] == "dm5":
            warning = "Date::Manip::DM5 is deprecated and will be removed from the Date::Manip package starting in version 7.00 at (eval 42) line 1.\n"
            if warnings != [warning]: raise AssertionError(f"{cid}: DM5 warning differs")
        feature = source_rows[cid]
        profile = {"dm6":"current DM6", "dm5":"legacy DM5"}[case["backend"]]
        if feature["profile"] != profile or feature["time request"] != render_time(case["arguments"]):
            raise AssertionError(f"{cid}: feature binding or time arguments differ")
        if feature["date text"] != case["arguments"][0]:
            raise AssertionError(f"{cid}: feature date input differs")
        if feature["scalar outcome"] != render_scalar(row["scalar_context"]):
            raise AssertionError(f"{cid}: feature scalar outcome differs")
        if feature["list outcome"] != render_list(row["list_context"]):
            raise AssertionError(f"{cid}: feature list outcome differs")
        if feature["diagnostic"] != expected_diagnostic(case["backend"]):
            raise AssertionError(f"{cid}: feature diagnostic differs")
        if cid in portable_by_observation:
            portable = portable_by_observation[cid]
            portable_profile = {"dm6":"current functional", "dm5":"legacy compatibility"}[case["backend"]]
            if (portable["profile"] != portable_profile or portable["date text"] != case["arguments"][0]
                    or portable["time request"] != render_time(case["arguments"])
                    or portable["result"] != generic_result(row["scalar_context"])):
                raise AssertionError(f"{cid}: portable feature differs from mapped evidence")
    print(f"reviewed {len(observations)} source rows and 18 portable mappings; hashes, inputs, results, and diagnostics match")

if __name__ == "__main__": main()
