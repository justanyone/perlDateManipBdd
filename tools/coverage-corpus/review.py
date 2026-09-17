#!/usr/bin/env python3
"""Verify a completed public-probe coverage artifact; never claim suite completion."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('directory', type=Path)
    parser.add_argument('--source-commit', help='verify historical tracked sources against this Git commit')
    args = parser.parse_args()
    directory = args.directory.resolve()
    summary = json.loads((directory / 'summary.json').read_text())

    def source(relative):
        if args.source_commit and not relative.startswith('local/'):
            return subprocess.check_output(['git', 'show', args.source_commit + ':' + relative], cwd=ROOT)
        return (ROOT / relative).read_bytes()

    for relative, expected in summary['hashes'].items():
        assert digest(source(relative)) == expected, relative
    manifest = json.loads(source(summary['manifest']))
    requests = [(family['name'], family['probe'], cid)
                for family in manifest['families'] for cid in family['case_ids']]
    assert len(requests) == len(set((probe, cid) for _, probe, cid in requests))
    assert len(requests) == summary['case_count'] == len(summary['fidelity'])

    # Use the exact pinned collector's narrowly scoped warning-normalization rule.
    namespace = {'__name__': 'coverage_review_collector', '__file__': str(ROOT / 'tools/coverage-corpus/collect.py')}
    exec(compile(source('tools/coverage-corpus/collect.py'), namespace['__file__'], 'exec'), namespace)
    normalize = namespace['normalize_deprecation_sites']
    adjustments = 0
    expected_dirs = set()
    for index, ((family, probe, cid), recorded) in enumerate(zip(requests, summary['fidelity'])):
        assert (recorded['family'], recorded['probe'], recorded['case_id']) == (family, probe, cid)
        label = f'{index:02d}-{family}-{cid}'
        expected_dirs.add(label)
        work = directory / 'work' / label
        plain = (work / 'plain.stdout').read_bytes()
        covered = (work / 'covered.stdout').read_bytes()
        stderr = (work / 'plain.stderr').read_bytes()
        assert stderr == (work / 'covered.stderr').read_bytes(), label
        assert digest(plain) == recorded['plain_stdout_sha256'], label
        assert digest(covered) == recorded['covered_stdout_sha256'], label
        assert digest(stderr) == recorded['stderr_sha256'], label
        assert stderr.decode('utf-8', 'surrogateescape') == recorded['process_stderr'], label
        a, b = json.loads(plain), json.loads(covered)
        assert recorded['stdout_byte_identical'] == (plain == covered), label
        if plain == covered:
            assert recorded['comparison_adjustment'] is None
        else:
            assert summary['fidelity_policy']['normalize_dm5_deprecation_sites']
            assert recorded['comparison_adjustment'] == 'DM5 deprecation dynamic eval site only'
            assert normalize(a) == normalize(b), label
            adjustments += 1
    assert {p.name for p in (directory / 'work').iterdir() if p.is_dir()} == expected_dirs
    assert adjustments == summary['fidelity_policy']['raw_stdout_different_cases']

    report = json.loads((directory / 'report/cover.json').read_text())['summary']
    inventory = summary['source_inventory']
    loaded, unloaded = inventory['loaded_files'], inventory['unloaded_files']
    assert len(loaded) == len(set(loaded)) == inventory['loaded_file_count']
    assert len(unloaded) == len(set(unloaded)) == inventory['unloaded_file_count']
    assert not set(loaded) & set(unloaded)
    assert len(loaded) + len(unloaded) == inventory['file_count']
    lib = ROOT / 'local/date-manip-7.00/lib/perl5/Date'
    actual = {str(path.relative_to(lib)) for path in lib.rglob('*.pm')}
    assert set(loaded) | set(unloaded) == actual
    report_library_files = {str(Path(name).resolve().relative_to(lib))
                            for name in report if name != 'Total' and Path(name).resolve().is_relative_to(lib)}
    assert report_library_files == set(loaded)
    for kind, expected in summary['date_manip_only_totals'].items():
        counts = {field: sum(report[str(lib / path)].get(kind, {}).get(field, 0)
                             for path in loaded)
                  for field in ('covered', 'error', 'uncoverable', 'total')}
        assert all(type(n) is int and n >= 0 for n in counts.values())
        assert counts['covered'] + counts['error'] + counts['uncoverable'] == counts['total']
        assert all(expected[key] == value for key, value in counts.items())
        raw = 100 * counts['covered'] / counts['total'] if counts['total'] else None
        assert raw == expected['raw_percentage']
        assert summary['upstream_annotations'][kind] == counts['uncoverable']
    print(json.dumps({'verified_public_requests': len(requests), 'warning_location_adjustments': adjustments,
                      'loaded_files': len(loaded), 'unloaded_files': len(unloaded),
                      'totals': summary['date_manip_only_totals'],
                      'limitation': 'reference-probe coverage only; process exit success is recorded by the collector, not independently recoverable from raw stdout files'}, indent=2))


if __name__ == '__main__':
    main()
