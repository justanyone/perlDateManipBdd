#!/usr/bin/env python3
"""Verify calendar-length evidence, source bindings, and every frozen literal."""
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/calendar-lengths-family"
FEATURES = ROOT / "spec/drafts/calendar-lengths"
MANIFEST = FAMILY / "cases.json"
EVIDENCE = FAMILY / "observations.json"
FIXTURE = ROOT / "docs/automation/reference-profiles.json"
PROBE = ROOT / "tools/probes/calendar-lengths-family/probe.pl"
RUNNER = ROOT / "tools/probes/calendar-lengths-family/run.py"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def compact(value):
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def clean_warning(value):
    return re.sub(r" at .*? line \d+\.?\n?$", "", value)


def generic(call):
    if not call["call_completed"]:
        return "no result because the request fails"
    if call["return_type"] == "undefined":
        return "an absent value"
    if call["return_type"] == "list":
        return "ordered numbers " + compact(call["return"])
    value = call["return"]
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        return "number " + str(value)
    return "text " + compact(value)


def native(call):
    if not call["call_completed"]:
        return "no return because the call raises an exception"
    if call["return_type"] == "undefined":
        return "undefined scalar"
    if call["return_type"] == "list":
        return "list " + compact(call["return"])
    return "scalar " + compact(call["return"])


def diagnostic(call):
    if call["exception"] is not None:
        return "exception " + compact(call["exception"].splitlines()[0])
    if not call["warnings"]:
        return "no warning or exception"
    return "warnings " + compact([clean_warning(w) for w in call["warnings"]])


def parse_tables(path):
    tables = []
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
        tables.append(dict(zip(header, cells)))
    return tables


manifest = json.loads(MANIFEST.read_text())
evidence = json.loads(EVIDENCE.read_text())
fixture = json.loads(FIXTURE.read_text())
cases = manifest["cases"]
rows = evidence["observations"]
ids = [c["case_id"] for c in cases]
assert len(ids) == 171 and len(ids) == len(set(ids))
assert [r["case_id"] for r in rows] == ids
assert evidence["execution"] == {
    "repetitions_per_case": 2, "parallel_workers": 4,
    "timeout_seconds": 15,
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
for key, digest in evidence["installed_module_sha256"].items():
    assert digest == sha(ROOT / key), key

profile_by_name = {p["name"]: p for p in fixture["profiles"]}
obs_by_id = {}
exception_ids = set()
for case, row in zip(cases, rows):
    assert row["research_status"] == "repeatable"
    assert row["process_stderr_hex"] == ""
    obs = row["observation"]
    obs_by_id[case["case_id"]] = obs
    assert obs["request"] == case and obs["operation_id"] == case["operation_id"]
    assert obs["route"] == case["route"] and obs["profile"] == case["profile"]
    expected_config = list(profile_by_name[case["profile"]]["configuration"])
    if case.get("yytoyyyy") is not None:
        expected_config.append("YYtoYYYY=" + case["yytoyyyy"])
    assert obs["effective_configuration"] == expected_config
    assert obs["configuration_call_completed"] is True
    assert obs["configuration_exception"] is None
    assert obs["configuration_stdout"] == "" and obs["load_stdout"] == ""
    assert obs["dependent_operation_executed"] is True
    assert obs["observed_distribution_version"] == "7.00"
    assert obs["observed_backend_version"] == ("5.66" if case["route"] == "dm5" else "7.00")
    assert obs["perl_version"] == "v5.40.1"
    if case["route"] in {"base", "dm5"}:
        assert obs["configuration_return"] is None
        assert obs["configuration_return_type"] == "undefined"
        if case["route"] == "dm5":
            assert len(obs["load_warnings"]) == 1 and "deprecated" in obs["load_warnings"][0]
        else:
            assert obs["load_warnings"] == []
    else:
        assert obs["configuration_return"] == ""
        assert obs["configuration_return_type"] == "scalar"
        assert obs["load_warnings"] == []
    for loaded in obs["loaded_date_manip_module_files"].values():
        key = str(Path(loaded).relative_to(ROOT))
        assert key in evidence["installed_module_sha256"]
    call = obs["call"]
    assert call["arguments"] == case["arguments"]
    assert call["return_context"] == case["return_context"]
    assert call["stdout"] == ""
    if call["call_completed"]:
        assert call["exception"] is None
        assert "return" in call and "return_type" in call
    else:
        exception_ids.add(case["case_id"])
        assert call["exception"] is not None
        assert "return" not in call and "return_type" not in call
    observer = call["error_observer"]
    if case["route"] == "base":
        assert observer == {
            "operation": "Base::err", "initial": "",
            "clear_call_completed": True, "clear_return": None,
            "clear_return_type": "undefined", "before": "", "after": "",
        }
    else:
        assert observer == {
            "operation": "none documented by the functional facade",
            "called": False,
        }

assert exception_ids == {
    "CL-DM5-INVALID-M-YEAR-TEXT", "CL-DM5-INVALID-M-YEAR-HIGH",
    "CL-DM5-INVALID-Y-TEXT", "CL-DM5-INVALID-Y-FRACTION",
    "CL-DM5-INVALID-Y-HIGH",
}

# Independently compute selected valid Gregorian facts.
def leap(year):
    return year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)


def month_length(year, month):
    if month == 2:
        return 29 if leap(year) else 28
    return 30 if month in (4, 6, 9, 11) else 31


for case in cases:
    call = obs_by_id[case["case_id"]]["call"]
    if case["partition"].startswith("all-months-"):
        year, month = (case["arguments"] if case["route"] == "base"
                       else reversed(case["arguments"]))
        assert call["return"] == month_length(year, month)
    if case["partition"] in {"century-common", "century-leap", "ordinary-common", "ordinary-leap"}:
        year = case["arguments"][0]
        assert call["return"] == (366 if leap(year) else 365)
    if case["route"] == "base" and case["partition"] == "month-zero-list":
        year = case["arguments"][0]
        assert call["return"] == [month_length(year, m) for m in range(1, 13)]

# With reference year 2040, default 89-year window and C20 map 00 to
# Gregorian 2000; C19 maps it to 1900.
for case in cases:
    if case["route"] == "dm5" and case["partition"] == "short-year":
        selected = 1900 if case.get("yytoyyyy") == "C19" else 2000
        expected = month_length(selected, 2) if case["operation_id"].endswith("month") else (366 if leap(selected) else 365)
        assert obs_by_id[case["case_id"]]["call"]["return"] == expected

# Parse all feature files with the repository's installed real Gherkin parser.
feature_files = sorted(FEATURES.glob("*.feature"))
parser_lib = ROOT / "local/bdd-runner/lib/perl5"
subprocess.run(
    ["perl", "-I" + str(parser_lib), "-MTest::BDD::Cucumber::Parser", "-e",
     "Test::BDD::Cucumber::Parser->parse_file($_) for @ARGV", *map(str, feature_files)],
    check=True, cwd=ROOT, env={"PATH": "/usr/bin:/bin"}, capture_output=True,
)

generic_rows = {}
binding_rows = {}
base_observer_rows = {}
setup_rows = {}
for path in feature_files:
    for row in parse_tables(path):
        if "setup route" in row:
            assert row["setup route"] not in setup_rows
            setup_rows[row["setup route"]] = row
            continue
        if set(row) == {"case", "error before", "error after"}:
            assert row["case"] not in base_observer_rows
            base_observer_rows[row["case"]] = row
            continue
        target = binding_rows if path.name == "perl-binding.feature" else generic_rows
        assert row["case"] not in target
        target[row["case"]] = row
assert set(generic_rows) == set(ids)
assert set(binding_rows) == set(ids)
base_ids = {case["case_id"] for case in cases if case["route"] == "base"}
assert set(base_observer_rows) == base_ids
assert setup_rows == {
    "base": {"setup route": "base", "setup return": "undefined scalar", "load diagnostic": "no warning"},
    "dm6": {"setup route": "dm6", "setup return": "empty text", "load diagnostic": "no warning"},
    "dm5": {"setup route": "dm5", "setup return": "undefined scalar", "load diagnostic": 'warning "Date::Manip::DM5 is deprecated and will be removed from the Date::Manip package starting in version 7.00"'},
}
profile_label = {
    "base": "current calendar arithmetic profile",
    "dm6": "current functional profile",
    "dm5": "legacy functional profile",
}
for case in cases:
    call = obs_by_id[case["case_id"]]["call"]
    row = generic_rows[case["case_id"]]
    assert row["profile"] == profile_label[case["route"]]
    assert row["result"] == generic(call)
    if "year" in row:
        expected_year = (case["arguments"][0] if case["route"] == "base" or
                         case["operation_id"] == "calendar.days-in-year" else case["arguments"][1])
        assert row["year"] == str(expected_year)
    if "month" in row:
        expected_month = case["arguments"][1] if case["route"] == "base" else case["arguments"][0]
        assert row["month"] == str(expected_month)
    if "arguments" in row:
        assert json.loads(row["arguments"]) == case["arguments"]
    if "operation" in row:
        assert row["operation"] == case["operation_id"]
    if "configuration" in row:
        assert row["configuration"] == case.get("yytoyyyy", "pinned default")
    if "partition" in row:
        assert row["partition"] == case["partition"]
    bind = binding_rows[case["case_id"]]
    assert bind["route"] == case["route"]
    assert bind["operation"] == case["operation_id"]
    assert json.loads(bind["arguments"]) == case["arguments"]
    assert bind["context"] == case["return_context"]
    assert bind["native result"] == native(call)
    assert bind["diagnostic"] == diagnostic(call)
    expected_action = ("cleared and read before and after" if case["route"] == "base"
                       else "not called because the facade exposes none")
    assert bind["observer action"] == expected_action
    if case["route"] == "base":
        observer_row = base_observer_rows[case["case_id"]]
        assert observer_row["error before"] == compact(call["error_observer"]["before"])
        assert observer_row["error after"] == compact(call["error_observer"]["after"])

feature_map = json.loads((FAMILY / "feature-map.json").read_text())
assert len(feature_map["case_map"]) == 171
assert [x["case_id"] for x in feature_map["case_map"]] == ids
assert feature_map["aliases"] == []
canonical = {x["id"] for x in json.loads((ROOT / "docs/research/api/contract-map.json").read_text())["operations"]}
assert set(feature_map["canonical_operations"]) <= canonical
bindings = json.loads((FAMILY / "bindings.json").read_text())
assert {x["operation_id"] for x in bindings["operations"]} == set(feature_map["canonical_operations"])
assert bindings["aliases"] == []
print("calendar-lengths-family: 171 requests, 342 isolated attempts, native carriers, Gregorian facts, hashes, mappings, and Gherkin literals verified")
