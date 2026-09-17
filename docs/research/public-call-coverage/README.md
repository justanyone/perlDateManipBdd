# Public-call coverage instrumentation

This directory prepares coverage collection for the eventual Perl BDD harness.
It is not a harness, a coverage completion result, or a portable specification.
The collection command only executes public Date::Manip entrypoints; private
implementation is measured only when those public calls reach it.

## Pinned tools and separate installation

The reference is Date-Manip 7.00 from the archive recorded in
[`docs/upstream.md`](../../upstream.md):

```text
Date-Manip-7.00.tar.gz
SHA-256 37133eeb09d36da6d461546cc216b8f6a2297a43331c680a6848f3fff925975c
```

The coverage tool is Devel-Cover 1.52, released 2026-03-07. Its CPAN archive
was saved outside the repository as `Devel-Cover-1.52.tar.gz` with:

```text
SHA-256 9d90b44ab602ca373fa221255708de4d19df86026f4d7110bef608846eed44fb
```

The archive metadata and `LICENCE` identify Devel::Cover as Paul Johnson's
work, copyright 2026, under the same terms as Perl 5 (Artistic or GPL). Its
README is the primary tool documentation used here: it describes statement and
branch collection and the `-db`, `-coverage`, `-select`, and JSON report
options. Date::Manip is Sullivan Beck's separately installed dependency,
copyright 1995–2026, under the same terms as Perl 5. Neither dependency is
vendored or distributed by this repository; the ignored `local/` directory is
only a machine-local install. The dependency is recorded in the repository third-party notice.

From checked archives outside the repository, install into the ignored local
prefixes with the following commands. Verify both hashes before unpacking.

```sh
repo=/home/kevin/my_code/perlDateManipBdd
cd /tmp/Date-Manip-7.00
perl Makefile.PL INSTALL_BASE="$repo/local/date-manip-7.00"
make
make pure_install

cd /tmp/Devel-Cover-1.52
perl Makefile.PL INSTALL_BASE="$repo/local/devel-cover-1.52"
make
make pure_install
```

Devel::Cover compiles an XS component, so its install is tied to the Perl
architecture that built it. The runner checks the active architecture before
starting. The installed `Date/Manip.pm` and `Devel/Cover.pm` both match their
respective archive source files by SHA-256 in the completed pilot.

## Pilot and fidelity check

[`tools/coverage/public_call_pilot.pl`](../../../tools/coverage/public_call_pilot.pl)
uses only public OO, DM6, and DM5 calls. It fixes UTC, locale, reference time,
English, encoding, and date format. It records result carriers, errors,
warnings, and call-produced stdout as canonical JSON.

Run it only with a new output directory; this prevents accidental merges with
an earlier coverage database:

```sh
tools/coverage/run_public_call_pilot.sh /tmp/date-manip-public-call-pilot
```

The runner performs each profile once without instrumentation and once with
Devel::Cover statement and branch collection. Every process starts with an
otherwise empty environment: fixed `PATH`, `LANG`, `LC_ALL`, `TZ`, and only the
required `PERL5LIB`; `HOME` and `PERL5OPT` are not inherited. Each plain and
instrumented process has its own fresh working directory. The runner stops if
either JSON stdout or process stderr differs. It asserts Date-Manip 7.00,
Devel-Cover 1.52, and the Perl architecture before collecting. It then creates
`summary.json` with source hashes, all loaded and unloaded source module paths,
raw totals, Devel::Cover's effective denominator, and the tool's upstream
`uncoverable` annotations. The raw structural total is never replaced by the
effective denominator.

The initial verified pilot recorded byte-identical stdout, no pilot-process
stderr, and identical result/error/warning/stdout values for all three
profiles. It loaded 16 of 804 installed Date::Manip `.pm` files. For those 16
files only, it reached 3,830 of 11,375 statement criteria and 460 of 6,376
branch criteria. Devel::Cover marked two statements and one branch as upstream
`uncoverable` annotations in `Date::Manip::Obj`; those are recorded for review,
not approved exclusions. The 788 unloaded modules have no generated criterion
rows, so this is not an all-library percentage and cannot be compared with the
required 99% statement / 95% branch completion thresholds.

[`pilot-result.json`](pilot-result.json) is the compact, checked-in record of
that run: archive, tool, module, and script hashes; version and environment
checks; fidelity result; source-inventory manifest hash; and raw totals. The
full Devel::Cover database and its full per-module enumeration are deliberately
external artifacts under the chosen `/tmp` output directory.

The final harness should reuse the collector setup, leave the source inventory
whole, and review every remaining error and every upstream/tool exclusion. Its
coverage assertion must calculate Date::Manip-only totals from `summary.json`'s
source-root filter, because Devel::Cover's JSON report also contains the program
being instrumented.

Coordinator validation
----------------------

A fresh root review run at `/tmp/date-manip-public-call-pilot-root-review`
reproduced the loaded-file counts and criterion totals with byte-identical
plain/instrumented results and stderr. The summarizer rejects negative or
inconsistent counts, absence of instrumented library files, incomplete pilot
calls, and changed output channels. It reports `raw_percentage` separately from
`tool_effective_percentage`; the latter removes upstream annotations and must
not be used as an approved-exclusion percentage. Neither is whole-library coverage
while788 modules lack criterion rows.

Seven original regression checks cover these safeguards:

```sh
python3 -m unittest discover -s tests/coverage -v
```

These are tests of the coverage tooling, not Date::Manip BDD scenarios. The
compact pilot-result.json includes current tool hashes and raw/tool-adjusted
percentages. Final coverage reporting must retain all uncovered rows and review
each upstream/tool annotation independently.
