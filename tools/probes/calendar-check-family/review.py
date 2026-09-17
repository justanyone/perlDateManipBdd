#!/usr/bin/env python3
"""Strictly verify calendar validation evidence and every frozen feature row."""
import datetime
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/calendar-check-family"
FEATURES = ROOT / "spec/drafts/calendar-checks"
MANIFEST = FAMILY / "cases.json"
EVIDENCE = FAMILY / "observations.json"
FIXTURE = ROOT / "docs/automation/reference-profiles.json"
PROBE = ROOT / "tools/probes/calendar-check-family/probe.pl"
RUNNER = ROOT / "tools/probes/calendar-check-family/run.py"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


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


def outcome(call):
    if not call["call_completed"]:
        return "no result because the request fails"
    return "valid" if call["return"] == 1 else "invalid"


def parse_tables(path):
    rows = []
    header = None
    for line in path.read_text().splitlines():
        if not line.strip().startswith("|"):
            header = None
            continue
        cells = [x.strip() for x in line.strip().strip("|").split("|")]
        if header is None:
            header = cells
            continue
        assert len(cells) == len(header), (path, line)
        rows.append(dict(zip(header, cells)))
    return rows


manifest = json.loads(MANIFEST.read_text())
evidence = json.loads(EVIDENCE.read_text())
fixture_doc = json.loads(FIXTURE.read_text())
fixture = next(p for p in fixture_doc["profiles"] if p["name"] == "oo")
cases = manifest["cases"]
rows = evidence["observations"]
ids = [case["case_id"] for case in cases]
assert len(ids) == 36 and len(ids) == len(set(ids))
assert [row["case_id"] for row in rows] == ids
assert manifest["canonical_operations"] == ["calendar.validate-time", "calendar.validate-date"]
assert evidence["execution"] == {
    "repetitions_per_case": 2, "parallel_workers": 4, "timeout_seconds": 15,
    "fresh_process_and_temporary_working_directory_per_attempt": True,
    "environment": {
        "PATH": "/usr/bin:/bin",
        "PERL5LIB": str(ROOT / "local/date-manip-7.00/lib/perl5"),
        "TZ": "Etc/UTC", "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8",
        "PERL_HASH_SEED": "0", "PERL_PERTURB_KEYS": "0",
    },
}
for path in (MANIFEST, PROBE, FIXTURE, RUNNER):
    assert evidence["sha256"][str(path.relative_to(ROOT))] == sha(path)
for section in ("installed_module_sha256", "research_source_sha256"):
    for key, digest in evidence[section].items():
        assert digest == sha(ROOT / key), key

obs_by_id = {}
for case, row in zip(cases, rows):
    assert row["research_status"] == "repeatable" and row["process_stderr_hex"] == ""
    obs = row["observation"]
    obs_by_id[case["case_id"]] = obs
    assert obs["case_id"] == case["case_id"]
    assert obs["request"] == case
    assert obs["operation_id"] == case["operation_id"]
    assert obs["profile"] == case["profile"] == "oo"
    assert obs["effective_configuration"] == fixture["configuration"]
    assert obs["fixture_reference"] == fixture_doc["reference"]
    assert obs["fixture_timezone_data"] == fixture["timezone_data"]
    assert obs["perl_version"] == "v5.40.1"
    assert obs["observed_distribution_version"] == "7.00"
    assert obs["observed_backend_version"] == "7.00"
    assert obs["load_warnings"] == [] and obs["load_stdout"] == ""
    assert obs["configuration_call_completed"] is True
    assert obs["configuration_return"] is None
    assert obs["configuration_return_type"] == "undefined"
    assert obs["configuration_exception"] is None
    assert obs["configuration_warnings"] == [] and obs["configuration_stdout"] == ""
    assert obs["dependent_operations_executed"] is True
    for loaded in obs["loaded_date_manip_module_files"].values():
        key = str(Path(loaded).relative_to(ROOT))
        assert key in evidence["installed_module_sha256"]
    assert [call["context"] for call in obs["calls"]] == ["scalar", "list"]
    scalar, listed = obs["calls"]
    for call in obs["calls"]:
        assert call["input"] == case["input"]
        assert call["stdout"] == ""
        assert call["error_observer"] == {
            "operation": "Base::err", "initial": "", "clear_call_completed": True,
            "clear_return": None, "clear_return_type": "undefined",
            "before": "", "after": "",
        }
        if call["call_completed"]:
            assert call["exception"] is None
            assert "return" in call and "return_type" in call
        else:
            assert call["exception"] is not None
            assert "return" not in call and "return_type" not in call
    assert scalar["call_completed"] == listed["call_completed"]
    assert scalar["warnings"] == listed["warnings"]
    if scalar["call_completed"]:
        assert scalar["return"] in (0, 1)
        assert listed["return"] == [scalar["return"]]
        assert listed["return_count"] == 1
    else:
        assert case["case_id"] == "CC-D-SCALAR-CARRIER"
        assert scalar["exception"] == listed["exception"]

# Independent valid facts: Python validates the selected Gregorian dates; the
# civil-clock upper endpoint is checked separately because datetime stops at 23.
valid_time_ids = {"CC-T-MIDNIGHT-NUMERIC", "CC-T-MIDNIGHT-ONE-DIGIT", "CC-T-MIDNIGHT-PADDED", "CC-T-LAST-SECOND", "CC-T-24-EXACT"}
for case_id in valid_time_ids:
    assert obs_by_id[case_id]["calls"][0]["return"] == 1
for case in cases:
    if case["case_id"] in {"CC-D-ORDINARY", "CC-D-LEAP-DAY", "CC-D-LOWER-ENDPOINT", "CC-D-UPPER-ENDPOINT", "CC-D-APRIL-END"}:
        y, m, d, h, minute, second = case["input"]["fields"]
        datetime.date(y, m, d)
        assert (0 <= h <= 23 and 0 <= minute <= 59 and 0 <= second <= 59) or (h, minute, second) == (24, 0, 0)
        assert obs_by_id[case["case_id"]]["calls"][0]["return"] == 1

documented_invalid = {case["case_id"] for case in cases
                      if case["disposition"] == "documented" and case["category"] == "invalid-value"}
assert len(documented_invalid) == 12
for case_id in documented_invalid:
    assert obs_by_id[case_id]["calls"][0]["return"] == 0

# Parse all features with the installed Gherkin parser.
feature_files = sorted(FEATURES.glob("*.feature"))
subprocess.run(
    ["perl", "-I" + str(ROOT / "local/bdd-runner/lib/perl5"),
     "-MTest::BDD::Cucumber::Parser", "-e",
     "Test::BDD::Cucumber::Parser->parse_file($_) for @ARGV", *map(str, feature_files)],
    cwd=ROOT, env={"PATH": "/usr/bin:/bin"}, check=True, capture_output=True,
)

generic_rows = {}
binding_rows = {}
for path in feature_files:
    for table_row in parse_tables(path):
        target = binding_rows if path.name == "perl-binding.feature" else generic_rows
        assert table_row["case"] not in target
        target[table_row["case"]] = table_row
assert set(binding_rows) == set(ids)
assert set(generic_rows) == set(ids) - {"CC-D-SCALAR-CARRIER"}

for case in cases:
    scalar, listed = obs_by_id[case["case_id"]]["calls"]
    bind = binding_rows[case["case_id"]]
    assert bind["operation"] == case["operation_id"]
    assert json.loads(bind["input"]) == case["input"]
    assert bind["scalar native"] == native(scalar)
    assert bind["list native"] == native(listed)
    assert bind["scalar diagnostic"] == diagnostics(scalar)
    assert bind["list diagnostic"] == diagnostics(listed)
    assert bind["scalar error after"] == compact(scalar["error_observer"]["after"])
    assert bind["list error after"] == compact(listed["error_observer"]["after"])
    if case["case_id"] in generic_rows:
        generic_row = generic_rows[case["case_id"]]
        assert generic_row["outcome"] == outcome(scalar)
        if "fields" in generic_row:
            assert json.loads(generic_row["fields"]) == case["input"]["fields"]
        else:
            assert generic_row["operation"] == case["operation_id"]
            assert json.loads(generic_row["input"]) == case["input"]
            assert generic_row["reason"] == case["note"]

feature_map = json.loads((FAMILY / "feature-map.json").read_text())
assert [entry["case_id"] for entry in feature_map["case_map"]] == ids
for case, entry in zip(cases, feature_map["case_map"]):
    assert entry["operation_id"] == case["operation_id"]
    assert entry["profile"] == case["profile"]
    assert entry["input"] == case["input"]
    assert entry["partition_id"] == case["partition_id"]
    assert entry["disposition"] == case["disposition"]
    assert (entry["portable_feature"] is None) == (case["case_id"] == "CC-D-SCALAR-CARRIER")
bindings = json.loads((FAMILY / "bindings.json").read_text())
assert bindings["aliases"] == [] and len(bindings["bindings"]) == 2
canonical = {op["id"] for op in json.loads((ROOT / "docs/research/api/contract-map.json").read_text())["operations"]}
assert set(feature_map["canonical_operations"]) <= canonical
coverage = json.loads((FAMILY / "coverage-map.json").read_text())
assert {p["partition_id"] for p in coverage["operation_partitions"]} == {
    f"calendar.validate-{kind}.p{n}" for kind in ("time", "date") for n in range(1, 5)
}
print("calendar-check-family: 36 cases, 72 native calls, 72 isolated attempts, exact rows, Gregorian facts, provenance, and Gherkin verified")
