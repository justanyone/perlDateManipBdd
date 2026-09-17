#!/usr/bin/env perl
# Original input/output research; this is not a conformance expectation generator.
use strict;
use warnings;
use JSON::PP;
use Config ();
use FindBin qw($Bin);

sub read_json {
   open my $fh, '<', $_[0] or die $!;
   return decode_json(do { local $/; <$fh> });
}
sub type_of {
   my($value) = @_;
   return 'absent' if ! defined $value;
   return ref($value) || 'text';
}

my $root = "$Bin/../../..";
my $id = shift @ARGV // die "case ID required";
die 'unexpected arguments' if @ARGV;
my $corpus = read_json("$root/docs/research/partial-parsing-family/cases.json");
my($case) = grep { $_->{'case_id'} eq $id } @{$corpus->{'cases'}};
die 'unknown case' if ! $case;
my $profiles = read_json("$root/docs/automation/reference-profiles.json");
my($fixture) = grep { $_->{'name'} eq $case->{'profile'} } @{$profiles->{'profiles'}};
die 'missing fixture' if ! $fixture;

my @warnings;
local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
my %out = (
   case_id => $id,
   profile => $case->{'profile'},
   fixture_expected_distribution_version => $profiles->{'reference'}{'distribution_version'},
   fixture_expected_backend_version => $fixture->{'backend_version'},
   operation_id => $case->{'operation'} eq 'parse_date' ? 'date.parse-date-only' :
                   $case->{'operation'} eq 'parse_time' ? 'time.parse-text' :
                   'date.parse-leading-tokens',
   request => $case,
   perl_version => "$^V",
   perl_archname => $Config::Config{'archname'},
   os_name => $^O,
   warnings => \@warnings,
);
my $stdout = '';
{
   open local *STDOUT, '>', \$stdout or die $!;
   my $stage = 'load';
   my $ok = eval {
      if ($case->{'profile'} eq 'oo') {
         require Date::Manip::Date;
         $out{'loaded_module_file'} = $INC{'Date/Manip/Date.pm'};
         $out{'observed_distribution_version'} = $Date::Manip::Date::VERSION;
         my $date = Date::Manip::Date->new();
         $out{'observed_backend_version'} = scalar $date->version();
         die 'wrong distribution' if $out{'observed_distribution_version'} ne
                                     $out{'fixture_expected_distribution_version'};
         $stage = 'configuration';
         $out{'configuration_status'} = $date->config(map { split /=/, $_, 2 } @{$fixture->{'configuration'}});
         $out{'configuration_status_type'} = type_of($out{'configuration_status'});
         $out{'configuration_error'} = scalar $date->err();
         $out{'observed_tzdata'} = scalar $date->tz()->tzdata();
         $out{'observed_tzcode'} = scalar $date->tz()->tzcode();
         my $expected_tzdata = $fixture->{'timezone_data'}{'tzdata'};
         die 'wrong tzdata' if $out{'observed_tzdata'} ne $expected_tzdata;
         if ($case->{'initial'} ne 'unset') {
            $stage = 'initialization';
            $out{'initialization_performed'} = JSON::PP::true;
            $out{'initial_request'} = $case->{'initial'};
            $out{'initialization_status'} = $date->parse($case->{'initial'});
            $out{'initialization_status_type'} = 'number';
            $out{'initialization_error'} = scalar $date->err();
            die 'invalid initial value' if $out{'initialization_status'};
            # The concrete initial value is part of the request.  Do not call
            # value() here: in 7.00 that read populates a cache which can hide
            # a later successful parse_date/parse_time mutation.
            $out{'initial_value_read_skipped'} = JSON::PP::true;
         } else {
            $out{'initialization_performed'} = JSON::PP::false;
            $out{'initial_request'} = undef;
            $out{'initial_value_read_skipped'} = JSON::PP::true;
         }
         $stage = 'call';
         my $method = $case->{'operation'};
         $out{'status'} = $date->$method($case->{'text'}, @{$case->{'options'}});
         $out{'status_type'} = 'number';
         # Preserve each public observer return in its native scalar carrier,
         # in the exact order called.  In particular, empty text is distinct
         # from undef and err(1) returns undef.
         $out{'error_after_call'} = scalar $date->err();
         my $value = scalar $date->value('local');
         $out{'value_after_call'} = $value;
         $out{'value_after_call_type'} = type_of($value);
         $out{'value_read_context'} = 'scalar';
         $out{'error_after_value_read'} = scalar $date->err();
         if ($out{'status'}) {
            $out{'error_clear_return'} = $date->err(1);
            $out{'error_clear_return_type'} = type_of($out{'error_clear_return'});
            $out{'error_after_clear'} = scalar $date->err();
            my $retained = scalar $date->value('local');
            $out{'value_after_error_clear'} = $retained;
            $out{'value_after_error_clear_type'} = type_of($retained);
            $out{'error_after_retained_value_read'} = scalar $date->err();
         }
         $out{'observed_zone_after_call'} = scalar $date->tz()->zone();
      } else {
         my $module = $case->{'profile'} eq 'dm5' ? 'Date::Manip::DM5' : 'Date::Manip::DM6';
         eval "require $module; 1" or die $@;
         no strict 'refs';
         (my $module_file = "$module.pm") =~ s{::}{/}g;
         $out{'loaded_module_file'} = $INC{$module_file};
         $out{'observed_distribution_version'} = ${$module.'::VERSION'};
         $out{'observed_backend_version'} = &{$module.'::DateManipVersion'}();
         die 'wrong distribution' if $out{'observed_distribution_version'} ne
                                     $out{'fixture_expected_distribution_version'};
         die 'wrong backend' if $out{'observed_backend_version'} ne
                                 $out{'fixture_expected_backend_version'};
         $stage = 'configuration';
         $out{'configuration_status'} = &{$module.'::Date_Init'}(@{$fixture->{'configuration'}});
         $out{'configuration_status_type'} = type_of($out{'configuration_status'});
         my $carrier = $case->{'carrier'};
         my $arg;
         if ($carrier eq 'plain') {
            $arg = $case->{'value'};
         } elsif ($carrier eq 'scalar-ref') {
            my $holder = $case->{'value'};
            $arg = \$holder;
         } elsif ($carrier eq 'token-array') {
            my @holder = @{$case->{'value'}};
            $arg = \@holder;
         } elsif ($carrier eq 'hash-ref') {
            my %holder = %{$case->{'value'}};
            $arg = \%holder;
         } else {
            die 'unknown carrier';
         }
         $out{'carrier_before'} = ref($arg) eq 'ARRAY' ? [@$arg] :
                                  ref($arg) eq 'SCALAR' ? $$arg :
                                  ref($arg) eq 'HASH' ? {%$arg} : $arg;
         $stage = 'call';
         $out{'value'} = &{$module.'::ParseDate'}($arg, @{$case->{'options'}});
         $out{'value_type'} = defined($out{'value'}) ? 'text' : 'absent';
         $out{'carrier_after'} = ref($arg) eq 'ARRAY' ? [@$arg] :
                                 ref($arg) eq 'SCALAR' ? $$arg :
                                 ref($arg) eq 'HASH' ? {%$arg} : $arg;
         if (ref($arg) eq 'ARRAY') {
            $out{'consumed_count'} = @{$case->{'value'}} - @$arg;
            $out{'remaining_tokens'} = [@$arg];
         }
      }
      1;
   };
   $out{'exception'} = $ok ? undef : "$@";
   $out{'exception_stage'} = $ok ? undef : $stage;
}
$out{'call_stdout'} = $stdout;
print JSON::PP->new->canonical->encode(\%out), "\n";
