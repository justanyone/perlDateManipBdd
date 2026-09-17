# Public-probe coverage corpus diagnostic

This is a bounded source-coverage diagnostic that reuses existing original
public-reference probes. It is neither an executable BDD suite nor a completion
coverage result. Every collected process invokes only a selected probe's public
Date-Manip calls; private implementation code is measured only if reached by
those calls.

The committed manifest selects 30 varied cases: 12 `Date->set` cases, all 11
completeness cases, and seven partial-parser cases. The collector requires an
explicit manifest, so it cannot silently choose or expand the corpus.

```sh
python3 tools/coverage-corpus/collect.py \
  --manifest tools/coverage-corpus/representative-manifest.json \
  --output /tmp/public-coverage-corpus
```

Each case runs in a fresh plain process and a fresh Devel-Cover process with a
minimal environment (`PATH`, `LANG`, `LC_ALL`, `TZ`, and profile-specific
`PERL5LIB`; no inherited `HOME` or `PERL5OPT`). The collector rejects changed
native JSON stdout, changed process stderr, nonzero exit, malformed JSON, or a
shared coverage database. It gives every covered process its own database, then
merges the databases only after all fidelity checks pass.

The external run at `/tmp/public-coverage-corpus-v4` had byte-identical native
JSON and empty identical stderr for all 30 pairs. It loaded 14 of 804 installed
Date-Manip modules; the other 790 are named in the external summary as unloaded
files with no fabricated criterion rows. For the loaded-file denominator it
reached 2,231/5,802 statements (38.4523% raw) and 333/3,080 branches (10.8117%
raw). Devel-Cover's tool-effective values are separate and do not approve its
two statement and one branch `uncoverable` annotations.

[`result.json`](result.json) is the compact checked-in record. The full merged
database, JSON report, all loaded/unloaded paths, and per-case fidelity hashes
remain under the chosen `/tmp` output directory.

The report ranks remaining branch criteria by loaded core module and lists
public-operation source entry locations to guide the next corpus expansion:
`Date::Manip::Date` parsing and `set`, `Date::Manip::TZ` resolution and period
enumeration, `Date::Manip::Base` configuration, and `Date::Manip::Obj`
construction. These locations identify public domains with remaining branches;
they do not claim a one-to-one mapping from a particular Devel-Cover criterion to
a source line. No upstream source excerpt or private call is included.
