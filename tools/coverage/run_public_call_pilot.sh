#!/usr/bin/env bash
# Run the original, intentionally small public-entrypoint coverage pilot.
# The output directory must be new so a run never silently merges old data.
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

date_prefix="$repo_root/local/date-manip-7.00"
cover_prefix="$repo_root/local/devel-cover-1.52"
date_lib="$date_prefix/lib/perl5"
cover_arch=$(env -i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin perl -MConfig -e 'print $Config::Config{archname}')
cover_lib="$cover_prefix/lib/perl5"
cover_arch_lib="$cover_lib/$cover_arch"
cover_bin="$cover_prefix/bin/cover"
module_root="$date_lib/Date"
clean_path='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

for required in "$date_lib/Date/Manip.pm" "$cover_arch_lib/Devel/Cover.pm" "$cover_bin"; do
  if [ ! -e "$required" ]; then
    printf 'missing separately installed dependency: %s\n' "$required" >&2
    exit 2
  fi
done

mkdir -p "$output_dir"
output_dir=$(CDPATH= cd -- "$output_dir" && pwd -P)
coverage_db="$output_dir/cover_db"
toolcheck_dir="$output_dir/toolcheck"
mkdir -p "$toolcheck_dir"

reference_version=$(cd "$toolcheck_dir" && env -i PATH="$clean_path" LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Etc/UTC \
  PERL5LIB="$date_lib" perl -MDate::Manip::Date -e 'die "Date-Manip release mismatch\n" unless $Date::Manip::Date::VERSION eq q(7.00); print $Date::Manip::Date::VERSION')
cover_version=$(cd "$toolcheck_dir" && env -i PATH="$clean_path" LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Etc/UTC \
  PERL5LIB="$cover_arch_lib:$cover_lib" perl -MDevel::Cover=-db,"$toolcheck_dir/cover_db",-coverage,none,-silent,1 -e 'die "Devel-Cover release mismatch\n" unless $Devel::Cover::VERSION eq q(1.52); print $Devel::Cover::VERSION')
perl_arch=$(env -i PATH="$clean_path" LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Etc/UTC perl -MConfig -e 'print $Config::Config{archname}')
cd "$repo_root"
for profile in oo dm6 dm5; do
  plain_work="$output_dir/work/$profile/plain"
  covered_work="$output_dir/work/$profile/covered"
  mkdir -p "$plain_work" "$covered_work"
  (cd "$plain_work" && env -i PATH="$clean_path" LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Etc/UTC PERL5LIB="$date_lib" \
    perl "$repo_root/tools/coverage/public_call_pilot.pl" "$profile") \
    >"$output_dir/plain-$profile.json" 2>"$output_dir/plain-$profile.stderr"

  (cd "$covered_work" && env -i PATH="$clean_path" LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Etc/UTC \
    PERL5LIB="$cover_arch_lib:$cover_lib:$date_lib" \
    perl -MDevel::Cover=-db,"$coverage_db",-coverage,statement,branch,-silent,1,-select,"$module_root/Manip" \
      "$repo_root/tools/coverage/public_call_pilot.pl" "$profile") \
      >"$output_dir/covered-$profile.json" 2>"$output_dir/covered-$profile.stderr"

  cmp "$output_dir/plain-$profile.json" "$output_dir/covered-$profile.json" \
    >"$output_dir/fidelity-$profile.cmp"
  cmp "$output_dir/plain-$profile.stderr" "$output_dir/covered-$profile.stderr" \
    >"$output_dir/fidelity-$profile.stderr.cmp"
done

# The JSON reporter writes every collected file, so the original summarizer
# below filters it to the pinned Date::Manip installation before calculating
# the target denominator.
env -i PATH="$clean_path" LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Etc/UTC PERL5LIB="$cover_arch_lib:$cover_lib" \
  "$cover_bin" -report json -outputdir "$output_dir/report" \
    -coverage statement -coverage branch "$coverage_db" \
    >"$output_dir/cover-report.stdout" 2>"$output_dir/cover-report.stderr"

env -i PATH="$clean_path" LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Etc/UTC perl "$repo_root/tools/coverage/summarize_public_call_coverage.pl" \
  --module-root "$module_root" \
  --cover-json "$output_dir/report/cover.json" \
  --plain-directory "$output_dir" \
  --covered-directory "$output_dir" \
  --reference-version "$reference_version" \
  --cover-version "$cover_version" \
  --perl-archname "$perl_arch" \
  --execution-path "$clean_path" \
  --cover-module "$cover_arch_lib/Devel/Cover.pm" \
  --pilot-script "$repo_root/tools/coverage/public_call_pilot.pl" \
  --runner-script "$repo_root/tools/coverage/run_public_call_pilot.sh" \
  --summary-script "$repo_root/tools/coverage/summarize_public_call_coverage.pl" \
  --output "$output_dir/summary.json"

printf 'public-call coverage pilot written to %s\n' "$output_dir"
