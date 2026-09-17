#!/usr/bin/env bash
# Install the pinned Date::Manip reference outside tracked project files.
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/../.." && pwd)
archive=${DATE_MANIP_ARCHIVE:-/tmp/Date-Manip-7.00.tar.gz}
prefix=${DATE_MANIP_REFERENCE_PREFIX:-"$repo_dir/local/date-manip-7.00"}
expected_sha256=37133eeb09d36da6d461546cc216b8f6a2297a43331c680a6848f3fff925975c

if [ ! -f "$archive" ]; then
  printf 'Pinned archive is missing: %s\n' "$archive" >&2
  exit 1
fi

actual_sha256=$(sha256sum "$archive" | awk '{print $1}')
if [ "$actual_sha256" != "$expected_sha256" ]; then
  printf 'Archive SHA-256 mismatch: expected %s, got %s\n' "$expected_sha256" "$actual_sha256" >&2
  exit 1
fi

build_dir=$(mktemp -d /tmp/date-manip-reference-build.XXXXXX)
cleanup() { rm -rf "$build_dir"; }
trap cleanup EXIT HUP INT TERM

tar -xzf "$archive" -C "$build_dir"
source_dir="$build_dir/Date-Manip-7.00"
if [ ! -f "$source_dir/lib/Date/Manip.pm" ]; then
  printf 'Archive did not contain the expected Date-Manip-7.00 source tree.\n' >&2
  exit 1
fi

installed_version=$(perl -ne 'print $1 if /^\s*\$VERSION\s*=\s*\x27([^\x27]+)\x27/' "$source_dir/lib/Date/Manip.pm")
if [ "$installed_version" != '7.00' ]; then
  printf 'Archive module version mismatch: expected 7.00, got %s\n' "$installed_version" >&2
  exit 1
fi

mkdir -p "$prefix"
(
  cd "$source_dir"
  perl Makefile.PL "INSTALL_BASE=$prefix"
  make
  make pure_install
)

library_dir="$prefix/lib/perl5"
PERL5LIB="$library_dir${PERL5LIB:+:$PERL5LIB}" perl -MDate::Manip -e '
  die "Installed Date::Manip version is not 7.00\n" if $Date::Manip::VERSION ne q(7.00);
  print "Installed Date::Manip $Date::Manip::VERSION at $INC{q(Date/Manip.pm)}\n";
'
