# Date::Manip source map

Verified on 2026-09-17. The complete upstream development repository is
[SBECK-github/Date-Manip](https://github.com/SBECK-github/Date-Manip).
The published distribution is [Date-Manip on CPAN](https://metacpan.org/dist/Date-Manip).

| Source | Inspected version | Reproducible identifier |
| --- | --- | --- |
| Published CPAN source | 7.00, released 2026-09-01 | [Source archive](https://cpan.metacpan.org/authors/id/S/SB/SBECK/Date-Manip-7.00.tar.gz) |
| Upstream Git | Version field 7.01 | `4b9b9d5c802750f0fca04f9168c65d9dc4562d65` |

CPAN's [release API](https://fastapi.metacpan.org/v1/release/Date-Manip) reported
7.00 as latest at inspection. Git's version field does not establish a release.
The archive's locally calculated SHA-256 is:

```text
37133eeb09d36da6d461546cc216b8f6a2297a43331c680a6848f3fff925975c
```

This checksum records the downloaded bytes; it is not an upstream signature.
[Machine-readable provenance](upstream-source.json) records the same identifiers.

## Complete file inventories

Both inspected trees have 1,123 files. All paths, not just the main module, are
listed in [the release inventory](upstream-release-files.txt) and
[the Git inventory](upstream-git-files.txt). Git contains 804 `.pm` files across
the tree. Its 847 `lib/` files include modules and documentation. These counts
are file counts, not function or behavioral coverage counts.

| Location | Contents and testing significance |
| --- | --- |
| `lib/Date/Manip.pm` | Entry point selecting the functional backend |
| `lib/Date/Manip/DM5.pm`, `DM5abbrevs.pm` | Legacy backend and abbreviation data |
| `lib/Date/Manip/DM6.pm` | Modern functional API |
| `lib/Date/Manip/{Obj,Base,Date,Delta,Recur,TZ}.pm` | OO base, parsing, dates, deltas, recurrences, timezones |
| `lib/Date/Manip/{TZ_Base,TZdata,Zones}.pm` | Timezone support and data |
| `lib/Date/Manip/{Lang,Offset,TZ}/` | Language and generated timezone/offset modules |
| `lib/**/*.pod` | API contracts and usage documentation |
| `t/` | 228 upstream test/support files; licensed upstream material |
| `internal/` | 34 development files, including generators and benchmarks |
| `examples/` | Example tools and documentation |
| `Makefile.PL`, `META.*`, `MANIFEST`, `LICENSE` | Build, prerequisites, packaging and license evidence |

The full Git clone, including available history/tags, was inspected at
`/tmp/date-manip-upstream`; the archive at `/tmp/Date-Manip-7.00.tar.gz`.
These temporary paths are not repository dependencies or durable storage.
The inventories cover these snapshots, not every historical release or external
dependency. Older published versions are available through CPAN/MetaCPAN.

## Reproduce source inspection

Clone outside this project's tracked tree, then select the recorded revision:

```sh
git clone https://github.com/SBECK-github/Date-Manip.git /tmp/date-manip-review
git -C /tmp/date-manip-review checkout --detach 4b9b9d5c802750f0fca04f9168c65d9dc4562d65
git -C /tmp/date-manip-review ls-files
```

Alternatively download the release archive above and verify its SHA-256 before
unpacking. Use the release's `MANIFEST` to inspect its packaged contents.
Keep upstream source separately licensed; this repository records locations and
inventories rather than redistributing the library under MIT.

Before implementing the suite, select and record a supported release baseline.
Inventory named subroutines alongside POD, exports, aliases, and inherited methods.
A regex scan alone cannot establish the entire callable API or complete coverage.
