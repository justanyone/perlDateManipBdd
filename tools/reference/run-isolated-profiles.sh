#!/usr/bin/env bash
# Run each reference profile twice in clean processes and compare exact JSON output.
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/../.." && pwd)
prefix=${DATE_MANIP_REFERENCE_PREFIX:-"$repo_dir/local/date-manip-7.00"}
library_dir="$prefix/lib/perl5"
probe="$script_dir/profile-probe.pl"

if [ ! -f "$library_dir/Date/Manip.pm" ]; then
  printf 'Reference dependency is absent at %s. Run %s first.\n' "$prefix" "$script_dir/install-date-manip-reference.sh" >&2
  exit 1
fi

run_dir=$(mktemp -d /tmp/date-manip-reference-probe.XXXXXX)
cleanup() { rm -rf "$run_dir"; }
trap cleanup EXIT HUP INT TERM
mkdir "$run_dir/work"

run_once() {
  profile=$1
  output=$2
  (
    cd "$run_dir/work"
    env -i \
      PATH="$PATH" \
      LANG=C.UTF-8 \
      LC_ALL=C.UTF-8 \
      TZ=Etc/UTC \
      PERL5LIB="$library_dir" \
      perl "$probe" "$profile" > "$output"
  )
}

for profile in dm6 dm5 oo; do
  first="$run_dir/$profile.first.json"
  second="$run_dir/$profile.second.json"
  run_once "$profile" "$first"
  run_once "$profile" "$second"
  cmp -- "$first" "$second"
  printf '%s\n' "$(cat "$first")"
done
