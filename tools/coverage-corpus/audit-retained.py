#!/usr/bin/env python3
"""Audit retained probe/report artifacts after a collector summary failure."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('directory', type=Path)
    parser.add_argument('--capture-commit', required=True)
    parser.add_argument('--manifest', required=True)
    args = parser.parse_args()
    directory = args.directory.resolve()
    commit = subprocess.check_output(['git', 'rev-parse', args.capture_commit], cwd=ROOT, text=True).strip()

    def original(path):
        return subprocess.check_output(['git', 'show', commit + ':' + path], cwd=ROOT)

    manifest_bytes = original(args.manifest)
    manifest = json.loads(manifest_bytes)
    collector_path = 'tools/coverage-corpus/collect.py'
    old_collector = original(collector_path)
    namespace = {'__name__': 'retained_capture_collector', '__file__': str(ROOT / collector_path)}
    exec(compile(old_collector, collector_path, 'exec'), namespace)
    normalize = namespace['normalize_deprecation_sites']
    spec = importlib.util.spec_from_file_location('current_collector', ROOT / collector_path)
    current = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(current)
    capture_hashes = {args.manifest: sha(manifest_bytes), collector_path: sha(old_collector)}
    requests = []
    for family in manifest['families']:
        probe = family['probe']
        pinned = original(probe)
        assert (ROOT / probe).read_bytes() == pinned, f'probe changed since capture: {probe}'
        capture_hashes[probe] = sha(pinned)
        requests.extend((family['name'], probe, cid) for cid in family['case_ids'])
    assert len(requests) == len(set((probe, cid) for _, probe, cid in requests))
    report_path = directory / 'report/cover.json'
    report_bytes = report_path.read_bytes()
    report = json.loads(report_bytes)
    runs = {r['dir']: r for r in report['runs']}
    assert len(runs) == len(report['runs']) == len(requests)
    fidelity = []
    labels = set()
    for index, (family, probe, cid) in enumerate(requests):
        label = f'{index:02d}-{family}-{cid}'
        labels.add(label)
        work = directory / 'work' / label
        plain = (work / 'plain.stdout').read_bytes()
        covered = (work / 'covered.stdout').read_bytes()
        stderr = (work / 'plain.stderr').read_bytes()
        assert stderr == (work / 'covered.stderr').read_bytes(), label
        a, b = json.loads(plain), json.loads(covered)
        assert normalize(a) == normalize(b), label
        run = runs[str(work / 'covered')]
        assert run['run'] == str(ROOT / probe), label
        assert run['perl'] == '5.40.1' and run['OS'] == 'linux', label
        assert run['finish'] >= run['start'], label
        assert (directory / 'db' / label).is_dir(), label
        fidelity.append({'family': family, 'probe': probe, 'case_id': cid,
                         'stdout_byte_identical': plain == covered,
                         'plain_stdout_sha256': sha(plain), 'covered_stdout_sha256': sha(covered),
                         'stderr_sha256': sha(stderr)})
    assert {p.name for p in (directory / 'work').iterdir() if p.is_dir()} == labels
    library = ROOT / 'local/date-manip-7.00/lib/perl5'
    files = current.source_files(library / 'Date')
    totals, loaded = current.totals(report['summary'], {str(p) for p in files})
    arch = ROOT / 'local/devel-cover-1.52/lib/perl5/x86_64-linux-gnu-thread-multi'
    cover_lib = ROOT / 'local/devel-cover-1.52/lib/perl5'
    extractor = ROOT / 'tools/coverage-corpus/locations.pl'
    extracted = subprocess.check_output(['/usr/bin/perl', str(extractor), str(directory / 'merged_db'), str(library)],
                                        env={'PATH': '/usr/bin:/bin', 'PERL5LIB': f'{arch}:{cover_lib}'}, cwd=ROOT)
    numeric = json.loads(extracted)
    for kind, row in totals.items():
        raw = numeric['totals'][kind]
        assert (row['total'], row['covered'], row['unexecuted'], row['uncoverable']) == (
            raw['total'], raw['executed'], raw['unexecuted'], raw.get('annotated', 0))
        conflicts = sum(r['kind'] == kind and r['upstream_annotation'] and r['hits'] > 0 for r in numeric['outstanding'])
        assert conflicts == row['execution_annotation_cells']['executed_annotated']
    loaded_set = {str(Path(p).resolve()) for p in loaded}
    audit_sources = [Path(__file__), ROOT / collector_path, extractor, arch / 'Devel/Cover/Criterion.pm']
    print(json.dumps({
        'schema_version': 1,
        'status': 'audited retained coverage artifacts after summary failure; not a completed collector or BDD run',
        'capture_commit': commit, 'capture_source_sha256': capture_hashes,
        'audit_source_sha256': {str(p.relative_to(ROOT)): sha(p.read_bytes()) for p in audit_sources},
        'report_sha256': sha(report_bytes), 'numeric_extraction_sha256': sha(extracted),
        'external_directory': str(directory), 'case_count': len(requests),
        'fidelity': fidelity,
        'normalization': 'Only known DM5 deprecation dynamic eval locations; all other JSON values and stderr exact',
        'warning_location_adjustments': sum(not r['stdout_byte_identical'] for r in fidelity),
        'source_inventory': {
            'file_count': len(files), 'loaded_file_count': len(loaded),
            'loaded_files': [str(Path(p).relative_to(library)) for p in sorted(loaded)],
            'unloaded_files': [str(p.relative_to(library)) for p in files if str(p) not in loaded_set],
            'denominator_note': 'Measured files only; unloaded files have no fabricated criterion rows'},
        'loaded_module_sha256': {str(Path(p).relative_to(ROOT)): sha(Path(p).read_bytes()) for p in sorted(loaded)},
        'date_manip_only_totals': totals,
        'annotation_conflicts': [r for r in numeric['outstanding'] if r['upstream_annotation']],
        'limitations': [
            'Original collector exited during summary validation after collection and merge; this audit does not replace that exit status.',
            'Per-process exit codes were not retained and cannot be reconstructed from stdout or run records.',
            'Source identity relies on the capture checkpoint and verifies retained committed probes against current files.',
            'Reference-probe diagnostic only; no BDD adapter execution and no whole-library completeness claim.',
            'No upstream annotation is an approved project exclusion.'],
    }, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
