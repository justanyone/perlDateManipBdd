#!/usr/bin/env python3
"""Record separately installed development distributions without vendoring them."""
import hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
rows=[]
for path in sorted((ROOT/'local/bdd-runner/lib/perl5').glob('*/.meta/*/install.json')):
 installed=json.loads(path.read_text())
 metadata=json.loads(path.with_name('MYMETA.json').read_text())
 rows.append({'distribution':installed['dist'],'version':installed['version'],
              'cpan_archive':installed.get('pathname'),'declared_licenses':metadata.get('license'),
              'install_metadata_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
              'package_metadata_sha256':hashlib.sha256(path.with_name('MYMETA.json').read_bytes()).hexdigest()})
module=ROOT/'local/bdd-runner/lib/perl5/Test/BDD/Cucumber.pm'
version=subprocess.check_output(['perl','-I'+str(ROOT/'local/bdd-runner/lib/perl5'),'-MTest::BDD::Cucumber','-e','print $Test::BDD::Cucumber::VERSION'],text=True)
assert version=='0.87',version
rows.append({'distribution':'Test-BDD-Cucumber-0.87','version':version,'declared_licenses':['perl_5'],'cpan_archive':'local pinned archive; cpanminus supplied no install metadata','installed_module_sha256':hashlib.sha256(module.read_bytes()).hexdigest()})
print(json.dumps({'scope':'separately installed development environment; no source files included',
                  'runner_archive_sha256':'afa2f8a1c5aaa7435270088b33edf7ecc94987181e4e5f4af0907a61bc258a43',
                  'distributions':rows},indent=2))
