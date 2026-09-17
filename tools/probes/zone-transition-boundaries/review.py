#!/usr/bin/env python3
"""Validate bounded transition evidence and feature/map cardinalities."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FAMILY = ROOT / "docs/research/zone-transition-boundaries"


def load(path: Path):
    return json.loads(path.read_text())


def digest(path: Path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def civil(fields):
    y, m, d, h, minute, second = fields
    return f"{y:04}-{m:02}-{d:02} {h:02}:{minute:02}:{second:02}"


def period_text(period):
    return (f"{civil(period[0])} UTC/{civil(period[1])} local/"
            f"{period[2]}/{period[4]}/{period[5]} through "
            f"{civil(period[6])} UTC/{civil(period[7])} local")


def verify_feature_literals(data, mapping):
    observations = {r['case_id']: r['observation'] for r in data['observations']}
    actual_ids = set()
    counts = {'utc': 0, 'wall': 0, 'enumeration': 0}
    for path in mapping['features']:
        header = None
        for line in (ROOT / path).read_text().splitlines():
            if not line.strip().startswith('|'):
                header = None
                continue
            cells = [c.strip() for c in line.strip().strip('|').split('|')]
            if header is None:
                header = cells
                continue
            r = dict(zip(header, cells))
            assert len(header) == len(cells)
            assert r['case'] not in actual_ids
            actual_ids.add(r['case'])
            observed = observations[r['observation']]
            assert r['zone'] == observed['request']['zone']
            if 'utc' in r:
                counts['utc'] += 1
                points = [p for p in observed['utc_points'] if civil(p['utc']) + ' Etc/UTC' == r['utc']]
                assert len(points) == 1
                p = points[0]; values = p['tz_convert_return']; period = p['absolute_date_period']
                assert values[0] == 0 and r['local'] == civil(values[1])
                assert [r['offset'], r['abbreviation'], int(r['dst'])] == [period[2], values[4], values[3]]
                assert [period[4], period[5]] == [values[4], values[3]]
                assert r['rendered'] == p['date']['after_convert']['rendered']
                assert r['fields'] == ','.join(map(str, p['date']['after_convert']['list']))
            elif 'wall' in r:
                counts['wall'] += 1
                queries = [q for q in observed['wall_queries'] if civil(q['request']['date']) == r['wall'] and q['request']['selector'] == int(r['selector'])]
                assert len(queries) == 1
                period = queries[0]['return']
                if 'offset' not in r:
                    assert period is None
                else:
                    assert [r['offset'], r['abbreviation'], int(r['dst'])] == [period[2], period[4], period[5]]
            else:
                counts['enumeration'] += 1
                assert int(r['year']) == observed['request']['year']
                for col, key in [('beginning', 'periods'), ('intersecting', 'all_periods')]:
                    periods = observed[key]['value']
                    assert r[col] == ('; '.join(period_text(p) for p in periods) if periods else 'no records'), r['case']
    expected = {e['example_id'] for f in mapping['features'].values() for e in f['examples']}
    assert actual_ids | {'ZTB-UTC-WALL-STABLE'} == expected
    assert counts == {'utc': 24, 'wall': 34, 'enumeration': 8}
    stable = observations['ZTB-UTC-NO-TRANSITION']['wall_queries']
    text = (ROOT / 'spec/drafts/zone-transition-boundaries/period-boundaries.feature').read_text()
    for q in stable:
        assert civil(q['request']['date']) in text
        assert q['return'][2:6] == ['+00:00:00', [0, 0, 0], 'UTC', 0]
        assert civil(q['return'][0]) + ' UTC' in text
        assert civil(q['return'][6]) + ' UTC' in text


def main():
    data = load(FAMILY / "observations.json")
    corpus = load(FAMILY / "cases.json")["cases"]
    mapping = load(FAMILY / "feature-map.json")
    bindings = load(FAMILY / "bindings.json")
    assert data["execution"]["repetitions"] == 2
    assert data["execution"]["whole_runner_repetitions"] == 2
    assert data["execution"]["whole_runner_payloads_identical"] is True
    assert len(data["observations"]) == len(corpus) == 8
    assert data["independent_zoneinfo"]["checked_utc_instants"] == 24
    assert data["independent_zoneinfo"]["tzdata_zi_version_line"] == "# version 2026c"
    assert any(path.endswith("Date/Manip/TZ/etutc00.pm") for path in data["installed_module_sha256"])
    operation_ids = set(mapping["source_binding"]["operation_ids"])
    assert "date.convert-zone" not in operation_ids
    required = {"zone.convert-value", "object.create", "config.apply-settings", "meta.reference-version", "context.zone-service", "meta.zone-data-version", "meta.zone-rule-version", "zone.resolve", "date.create", "date.read-value", "date.render-pattern", "error.read-state", "date.parse-text", "zone.convert-from-utc", "zone.period-for-date", "zone.list-periods", "zone.list-all-periods"}
    assert required <= operation_ids
    bound = {item.get("operation_id") for item in bindings["bindings"]}
    bound |= {op for item in bindings["supporting_public_calls"] for op in item.get("operation_ids", [item.get("operation_id")])}
    assert {"zone.convert-value", "date.parse-text", "zone.convert-from-utc", "zone.period-for-date", "zone.list-periods", "zone.list-all-periods", "date.read-value", "date.render-pattern", "error.read-state"} <= bound
    points = walls = enumerations = 0
    for row, case in zip(data["observations"], corpus):
        assert row["case_id"] == case["case_id"]
        assert row["observation"]["operation_ids"][1] == "zone.convert-value"
        assert row["research_status"] == "repeatable"
        assert row["process_attempts"] == [{"exit_code": 0, "stderr": ""}, {"exit_code": 0, "stderr": ""}]
        observed = row["observation"]
        assert observed["exception"] == "" and observed["warnings"] == [] and observed["call_stdout"] == ""
        assert len(observed["utc_points"]) == 3
        assert len(observed["wall_queries"]) == len(case["wall_queries"])
        points += len(observed["utc_points"]); walls += len(observed["wall_queries"]); enumerations += 1
        for point in observed["utc_points"]:
            date = point["date"]
            assert date["parse_status_type"] == date["convert_status_type"] == "number"
            assert date["parse_error"] == date["convert_error"] == ""
            for phase in (date["before_convert"], date["after_convert"]):
                assert phase["error_after_scalar"] == phase["error_after_list"] == ""
                assert phase["scalar_exception"] == phase["list_exception"] == ""
            assert date["after_convert"]["error_after_printf"] == ""
            assert date["after_convert"]["printf_exception"] == ""
    assert (points, walls, enumerations) == (24, 37, 8)
    verify_feature_literals(data, mapping)
    for relative, expected_hash in data["installed_module_sha256"].items():
        assert digest(ROOT / relative) == expected_hash, relative
    canonical = {r["id"] for r in load(ROOT / "docs/research/api/contract-map.json")["operations"]}
    assert operation_ids <= canonical and bound <= canonical
    examples = [item for feature in mapping["features"].values() for item in feature["examples"]]
    assert len(examples) == len({item["example_id"] for item in examples}) == 67
    period_feature = (ROOT / "spec/drafts/zone-transition-boundaries/period-boundaries.feature").read_text()
    assert "plus the" not in period_feature and "beginning records" not in period_feature
    for relative, value in data["sha256"].items():
        assert digest(ROOT / relative) == value, relative
    print("67 IDs, 24 UTC instants, 37 wall queries, and 8 enumerations match complete provenance and call-boundary evidence")


if __name__ == "__main__":
    main()
