#!/usr/bin/env python3
"""Capture the complete valid Base week-rule matrix twice in clean processes."""
from __future__ import annotations
import hashlib, json, subprocess, tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
FAMILY=ROOT/'docs/research/week-rules-family'
MANIFEST=FAMILY/'matrix-manifest.json'
PROBE=Path(__file__).with_name('probe.pl')
REVIEW=Path(__file__).with_name('review.py')
FEATURE=ROOT/'spec/drafts/week-rules/week-rules.feature'
DATE_LIB=ROOT/'local/date-manip-7.00/lib/perl5'
ENV={'PATH':'/usr/bin:/bin','LANG':'C.UTF-8','LC_ALL':'C.UTF-8','TZ':'Etc/UTC','PERL5LIB':str(DATE_LIB)}
REFERENCE={'release':'Date-Manip-7.00','distribution_version':'7.00','archive_sha256':'37133eeb09d36da6d461546cc216b8f6a2297a43331c680a6848f3fff925975c','archive_url':'https://cpan.metacpan.org/authors/id/S/SB/SBECK/Date-Manip-7.00.tar.gz'}
def digest(path:Path)->str:return hashlib.sha256(path.read_bytes()).hexdigest()
def main()->None:
    raw=[]; processes=[]
    for _ in range(2):
        with tempfile.TemporaryDirectory(prefix='dm-week-rules-') as cwd:
            run=subprocess.run(['/usr/bin/perl',str(PROBE)],cwd=cwd,env=ENV,capture_output=True,timeout=60)
        processes.append({'exit_code':run.returncode,'stderr':run.stderr.decode('utf-8','surrogateescape')})
        if run.returncode or run.stderr: raise AssertionError((run.returncode,run.stderr))
        raw.append(run.stdout)
    if raw[0]!=raw[1]: raise AssertionError('matrix payload differs across fresh processes')
    observation=json.loads(raw[0])
    if observation['exception'] is not None or observation['warnings'] or observation['call_stdout']: raise AssertionError('unexpected native channel')
    if observation['distribution_version']!='7.00': raise AssertionError('wrong distribution')
    paths=observation['loaded_module_paths']; hashes={module:digest(Path(path)) for module,path in sorted(paths.items())}
    for module,path in paths.items():
        resolved=Path(path).resolve()
        if not resolved.is_file() or DATE_LIB not in resolved.parents: raise AssertionError(f'unpinned module {module}')
    artifacts=[MANIFEST,PROBE,Path(__file__).resolve(),REVIEW,FEATURE,Path(__file__).with_name('make_manifest.py'),Path(__file__).with_name('make_feature.py'),Path(__file__).with_name('make_coverage_map.py'),FAMILY/'coverage-map.json']
    print(json.dumps({'schema_version':1,'purpose':'complete valid public Base week-rule matrix; reference evidence, not a BDD run','reference':REFERENCE,'repetitions':2,'timeout_seconds':60,'environment':ENV,'runtime':observation['runtime'],'process_runs':processes,'native_payload_sha256':hashlib.sha256(raw[0]).hexdigest(),'sha256':{str(path.relative_to(ROOT)):digest(path) for path in artifacts},'loaded_module_sha256':hashes,'observation':observation},indent=2,sort_keys=True))
if __name__=='__main__':main()
