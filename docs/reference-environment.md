# Reproducible Date::Manip reference environment

The reference baseline is CPAN `Date-Manip-7.00`, with archive SHA-256
`37133eeb09d36da6d461546cc216b8f6a2297a43331c680a6848f3fff925975c` as recorded
in [upstream-source.json](upstream-source.json). The reference dependency is installed
into `local/date-manip-7.00`, an ignored directory, so no Date::Manip source or
generated install files enter the repository.

The setup and probe files under `tools/reference/` are original project tooling. They
are reference observations, not the BDD runner, step definitions, or an assertion
adapter.

Run the following from the repository root. Fetch the exact release into `/tmp` when
it is absent; the installer verifies its hash before it extracts or installs anything.

```sh
curl --fail --location --output /tmp/Date-Manip-7.00.tar.gz \
  https://cpan.metacpan.org/authors/id/S/SB/SBECK/Date-Manip-7.00.tar.gz
tools/reference/install-date-manip-reference.sh
tools/reference/run-isolated-profiles.sh
```

`install-date-manip-reference.sh` extracts the archive to a newly created temporary
directory, checks that `Date::Manip.pm` declares version 7.00, and uses `INSTALL_BASE`
to install the dependency in the ignored prefix. It does not modify the checked-out
upstream extraction at `/tmp/Date-Manip-7.00`.

`run-isolated-profiles.sh` runs each of these profiles twice in separate Perl
processes and compares their canonical JSON output byte-for-byte:

| Profile | Public interface | Purpose |
| --- | --- | --- |
| `dm6` | `Date::Manip::DM6` | Primary functional reference profile |
| `dm5` | `Date::Manip::DM5` | Explicit legacy compatibility profile |
| `oo` | `Date::Manip::Date` | Primary object-oriented profile |

Every run has `TZ=Etc/UTC`, `LANG=C.UTF-8`, `LC_ALL=C.UTF-8`, a fresh empty working
directory, and a fixed Date::Manip clock of `2040-02-28 10:20:30`. DM6 and OO set the
clock in `Etc/UTC`; their first setting is `Defaults=1`, and they do not load a
configuration file because the 6.x interface only reads one when `ConfigFile` is
explicitly set. They name English/ASCII parsing, US numeric order, native printable
representation, midnight as the default missing time, Monday/January-4 week rules,
Monday-Friday 09:00-17:00 working hours, and cleared holidays and events.

DM5 has a deliberately separate compatibility configuration: it explicitly sets
`IgnoreGlobalCnf=1`, empty `PersonalCnf` and `PersonalCnfPath`, the UTC timezone,
native internal representation, `Jan1Week1=0`, and `TodayIsMidnight=1`. DM5's fixed
clock accepts no zone suffix, so its UTC zone comes from both the explicit `TZ` setting
and the process environment. It has no `Printable`, `Week1ofYear`, `DefaultTime`, or
`EraseEvents` setting; the record retains those differences instead of silently
pretending that DM6 defaults apply.

The probe rejects a distribution or backend version other than its named baseline.
DM6 and OO also reject bundled timezone data other than `tzdata2026c` and
`tzcode2026c`. DM5 is a retained 5.66 compatibility backend in the 7.00 distribution;
it does not expose those 6.x timezone-data identifiers, so its record does not claim
them. Its zone input is instead the explicit UTC configuration and process `TZ`.

The probe emits environment, runtime, loaded module path, configuration status, and
a small set of public-call observations. DM5's `tomorrow` result is deliberately
retained as an independent compatibility observation; it is not an expected copy of
the DM6 or OO value. The retained source-separated record is
[`reference-profiles.json`](automation/reference-profiles.json). These observations
establish profile setup and repeatability only. New cases must use their own original
probe, preserve full context and output channels, be repeated in fresh processes,
and be reviewed before their literal result enters a feature expectation.

On 2026-09-17, the two-run comparison passed for all three profiles with Perl
`5.40.1`, architecture `x86_64-linux-gnu-thread-multi`, and OS name `linux`. DM6 and
OO reported distribution version `7.00`, `tzdata2026c`, and `tzcode2026c`; DM5
reported distribution version `7.00` and compatibility backend version `5.66`. The
setup observations were DM6 `tomorrow=2040022900:00:00`, DM5
`tomorrow=2040022910:20:30`, and OO `tomorrow=2040022900:00:00` with status `0`.
All profiles produced `2040022916:05:09` for the explicit leap date; their
configuration-status channels are included in the JSON rather than normalized away.

This baseline remains host-sensitive for the Perl runtime and operating system. The
Date::Manip 7.00 distribution bundles `tzdata2026c` and `tzcode2026c`; capture the
actual probe output with any case evidence. OS-dependent zone discovery and POSIX
formatting are separate profiles because their host integration is deliberately not
covered by this fixed UTC setup.
