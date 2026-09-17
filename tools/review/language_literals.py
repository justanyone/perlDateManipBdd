#!/usr/bin/env python3
"""Check language draft literals and recorded provenance, without reference calls."""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
FAMILY = ROOT / 'docs/research/language-family'
records = {}
for backend in ('dm6', 'dm5'):
    corpus = json.loads((FAMILY / f'{backend}-observations.json').read_text())
    assert len(corpus['observations']) == 32
    for name, digest in corpus['sha256'].items():
        assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest, name
    for row in corpus['observations']:
        assert row['repeatable'] and row['exit_status'] == 0 and row['stderr'] == ''
        assert row['fixture_hash_matches'] and row['json_decode_error'] is None
        record = row['observation']
        assert record['fixture_sha256'] == corpus['fixture_sha256']
        assert record['distribution_version'] == '7.00'
        records[record['case_id']] = record

def table_rows(path):
    header = None
    for line in path.read_text().splitlines():
        if not line.strip().startswith('|'):
            continue
        cells = [c.strip() for c in re.split(r'(?<!\\)\|', line.strip())[1:-1]]
        if cells[0] == 'case':
            header = cells
        else:
            assert header and len(header) == len(cells)
            yield dict(zip(header, cells))

def civil(value):
    if value is None:
        return 'no date-time result'
    if value == '':
        return 'empty text'
    m = re.fullmatch(r'(\d{4})(\d{2})(\d{2})(\d{2}:\d{2}:\d{2})', value)
    assert m, value
    y, m, d, t = m.groups()
    return f'{y}-{m}-{d} {t}'

def rendered(value):
    # Exact notation for an otherwise invisible control character in the feature.
    if value == 'empty text':
        return ''
    return '\u009croda' if value == 'U+009C followed by "roda"' else value

seen = set()
for row in table_rows(ROOT / 'spec/drafts/languages/canonical-dm6.feature'):
    case = row['case']; assert case not in seen; seen.add(case)
    record = records[case.removesuffix('-PREPROCESS')]
    assert row['language'] == record['canonical_language']
    result = record['raw_return']
    if case.endswith('-PREPROCESS'):
        value = result['special_preprocessing']
        assert row['input'] == value['input']
        assert value['status'] == 0 and value['exception'] is None
        assert civil(value['value']) == '2040-02-29 00:00:00'
        continue
    for input_col, output_col, key in [('full date', 'full result', 'full_date'),
                                     ('weekday date', 'weekday result', 'matching_weekday'),
                                     ('tomorrow', 'tomorrow result', 'tomorrow')]:
        value = result[key]
        assert row[input_col] == value['input'], case
        expected = row.get(output_col, '2040-02-29 00:00:00')
        assert civil(value['value']) == expected, case
        assert value['error'] == row.get('error', '') and value['exception'] is None, case
        assert value['setup']['exception'] is None and value['setup']['status'] is None, case
    assert result['rendering']['value'] == row['weekday rendering']+'|'+rendered(row['month rendering']), case
    assert result['rendering']['parse_status'] == 0
assert len(seen) == 36
for row in table_rows(ROOT / 'spec/drafts/languages/dm5-comparisons.feature'):
    case = row['case']; assert case not in seen; seen.add(case)
    record = records[case]; result = record['raw_return']
    assert row['language'] == record['canonical_language']
    assert 'legacy-'+row['mode'] == record['mode']
    if 'exception' in row:
        assert not result['dependent_operations_executed']
        for key in ('full_date','matching_weekday','tomorrow','rendering','special_preprocessing'):
            assert result[key] is None
        exception = result['setup']['exception']
        expected = 'Unknown language' if row['exception'] == 'unknown language' else 'undefined value as an ARRAY reference'
        assert expected in exception, case
        assert len(record['warnings']) == 1
        continue
    assert result['dependent_operations_executed'] and result['setup']['exception'] is None
    for input_col, output_col, key in [('full date','full result','full_date'),
                                     ('weekday date','weekday result','matching_weekday'),
                                     ('tomorrow input','tomorrow result','tomorrow')]:
        assert row[input_col] == result[key]['input'], case
        assert row[output_col] == civil(result[key]['value']), case
        assert result[key]['exception'] is None
    assert result['rendering']['value'] == rendered(row['weekday rendering'])+'|'+rendered(row['month rendering']), case
    special = result['special_preprocessing']
    if special is None:
        assert row['special input'] == row['special result'] == 'not applicable'
    else:
        assert row['special input'] == special['input'] and row['special result'] == civil(special['value']), case
    assert int(row['warning count']) == len(record['warnings']), case
assert len(seen) == 68
selector_document=json.loads((FAMILY/'selector-observations.json').read_text())
for path,digest in selector_document['sha256'].items():
    assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest()==digest,path
selectors={r['selector']:r for r in selector_document['observations']}
selector_map=json.loads((FAMILY/'selector-feature-map.json').read_text())
by_case={r['case_id']:r for r in selector_map['cases']}
assert len(selectors)==len(by_case)==45
selector_count=0
for row in table_rows(ROOT/'spec/drafts/languages/selectors.feature'):
    selector_count+=1
    mapped=by_case[row['case']]
    assert mapped['selector']==row['selector']
    wrapper=selectors[row['selector']];o=wrapper['observation']
    assert wrapper['repeatable'] and wrapper['exit_status']==0 and wrapper['stderr']==''
    assert o['exception'] is None and o['warnings']==[] and o['call_stdout']==''
    assert o['canonical']==row['language'] and o['selected_language']==row['selector']
    assert o['request']=={'text':row['input'],'pattern':'%A|%B'}
    assert o['parse_status']==0 and o['parse_error']==o['error_after_value']==o['error_after_render']==''
    assert o['configuration_return'] is None and o['configuration_error']==''
    assert o['dependent_reads_executed'] and o['value']=='2040022900:00:00'
    assert o['rendered']==row['weekday']+'|'+row['month']
assert selector_count==45
print(json.dumps({'reference_records_checked':len(records), 'draft_rows_checked':len(seen),
                  'selector_rows_checked':selector_count,'approved_specification_cases':0}, indent=2))
