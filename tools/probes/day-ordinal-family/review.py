#!/usr/bin/env python3
"""Verify hashes, carriers, and every frozen day-ordinal feature literal."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/day-ordinal-family"
FEATURE_DIR = ROOT / "spec/drafts/day-ordinal"
MANIFEST = FAMILY / "cases.json"
EVIDENCE = FAMILY / "observations.json"
FIXTURE = ROOT / "docs/automation/reference-profiles.json"
PROBE = ROOT / "tools/probes/day-ordinal-family/probe.pl"
RUNNER = ROOT / "tools/probes/day-ordinal-family/run.py"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def literal(call):
    if not call["call_completed"]:
        return "no return because the call raises an exception"
    if call["return_type"] == "undefined":
        return "an absent value"
    return "text " + json.dumps(call["return"], ensure_ascii=False, separators=(",", ":"))


manifest = json.loads(MANIFEST.read_text())
evidence = json.loads(EVIDENCE.read_text())
fixture = json.loads(FIXTURE.read_text())
cases = manifest["cases"]
rows = evidence["observations"]
case_ids = [case["case_id"] for case in cases]
assert len(case_ids) == 56 and len(case_ids) == len(set(case_ids))
assert [row["case_id"] for row in rows] == case_ids
assert evidence["execution"]["repetitions_per_case"] == 2
assert evidence["execution"]["parallel_workers"] == 4
assert evidence["execution"]["timeout_seconds"] == 15
assert evidence["execution"]["fresh_process_and_temporary_working_directory_per_attempt"] is True
assert evidence["execution"]["environment"]["PERL5LIB"] == str(ROOT / "local/date-manip-7.00/lib/perl5")

for path in (MANIFEST, PROBE, FIXTURE, RUNNER):
    key = str(path.relative_to(ROOT))
    assert evidence["sha256"][key] == sha(path), key
for key, digest in evidence["installed_module_sha256"].items():
    assert digest == sha(ROOT / key), key

features = "\n".join(path.read_text() for path in sorted(FEATURE_DIR.glob("*.feature")))
request_count = 0
warning_request_ids = set()
for case, row in zip(cases, rows):
    assert row["research_status"] == "repeatable"
    assert row["process_stderr_hex"] == ""
    obs = row["observation"]
    assert obs["request"] == case
    assert obs["request_set"] == manifest["request_sets"][case["request_set"]]
    assert obs["operation_id"] == "date.localized-day-ordinal"
    assert obs["observed_distribution_version"] == "7.00"
    assert obs["perl_version"] == "v5.40.1"
    expected_backend = "7.00" if case["profile"] == "dm6" else "5.66"
    assert obs["observed_backend_version"] == expected_backend
    assert obs["load_stdout"] == "" and obs["configuration_stdout"] == ""
    if case["profile"] == "dm6":
        assert obs["load_warnings"] == []
        assert obs["configuration_return"] == ""
        assert obs["configuration_return_type"] == "text"
    else:
        assert len(obs["load_warnings"]) == 1
        assert "Date::Manip::DM5 is deprecated" in obs["load_warnings"][0]
        if obs["configuration_call_completed"]:
            assert obs["configuration_return_type"] == "undefined"
    if case["case_id"] == "DO-DM5-CATALAN-DAYS":
        assert obs["configuration_call_completed"] is False
        assert obs["dependent_operations_executed"] is False
        assert obs["calls"] == []
        assert "configuration_return" not in obs and "configuration_return_type" not in obs
        assert "undefined value as an ARRAY reference" in obs["configuration_exception"]
        assert features.count('"DO-DM5-CATALAN-DAYS"') == 1
        continue
    assert obs["configuration_call_completed"] is True
    assert obs["dependent_operations_executed"] is True
    assert obs["configuration_exception"] is None
    assert len(obs["calls"]) == len(manifest["request_sets"][case["request_set"]])
    for call in obs["calls"]:
        request_count += 1
        request_id = (case["case_id"] + "-" + call["request_id"]
                      if case["request_set"] == "days-1-through-31"
                      else case["case_id"])
        scalar = call["scalar_call"]
        listed = call["list_call"]
        assert scalar["call_completed"] is True and listed["call_completed"] is True
        assert scalar["exception"] is None and listed["exception"] is None
        assert scalar["stdout"] == "" and listed["stdout"] == ""
        assert listed["return_count"] == 1
        assert listed["return"][0] == scalar["return"]
        assert listed["return_element_types"][0] == scalar["return_type"]
        if scalar["warnings"] or listed["warnings"]:
            warning_request_ids.add(request_id)
            assert scalar["warnings"] == listed["warnings"]
            assert len(scalar["warnings"]) == 1
        matching = [line for line in features.splitlines()
                    if "| " + request_id + " |" in line]
        assert len(matching) == 1, request_id
        assert literal(scalar) in matching[0], request_id

assert request_count == 925
assert warning_request_ids == {
    "DO-DM6-OMITTED", "DO-DM6-UNDEFINED", "DO-DM6-EMPTY", "DO-DM6-NONNUMERIC",
    "DO-DM5-OMITTED", "DO-DM5-UNDEFINED", "DO-DM5-EMPTY", "DO-DM5-NONNUMERIC",
}

# Independent English ordinal rule, including the teen exception and 21/31 boundaries.
english = next(row["observation"] for row in rows if row["case_id"] == "DO-DM6-ENGLISH-DAYS")
actual = [call["scalar_call"]["return"] for call in english["calls"]]
expected = []
for day in range(1, 32):
    ending = day % 100
    suffix = "th" if 11 <= ending <= 13 else {1: "st", 2: "nd", 3: "rd"}.get(day % 10, "th")
    expected.append(str(day) + suffix)
assert actual == expected

feature_map = json.loads((FAMILY / "feature-map.json").read_text())
assert len(feature_map["case_map"]) == 56
assert len(feature_map["request_map"]) == 925
assert {row["operation_id"] for row in feature_map["request_map"]} == {"date.localized-day-ordinal"}
print("day-ordinal-family: 56 isolated cases, 925 request rows, 1,850 native calls, hashes, and literals verified")

# Validate every request's language/profile/arguments in its own feature row.
tables = {}
binding_tables = {}
for path in FEATURE_DIR.glob('*.feature'):
    header = None
    for line in path.read_text().splitlines():
        if not line.strip().startswith('|'):
            header = None
            continue
        cells = [cell.strip() for cell in line.strip().strip('|').split('|')]
        if header is None:
            header = cells
            continue
        assert len(cells) == len(header)
        row = dict(zip(header, cells))
        target = tables if 'request' in row else binding_tables
        key = row.get('request', row.get('binding case'))
        assert key not in target
        target[key] = (str(path.relative_to(ROOT)), row)
assert len(tables) == 925 and len(binding_tables) == 4
mapped = {item['request_id']: item for item in feature_map['request_map']}
assert set(mapped) == set(tables)
for case, row in zip(cases, rows):
    obs = row['observation']
    profile = next(p for p in fixture['profiles'] if p['name'] == case['profile'])
    expected_config = ['Language=' + case['language'] if value.startswith('Language=') else value for value in profile['configuration']]
    assert obs['effective_configuration'] == expected_config
    for path in obs['loaded_date_manip_module_files'].values():
        assert str(Path(path).relative_to(ROOT)) in evidence['installed_module_sha256']
    for call in obs['calls']:
        rid = case['case_id'] + '-' + call['request_id'] if case['request_set'] == 'days-1-through-31' else case['case_id']
        path, table = tables[rid]
        entry = mapped[rid]
        assert entry['feature'] == path and entry['observation_case_id'] == case['case_id']
        assert entry['input_arguments'] == call['arguments']
        assert call['scalar_call']['arguments'] == call['list_call']['arguments'] == call['arguments']
        if 'day' in table:
            assert call['arguments'] == [int(table['day'])]
            assert table['language'] == case['language']
        else:
            assert table['profile'] == case['profile']
            assert json.loads(table['arguments']) == call['arguments']
        assert table['literal result'] == literal(call['scalar_call'])
        if 'diagnostic' in table:
            warnings = call['scalar_call']['warnings']
            diagnostic = table['diagnostic']
            if diagnostic == 'no warning': assert warnings == []
            elif diagnostic == 'one uninitialized-value warning':
                assert len(warnings) == 1 and 'uninitialized' in warnings[0]
            else:
                assert diagnostic == 'one nonnumeric-value warning'
                assert len(warnings) == 1 and "isn't numeric" in warnings[0]
for item in feature_map['binding_assertions']:
    _, table = binding_tables[item['scenario_id']]
    source = next(row['observation'] for row in rows if row['case_id'] == item['source_case_id'])
    call = source['calls'][0]
    assert table['profile'] == source['profile']
    assert json.loads(table['arguments']) == call['arguments']
    assert call['scalar_call']['return'] is None and call['list_call']['return'] == [None]
    for context in ['scalar_call', 'list_call']:
        assert call[context]['exception'] is None and call[context]['warnings'] == []
print('925 exact language/profile/request/result rows and four binding assertions verified')

canonical = {item['id'] for item in json.loads((ROOT / 'docs/research/api/contract-map.json').read_text())['operations']}
bindings = json.loads((FAMILY / 'bindings.json').read_text())
assert bindings['operation_id'] in canonical
for binding in bindings['bindings']:
    assert binding['setup']['operation_id'] in canonical
    assert binding['metadata']['operation_id'] in canonical
