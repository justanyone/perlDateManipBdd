#!/usr/bin/env python3
"""Review input-history literals and required provenance; not a BDD result."""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/input-history"
DATE_LIB = ROOT / "local/date-manip-7.00/lib/perl5"
REQUIRED_MODULES = {
    "Date/Manip/Date.pm",
    "Date/Manip/Obj.pm",
    "Date/Manip/TZ.pm",
    "Date/Manip/Zones.pm",
    "Date/Manip/TZ/etutc00.pm",
}
REQUIRED_HEADER = {
    "schema_version", "purpose", "export_status", "reference", "repetitions",
    "timeout_seconds", "environment", "fixture_expectation", "runtime",
    "configured_zone", "loaded_module_paths", "loaded_module_sha256", "sha256",
    "observations",
}
REQUIRED_ROW = {
    "case_id", "request", "observation", "warnings", "call_stdout", "exception",
    "native_payload_sha256", "process_runs",
}


def load(name: str) -> dict:
    return json.loads((FAMILY / name).read_text())


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def scenario_blocks(text: str) -> list[tuple[str, str]]:
    matches = list(re.finditer(r"^  Scenario: Read remembered source text for (INPUT-[A-Z-]+)\n", text, re.M))
    return [(match.group(1), text[match.start():matches[index + 1].start() if index + 1 < len(matches) else len(text)])
            for index, match in enumerate(matches)]


def values(block: str, prefix: str) -> list[object]:
    return [json.loads(line.strip()[len(prefix):]) for line in block.splitlines()
            if line.strip().startswith(prefix)]


def main() -> None:
    data = load("observations.json")
    cases = load("cases.json")["cases"]
    mapping = load("feature-map.json")
    bindings = json.loads((ROOT / mapping["binding_file"]).read_text())
    missing_header = REQUIRED_HEADER - data.keys()
    assert not missing_header, f"missing evidence header fields: {sorted(missing_header)}"
    assert data["schema_version"] == 2 and data["repetitions"] == 2 and data["timeout_seconds"] == 15
    assert data["reference"] == {
        "release": "Date-Manip-7.00", "distribution_version": "7.00",
        "archive_sha256": "37133eeb09d36da6d461546cc216b8f6a2297a43331c680a6848f3fff925975c",
        "archive_url": "https://cpan.metacpan.org/authors/id/S/SB/SBECK/Date-Manip-7.00.tar.gz",
    }
    assert data["environment"] == {
        "PATH": "/usr/bin:/bin", "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8",
        "TZ": "Etc/UTC", "PERL5LIB": str(DATE_LIB),
    }
    expected_files = {
        "docs/research/input-history/cases.json",
        "docs/automation/reference-profiles.json",
        "docs/research/input-history/bindings.json",
        "tools/probes/input-history/probe.pl",
        "tools/probes/input-history/run.py",
        "tools/probes/input-history/review.py",
    }
    assert set(data["sha256"]) == expected_files
    for relative, digest in data["sha256"].items():
        assert sha256(ROOT / relative) == digest, relative
    profile = next(item for item in json.loads((ROOT / "docs/automation/reference-profiles.json").read_text())["profiles"] if item["name"] == "oo")
    assert data["fixture_expectation"] == {"profile_name": "oo", "ordered_configuration": profile["configuration"]}
    assert data["configured_zone"] == "Etc/UTC"
    assert set(data["runtime"]) == {"perl_version", "perl_archname", "os_name"}
    assert all(data["runtime"].values())
    assert REQUIRED_MODULES <= set(data["loaded_module_paths"])
    assert set(data["loaded_module_paths"]) == set(data["loaded_module_sha256"])
    for module, raw_path in data["loaded_module_paths"].items():
        path = Path(raw_path).resolve()
        assert path.is_file() and DATE_LIB in path.parents, (module, raw_path)
        assert sha256(path) == data["loaded_module_sha256"][module], module
    catalogue = {r["id"] for r in json.loads((ROOT / "docs/research/api/contract-map.json").read_text())["operations"]}
    binding_ids = {binding["operation_id"] for binding in bindings["bindings"]}
    assert {"date.read-input", "date.parse-text", "date.parse-date-only", "time.parse-text", "date.parse-pattern", "date.replace-field", "zone.convert-value", "error.read-state", "date.read-value"} <= binding_ids
    assert binding_ids <= catalogue
    assert all(set(row["public_operation_ids"]) <= binding_ids for row in mapping["cases"])
    list_binding = next(binding for binding in bindings["bindings"] if binding.get("variant") == "list-context")
    assert list_binding["classification"].startswith("observed-compatibility")
    assert "observed-compatibility" in mapping["classification"]
    text = (ROOT / mapping["feature"]).read_text()
    blocks = scenario_blocks(text)
    assert len(blocks) == len(cases) == len(data["observations"]) == len(mapping["cases"]) == 17
    for (feature_id, block), case, row, mapped in zip(blocks, cases, data["observations"], mapping["cases"]):
        cid = case["case_id"]
        assert feature_id == row["case_id"] == mapped["case_id"] == cid
        assert REQUIRED_ROW <= row.keys(), cid
        assert row["request"] == case and row["warnings"] == [] and row["exception"] is None and row["call_stdout"] == ""
        assert len(row["process_runs"]) == 2
        assert all(process == {"exit_code": 0, "stderr": ""} for process in row["process_runs"])
        assert re.fullmatch(r"[0-9a-f]{64}", row["native_payload_sha256"])
        observation = row["observation"]
        assert observation["configuration_call_executed"] == int("constructor_initial" not in case)
        assert ("configuration_return" in observation) == bool(observation["configuration_call_executed"])
        assert observation["configuration_error"] == "" and observation["version"] == observation["package_version"] == "7.00"
        assert observation["tzdata"] == "tzdata2026c" and observation["tzcode"] == "tzcode2026c"
        assert observation["configured_zone"] == data["configured_zone"]
        assert observation["runtime"] == data["runtime"]
        assert observation["loaded_module_paths"] == data["loaded_module_paths"]
        assert observation["profile_expected"] == data["fixture_expectation"]["ordered_configuration"]
        assert observation["input_list"] == [observation["input_scalar"]]
        assert observation["error_before_input"] == observation["error_after_scalar"] == observation["error_after_list"]
        assert values(block, "Then the action return is ") == [action["result"] for action in observation["actions"]]
        assert values(block, "And the immediate error is ") == [action["error"] for action in observation["actions"]]
        assert values(block, "Then the result is ") == [observation["input_scalar"]]
        assert values(block, "Then the collection is ") == [observation["input_list"]]
        assert values(block, "And the error is ") == [observation["error_before_input"], observation["error_after_list"], observation["error_after_value"]]
        assert [json.loads(line.split(" with arguments ", 1)[1]) for line in block.splitlines() if " with arguments " in line] == [action["arguments"] for action in case["actions"]]
        native = observation["value"]
        normalized = f"{native[:4]}-{native[4:6]}-{native[6:8]} {native[8:]}" if native else ""
        assert values(block, "Then the date-value text is ") == [normalized]
    print("17 input-history scenarios match exact request, result, error and carriers; required runtime, profile, module, hash, exit, and stderr provenance checked")


if __name__ == "__main__":
    main()
