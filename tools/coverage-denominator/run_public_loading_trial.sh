#!/usr/bin/env bash
# Run public-load denominator probes into a new external directory.
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
if [ "$#" -ne 1 ]; then
  printf 'usage: %s OUTPUT_DIRECTORY\n' "$0" >&2
  exit 2
fi
output_dir=$1
if [ "${output_dir#/}" = "$output_dir" ]; then
  output_dir="$(pwd -P)/$output_dir"
fi
if [ -e "$output_dir" ]; then
  printf 'refusing to merge into existing output directory: %s\n' "$output_dir" >&2
  exit 2
fi

date_lib="$repo_root/local/date-manip-7.00/lib/perl5"
cover_lib="$repo_root/local/devel-cover-1.52/lib/perl5"
arch=$(env -i PATH=/usr/bin:/bin perl -MConfig -e 'print $Config::Config{archname}')
cover_arch_lib="$cover_lib/$arch"
cover_bin="$repo_root/local/devel-cover-1.52/bin/cover"
for required in "$date_lib/Date/Manip.pm" "$cover_arch_lib/Devel/Cover.pm" "$cover_bin"; do
  test -e "$required" || { printf 'missing separately installed dependency: %s\n' "$required" >&2; exit 2; }
done

mkdir -p "$output_dir"
output_dir=$(CDPATH= cd -- "$output_dir" && pwd -P)
coverage_db="$output_dir/cover_db"
mkdir -p "$output_dir/toolcheck"
reference_version=$(cd "$output_dir/toolcheck" &&
  env -i PATH=/usr/bin:/bin LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Etc/UTC PERL5LIB="$date_lib" \
    perl -MDate::Manip::Date -e 'die "Date-Manip release mismatch\n" unless $Date::Manip::Date::VERSION eq q(7.00); print $Date::Manip::Date::VERSION')
cover_version=$(cd "$output_dir/toolcheck" &&
  env -i PATH=/usr/bin:/bin LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Etc/UTC PERL5LIB="$cover_arch_lib:$cover_lib" \
    perl -MDevel::Cover=-db,"$output_dir/toolcheck/cover_db",-coverage,none,-silent,1 -e 'die "Devel-Cover release mismatch\n" unless $Devel::Cover::VERSION eq q(1.52); print $Devel::Cover::VERSION')
test "$reference_version" = 7.00
test "$cover_version" = 1.52
for scenario in language-french zone-tokyo offset-0530; do
  mkdir -p "$output_dir/work/$scenario/plain" "$output_dir/work/$scenario/covered"
  (cd "$output_dir/work/$scenario/plain" &&
    env -i PATH=/usr/bin:/bin LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Etc/UTC PERL5LIB="$date_lib" \
      perl "$repo_root/tools/coverage-denominator/public_load_trial.pl" "$scenario") \
      >"$output_dir/plain-$scenario.json" 2>"$output_dir/plain-$scenario.stderr"
  (cd "$output_dir/work/$scenario/covered" &&
    env -i PATH=/usr/bin:/bin LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Etc/UTC PERL5LIB="$cover_arch_lib:$cover_lib:$date_lib" \
      perl -MDevel::Cover=-db,"$coverage_db",-coverage,statement,branch,-silent,1,-select,"$date_lib/Date/Manip" \
        "$repo_root/tools/coverage-denominator/public_load_trial.pl" "$scenario") \
      >"$output_dir/covered-$scenario.json" 2>"$output_dir/covered-$scenario.stderr"
  cmp "$output_dir/plain-$scenario.json" "$output_dir/covered-$scenario.json" >"$output_dir/fidelity-$scenario.stdout.cmp"
  cmp "$output_dir/plain-$scenario.stderr" "$output_dir/covered-$scenario.stderr" >"$output_dir/fidelity-$scenario.stderr.cmp"
done

cd "$repo_root"
env -i PATH=/usr/bin:/bin LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Etc/UTC PERL5LIB="$cover_arch_lib:$cover_lib" \
  "$cover_bin" -report json -outputdir "$output_dir/report" -coverage statement -coverage branch "$coverage_db" \
  >"$output_dir/cover-report.stdout" 2>"$output_dir/cover-report.stderr"
printf 'public loading trial written to %s\n' "$output_dir"
