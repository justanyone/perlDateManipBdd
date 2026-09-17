# BDD runner compatibility trial

This original development-only trial exercises Test::BDD::Cucumber0.87 before
implementing the Date::Manip adapter. It contains no Date::Manip behavior tests
and does not promote any draft specification.

The separately downloaded archive has SHA-256
`afa2f8a1c5aaa7435270088b33edf7ecc94987181e4e5f4af0907a61bc258a43`.
Its LICENSE names Peter Sergeant, copyright2025, and offers the same terms as
Perl5 (Artistic or GPL1-or-later). The project notice records this dependency;
upstream source and dependency installs remain outside tracked project files.

Install into the ignored local prefix using cpanminus and its normal build/tests:

```sh
env -u NO_COLOR -u ANSI_COLORS_DISABLED PERL_CPANM_HOME=/tmp/date-manip-cpanm-work perl /tmp/date-manip-cpanm.pl \
  --local-lib-contained "$PWD/local/bdd-runner" \
  --mirror https://cpan.metacpan.org --mirror-only \
  /tmp/Test-BDD-Cucumber-0.87.tar.gz
```

The cpanminus bootstrap used for this trial was fetched from `https://cpanmin.us`
and has SHA-256
`137e8c5856e09867f6d7631d6d67a5e7778166962e29830c573cbbbab6ed2e21`.
Dependency versions are resolved during install; retain the generated receipt
rather than assuming a later unpinned dependency resolution is identical.

Run and capture the trial:

```sh
python3 tools/runner-trial/run.py > /tmp/date-manip-runner-trial.json
python3 tools/runner-trial/install-receipt.py > /tmp/date-manip-runner-install.json
```

The positive selection must execute five scenarios: three expanded Examples
rows, a step data table, and a multiline docstring. It checks Unicode, escaped
pipes, ordering, and fresh scenario state. Tag selection must execute exactly
three outline rows. The incorrect-literal run must fail; the undefined-step run
must also fail with strict mode enabled. Empty execution is rejected.

Verified results: the positive selection passes five scenarios, the outline
selection passes three, the deliberate wrong literal exits2 with a failed step,
and strict undefined-step selection exits1 with a skipped/undefined step.
The runner preserves a trailing newline in docstring data. The trial asserts
that actual behavior explicitly; an adapter must define any normalization.

The first upstream install attempt failed one colour-output assertion because
this session inherited `NO_COLOR=1`. Re-running with both colour override
variables removed passed all532 upstream tests across22 files (the author-only
POD test is skipped). No upstream test or source was modified or forced past.
The49 dependency distributions also built and tested successfully.

`install-receipt.json` records installed versions and their declared license
metadata. `trial-result.json` records the verified original trial counts, statuses
and tool hashes. These are runner-capability results, not Date::Manip BDD passes.
The Date::Manip adapter and whole-library coverage gates remain incomplete.

## Draft syntax audit

The public runner parser accepted all37 tracked draft files after replacing19
unsupported typed docstring markers (`"""json`) with plain `"""` markers in
configuration-file features. JSON contents and English instructions are unchanged;
the existing36-case literal checker still verifies the exact decoded file bytes.
The audit counted251 scenario declarations and1,047 expanded scenarios. This
snapshot predates subsequent worker integrations and makes no semantic claim.
A temporary malformed typed-docstring control returned a nonzero status, proving
that parser errors make the audit fail.

Invoke the public parser audit with explicit feature paths:

```sh
PERL5LIB="$PWD/local/bdd-runner/lib/perl5" \
  perl tools/runner-trial/parse-features.pl spec/drafts/config-files/loading.feature
```

`draft-parse-result.json` records each parsed file hash. An in-progress worker's
later edits invalidate that file's recorded syntax snapshot until it is rechecked.
