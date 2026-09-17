#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP qw(encode_json);

# Research-only probe.  It deliberately uses Date::Manip's public surfaces,
# captures every observable channel needed by the draft, and emits only JSON.
my $case = shift @ARGV // '';
die "usage: $0 --list | CASE-ID\n" if @ARGV;

my @cases = qw(
  ZB-ZONE-CANONICAL-DM6 ZB-ZONE-CANONICAL-DM5 ZB-ZONE-TZ-NAMED
  ZB-ZONE-TZ-OVERLAP ZB-ZONE-TZ-GAP ZB-ZONE-OO-MUTATES
  ZB-ZONE-RESOLVE ZB-ZONE-ALIAS ZB-ZONE-ABBREVIATION ZB-ZONE-OFFSET
  ZB-ZONE-PERIODS ZB-ZONE-CURRENT ZB-ZONE-INVALID
  ZB-ZONE-FROM-UTC-NONWHOLE ZB-ZONE-TO-LOCAL-NONWHOLE
  ZB-ZONE-FROM-LOCAL-NONWHOLE ZB-ZONE-DISCOVERY-METHODS
  ZB-ZONE-LIST-PERIODS ZB-ZONE-CUSTOM-ALIAS-ERROR
  ZB-BUSINESS-HOLIDAYS-OO ZB-BUSINESS-HOLIDAYS-DM6
  ZB-BUSINESS-HOLIDAYS-DM5 ZB-BUSINESS-WORK-HOURS
  ZB-BUSINESS-NEXT-PREV ZB-BUSINESS-NEAREST ZB-BUSINESS-LIST-HOLIDAYS
  ZB-BUSINESS-INVALID-STATE ZB-BUSINESS-NEXT-HOURS
  ZB-EVENTS-OO-INSTANT ZB-EVENTS-OO-DAY ZB-EVENTS-OO-RANGE
  ZB-EVENTS-DM6-DATES ZB-LEGACY-ERASE-HOLIDAYS
);
if ($case eq '--list') { print "$_\n" for @cases; exit 0 }
die "unknown case: $case\n" if !grep { $_ eq $case } @cases;

my $fixture = $ENV{ZB_FIXTURE} // die "ZB_FIXTURE is required\n";
my $fixture_dm5 = $ENV{ZB_FIXTURE_DM5} // die "ZB_FIXTURE_DM5 is required\n";

sub date_text {
  my ($date) = @_;
  return undef if !defined $date;
  my @v = $date->value('actual');
  return undef if !@v;
  return sprintf('%04d%02d%02d%02d:%02d:%02d', @v);
}

sub plain {
  my ($value) = @_;
  return undef if !defined $value;
  if (ref($value) eq 'ARRAY') { return [ map { plain($_) } @$value ] }
  if (ref($value) eq 'HASH')  { return { map { $_ => plain($value->{$_}) } sort keys %$value } }
  if (eval { $value->isa('Date::Manip::Date') }) { return date_text($value) }
  return $value;
}

sub oo {
  require Date::Manip::Date;
  die "wrong release" unless $Date::Manip::Date::VERSION eq "7.00";
  my $date = Date::Manip::Date->new();
  my $config = $date->config(ConfigFile => $fixture);
  die "wrong tzdata" unless $date->tz->tzdata eq "tzdata2026c";
  return ($date, $config);
}

sub oo_date {
  my ($base, $text) = @_;
  my $date = $base->new_date();
  my $status = $date->parse($text);
  return ($date, $status);
}

sub dm6 {
  require Date::Manip::DM6;
  die "wrong release" unless $Date::Manip::DM6::VERSION eq "7.00";
  Date::Manip::DM6->import();
  return Date_Init('Defaults=1', "ConfigFile=$fixture");
}

sub dm5 {
  require Date::Manip::DM5;
  die "wrong release" unless $Date::Manip::DM5::VERSION eq "7.00";
  no warnings 'deprecated';
  Date::Manip::DM5->import();
  return Date_Init("GlobalCnf=$fixture_dm5", 'ForceDate=2040-02-28-10:20:30', 'TZ=Etc/UTC', 'PersonalCnf=', 'PersonalCnfPath=');
}

my @warnings;
my $result;
my $exception = '';
{
  local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
  eval {
    if ($case eq 'ZB-ZONE-CANONICAL-DM6') {
      my $config = dm6();
      $result = { configuration_return => plain($config), converted => Date_ConvTZ('2040031012:00:00', 'America/New_York', 'Europe/London') };
    } elsif ($case eq 'ZB-ZONE-CANONICAL-DM5') {
      my $config = dm5();
      $result = { configuration_return => plain($config), converted => Date_ConvTZ('2040031012:00:00', 'America/New_York', 'Europe/London') };
    } elsif ($case eq 'ZB-ZONE-TZ-NAMED') {
      my ($base, $config) = oo(); my $tz = $base->tz();
      my @reply = $tz->convert([2040,3,10,12,0,0], 'America/New_York', 'Europe/London');
      $result = { configuration_return => plain($config), reply => plain(\@reply) };
    } elsif ($case eq 'ZB-ZONE-TZ-OVERLAP') {
      my ($base, $config) = oo(); my $tz = $base->tz();
      my @standard = $tz->convert([2040,11,4,1,30,0], 'America/New_York', 'Etc/UTC', 0);
      my @daylight = $tz->convert([2040,11,4,1,30,0], 'America/New_York', 'Etc/UTC', 1);
      $result = { configuration_return => plain($config), standard => plain(\@standard), daylight => plain(\@daylight) };
    } elsif ($case eq 'ZB-ZONE-TZ-GAP') {
      my ($base, $config) = oo(); my $tz = $base->tz();
      my @reply = $tz->convert([2040,3,11,2,30,0], 'America/New_York', 'Etc/UTC', 0);
      $result = { configuration_return => plain($config), reply => plain(\@reply) };
    } elsif ($case eq 'ZB-ZONE-OO-MUTATES') {
      my ($base, $config) = oo(); my ($date, $parse) = oo_date($base, '2040-03-10 12:00');
      my $before = date_text($date); my $status = $date->convert('America/New_York');
      $result = { configuration_return => plain($config), parse_status => $parse, before => $before, convert_status => $status, after => date_text($date), error => $date->err() };
    } elsif ($case eq 'ZB-ZONE-RESOLVE') {
      my ($base, $config) = oo(); my $tz = $base->tz();
      my @all = $tz->zone('EDT');
      $result = { configuration_return => plain($config), scalar_default => scalar($tz->zone('EDT')), ordered_matches => plain(\@all), no_match => scalar($tz->zone('XYZ')) };
    } elsif ($case eq 'ZB-ZONE-ALIAS') {
      my ($base, $config) = oo(); my $tz = $base->tz();
      my $add = $tz->define_alias('office-central', 'America/Chicago');
      my $resolved = scalar($tz->zone('office-central'));
      my $reset = $tz->define_alias('office-central', 'reset');
      $result = { configuration_return => plain($config), add => $add, resolved => $resolved, reset => $reset, after_reset => scalar($tz->zone('office-central')) };
    } elsif ($case eq 'ZB-ZONE-ABBREVIATION') {
      my ($base, $config) = oo(); my $tz = $base->tz();
      my @ok = $tz->define_abbrev('EDT', 'America/New_York');
      my @bad = $tz->define_abbrev('EDT', 'Etc/UTC');
      my @reset = $tz->define_abbrev('EDT', 'reset');
      $result = { configuration_return => plain($config), valid => plain(\@ok), invalid_member => plain(\@bad), reset => plain(\@reset) };
    } elsif ($case eq 'ZB-ZONE-OFFSET') {
      my ($base, $config) = oo(); my $tz = $base->tz();
      my @valid = $tz->define_offset('-0500', 'America/New_York');
      my @bad = $tz->define_offset('+99:00', 'America/New_York');
      my @reset = $tz->define_offset('-0500', 'reset');
      $result = { configuration_return => plain($config), valid => plain(\@valid), invalid => plain(\@bad), reset => plain(\@reset) };
    } elsif ($case eq 'ZB-ZONE-PERIODS') {
      my ($base, $config) = oo(); my $tz = $base->tz();
      my $gap = $tz->date_period([2040,3,11,2,30,0], 'America/New_York', 1, 0);
      my $standard = $tz->date_period([2040,11,4,1,30,0], 'America/New_York', 1, 0);
      my $daylight = $tz->date_period([2040,11,4,1,30,0], 'America/New_York', 1, 1);
      my @periods = $tz->all_periods('America/New_York', 2040);
      $result = { configuration_return => plain($config), gap => plain($gap), overlap_standard => plain($standard), overlap_daylight => plain($daylight), all_periods => plain(\@periods) };
    } elsif ($case eq 'ZB-ZONE-CURRENT') {
      my ($base, $config) = oo(); my $tz = $base->tz();
      $result = { configuration_return => plain($config), first => $tz->curr_zone(), reset => $tz->curr_zone(1) };
    } elsif ($case eq 'ZB-ZONE-INVALID') {
      my ($base, $config) = oo(); my $tz = $base->tz();
      my @bad_target = $tz->convert([2040,3,10,12,0,0], 'Etc/UTC', 'No/Such_Zone');
      my @bad_arguments = $tz->convert_to_gmt([2040,3,10,12,0,0], 'Etc/UTC', 0, 'extra');
      $result = { configuration_return => plain($config), bad_target => plain(\@bad_target), bad_arguments => plain(\@bad_arguments) };
    } elsif ($case eq 'ZB-ZONE-FROM-UTC-NONWHOLE') {
      my ($base, $config) = oo(); my @reply = $base->tz()->convert_from_gmt([2040,3,10,12,0,0], 'Asia/Kathmandu');
      $result = { configuration_return => plain($config), reply => plain(\@reply) };
    } elsif ($case eq 'ZB-ZONE-TO-LOCAL-NONWHOLE') {
      my ($base, $config) = oo(); my @reply = $base->tz()->convert_to_local([2040,3,10,12,0,0], 'Asia/Kathmandu');
      $result = { configuration_return => plain($config), reply => plain(\@reply) };
    } elsif ($case eq 'ZB-ZONE-FROM-LOCAL-NONWHOLE') {
      my ($base, $config) = oo(); my @reply = $base->tz()->convert_from_local([2040,3,10,12,0,0], 'Asia/Kathmandu');
      $result = { configuration_return => plain($config), reply => plain(\@reply) };
    } elsif ($case eq 'ZB-ZONE-DISCOVERY-METHODS') {
      my ($base, $config) = oo(); my $tz = $base->tz();
      my $set_return = $tz->curr_zone_methods('env', 'zone', 'TZ');
      $result = { configuration_return => plain($config), set_return => plain($set_return), rediscovered => $tz->curr_zone(1) };
    } elsif ($case eq 'ZB-ZONE-LIST-PERIODS') {
      my ($base, $config) = oo(); my $tz = $base->tz();
      my @new_york = $tz->periods('America/New_York', 2040);
      my @kathmandu = $tz->periods('Asia/Kathmandu', 2040);
      $result = { configuration_return => plain($config), new_york => plain(\@new_york), kathmandu => plain(\@kathmandu) };
    } elsif ($case eq 'ZB-ZONE-CUSTOM-ALIAS-ERROR') {
      my ($base, $config) = oo(); my $tz = $base->tz();
      my $add = $tz->define_alias('office-central', 'America/Chicago');
      my $invalid = $tz->define_alias('broken-office', 'No/Such_Zone');
      my $reset_all = $tz->define_alias('reset', 'ignored');
      $result = { configuration_return => plain($config), add => $add, invalid => $invalid, reset_all => $reset_all, after_reset => scalar($tz->zone('office-central')) };
    } elsif ($case eq 'ZB-BUSINESS-HOLIDAYS-OO') {
      my ($base, $config) = oo(); my ($date, $parse) = oo_date($base, '2040-03-01 10:00');
      my @labels = $date->holiday();
      $result = { configuration_return => plain($config), parse_status => $parse, scalar_label => scalar($date->holiday()), labels => plain(\@labels), business_day => $date->is_business_day(1) };
    } elsif ($case eq 'ZB-BUSINESS-HOLIDAYS-DM6') {
      my $config = dm6(); my @labels = Date_IsHoliday('2040030110:00:00');
      $result = { configuration_return => plain($config), scalar_label => scalar(Date_IsHoliday('2040030110:00:00')), labels => plain(\@labels), unnamed_label => scalar(Date_IsHoliday('2040030210:00:00')), business_day => Date_IsWorkDay('2040030110:00:00', 1) };
    } elsif ($case eq 'ZB-BUSINESS-HOLIDAYS-DM5') {
      my $config = dm5(); my @labels = Date_IsHoliday('2040030110:00:00');
      $result = { configuration_return => plain($config), scalar_label => scalar(Date_IsHoliday('2040030110:00:00')), labels => plain(\@labels), business_day => Date_IsWorkDay('2040030110:00:00', 1) };
    } elsif ($case eq 'ZB-BUSINESS-WORK-HOURS') {
      my ($base, $config) = oo();
      my @rows;
      for my $text ('2040-03-05 08:59:59', '2040-03-05 09:00:00', '2040-03-05 17:00:00', '2040-03-05 17:00:01', '2040-03-04 12:00:00') {
        my ($date, $parse) = oo_date($base, $text);
        push @rows, { input => $text, parse_status => $parse, date_only => $date->is_business_day(0), time_checked => $date->is_business_day(1) };
      }
      $result = { configuration_return => plain($config), rows => \@rows };
    } elsif ($case eq 'ZB-BUSINESS-NEXT-PREV') {
      my ($base, $config) = oo();
      my ($next, $next_parse) = oo_date($base, '2040-03-01 10:00'); my $next_status = $next->next_business_day(0, 1);
      my ($prev, $prev_parse) = oo_date($base, '2040-03-01 10:00'); my $prev_status = $prev->prev_business_day(0, 1);
      my ($offset, $offset_parse) = oo_date($base, '2040-03-05 10:00'); my $offset_status = $offset->prev_business_day(1, 0);
      $result = { configuration_return => plain($config), next => { parse_status => $next_parse, status => plain($next_status), value => date_text($next) }, previous_zero => { parse_status => $prev_parse, status => plain($prev_status), value => date_text($prev) }, previous_one => { parse_status => $offset_parse, status => plain($offset_status), value => date_text($offset) } };
    } elsif ($case eq 'ZB-BUSINESS-NEAREST') {
      my ($base, $config) = oo();
      my ($earlier, $ep) = oo_date($base, '2040-03-03 10:00'); $earlier->nearest_business_day(0);
      my ($later, $lp) = oo_date($base, '2040-03-03 10:00'); $later->nearest_business_day(1);
      $result = { configuration_return => plain($config), earlier => { parse_status => $ep, value => date_text($earlier) }, later => { parse_status => $lp, value => date_text($later) } };
    } elsif ($case eq 'ZB-BUSINESS-LIST-HOLIDAYS') {
      my ($base, $config) = oo(); my @dates = $base->list_holidays(2040);
      $result = { configuration_return => plain($config), dates => plain(\@dates) };
    } elsif ($case eq 'ZB-BUSINESS-INVALID-STATE') {
      my ($base, $config) = oo(); my ($date, $parse) = oo_date($base, 'not a date');
      my $working = $date->is_business_day(1);
      $result = { configuration_return => plain($config), parse_status => $parse, working => plain($working), error => $date->err() };
    } elsif ($case eq 'ZB-BUSINESS-NEXT-HOURS') {
      my ($base, $config) = oo(); my ($date, $parse) = oo_date($base, '2040-03-05 17:00:01');
      my $status = $date->next_business_day(0, 1);
      $result = { configuration_return => plain($config), parse_status => $parse, status => plain($status), value => date_text($date) };
    } elsif ($case eq 'ZB-EVENTS-OO-INSTANT' || $case eq 'ZB-EVENTS-OO-DAY' || $case eq 'ZB-EVENTS-OO-RANGE') {
      my ($base, $config) = oo(); my ($start, $parse) = oo_date($base, '2040-03-01 10:00');
      my @events;
      if ($case eq 'ZB-EVENTS-OO-INSTANT') { @events = $start->list_events() }
      elsif ($case eq 'ZB-EVENTS-OO-DAY') { @events = $start->list_events(0, 'dates') }
      else { my ($end) = oo_date($base, '2040-03-01 14:00'); @events = $start->list_events($end, 'dates') }
      $result = { configuration_return => plain($config), parse_status => $parse, events => plain(\@events) };
    } elsif ($case eq 'ZB-EVENTS-DM6-DATES') {
      my $config = dm6(); my $events = Events_List('2040-03-01', 0);
      $result = { configuration_return => plain($config), events => plain($events) };
    } elsif ($case eq 'ZB-LEGACY-ERASE-HOLIDAYS') {
      my $config = dm5(); my $before = scalar(Date_IsHoliday('2040030110:00:00'));
      my $erase = Date::Manip::DM5::EraseHolidays(); my $after = scalar(Date_IsHoliday('2040030110:00:00'));
      $result = { configuration_return => plain($config), before => plain($before), erase_return => plain($erase), after => plain($after), business_day_after => Date_IsWorkDay('2040030110:00:00', 1) };
    }
  };
  $exception = $@ if $@;
}

print encode_json({ case_id => $case, result => plain($result), warnings => \@warnings, exception => $exception }), "\n";
