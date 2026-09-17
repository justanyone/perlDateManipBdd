#!/usr/bin/env perl
# Original fixed-input research probe for Date::Manip explicit-pattern parsing.
use strict;
use warnings;
use Config ();
use FindBin qw($Bin);
use JSON::PP ();
use File::Spec ();

my ($interface, $case_id) = @ARGV;
die "usage: $0 oo|dm6 CASE-ID\n"
  if !defined($interface) || $interface !~ /\A(?:oo|dm6)\z/ || !defined($case_id) || @ARGV != 2;

my $cases_path = File::Spec->catfile($Bin, '..', '..', '..', 'docs', 'research',
                                    'pattern-parsing-family', 'cases.json');
open my $cases_fh, '<', $cases_path or die "cannot read $cases_path: $!\n";
local $/;
my $manifest = JSON::PP->new->decode(<$cases_fh>);
close $cases_fh or die "cannot close $cases_path: $!\n";
my ($case) = grep { $_->{case_id} eq $case_id } @{$manifest->{cases}};
die "unknown case ID: $case_id\n" if !$case;

my @configuration = (
  'Defaults=1', 'ForceDate=2040-02-28-10:20:30,Etc/UTC', 'Language=English',
  'Encoding=ASCII', 'DateFormat=US', 'Printable=0', 'FirstDay=1',
  'Week1ofYear=jan4', 'DefaultTime=midnight', 'WorkWeekBeg=1',
  'WorkWeekEnd=5', 'WorkDayBeg=09:00', 'WorkDayEnd=17:00', 'WorkDay24Hr=0',
  'EraseHolidays=1', 'EraseEvents=1',
);
my @configuration_pairs = map { split(/=/, $_, 2) } @configuration;

sub success_status {
  my ($status) = @_;
  return defined($status) && !ref($status) && "$status" eq '0';
}

sub capture_channels (&) {
  my ($code) = @_;
  my ($stdout, @warnings, $exception);
  {
    open my $capture, '>', \$stdout or die "cannot capture stdout: $!\n";
    local *STDOUT = $capture;
    local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
    local $@;
    $exception = eval { $code->(); 1 } ? undef : "$@";
  }
  $stdout = '' if !defined($stdout);
  return ($stdout, \@warnings, $exception);
}

sub checked_timezone_data {
  my ($tz) = @_;
  my $got = { tzdata => $tz->tzdata(), tzcode => $tz->tzcode() };
  die "unexpected tzdata version\n" if $got->{tzdata} ne 'tzdata2026c';
  die "unexpected tzcode version\n" if $got->{tzcode} ne 'tzcode2026c';
  return $got;
}

sub configured_date {
  my $date = Date::Manip::Date->new();
  my $configuration_error = $date->config(@configuration_pairs);
  die "fixture configuration failed: $configuration_error\n" if $configuration_error;
  return $date;
}

my %record = (
  schema_version => 3, case_id => $case_id, kind => $case->{kind},
  directive => $case->{directive}, pattern => $case->{pattern}, text => $case->{text},
  interface => $interface, fixture => $manifest->{fixture},
  operation_id => $manifest->{operation_id}, contract_ids => [ $manifest->{operation_id} ],
  partition_ids => [ 'date.parse-pattern.' . $case->{kind} ],
  environment => { LANG => $ENV{LANG} // '', LC_ALL => $ENV{LC_ALL} // '', TZ => $ENV{TZ} // '' },
  runtime => { os_name => $^O, perl_version => "$^V", perl_archname => $Config::Config{archname} },
  configuration => \@configuration,
);

if ($interface eq 'oo') {
  require Date::Manip::Date;
  die "unexpected Date::Manip::Date version\n" if $Date::Manip::Date::VERSION ne '7.00';
  my ($scalar_status, $scalar_value, $scalar_parse_error, $scalar_value_error);
  my ($scalar_stdout, $scalar_warnings, $scalar_exception);

  my ($list_status, $list_value, $list_parse_error, $list_value_error, %named_captures);
  my ($list_stdout, $list_warnings, $list_exception);

  if ($case->{kind} ne 'dateformat-cache' && $case->{kind} ne 'posix-setting') {
    ($scalar_stdout, $scalar_warnings, $scalar_exception) = capture_channels {
      my $date = configured_date();
      $scalar_status = $date->parse_format($case->{pattern}, $case->{text});
      $scalar_parse_error = $date->err();
      if (success_status($scalar_status)) {
        $scalar_value = $date->value('local');
        $scalar_value_error = $date->err();
      }
    };
    ($list_stdout, $list_warnings, $list_exception) = capture_channels {
      my $date = configured_date();
      my @returned;
      ($list_status, @returned) = $date->parse_format($case->{pattern}, $case->{text});
      $list_parse_error = $date->err();
      die "odd list-context capture result\n" if @returned % 2;
      %named_captures = @returned;
      if (success_status($list_status)) {
        $list_value = $date->value('local');
        $list_value_error = $date->err();
      }
    };
  }

  my $sequence;
  if ($case->{kind} eq 'dateformat-cache') {
    my ($stdout, $warnings, $exception) = capture_channels {
      my $date = configured_date();
      my $first_status = $date->parse_format('%x', '02/29/40');
      my $first_parse_error = $date->err();
      my ($first_value, $first_value_error);
      if (success_status($first_status)) {
        $first_value = $date->value('local');
        $first_value_error = $date->err();
      }
      my $change_error = $date->config(DateFormat => 'non-US');
      my $second_status = $date->parse_format('%x', '02/29/40');
      my $second_parse_error = $date->err();
      my ($second_value, $second_value_error);
      if (success_status($second_status)) {
        $second_value = $date->value('local');
        $second_value_error = $date->err();
      }
      $sequence = { steps => [
        { request => { date_format => 'US', pattern => '%x', text => '02/29/40' }, status => $first_status,
          parse_error => $first_parse_error,
          value => $first_value, error_after_value_read => $first_value_error },
        { request => { setting => 'DateFormat', value => 'non-US' }, configuration_error => $change_error },
        { request => { date_format => 'non-US', pattern => '%x', text => '02/29/40' }, status => $second_status,
          parse_error => $second_parse_error,
          value => $second_value, error_after_value_read => $second_value_error },
      ] };
    };
    $sequence->{call_stdout} = $stdout; $sequence->{warnings} = $warnings; $sequence->{exception} = $exception;
  } elsif ($case->{kind} eq 'posix-setting') {
    my ($stdout, $warnings, $exception) = capture_channels {
      my $date = configured_date();
      my $change_error = $date->config(Use_POSIX_Printf => 1);
      my $status = $date->parse_format('%x', '02/29/40');
      my $parse_error = $date->err();
      my ($value, $value_error);
      if (success_status($status)) {
        $value = $date->value('local');
        $value_error = $date->err();
      }
      $sequence = { steps => [
        { request => { setting => 'Use_POSIX_Printf', value => 1 }, configuration_error => $change_error },
        { request => { pattern => '%x', text => '02/29/40' }, status => $status,
          parse_error => $parse_error,
          value => $value, error_after_value_read => $value_error },
      ] };
    };
    $sequence->{call_stdout} = $stdout; $sequence->{warnings} = $warnings; $sequence->{exception} = $exception;
  }

  my $metadata_date = configured_date();
  $record{distribution_version} = $Date::Manip::Date::VERSION;
  $record{module_path} = $INC{'Date/Manip/Date.pm'};
  $record{timezone_data} = checked_timezone_data($metadata_date->tz());
  if ($sequence) {
    $record{raw_return} = { sequence => $sequence };
  } else {
    $record{raw_return} = {
      scalar => { status => $scalar_status, parse_error => $scalar_parse_error,
                  value => $scalar_value,
                  error_after_value_read => $scalar_value_error,
                  exception => $scalar_exception, warnings => $scalar_warnings, call_stdout => $scalar_stdout },
      list => { status => $list_status, parse_error => $list_parse_error,
                value => $list_value,
                error_after_value_read => $list_value_error,
                named_captures => \%named_captures, exception => $list_exception,
                warnings => $list_warnings, call_stdout => $list_stdout },
    };
  }
} else {
  require Date::Manip::DM6;
  die "unexpected Date::Manip::DM6 version\n" if $Date::Manip::DM6::VERSION ne '7.00';
  my ($configuration_error, $value);
  my ($stdout, $warnings, $exception);
  if ($case->{kind} ne 'dateformat-cache' && $case->{kind} ne 'posix-setting') {
    ($stdout, $warnings, $exception) = capture_channels {
      $configuration_error = Date::Manip::DM6::Date_Init(@configuration);
      die "fixture configuration failed: $configuration_error\n" if $configuration_error;
      $value = Date::Manip::DM6::ParseDateFormat($case->{pattern}, $case->{text});
    };
  }
  my $sequence;
  if ($case->{kind} eq 'dateformat-cache') {
    my ($sequence_stdout, $sequence_warnings, $sequence_exception) = capture_channels {
      my $config_error = Date::Manip::DM6::Date_Init(@configuration);
      die "fixture configuration failed: $config_error\n" if $config_error;
      my $first = Date::Manip::DM6::ParseDateFormat('%x', '02/29/40');
      my $change_error = Date::Manip::DM6::Date_Init('DateFormat=non-US');
      my $second = Date::Manip::DM6::ParseDateFormat('%x', '02/29/40');
      $sequence = { steps => [
        { request => { date_format => 'US', pattern => '%x', text => '02/29/40' },
          success => defined($first) && $first ne '' ? JSON::PP::true : JSON::PP::false, value => $first },
        { request => { setting => 'DateFormat', value => 'non-US' }, configuration_error => $change_error },
        { request => { date_format => 'non-US', pattern => '%x', text => '02/29/40' },
          success => defined($second) && $second ne '' ? JSON::PP::true : JSON::PP::false, value => $second },
      ] };
    };
    $sequence->{call_stdout} = $sequence_stdout; $sequence->{warnings} = $sequence_warnings; $sequence->{exception} = $sequence_exception;
  } elsif ($case->{kind} eq 'posix-setting') {
    my ($sequence_stdout, $sequence_warnings, $sequence_exception) = capture_channels {
      my $config_error = Date::Manip::DM6::Date_Init(@configuration);
      die "fixture configuration failed: $config_error\n" if $config_error;
      my $change_error = Date::Manip::DM6::Date_Init('Use_POSIX_Printf=1');
      my $result = Date::Manip::DM6::ParseDateFormat('%x', '02/29/40');
      $sequence = { steps => [
        { request => { setting => 'Use_POSIX_Printf', value => 1 }, configuration_error => $change_error },
        { request => { pattern => '%x', text => '02/29/40' },
          success => defined($result) && $result ne '' ? JSON::PP::true : JSON::PP::false, value => $result },
      ] };
    };
    $sequence->{call_stdout} = $sequence_stdout; $sequence->{warnings} = $sequence_warnings; $sequence->{exception} = $sequence_exception;
  }
  no warnings 'once';
  $record{distribution_version} = $Date::Manip::DM6::VERSION;
  $record{backend_version} = Date::Manip::DM6::DateManipVersion();
  $record{module_path} = $INC{'Date/Manip/DM6.pm'};
  $record{timezone_data} = checked_timezone_data($Date::Manip::DM6::dmt);
  if ($sequence) {
    $record{raw_return} = { sequence => $sequence };
  } else {
    $record{raw_return} = {
      configuration_error => $configuration_error,
      success => defined($value) && $value ne '' ? JSON::PP::true : JSON::PP::false,
      value => $value,
      exception => $exception, warnings => $warnings, call_stdout => $stdout,
    };
  }
}

print JSON::PP->new->canonical->ascii->encode(\%record), "\n";
