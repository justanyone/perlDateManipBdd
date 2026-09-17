#!/usr/bin/env perl
# Source-side discovery only.  This is not a test process and its output is
# intended for an external, ephemeral coverage manifest.
use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use JSON::PP ();

require Date::Manip::Zones;
die "Date-Manip release mismatch\n" unless $Date::Manip::Zones::VERSION eq '7.00';

my $zones_path = $INC{'Date/Manip/Zones.pm'} or die "Zones module path missing\n";
open my $zones_fh, '<:raw', $zones_path or die "cannot read $zones_path: $!\n";
my $sha = Digest::SHA->new(256);
$sha->addfile($zones_fh);
my @entries = map {
  my $module = $Date::Manip::Zones::Offmod{$_};
  {
    case_id => "FO-REACH-$module",
    offset => $_,
    offset_module => "Date/Manip/Offset/$module.pm",
  }
} sort keys %Date::Manip::Zones::Offmod;
die "expected 408 generated offsets\n" unless @entries == 408;
my %module = map { $_->{offset_module} => 1 } @entries;
die "offset module mapping is not one-to-one\n" unless keys(%module) == 408;

print JSON::PP->new->canonical->utf8(0)->encode({
  schema_version => 1,
  purpose => 'ephemeral source-side fixed-offset reachability manifest; not portable test data',
  date_manip_version => $Date::Manip::Zones::VERSION,
  zones_module_sha256 => $sha->hexdigest,
  entry_count => scalar @entries,
  entries => \@entries,
}), "\n";
