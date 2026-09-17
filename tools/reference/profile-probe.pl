#!/usr/bin/env perl
use strict;
use warnings;
use Config ();
use JSON::PP qw(encode_json);

my $expected_distribution_version = '7.00';
my $expected_dm5_compatibility_version = '5.66';
my $expected_tzdata = 'tzdata2026c';
my $expected_tzcode = 'tzcode2026c';

my $profile = shift @ARGV // '';
die "usage: $0 dm6|dm5|oo\n" if $profile !~ /\A(?:dm6|dm5|oo)\z/ || @ARGV;

my @dm6_configuration = (
  'Defaults=1',
  'ForceDate=2040-02-28-10:20:30,Etc/UTC',
  'Language=English',
  'Encoding=ASCII',
  'DateFormat=US',
  'Printable=0',
  'FirstDay=1',
  'Week1ofYear=jan4',
  'DefaultTime=midnight',
  'WorkWeekBeg=1',
  'WorkWeekEnd=5',
  'WorkDayBeg=09:00',
  'WorkDayEnd=17:00',
  'WorkDay24Hr=0',
  'EraseHolidays=1',
  'EraseEvents=1',
);

my @dm5_configuration = (
  'IgnoreGlobalCnf=1',
  'PersonalCnf=',
  'PersonalCnfPath=',
  'ForceDate=2040-02-28-10:20:30',
  'TZ=Etc/UTC',
  'Language=English',
  'DateFormat=US',
  'Internal=0',
  'FirstDay=1',
  'Jan1Week1=0',
  'WorkWeekBeg=1',
  'WorkWeekEnd=5',
  'WorkDayBeg=09:00',
  'WorkDayEnd=17:00',
  'WorkDay24Hr=0',
  'TodayIsMidnight=1',
  'EraseHolidays=1',
);

my %record = (
  environment => {
    LANG => $ENV{LANG} // '',
    LC_ALL => $ENV{LC_ALL} // '',
    TZ => $ENV{TZ} // '',
  },
  os_name => $^O,
  perl_archname => $Config::Config{archname},
  perl_version => $],
  profile => $profile,
);

sub require_value {
  my ($label, $actual, $expected) = @_;
  die "$label mismatch: expected $expected, got " .
    (defined($actual) ? $actual : 'undef') . "\n" if !defined($actual) || $actual ne $expected;
}

sub checked_timezone_data {
  my ($tz) = @_;
  my $data = {
    tzcode => $tz->tzcode(),
    tzdata => $tz->tzdata(),
  };
  require_value('tzdata version', $data->{tzdata}, $expected_tzdata);
  require_value('tzcode version', $data->{tzcode}, $expected_tzcode);
  return $data;
}

if ($profile eq 'dm6') {
  $record{configuration} = \@dm6_configuration;
  require Date::Manip::DM6;
  Date::Manip::DM6->import();
  $record{distribution_version} = $Date::Manip::DM6::VERSION;
  $record{backend_version} = DateManipVersion();
  require_value('DM6 distribution version', $record{distribution_version}, $expected_distribution_version);
  require_value('DM6 backend version', $record{backend_version}, $expected_distribution_version);
  $record{module_path} = $INC{'Date/Manip/DM6.pm'};
  $record{configuration_error} = Date_Init(@dm6_configuration);
  no warnings 'once';
  $record{timezone_data} = checked_timezone_data($Date::Manip::DM6::dmt);
  $record{results} = {
    fixed_tomorrow => ParseDateString('tomorrow'),
    leap_date => ParseDateString('2040-02-29 16:05:09'),
    next_work_day => Date_NextWorkDay('2040030216:05:09', 1),
  };
} elsif ($profile eq 'dm5') {
  $record{configuration} = \@dm5_configuration;
  no warnings 'deprecated';
  require Date::Manip::DM5;
  Date::Manip::DM5->import();
  $record{distribution_version} = $Date::Manip::DM5::VERSION;
  $record{backend_version} = DateManipVersion();
  require_value('DM5 distribution version', $record{distribution_version}, $expected_distribution_version);
  require_value('DM5 compatibility version', $record{backend_version}, $expected_dm5_compatibility_version);
  $record{module_path} = $INC{'Date/Manip/DM5.pm'};
  $record{configuration_error} = Date_Init(@dm5_configuration);
  $record{results} = {
    fixed_tomorrow => ParseDateString('tomorrow'),
    leap_date => ParseDateString('2040-02-29 16:05:09'),
    next_work_day => Date_NextWorkDay('2040030216:05:09', 1),
  };
} else {
  $record{configuration} = \@dm6_configuration;
  require Date::Manip::Date;
  my $date = Date::Manip::Date->new();
  $record{distribution_version} = $Date::Manip::Date::VERSION;
  require_value('OO distribution version', $record{distribution_version}, $expected_distribution_version);
  $record{module_path} = $INC{'Date/Manip/Date.pm'};
  my @configuration_pairs = map { split(/=/, $_, 2) } @dm6_configuration;
  $record{configuration_error} = $date->config(@configuration_pairs);
  $record{timezone_data} = checked_timezone_data($date->tz());
  my $leap_status = $date->parse('2040-02-29 16:05:09');
  my $leap_value = $leap_status ? '' : $date->value('local');
  my $tomorrow_status = $date->parse('tomorrow');
  my $tomorrow_value = $tomorrow_status ? '' : $date->value('local');
  $record{results} = {
    fixed_tomorrow => { status => $tomorrow_status, value => $tomorrow_value },
    leap_date => { status => $leap_status, value => $leap_value },
  };
}

print JSON::PP->new->canonical->ascii->encode(\%record), "\n";
