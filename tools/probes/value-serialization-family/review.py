#!/usr/bin/env python3
"""Check internal fidelity of the frozen value-serialization research batch."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/value-serialization-family"
FEATURES = ROOT / "spec/drafts/value-serialization"
MANIFEST = FAMILY / "cases.json"
EVIDENCE = FAMILY / "observations.json"
FIXTURE = ROOT / "docs/automation/reference-profiles.json"
PROBE = ROOT / "tools/probes/value-serialization-family/probe.pl"
RUNNER = ROOT / "tools/probes/value-serialization-family/run.py"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def literal(call):
    if not call["call_completed"]:
        return "no return because the call raises an exception"
    if call["return_type"] == "undefined":
        return "an absent value"
    value = call["return"]
    if isinstance(value, list):
        return "ordered fields " + json.dumps(value, separators=(",", ":"))
    if value == "":
        return "empty text"
    return "text " + json.dumps(value, separators=(",", ":"))


manifest = json.loads(MANIFEST.read_text())
evidence = json.loads(EVIDENCE.read_text())
fixture = json.loads(FIXTURE.read_text())
cases = manifest["cases"]
rows = evidence["observations"]
ids = [case["case_id"] for case in cases]
assert len(ids) == 73 and len(ids) == len(set(ids))
assert [row["case_id"] for row in rows] == ids
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

features = "\n".join(path.read_text() for path in sorted(FEATURES.glob("*.feature")))
for case, row in zip(cases, rows):
    assert row["research_status"] == "repeatable"
    assert row["process_stderr"] == ""
    obs = row["observation"]
    assert obs["request"] == case
    assert obs["operation_id"] == case["operation_id"]
    assert obs["observed_distribution_version"] == "7.00"
    assert obs["observed_module_versions"] == {
        "Date::Manip::Date": "7.00",
        "Date::Manip::Base": "7.00",
        "Date::Manip::Obj": "7.00",
    }
    assert obs["perl_version"] == "v5.40.1"
    assert features.count("| " + case["case_id"] + " |") == 1, case["case_id"]
    assert literal(obs["scalar_call"]) in next(
        line for line in features.splitlines() if "| " + case["case_id"] + " |" in line
    )
    for context in ("scalar_call", "list_call"):
        call = obs[context]
        assert call["configuration_return_type"] == "undefined"
        assert call["configuration_error"] == ""
        assert call["error_before_call"] == ""
        assert call["error_after_call"] == ""
        assert call["stdout"] == ""
        assert call["observed_backend_version"] == "7.00"
        assert call["observed_tzdata"] == "tzdata2026c"
        assert call["observed_tzcode"] == "tzcode2026c"
    scalar = obs["scalar_call"]
    listed = obs["list_call"]
    assert scalar["call_completed"] == listed["call_completed"]
    if scalar["call_completed"]:
        assert listed["return_count"] == 1
        assert listed["return"][0] == scalar["return"]
        assert listed["return_element_types"][0] == scalar["return_type"]
        assert scalar["exception"] is None and listed["exception"] is None
    else:
        assert "return" not in scalar and "return" not in listed
        assert scalar["exception"] == listed["exception"]

warning_ids = {
    row["case_id"] for row in rows
    if row["observation"]["scalar_call"]["warnings"]
       or row["observation"]["list_call"]["warnings"]
}
assert warning_ids == {"VS-DATE-SPLIT-UNDEFINED"}
warning = next(row for row in rows if row["case_id"] == "VS-DATE-SPLIT-UNDEFINED")["observation"]
assert len(warning["scalar_call"]["warnings"]) == 3
assert warning["scalar_call"]["warnings"] == warning["list_call"]["warnings"]

# Independent arithmetic and civil-value checks for selected frozen literals.
by_id = {row["case_id"]: row["observation"]["scalar_call"].get("return") for row in rows}
assert by_id["VS-DATE-SPLIT-COLON"] == [2040, 2, 29, 16, 5, 9]  # 2040 is divisible by 4 and is not a century year.
assert by_id["VS-TIME-SPLIT-OVERFLOW"] == [3, 1, 30]  # 1*3600 + 120*60 + 90 seconds.
assert by_id["VS-OFFSET-SPLIT-POS-END"] == [23, 59, 59]
assert by_id["VS-OFFSET-SPLIT-NEG-END"] == [-23, -59, -59]
assert by_id["VS-BUSINESS-SPLIT-ALIAS"] == [0, 0, 0, 2, 0, 0, 0]  # Two configured 8-hour workdays.

feature_map = json.loads((FAMILY / "feature-map.json").read_text())
assert [row["case_id"] for row in feature_map["case_map"]] == ids
assert {row["operation_id"] for row in feature_map["case_map"]} == {
    "value.split-fields", "value.join-fields"
}
print("value-serialization-family: 73 requests, native carriers, hashes, feature literals, and selected independent facts verified")

# Every table cell is tied to its own request; no cross-row literal matching.
def compact(value):
    return json.dumps(value, separators=(",", ":"))

def request_input(case):
    value = case['input']
    if value is None:
        return 'an undefined scalar'
    return ('ordered fields ' if isinstance(value, list) else 'text ') + compact(value)

def request_options(case):
    style = case['options_style']
    if style == 'none':
        result = 'no options'
    elif style == 'map':
        result = 'options ' + compact(case['options'])
    else:
        assert style == 'legacy' and case['legacy_option'] == 1
        result = 'deprecated positional nonorm=true'
    if 'printable' in case:
        result += '; Printable=' + str(case['printable'])
    return result

tables = {}
for path in FEATURES.glob('*.feature'):
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
        key = row.get('case', row.get('binding case'))
        assert key not in tables
        tables[key] = (path, row)
assert len(tables) == 146
for case, evidence_row, mapping in zip(cases, rows, feature_map['case_map']):
    path, row = tables[case['case_id']]
    assert str(path.relative_to(ROOT)) == mapping['feature']
    assert row['input'] == request_input(case)
    assert row['kind'] == case['kind']
    assert row['options and configuration'] == request_options(case)
    if 'method' in row:
        assert row['method'] == case['method']
    if 'operation' in row:
        assert row['operation'] == case['operation_id']
    obs = evidence_row['observation']
    assert row['literal result'] == literal(obs['scalar_call'])
    for context in ('scalar_call', 'list_call'):
        call = obs[context]
        assert call['printable_override_performed'] == ('printable' in case)
        assert call['printable_override_error'] == ('' if 'printable' in case else None)
        assert call['printable_override_return'] is None
    for path in obs['loaded_modules'].values():
        key = str(Path(path).relative_to(ROOT))
        assert key in evidence['installed_module_sha256']
    _, binding = tables['VSB-' + case['case_id'][3:]]
    for column in ('input', 'kind', 'options and configuration'):
        assert binding[column] == row[column]
    assert binding['method'] == case['method']
    scalar = obs['scalar_call']; listed = obs['list_call']
    assert binding['scalar carrier'] == scalar.get('return_type', 'no return')
    assert binding['scalar value'] == (compact(scalar['return']) if scalar['call_completed'] else 'no return')
    assert binding['list value'] == (compact(listed['return']) if listed['call_completed'] else 'no return')
    assert int(binding['warning count']) == len(scalar['warnings']) == len(listed['warnings'])
    if scalar['call_completed']:
        assert binding['exception category'] == 'none'
    else:
        assert binding['exception category'] == 'expected array-reference carrier'
        assert 'ARRAY ref' in scalar['exception'] or 'ARRAY reference' in scalar['exception']
assert len(feature_map['binding_context_cases']) == 73
for case, mapped in zip(cases, feature_map['binding_context_cases']):
    assert mapped['source_case_id'] == case['case_id']
    assert mapped['scenario_id'] == 'VSB-' + case['case_id'][3:]
    assert mapped['operation_id'] == case['operation_id']
print('All 146 concrete request/result/context rows match their own frozen observations')

canonical = {item['id'] for item in json.loads((ROOT / 'docs/research/api/contract-map.json').read_text())['operations']}
bindings = json.loads((FAMILY / 'bindings.json').read_text())
for item in bindings['entrypoints'] + bindings['public_support_calls_in_order_per_context']:
    assert item['operation_id'] in canonical, item
