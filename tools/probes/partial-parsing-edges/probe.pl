#!/usr/bin/env perl
# Original public-input research; this is not an expectation generator.
use strict;
use warnings;
use JSON::PP;
use Config ();
use FindBin qw($Bin);

sub read_json {
   open my $fh, '<', $_[0] or die $!;
   return decode_json(do { local $/; <$fh> });
}
sub native_type {
   return 'absent' if ! defined $_[0];
   return ref($_[0]) || 'text';
}

my $root = "$Bin/../../..";
my $id = shift @ARGV // die "case ID required";
die 'unexpected arguments' if @ARGV;
my $corpus = read_json("$root/docs/research/partial-parsing-edges/cases.json");
my($case) = grep { $_->{'case_id'} eq $id } @{$corpus->{'cases'}};
die 'unknown case' if ! $case;
my $profiles = read_json("$root/docs/automation/reference-profiles.json");
my($oo_fixture) = grep { $_->{'name'} eq 'oo' } @{$profiles->{'profiles'}};

my @warnings;
local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
my %out = (
   case_id => $id,
   request => $case,
   perl_version => "$^V",
   perl_archname => $Config::Config{'archname'},
   os_name => $^O,
   fixture_expected_distribution_version =>
      $profiles->{'reference'}{'distribution_version'},
   warnings => \@warnings,
);
my $stdout = '';
{
   open local *STDOUT, '>', \$stdout or die $!;
   my $stage = 'load';
   my $ok = eval {
      if ($case->{'kind'} eq 'oo' || $case->{'kind'} eq 'date_gate') {
         $out{'profile'} = 'oo';
         $out{'fixture_expected_backend_version'} =
            $oo_fixture->{'backend_version'};
         $out{'fixture_expected_tzdata'} =
            $oo_fixture->{'timezone_data'}{'tzdata'};
         $out{'fixture_expected_tzcode'} =
            $oo_fixture->{'timezone_data'}{'tzcode'};
         require Date::Manip::Date;
         $out{'loaded_module_file'} = $INC{'Date/Manip/Date.pm'};
         $out{'observed_distribution_version'} = $Date::Manip::Date::VERSION;
         die 'wrong distribution'
            if $out{'observed_distribution_version'} ne
               $out{'fixture_expected_distribution_version'};

         my @extra = @{$case->{'configuration'} || []};
         if ($case->{'holiday_lines'}) {
            my $file = "$id-holidays.conf";
            open my $fh, '>', $file or die $!;
            print {$fh} "*Holidays\n",
                        join("\n",@{$case->{'holiday_lines'}}), "\n";
            close $fh or die $!;
            push @extra, "ConfigFile=$file";
            $out{'holiday_fixture'} = {
               file => $file,
               lines => $case->{'holiday_lines'},
            };
         }

         my $make_date = sub {
            my $date = Date::Manip::Date->new();
            my $backend_version = scalar $date->version();
            if (exists $out{'observed_backend_version'}) {
               die 'backend version changed'
                  if $out{'observed_backend_version'} ne $backend_version;
            } else {
               $out{'observed_backend_version'} = $backend_version;
            }
            my $config_status =
               $date->config(map { split /=/, $_, 2 }
                             (@{$oo_fixture->{'configuration'}},@extra));
            my $config_error = scalar $date->err();
            die "configuration failed: $config_error" if $config_error;
            my $tzdata = scalar $date->tz()->tzdata();
            my $tzcode = scalar $date->tz()->tzcode();
            my $context_zone = scalar $date->tz()->zone();
            die 'wrong tzdata'
               if $tzdata ne $out{'fixture_expected_tzdata'};
            die 'wrong tzcode'
               if $tzcode ne $out{'fixture_expected_tzcode'};
            for my $pair (
               ['observed_tzdata',$tzdata],
               ['observed_tzcode',$tzcode],
               ['observed_context_zone',$context_zone],
            ) {
               my($key,$value) = @$pair;
               if (exists $out{$key}) {
                  die "$key changed" if $out{$key} ne $value;
               } else {
                  $out{$key} = $value;
               }
            }
            return(
               $date,
               {
                  configuration_status => $config_status,
                  configuration_status_type => native_type($config_status),
                  configuration_error => $config_error,
                  observed_backend_version => $backend_version,
                  observed_tzdata => $tzdata,
                  observed_tzcode => $tzcode,
                  observed_context_zone => $context_zone,
               },
            );
         };

         if ($case->{'kind'} eq 'date_gate') {
            $out{'operation_id'} = 'date.parse-date-only';
            my @results;
            for my $call (@{$case->{'calls'}}) {
               $stage = 'configuration';
               my($date,$setup) = $make_date->();
               $stage = 'initialization';
               my $initial_status = $date->parse($case->{'initial'});
               my $initial_error = scalar $date->err();
               die 'invalid initial value' if $initial_status;
               my $method = $call->{'operation'};
               $stage = 'call';
               my $status =
                  $date->$method($case->{'text'},@{$call->{'options'}});
               my $error = scalar $date->err();
               my %result = (
                  label => $call->{'label'},
                  method => $method,
                  options => $call->{'options'},
                  %$setup,
                  initial_request => $case->{'initial'},
                  initialization_status => $initial_status,
                  initialization_status_type => 'number',
                  initialization_error => $initial_error,
                  status => $status,
                  status_type => 'number',
                  error_after_call => $error,
                  value_read_context => 'scalar',
               );
               if (!$status) {
                  my $value = scalar $date->value();
                  $result{'value'} = $value;
                  $result{'value_type'} = native_type($value);
                  $result{'error_after_value'} = scalar $date->err();
               } else {
                  my $while_error = scalar $date->value();
                  $result{'value_while_error'} = $while_error;
                  $result{'value_while_error_type'} =
                     native_type($while_error);
                  $result{'error_after_value_while_error'} =
                     scalar $date->err();
                  my $clear_return = $date->err(1);
                  $result{'error_clear_return'} = $clear_return;
                  $result{'error_clear_return_type'} =
                     native_type($clear_return);
                  $result{'error_after_clear'} = scalar $date->err();
                  my $after_clear = scalar $date->value();
                  $result{'value_after_error_clear'} = $after_clear;
                  $result{'value_after_error_clear_type'} =
                     native_type($after_clear);
                  $result{'error_after_value_after_clear'} =
                     scalar $date->err();
               }
               push @results, \%result;
            }
            $out{'calls'} = \@results;
         } else {
            $out{'operation_id'} =
               $case->{'operation'} eq 'parse_date' ?
                  'date.parse-date-only' : 'time.parse-text';
            $stage = 'configuration';
            my($date,$setup) = $make_date->();
            while (my($key,$value) = each %$setup) {
               $out{$key} = $value;
            }
            $stage = 'initialization';
            $out{'initial_request'} = $case->{'initial'};
            $out{'initialization_status'} =
               $date->parse($case->{'initial'});
            $out{'initialization_status_type'} = 'number';
            $out{'initialization_error'} = scalar $date->err();
            die 'invalid initial value' if $out{'initialization_status'};
            $stage = 'call';
            my $method = $case->{'operation'};
            $out{'status'} =
               $date->$method($case->{'text'},@{$case->{'options'}});
            $out{'status_type'} = 'number';
            $out{'error_after_call'} = scalar $date->err();
            if (!$out{'status'}) {
               $out{'parsed_value'} = scalar $date->value();
               $out{'parsed_value_type'} =
                  native_type($out{'parsed_value'});
               $out{'error_after_parsed_scalar'} = scalar $date->err();
               my @parsed = $date->value();
               $out{'parsed_fields'} = \@parsed;
               $out{'parsed_fields_type'} = 'ARRAY';
               $out{'error_after_parsed_list'} = scalar $date->err();
               $out{'gmt_value'} = scalar $date->value('gmt');
               $out{'gmt_value_type'} = native_type($out{'gmt_value'});
               $out{'error_after_gmt_scalar'} = scalar $date->err();
               my @gmt = $date->value('gmt');
               $out{'gmt_fields'} = \@gmt;
               $out{'gmt_fields_type'} = 'ARRAY';
               $out{'error_after_gmt_list'} = scalar $date->err();
               $out{'zone_render'} = scalar $date->printf('%Z|%z');
               $out{'zone_render_type'} =
                  native_type($out{'zone_render'});
               $out{'error_after_zone_render'} = scalar $date->err();
            } else {
               my $while_error = scalar $date->value();
               $out{'value_while_error'} = $while_error;
               $out{'value_while_error_type'} = native_type($while_error);
               $out{'error_after_value_while_error'} =
                  scalar $date->err();
               my $clear_return = $date->err(1);
               $out{'error_clear_return'} = $clear_return;
               $out{'error_clear_return_type'} =
                  native_type($clear_return);
               $out{'error_after_clear'} = scalar $date->err();
               my $after_clear = scalar $date->value();
               $out{'value_after_error_clear'} = $after_clear;
               $out{'value_after_error_clear_type'} =
                  native_type($after_clear);
               $out{'error_after_value_after_clear'} =
                  scalar $date->err();
            }
         }
      } elsif ($case->{'kind'} eq 'prefix') {
         $out{'profile'} = $case->{'profile'};
         my $module =
            $case->{'profile'} eq 'dm5' ?
               'Date::Manip::DM5' : 'Date::Manip::DM6';
         eval "require $module; 1" or die $@;
         no strict 'refs';
         $out{'operation_id'} = 'date.parse-leading-tokens';
         (my $module_file = "$module.pm") =~ s{::}{/}g;
         $out{'loaded_module_file'} = $INC{$module_file};
         $out{'observed_distribution_version'} =
            ${$module.'::VERSION'};
         $out{'observed_backend_version'} =
            &{$module.'::DateManipVersion'}();
         my($fixture) =
            grep { $_->{'name'} eq $case->{'profile'} }
                 @{$profiles->{'profiles'}};
         $out{'fixture_expected_backend_version'} =
            $fixture->{'backend_version'};
         die 'wrong distribution'
            if $out{'observed_distribution_version'} ne
               $out{'fixture_expected_distribution_version'};
         die 'wrong backend'
            if $out{'observed_backend_version'} ne
               $out{'fixture_expected_backend_version'};
         $stage = 'configuration';
         $out{'configuration_status'} =
            &{$module.'::Date_Init'}(@{$fixture->{'configuration'}});
         $out{'configuration_status_type'} =
            native_type($out{'configuration_status'});
         my($arg,$holder_scalar,@holder_array);
         if ($case->{'carrier'} eq 'plain') {
            $arg = $case->{'value'};
         } elsif ($case->{'carrier'} eq 'scalar-ref') {
            $holder_scalar = $case->{'value'};
            $arg = \$holder_scalar;
         } elsif ($case->{'carrier'} eq 'token-array') {
            @holder_array = @{$case->{'value'}};
            $arg = \@holder_array;
         } else {
            die 'unknown carrier';
         }
         $out{'carrier_before'} =
            ref($arg) eq 'ARRAY' ? [@$arg] :
            ref($arg) eq 'SCALAR' ? $$arg : $arg;
         $stage = 'call';
         $out{'value'} =
            &{$module.'::ParseDate'}($arg,@{$case->{'options'}});
         $out{'value_type'} = native_type($out{'value'});
         $out{'carrier_after'} =
            ref($arg) eq 'ARRAY' ? [@$arg] :
            ref($arg) eq 'SCALAR' ? $$arg : $arg;
         if (ref($arg) eq 'ARRAY') {
            $out{'consumed_count'} = @{$case->{'value'}} - @$arg;
            $out{'remaining_tokens'} = [@$arg];
         }
      } else {
         die 'unknown kind';
      }
      1;
   };
   $out{'exception'} = $ok ? undef : "$@";
   $out{'exception_stage'} = $ok ? undef : $stage;
}
$out{'call_stdout'} = $stdout;
print JSON::PP->new->canonical->encode(\%out), "\n";
