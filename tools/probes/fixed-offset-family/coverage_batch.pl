#!/usr/bin/env perl
# Coverage collection only: sequential public calls allow all generated offsets
# to enter one Devel::Cover database.  The two observation runs remain isolated
# one-process-per-case runs.
use strict;
use warnings;
use JSON::PP ();

my $manifest_path = shift @ARGV // die "manifest path required\n";
die "unexpected arguments\n" if @ARGV;
open my $manifest_fh, '<:raw', $manifest_path or die "cannot read manifest: $!\n";
local $/;
my $manifest = JSON::PP->new->decode(<$manifest_fh>);
die "unexpected manifest\n" unless $manifest->{entry_count} == 408;

require Date::Manip::Date;
die "Date-Manip release mismatch\n" unless $Date::Manip::Date::VERSION eq '7.00';
my @records;
for my $entry (@{ $manifest->{entries} }) {
  my (@warnings, $exception, $result, $call_stdout);
  $call_stdout = '';
  {
    local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
    local *STDOUT;
    open STDOUT, '>', \$call_stdout or die "cannot capture stdout: $!\n";
    local $@;
    my $ok = eval {
      my $anchor = Date::Manip::Date->new();
      my $configuration_status = $anchor->config(
        Defaults => 1,
        ForceDate => '2040-02-28-10:20:30,Etc/UTC',
        Language => 'English', Encoding => 'ASCII', DateFormat => 'non-US',
      );
      my %before = loaded_modules();
      my $date = $anchor->new_date("2040-02-29 12:34:56 $entry->{offset}");
      my $error_after_parse = $date->err();
      my %observers;
      if ($error_after_parse eq '') {
        my $parsed_scalar = $date->value(); my @parsed_list = $date->value();
        my $gmt_scalar = $date->value('gmt'); my @gmt_list = $date->value('gmt');
        my $formatted = $date->printf('%Y-%m-%d %H:%M:%S %z %Z');
        %observers = (
          value_observers_called => JSON::PP::true,
          parsed_scalar => $parsed_scalar, parsed_list => \@parsed_list,
          gmt_scalar => $gmt_scalar, gmt_list => \@gmt_list,
          formatted => $formatted, error_after_reads => $date->err(),
        );
      } else {
        %observers = (value_observers_called => JSON::PP::false);
      }
      my %after = loaded_modules();
      my @new_offset = sort grep { !$before{$_} && m{\ADate/Manip/Offset/} } keys %after;
      my @new_zone = sort grep { !$before{$_} && m{\ADate/Manip/TZ/} } keys %after;
      $result = {
        configuration_status => $configuration_status, configuration_error => $anchor->err(),
        error_after_parse => $error_after_parse, %observers,
        target_offset_module_loaded_before => exists $before{$entry->{offset_module}} ? JSON::PP::true : JSON::PP::false,
        target_offset_module_loaded => exists $after{$entry->{offset_module}} ? JSON::PP::true : JSON::PP::false,
        new_offset_modules => \@new_offset, new_offset_module_count => scalar @new_offset,
        new_zone_module_count => scalar @new_zone,
      };
      1;
    };
    $exception = "$@" unless $ok;
  }
  push @records, {
    schema_version => 1,
    purpose => 'public fixed-offset observation; module-loading fields are coverage evidence, not assertions of behavior completeness',
    case_id => $entry->{case_id}, input_offset => $entry->{offset},
    target_offset_module => $entry->{offset_module}, distribution_version => $Date::Manip::Date::VERSION,
    result => $result, warnings => \@warnings, exception => $exception,
    call_stdout => $call_stdout,
  };
}
print JSON::PP->new->canonical->utf8(0)->encode(\@records), "\n";

sub loaded_modules {
  return map { $_ => 1 } grep { m{\ADate/Manip/(?:Offset|TZ)/.+\.pm\z} } keys %INC;
}
