#!/usr/bin/env perl
# Original public-call fixed-offset observation.  Module load inspection is
# coverage evidence only; Date::Manip calls below are public OO operations.
use strict;
use warnings;
use JSON::PP ();

my ($case_id, $offset, $target_module) = @ARGV;
die "usage: probe.pl CASE_ID OFFSET OFFSET_MODULE\n"
  unless defined $target_module && !defined $ARGV[3];
die "invalid target module\n" unless $target_module =~ m{\ADate/Manip/Offset/off\d{3}\.pm\z};

require Date::Manip::Date;
die "Date-Manip release mismatch\n" unless $Date::Manip::Date::VERSION eq '7.00';

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
      Language => 'English',
      Encoding => 'ASCII',
      DateFormat => 'non-US',
    );
    my %before = loaded_modules();
    my $date = $anchor->new_date("2040-02-29 12:34:56 $offset");
    my $error_after_parse = $date->err();
    my %observers;
    if ($error_after_parse eq '') {
      my $parsed_scalar = $date->value();
      my @parsed_list = $date->value();
      my $gmt_scalar = $date->value('gmt');
      my @gmt_list = $date->value('gmt');
      my $formatted = $date->printf('%Y-%m-%d %H:%M:%S %z %Z');
      %observers = (
        value_observers_called => JSON::PP::true,
        parsed_scalar => $parsed_scalar,
        parsed_list => \@parsed_list,
        gmt_scalar => $gmt_scalar,
        gmt_list => \@gmt_list,
        formatted => $formatted,
        error_after_reads => $date->err(),
      );
    } else {
      %observers = (value_observers_called => JSON::PP::false);
    }
    my %after = loaded_modules();
    my @new_offset = sort grep { !$before{$_} && m{\ADate/Manip/Offset/} } keys %after;
    my @new_zone = sort grep { !$before{$_} && m{\ADate/Manip/TZ/} } keys %after;
    $result = {
      configuration_status => $configuration_status,
      configuration_error => $anchor->err(),
      error_after_parse => $error_after_parse,
      %observers,
      target_offset_module_loaded_before => exists $before{$target_module} ? JSON::PP::true : JSON::PP::false,
      target_offset_module_loaded => exists $after{$target_module} ? JSON::PP::true : JSON::PP::false,
      new_offset_modules => \@new_offset,
      new_offset_module_count => scalar @new_offset,
      new_zone_module_count => scalar @new_zone,
    };
    1;
  };
  $exception = "$@" unless $ok;
}
print JSON::PP->new->canonical->utf8(0)->encode({
  schema_version => 1,
  purpose => 'public fixed-offset observation; module-loading fields are coverage evidence, not assertions of behavior completeness',
  case_id => $case_id,
  input_offset => $offset,
  target_offset_module => $target_module,
  distribution_version => $Date::Manip::Date::VERSION,
  result => $result,
  warnings => \@warnings,
  call_stdout => $call_stdout,
  exception => $exception,
}), "\n";

sub loaded_modules {
  return map { $_ => 1 } grep { m{\ADate/Manip/(?:Offset|TZ)/.+\.pm\z} } keys %INC;
}
