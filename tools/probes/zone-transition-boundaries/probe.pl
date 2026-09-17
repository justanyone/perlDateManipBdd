#!/usr/bin/env perl
# Original public-call research probe; it does not generate expectations.
use strict;
use warnings;
use Config ();
use Scalar::Util qw(looks_like_number);
use FindBin qw($Bin);
use JSON::PP qw(decode_json encode_json);

sub read_json {
   open my $fh, '<', $_[0] or die "open $_[0]: $!";
   return decode_json(do { local $/; <$fh> });
}

sub native_type {
   return 'absent' if !defined $_[0];
   return 'number' if !ref($_[0]) && looks_like_number($_[0]);
   return ref($_[0]) || 'text';
}

sub plain {
   return undef if !defined $_[0];
   return [map { plain($_) } @{$_[0]}] if ref($_[0]) eq 'ARRAY';
   return {map { $_ => plain($_[0]->{$_}) } sort keys %{$_[0]}}
      if ref($_[0]) eq 'HASH';
   return $_[0];
}

sub date_text {
   my($d) = @_;
   return sprintf('%04d-%02d-%02d %02d:%02d:%02d Etc/UTC',@$d);
}

my $root = "$Bin/../../..";
my $id = shift @ARGV // die "case ID required\n";
die "unexpected arguments\n" if @ARGV;
my $corpus = read_json("$root/docs/research/zone-transition-boundaries/cases.json");
if ($id eq '--list') {
   print $_->{'case_id'}, "\n" for @{$corpus->{'cases'}};
   exit 0;
}
my($case) = grep { $_->{'case_id'} eq $id } @{$corpus->{'cases'}};
die "unknown case: $id\n" if !$case;
my $profiles = read_json("$root/docs/automation/reference-profiles.json");
my($fixture) = grep { $_->{'name'} eq 'oo' } @{$profiles->{'profiles'}};

my @warnings;
my $stdout = '';
my %out = (
   case_id => $id,
   request => $case,
   profile => 'oo',
   operation_ids => [
      'date.parse-text', 'zone.convert-value', 'zone.convert-from-utc',
      'zone.period-for-date', 'zone.list-periods', 'zone.list-all-periods',
   ],
   perl_version => "$^V",
   perl_archname => $Config::Config{'archname'},
   os_name => $^O,
   fixture_expected_distribution_version =>
      $profiles->{'reference'}{'distribution_version'},
   fixture_expected_backend_version => $fixture->{'backend_version'},
   fixture_expected_tzdata => $fixture->{'timezone_data'}{'tzdata'},
   fixture_expected_tzcode => $fixture->{'timezone_data'}{'tzcode'},
   warnings => \@warnings,
);

local $SIG{__WARN__} = sub { push @warnings,"$_[0]" };
{
   open local *STDOUT, '>', \$stdout or die $!;
   my $stage = 'load';
   my $ok = eval {
      require Date::Manip::Date;
      $out{'loaded_modules'}{'Date/Manip/Date.pm'} = $INC{'Date/Manip/Date.pm'};
      $out{'observed_distribution_version'} = $Date::Manip::Date::VERSION;
      die 'wrong distribution version'
         if $out{'observed_distribution_version'} ne
            $out{'fixture_expected_distribution_version'};

      $stage = 'configuration';
      my $base = Date::Manip::Date->new();
      $out{'setup_calls'}{'constructor'} = {
         return_type => ref($base) || native_type($base),
         error_after => scalar $base->err(), exception => '',
      };
      my $configuration_status =
         $base->config(map { split /=/, $_, 2 } @{$fixture->{'configuration'}});
      my $configuration_error = scalar $base->err();
      $out{'setup_calls'}{'config'} = {
         return => plain($configuration_status), return_type => native_type($configuration_status),
         error_after => $configuration_error, exception => '',
      };
      die "configuration failed: $configuration_error" if $configuration_error;
      my $tz = $base->tz();
      $out{'setup_calls'}{'tz'} = { return_type => ref($tz) || native_type($tz), error_after => scalar $base->err(), exception => '' };
      $out{'loaded_modules'}{'Date/Manip/Base.pm'} = $INC{'Date/Manip/Base.pm'};
      $out{'loaded_modules'}{'Date/Manip/Obj.pm'} = $INC{'Date/Manip/Obj.pm'};
      $out{'loaded_modules'}{'Date/Manip/TZ.pm'} = $INC{'Date/Manip/TZ.pm'};
      $out{'loaded_modules'}{'Date/Manip/Zones.pm'} = $INC{'Date/Manip/Zones.pm'};
      $out{'setup'} = {
         configuration_status => $configuration_status,
         configuration_status_type => native_type($configuration_status),
         configuration_error => $configuration_error,
         observed_backend_version => scalar $base->version(),
         observed_tzdata => scalar $tz->tzdata(),
         observed_tzcode => scalar $tz->tzcode(),
         observed_context_zone => scalar $tz->zone(),
      };
      die 'wrong backend version'
         if $out{'setup'}{'observed_backend_version'} ne
            $out{'fixture_expected_distribution_version'};
      die 'wrong tzdata'
         if $out{'setup'}{'observed_tzdata'} ne $out{'fixture_expected_tzdata'};
      die 'wrong tzcode'
         if $out{'setup'}{'observed_tzcode'} ne $out{'fixture_expected_tzcode'};

      $stage = 'periods';
      my @periods = $tz->periods($case->{'zone'},$case->{'year'});
      my @all_periods = $tz->all_periods($case->{'zone'},$case->{'year'});
      $out{'periods'} = { context => 'list', value => plain(\@periods),
                          count => scalar @periods };
      $out{'all_periods'} = { context => 'list', value => plain(\@all_periods),
                              count => scalar @all_periods };

      my @points;
      for my $point (@{$case->{'utc_points'}}) {
         $stage = 'zone conversion';
         my @reply = $tz->convert_from_gmt([@$point],$case->{'zone'});
         my $period = $tz->date_period([@$point],$case->{'zone'},0,0);

         $stage = 'date parsing';
         my $date = $base->new_date();
         my $constructor_error = scalar $date->err();
         my $parse_status = $date->parse(date_text($point));
         my $parse_error = scalar $date->err();
         my %date_result = (
            parse_input => date_text($point),
            parse_status => $parse_status,
            parse_status_type => native_type($parse_status),
            parse_error => $parse_error,
            parse_exception => '',
         );
         $date_result{'constructor'} = { return_type => ref($date) || native_type($date), error_after => $constructor_error, exception => '' };
         if (!$parse_status) {
            my $before_scalar = scalar $date->value();
            my $before_scalar_error = scalar $date->err();
            my @before_list = $date->value();
            my $before_list_error = scalar $date->err();
            $date_result{'before_convert'} = {
               scalar => $before_scalar,
               scalar_type => native_type($before_scalar),
               list => plain(\@before_list),
               error_after_scalar => $before_scalar_error,
               error_after_list => $before_list_error,
               scalar_exception => '', list_exception => '',
            };
            $stage = 'date conversion';
            my $convert_status = $date->convert($case->{'zone'});
            my $convert_error = scalar $date->err();
            $date_result{'convert_status'} = $convert_status;
            $date_result{'convert_status_type'} = native_type($convert_status);
            $date_result{'convert_error'} = $convert_error;
            $date_result{'convert_exception'} = '';
            if (!$convert_status) {
               my $after_scalar = scalar $date->value();
               my $after_scalar_error = scalar $date->err();
               my @after_list = $date->value();
               my $after_list_error = scalar $date->err();
               my $rendered = $date->printf('%Y-%m-%d %H:%M:%S %Z %z');
               my $printf_error = scalar $date->err();
               $date_result{'after_convert'} = {
                  scalar => $after_scalar,
                  scalar_type => native_type($after_scalar),
                  list => plain(\@after_list),
                  rendered => $rendered,
                  error_after_scalar => $after_scalar_error,
                  error_after_list => $after_list_error,
                  error_after_printf => $printf_error,
                  scalar_exception => '', list_exception => '', printf_exception => '',
               };
            }
         }
         push @points, {
            utc => plain($point),
            tz_convert_context => 'list',
            tz_convert_return => plain(\@reply),
            absolute_date_period_context => 'scalar',
            absolute_date_period => plain($period),
            date => \%date_result,
         };
      }
      $out{'utc_points'} = \@points;

      $stage = 'wall-clock period queries';
      my @wall;
      for my $query (@{$case->{'wall_queries'}}) {
         my $period = $tz->date_period(
            [@{$query->{'date'}}],$case->{'zone'},1,$query->{'selector'});
         push @wall, {
            request => $query,
            context => 'scalar',
            return => plain($period),
            return_type => native_type($period),
         };
      }
      $out{'wall_queries'} = \@wall;
      for my $module (sort grep { m{^Date/Manip/TZ/} } keys %INC) {
         $out{'loaded_modules'}{$module} = $INC{$module};
      }
      1;
   };
   $out{'exception'} = $ok ? '' : "$@";
   $out{'exception_stage'} = $ok ? '' : $stage;
}
$out{'call_stdout'} = $stdout;
print JSON::PP->new->canonical->encode(\%out);
