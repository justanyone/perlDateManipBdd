#!/usr/bin/env python3
"""Reconcile reviewed calendar drafts without rewriting capture-time catalogues."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / 'docs/research/calendar-evidence-index.json'


def build():
    hashes = {}

    def read(relative):
        data = (ROOT / relative).read_bytes()
        hashes[relative] = hashlib.sha256(data).hexdigest()
        return json.loads(data)

    contract = read('docs/research/contracts/calendar.json')
    operations = {o['operation_id']: o for o in contract['operations']}
    partitions = {p['id']: p for o in operations.values() for p in o['partitions']}
    rows = {}

    def add(partition, family, case, feature):
        assert partition in partitions, partition
        assert (ROOT / feature).is_file(), feature
        record = rows.setdefault(partition, {'evidence': []})
        value = {'family': family, 'case_id': case, 'portable_draft': feature}
        assert value not in record['evidence'], value
        record['evidence'].append(value)

    def family(name):
        prefix = 'docs/research/' + name + '/'
        mapping = read(prefix + 'feature-map.json')
        evidence = read(prefix + 'observations.json')
        return mapping, evidence

    mapping, evidence = family('leap-year-family')
    observed = {r['case_id'] for r in evidence['observations']}
    assert observed == {r['case_id'] for r in mapping['cases']}
    for case in mapping['cases']:
        for partition in case['contract_partitions']:
            add(partition, 'leap-year-family', case['case_id'], case['portable_feature'])

    mapping, evidence = family('calendar-lengths-family')
    observed = {r['case_id'] for r in evidence['observations']}
    assert observed == {r['case_id'] for r in mapping['case_map']}
    month_parts = {
        'all-months-common': [1], 'all-months-leap': [1],
        'month-zero-list': [3], 'month-zero-scalar': [3],
        'short-year': [4], 'invalid-month': [4], 'invalid-year-for-month': [4],
    }
    year_parts = {'ordinary-common': [1], 'century-common': [2],
                  'century-leap': [2], 'ordinary-leap': [2], 'invalid-year': [3], 'short-year': [3]}
    for case in mapping['case_map']:
        operation = case['operation_id']
        if operation == 'calendar.days-in-month':
            selected = list(month_parts[case['partition']])
            month_index = 1 if case['route'] == 'base' else 0
            if case['partition'].startswith('all-months-') and case['arguments'][month_index] == 2:
                selected.append(2)
        else:
            assert operation == 'calendar.days-in-year'
            selected = year_parts[case['partition']]
        for number in selected:
            add(f'{operation}.p{number}', 'calendar-lengths-family', case['case_id'], case['feature'])

    mapping, evidence = family('weekday-family')
    observed = {r['case_id'] for r in evidence['observations']}
    assert observed == {r['case_id'] for r in mapping['case_map']}
    for case in mapping['case_map']:
        add(case['partition_id'], 'weekday-family', case['case_id'], case['feature'])

    mapping, evidence = family('week-count-family')
    cases = read('docs/research/week-count-family/cases.json')
    assert set(mapping['case_ids']) == {r['case_id'] for r in cases['cases']}
    assert [r['request'] for r in evidence['observation']['observations']] == cases['cases']
    for case in cases['cases']:
        # Default-rule partition gets only its actual default setting.
        numbers = [2, 3]
        if case['first_day'] == 1 and case['rule'] == 'jan4':
            numbers.append(1)
        for number in numbers:
            add(f'calendar.weeks-in-year.p{number}', 'week-count-family', case['case_id'], mapping['portable_feature'])
    rows.setdefault('calendar.weeks-in-year.p4', {'evidence': []})

    result = []
    for partition, row in sorted(rows.items()):
        case_rows = row['evidence']
        result.append({'partition_id': partition,
                       'description': partitions[partition]['description'],
                       'catalogue_snapshot_status': partitions[partition]['status'],
                       'effective_research_status': 'observed-partial' if case_rows else 'unobserved',
                       'completion_status': 'unresolved', 'mapped_request_count': len(case_rows),
                       'evidence': case_rows})
    assert len(result) == 17
    return {'schema_version': 1,
            'scope': 'Five recently reviewed calendar operations only; other catalogue operations unchanged',
            'interpretation': 'Mapped observed requests are not completed partitions, approved portable contracts, BDD execution, or source-coverage proof.',
            'remaining_domain_review': 'docs/research/calendar-gap-priorities.md',
            'source_sha256': hashes, 'partitions': result}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    result = build()
    if args.write:
        OUTPUT.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    else:
        assert json.loads(OUTPUT.read_text()) == result, 'calendar evidence index drift'
    print(f"Verified {len(result['partitions'])} calendar partitions; none marked complete")


if __name__ == '__main__':
    main()
