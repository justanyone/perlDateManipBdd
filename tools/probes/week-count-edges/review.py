#!/usr/bin/env python3
"""Verify every week-count edge request, observation, mapping, and feature row."""
import datetime as dt
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/week-count-edges"
FEATURES = ROOT / "spec/drafts/week-count-edges"
MANIFEST = FAMILY / "cases.json"
EVIDENCE = FAMILY / "observations.json"
PROFILE_DOC = ROOT / "docs/automation/reference-profiles.json"
PROBE = ROOT / "tools/probes/week-count-edges/probe.pl"
RUNNER = ROOT / "tools/probes/week-count-edges/run.py"


def load(path):
    return json.loads(path.read_text())


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


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
    assert "return" in call and "return_type" in call
    value, kind = call["return"], call["return_type"]
    if kind == "undefined":
        assert value is None
        return "completed with undefined scalar"
    if kind == "ARRAY":
        assert isinstance(value, list)
        return "list " + compact(value)
    assert kind == "scalar" and not isinstance(value, (dict, list))
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


def parse_rows(path):
    rows, header = [], None
    for line in path.read_text().splitlines():
        if not line.lstrip().startswith("|"):
            header = None
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if header is None:
            header = cells
        else:
            assert len(cells) == len(header), (path, line)
            rows.append(dict(zip(header, cells)))
    return rows


manifest, evidence, profile_doc = load(MANIFEST), load(EVIDENCE), load(PROFILE_DOC)
cases = manifest["cases"]
observations = evidence["observations"]
profile = next(item for item in profile_doc["profiles"] if item["name"] == "oo")
case_ids = [case["case_id"] for case in cases]
assert manifest == {
    "schema_version": 1,
    "operation_id": "calendar.weeks-in-year",
    "fixture": "oo",
    "cases": cases,
}
assert len(case_ids) == 14 and len(set(case_ids)) == 14
assert [row["case_id"] for row in observations] == case_ids
assert sum(len(case["steps"]) for case in cases) == 22

# The execution envelope and all files that determine the raw observation are exact.
assert evidence["status"] == "repeatable research only"
assert evidence["repetitions"] == 2
assert evidence["fresh_process_and_workdir"] is True
assert evidence["timeout_seconds"] == 20 and evidence["workers"] == 4
assert evidence["environment"] == {
    "PATH": "/usr/bin:/bin",
    "PERL5LIB": str(ROOT / "local/date-manip-7.00/lib/perl5"),
    "TZ": "Etc/UTC", "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8",
    "PERL_HASH_SEED": "0", "PERL_PERTURB_KEYS": "0",
}
for path in (MANIFEST, PROFILE_DOC, PROBE, RUNNER):
    key = str(path.relative_to(ROOT))
    assert evidence["source_sha256"][key] == sha(path), key
assert set(evidence["source_sha256"]) == {
    str(path.relative_to(ROOT)) for path in (MANIFEST, PROFILE_DOC, PROBE, RUNNER)
}
for section in ("loaded_sha256", "research_source_sha256"):
    for key, digest in evidence[section].items():
        assert digest == sha(ROOT / key), key
assert set(evidence["research_source_sha256"]) == {
    "local/date-manip-7.00/lib/perl5/Date/Manip/Base.pm",
    "local/date-manip-7.00/lib/perl5/Date/Manip/Base.pod",
    "local/date-manip-7.00/lib/perl5/Date/Manip/Obj.pm",
    "docs/research/contracts/calendar.json",
}

requested_configuration = [entry for entry in profile["configuration"]
                           if not entry.startswith("ForceDate=")]
assert len(profile["configuration"]) == len(requested_configuration) + 1
assert not any(entry.startswith("ForceDate=") for entry in requested_configuration)
obs_by_id = {}
native_call_count = 0
for case, obs in zip(cases, observations):
    obs_by_id[case["case_id"]] = obs
    assert obs["request"] == case and obs["case_id"] == case["case_id"]
    assert obs["fixture"] == profile
    assert obs["requested_configuration"] == requested_configuration
    assert obs["reference"] == profile_doc["reference"]
    assert obs["version"] == "7.00"
    assert obs["perl_version"] == "v5.40.1"
    assert obs["perl_archname"] == profile_doc["execution"]["perl_archname"]
    assert obs["os_name"] == profile_doc["execution"]["os_name"] == "linux"
    for name, raw_path in obs["loaded"].items():
        path = Path(raw_path).resolve()
        assert path == ROOT / "local/date-manip-7.00/lib/perl5" / name
        assert evidence["loaded_sha256"][str(path.relative_to(ROOT))] == sha(path)
    setup = obs["setup"]
    assert setup == {
        "call_completed": True, "return": None, "return_type": "undefined",
        "exception": None, "warnings": [], "stdout": "",
    }
    assert len(obs["steps"]) == len(case["steps"])
    for request, step in zip(case["steps"], obs["steps"]):
        assert step["request"] == request
        assert step["error_before"] == step["error_after"] == ""
        expected_keys = {"request", "error_before", "scalar", "error_after"}
        if request["operation"] == "weeks_in_year":
            expected_keys |= {"repeated_scalar", "list"}
        assert set(step) == expected_keys
        calls = [step["scalar"]]
        if request["operation"] == "weeks_in_year":
            calls += [step["repeated_scalar"], step["list"]]
        native_call_count += len(calls)
        for call in calls:
            assert call["call_completed"] is True
            assert call["exception"] is None and call["stdout"] == ""
            assert "return" in call and "return_type" in call
        if request["operation"] == "weeks_in_year":
            scalar, repeated, listed = calls
            assert scalar["return_type"] == repeated["return_type"] == "scalar"
            assert listed["return_type"] == "ARRAY"
            assert scalar["return"] == repeated["return"]
            assert listed["return"] == [scalar["return"]]
        else:
            assert step["scalar"]["return_type"] == "undefined"
            assert step["scalar"]["return"] is None
assert native_call_count == 58

# Literal outcome and cache-sensitive warning checks.
for case_id in case_ids[:11]:
    assert obs_by_id[case_id]["steps"][0]["scalar"]["return"] == 52
warning_counts = {
    "WCE-OMITTED": [12, 2, 2], "WCE-ABSENT": [12, 2, 2],
    "WCE-EMPTY": [3, 0, 0], "WCE-TEXT": [3, 0, 0],
}
for case_id, expected in warning_counts.items():
    step = obs_by_id[case_id]["steps"][0]
    assert [len(step[name]["warnings"]) for name in ("scalar", "repeated_scalar", "list")] == expected
for case_id in set(case_ids) - set(warning_counts) - {"WCE-BAD-FIRSTDAY", "WCE-BAD-WEEKRULE"}:
    for step in obs_by_id[case_id]["steps"]:
        for name in ("scalar", "repeated_scalar", "list"):
            if name in step:
                assert step[name]["warnings"] == []
aba = obs_by_id["WCE-CONFIG-ABA"]["steps"]
assert [step["scalar"]["return"] for step in aba if step["request"]["operation"] == "weeks_in_year"] == [52, 53, 52]
for case_id in ("WCE-BAD-FIRSTDAY", "WCE-BAD-WEEKRULE"):
    steps = obs_by_id[case_id]["steps"]
    assert [steps[0]["scalar"]["return"], steps[2]["scalar"]["return"]] == [52, 52]
    assert len(steps[1]["scalar"]["warnings"]) == 1

# Independent civil-calendar facts; no Date-Manip call calculates these checks.
assert dt.date(1, 12, 28).isocalendar().week == 52
assert dt.date(9999, 12, 28).isocalendar().week == 52
assert (9999 - 1999) % 400 == 0 and dt.date(1999, 12, 28).isocalendar().week == 52


def week_start(year, january_day):
    anchor = dt.date(year, 1, january_day)
    return anchor - dt.timedelta(days=anchor.isoweekday() - 1)


assert (week_start(2001, 4) - week_start(2000, 4)).days // 7 == 52
assert (week_start(2001, 1) - week_start(2000, 1)).days // 7 == 53

# Parse all four draft files with the repository's real Gherkin parser.
feature_files = sorted(FEATURES.glob("*.feature"))
assert [path.name for path in feature_files] == [
    "configuration-state.feature", "endpoint-years.feature",
    "perl-binding.feature", "year-input-compatibility.feature",
]
subprocess.run(
    ["perl", "-I" + str(ROOT / "local/bdd-runner/lib/perl5"),
     "-MTest::BDD::Cucumber::Parser", "-e",
     "Test::BDD::Cucumber::Parser->parse_file($_) for @ARGV",
     *map(str, feature_files)],
    cwd=ROOT, env={"PATH": "/usr/bin:/bin"}, check=True, capture_output=True,
)

portable_rows, binding_rows = {}, {}
for path in feature_files:
    rows = parse_rows(path)
    target = binding_rows if path.name == "perl-binding.feature" else portable_rows
    key = "binding step" if target is binding_rows else "case"
    for row in rows:
        assert row[key] not in target
        target[row[key]] = row
assert len(portable_rows) == 14 and len(binding_rows) == 22


def portable_step(request):
    if request["operation"] == "weeks_in_year":
        return {"request": "count configured weeks", "typed arguments": request["arguments"]}
    setting, value = request["arguments"]
    return {"request": "set first weekday" if setting == "FirstDay" else "set week-one rule",
            "value": value}


for case in cases:
    obs = obs_by_id[case["case_id"]]
    row = portable_rows[case["case_id"]]
    count_trace = [step["scalar"]["return"] for step in obs["steps"]
                   if step["request"]["operation"] == "weeks_in_year"]
    if len(case["steps"]) == 1:
        assert row == {"case": case["case_id"],
                       "arguments": compact(case["steps"][0]["arguments"]),
                       "count": str(count_trace[0])}
    else:
        config_steps = [step for step in obs["steps"]
                        if step["request"]["operation"] == "config"]
        assert row == {
            "case": case["case_id"],
            "sequence": compact([portable_step(step) for step in case["steps"]]),
            "count trace": compact(count_trace),
            "configuration requests": compact([portable_step(step["request"]) for step in config_steps]),
            "configuration outcome trace": compact([
                "rejected" if step["scalar"]["warnings"] else "accepted"
                for step in config_steps
            ]),
        }
    for index, step in enumerate(obs["steps"], 1):
        binding_id = f"{case['case_id']}-S{index:02d}"
        bind = binding_rows[binding_id]
        assert bind == {
            "binding step": binding_id, "case": case["case_id"],
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
        }

# All stable IDs, profiles, partitions, and source bindings are mapped exactly.
feature_map = load(FAMILY / "feature-map.json")
assert feature_map["canonical_operation"] == manifest["operation_id"]
assert [entry["case_id"] for entry in feature_map["case_map"]] == case_ids
expected_profile = {"first_weekday": 1, "first_weekday_name": "Monday", "week_one_rule": "jan4"}
for case, entry in zip(cases, feature_map["case_map"]):
    assert entry["operation_id"] == manifest["operation_id"]
    assert entry["portable_profile"] == expected_profile
    assert entry["reference_fixture"] == "oo with ForceDate deliberately omitted for the direct Base service"
    assert entry["request_steps"] == case["steps"]
    assert entry["binding_steps"] == [f"{case['case_id']}-S{i:02d}" for i in range(1, len(case["steps"]) + 1)]
    assert entry["binding_feature"] == "spec/drafts/week-count-edges/perl-binding.feature"
    assert entry["observation"] == "docs/research/week-count-edges/observations.json"
    assert all(part.startswith("calendar.weeks-in-year.p") for part in entry["partition_ids"])
bindings = load(FAMILY / "bindings.json")
assert bindings["operation"] == {
    "operation_id": "calendar.weeks-in-year", "module": "Date::Manip::Base",
    "callable": "weeks_in_year", "call_shape": "(year)",
    "disposition": "public-oo-method",
}
assert bindings["aliases"] == [] and len(bindings["supporting_public_calls"]) == 3
canonical = {operation["id"]: operation for operation in
             load(ROOT / "docs/research/api/contract-map.json")["operations"]}
assert bindings["operation"] | {"profile": "dm6-reference"} == canonical["calendar.weeks-in-year"]["bindings"][0] | {"operation_id": "calendar.weeks-in-year", "call_shape": "(year)"}
coverage = load(FAMILY / "coverage-map.json")
assert {row["partition_id"] for row in coverage["partition_updates"]} == {
    f"calendar.weeks-in-year.p{i}" for i in range(1, 5)
}
assert next(row for row in coverage["partition_updates"] if row["partition_id"].endswith("p4"))["status"] == "observed-selected-not-complete"
source_review = load(FAMILY / "source-review.json")
assert source_review["private_calls_made_by_probe"] == []
assert source_review["documented_public_binding"]["callable"] == "weeks_in_year"
assert source_review["hash_source"] == "docs/research/week-count-edges/observations.json#research_source_sha256"

# Portable prose contains no Perl/source callable or native diagnostics.
for path in feature_files:
    text = path.read_text()
    if path.name == "perl-binding.feature":
        assert "@excluded-from-portable-handoff" in text.splitlines()[0]
    else:
        assert "weeks_in_year" not in text and "Date::Manip" not in text and "Perl" not in text
        assert "Use of uninitialized" not in text and "isn't numeric" not in text

print("week-count-edges: 14 cases, 22 steps, 58 native calls, exact profiles/carriers/diagnostics/rows/hashes, independent facts, and Gherkin verified")
