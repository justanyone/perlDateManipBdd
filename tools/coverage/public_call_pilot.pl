#!/usr/bin/env perl
# Original public-call-only pilot used to validate Date::Manip coverage collection.
use strict;
use warnings;
use JSON::PP ();
use Config ();

my $profile = shift @ARGV // die "profile required\n";
die "unexpected arguments\n" if @ARGV;
die "unknown profile\n" unless $profile eq 'oo' || $profile eq 'dm6' || $profile eq 'dm5';

my (@warnings, $call_stdout, $result, $exception);
$call_stdout = '';
{
  local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
  local *STDOUT;
  open STDOUT, '>:encoding(UTF-8)', \$call_stdout or die $!;
  local $@;
  my $ok = eval {
    $result = $profile eq 'oo' ? run_oo()
            : $profile eq 'dm6' ? run_dm6()
            : run_dm5();
    1;
  };
  $exception = "$@" unless $ok;
}

my $record = {
  schema_version => 1,
  profile => $profile,
  public_calls_only => JSON::PP::true,
  result => $result,
  exception => $exception,
  warnings => \@warnings,
  call_stdout => $call_stdout,
  environment => {
    perl_version => "$^V",
    perl_archname => $Config::Config{archname},
    timezone => 'Etc/UTC',
    locale => 'C.UTF-8',
  },
};
binmode STDOUT, ':encoding(UTF-8)';
print JSON::PP->new->canonical->utf8(0)->encode($record), "\n";

sub scalar_and_list_value {
  my ($value, @args) = @_;
  my $scalar = $value->value(@args);
  my @list = $value->value(@args);
  return { scalar => $scalar, list => \@list, error => $value->err() };
}

sub run_oo {
  require Date::Manip::Date;
  require Date::Manip::Delta;
  require Date::Manip::Recur;
  die "Date-Manip release mismatch\n" unless $Date::Manip::Date::VERSION eq '7.00';

  my $anchor = Date::Manip::Date->new();
  my $configuration_status = $anchor->config(
    Defaults => 1,
    ForceDate => '2040-02-28-10:20:30,Etc/UTC',
    Language => 'English',
    Encoding => 'ASCII',
    DateFormat => 'non-US',
  );
  my $tz = $anchor->tz();
  die "timezone-data mismatch\n" unless $tz->tzdata() eq 'tzdata2026c';
  die "timezone-code mismatch\n" unless $tz->tzcode() eq 'tzcode2026c';

  my $date = $anchor->new_date('2040-02-29 16:05:09 America/New_York');
  my $date_value = scalar_and_list_value($date);
  my $date_gmt = scalar_and_list_value($date, 'gmt');
  my $formatted = $date->printf('%Y-%m-%d %H:%M:%S %Z');

  my $delta = $anchor->new_delta('0:0:0:1:2:3:4');
  my $delta_value = scalar_and_list_value($delta);
  my $calculated = $date->calc($delta);
  my $calculated_value = scalar_and_list_value($calculated);

  my $recur = $anchor->new_recur();
  my $frequency_status = $recur->frequency('0:0:0:1:0:0:0');
  my $start_status = $recur->start('2040-03-01 08:00:00');
  my $end_status = $recur->end('2040-03-03 08:00:00');
  my @occurrences = map { scalar($_->value()) } $recur->dates();

  my $invalid = $anchor->new_date();
  my $invalid_status = $invalid->parse('not a valid date phrase');
  my $invalid_error = $invalid->err();
  my $clear_return = $invalid->err(1);

  return {
    distribution_version => $Date::Manip::Date::VERSION,
    tzdata => $tz->tzdata(),
    tzcode => $tz->tzcode(),
    configuration_status => $configuration_status,
    configuration_error => $anchor->err(),
    date => $date_value,
    date_gmt => $date_gmt,
    formatted => $formatted,
    delta => $delta_value,
    calculated => $calculated_value,
    recurrence => {
      frequency_status => $frequency_status,
      start_status => $start_status,
      end_status => $end_status,
      occurrences => \@occurrences,
      error => $recur->err(),
    },
    invalid => {
      status => $invalid_status,
      error_before_clear => $invalid_error,
      clear_return => $clear_return,
      clear_return_defined => defined($clear_return) ? JSON::PP::true : JSON::PP::false,
      error_after_clear => $invalid->err(),
    },
  };
}

sub run_dm6 {
  require Date::Manip::DM6;
  die "Date-Manip release mismatch\n" unless $Date::Manip::DM6::VERSION eq '7.00';
  my @configuration = (
    'Defaults=1', 'ForceDate=2040-02-28-10:20:30,Etc/UTC',
    'Language=English', 'Encoding=ASCII', 'DateFormat=non-US',
  );
  my $configuration_status = Date::Manip::DM6::Date_Init(@configuration);
  my $parsed = Date::Manip::DM6::ParseDate('2040-02-29 16:05:09 America/New_York');
  my $rendered = Date::Manip::DM6::UnixDate($parsed, '%Y-%m-%d %H:%M:%S %Z');
  my $calculation_error = '';
  my $calculated = Date::Manip::DM6::DateCalc($parsed, '+1 day 2 hours', \$calculation_error);
  my $invalid = Date::Manip::DM6::ParseDate('not a valid date phrase');
  return {
    distribution_version => $Date::Manip::DM6::VERSION,
    configuration_status => $configuration_status,
    parsed => $parsed,
    rendered => $rendered,
    calculated => $calculated,
    calculation_error => $calculation_error,
    invalid => $invalid,
  };
}

sub run_dm5 {
  require Date::Manip::DM5;
  die "Date-Manip release mismatch\n" unless $Date::Manip::DM5::VERSION eq '7.00';
  my @configuration = (
    'IgnoreGlobalCnf=1', 'PersonalCnf=', 'PersonalCnfPath=',
    'ForceDate=2040-02-28-10:20:30', 'TZ=Etc/UTC',
    'Language=English', 'DateFormat=non-US', 'Internal=0',
    'TodayIsMidnight=1', 'EraseHolidays=1',
  );
  my $configuration_status = Date::Manip::DM5::Date_Init(@configuration);
  my $dependent_calls_executed = !defined($configuration_status) || "$configuration_status" eq '';
  my ($parsed, $rendered, $calculated, $calculation_error, $invalid);
  if ($dependent_calls_executed) {
    $parsed = Date::Manip::DM5::ParseDate('2040-02-29 16:05:09');
    $rendered = Date::Manip::DM5::UnixDate($parsed, '%Y-%m-%d %H:%M:%S');
    $calculation_error = '';
    $calculated = Date::Manip::DM5::DateCalc($parsed, '+1 day 2 hours', \$calculation_error);
    $invalid = Date::Manip::DM5::ParseDate('not a valid date phrase');
  }
  return {
    distribution_version => $Date::Manip::DM5::VERSION,
    backend_version => Date::Manip::DM5::DateManipVersion(),
    configuration_status => $configuration_status,
    dependent_calls_executed => $dependent_calls_executed ? JSON::PP::true : JSON::PP::false,
    parsed => $parsed,
    rendered => $rendered,
    calculated => $calculated,
    calculation_error => $calculation_error,
    invalid => $invalid,
  };
}
