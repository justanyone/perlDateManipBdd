#!/usr/bin/env perl
# Original public-call routes used only to discover coverage denominators.
# It never imports generated data modules or calls underscore-prefixed methods.
use strict;
use warnings;
use utf8;
use JSON::PP ();

my $scenario = shift @ARGV // die "scenario required\n";
die "unexpected arguments\n" if @ARGV;
die "unknown scenario\n"
  unless $scenario =~ /\A(?:language-french|zone-tokyo|offset-0530)\z/;

require Date::Manip::Date;
die "Date-Manip release mismatch\n" unless $Date::Manip::Date::VERSION eq '7.00';

my $anchor = Date::Manip::Date->new();
my $bootstrap_status = $anchor->config(
  Defaults => 1,
  ForceDate => '2040-02-28-10:20:30,Etc/UTC',
  Language => 'English',
  Encoding => 'UTF-8',
  DateFormat => 'non-US',
);
die "bootstrap configuration failed\n" unless $anchor->err() eq q();
my %before = loaded_generated_modules();
my ($result, $status, $error);
if ($scenario eq 'language-french') {
  $status = $anchor->config(Language => 'French');
  my $date = $anchor->new_date('29 février 2040');
  $error = $date->err();
  $result = { parsed_value => scalar($date->value()), error_after_value => $date->err() };
} elsif ($scenario eq 'zone-tokyo') {
  my $tz = $anchor->tz();
  my @periods = $tz->all_periods('Asia/Tokyo', 2040);
  $error = $tz->err();
  $status = $error eq q() ? 0 : 1;
  $result = { period_count => scalar @periods };
} else {
  my $date = $anchor->new_date('2040-02-29 16:05:09 +05:30');
  $error = $date->err();
  $status = $error eq q() ? 0 : 1;
  $result = { parsed_value => scalar($date->value()), error_after_value => $date->err() };
}
die "public call failed\n" unless $error eq q();
if ($scenario eq 'zone-tokyo') {
  die "expected a zone period\n" unless $result->{period_count} > 0;
} else {
  my $expected = $scenario eq 'language-french' ? '2040022900:00:00' : '2040022916:05:09';
  die "unexpected public date result\n"
    unless $result->{parsed_value} eq $expected && $result->{error_after_value} eq q();
}

my %after = loaded_generated_modules();
my @new = sort grep { !$before{$_} } keys %after;
print JSON::PP->new->canonical->utf8(0)->encode({
  schema_version => 1,
  purpose => 'public-route denominator discovery; not a behavioral coverage assertion',
  scenario => $scenario,
  distribution_version => $Date::Manip::Date::VERSION,
  bootstrap_status => $bootstrap_status,
  status => $status,
  error => $error,
  result => $result,
  generated_modules_newly_loaded_after_public_call => \@new,
}), "\n";

sub loaded_generated_modules {
  return map {
    my $path = $INC{$_};
    $path =~ s{.*?/Date/}{Date/};
    $path => 1;
  } grep { m{\ADate/Manip/(?:Lang|TZ|Offset)/.+\.pm\z} } keys %INC;
}
