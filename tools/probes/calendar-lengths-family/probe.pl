#!/usr/bin/env perl
# Original public calendar-length observation probe; not an expectation oracle.
use strict;
use warnings;
use JSON::PP;
use Config ();
use FindBin qw($Bin);

sub read_json {
   open my $fh, '<', $_[0] or die "$!: $_[0]";
   return decode_json(do { local $/; <$fh> });
}
sub clone_json { decode_json(encode_json($_[0])) }
sub native_type {
   my($value) = @_;
   return 'undefined' if !defined $value;
   return ref($value) || 'scalar';
}
sub return_record {
   my($value) = @_;
   return (return => $value, return_type => native_type($value));
}

my $root = "$Bin/../../..";
my $id = shift @ARGV // die "case ID required";
die "unexpected arguments" if @ARGV;
my $manifest = read_json("$root/docs/research/calendar-lengths-family/cases.json");
my($case) = grep { $_->{'case_id'} eq $id } @{$manifest->{'cases'}};
die "unknown case ID" if !$case;
my $profiles = read_json("$root/docs/automation/reference-profiles.json");
my($fixture) = grep { $_->{'name'} eq $case->{'profile'} } @{$profiles->{'profiles'}};
die "missing profile fixture" if !$fixture;

my %route_module = (
   base => 'Date::Manip::Date',
   dm6  => 'Date::Manip::DM6',
   dm5  => 'Date::Manip::DM5',
);
my $module = $route_module{$case->{'route'}} // die "unknown route";
(my $module_file = "$module.pm") =~ s{::}{/}g;
my(@load_warnings,$load_stdout);
$load_stdout = '';
my $load_ok;
{
   local $SIG{__WARN__} = sub { push @load_warnings, "$_[0]" };
   open local *STDOUT, '>', \$load_stdout or die $!;
   $load_ok = eval "require $module; 1";
}
die "module load failed: $@" if !$load_ok;

my @configuration = @{$fixture->{'configuration'}};
push @configuration, "YYtoYYYY=$case->{'yytoyyyy'}" if exists $case->{'yytoyyyy'} && defined $case->{'yytoyyyy'};
my($receiver,$callable,@setup_warnings,$setup_stdout,$setup_return);
$setup_stdout = '';
my $setup_ok;
{
   local $SIG{__WARN__} = sub { push @setup_warnings, "$_[0]" };
   open local *STDOUT, '>', \$setup_stdout or die $!;
   $setup_ok = eval {
      if ($case->{'route'} eq 'base') {
         my $date = Date::Manip::Date->new();
         my @pairs = map { split /=/, $_, 2 } @configuration;
         $setup_return = $date->config(@pairs);
         $receiver = $date->base();
         $callable = $case->{'operation_id'} eq 'calendar.days-in-month'
                   ? $receiver->can('days_in_month')
                   : $receiver->can('days_in_year');
      } else {
         no strict 'refs';
         $setup_return = &{$module.'::Date_Init'}(@configuration);
         my $name = $case->{'operation_id'} eq 'calendar.days-in-month'
                  ? 'Date_DaysInMonth' : 'Date_DaysInYear';
         $callable = $module->can($name);
      }
      die "missing public callable" if !$callable;
      1;
   };
}

my %out = (
   case_id => $id,
   operation_id => $case->{'operation_id'},
   request => clone_json($case),
   profile => $case->{'profile'},
   route => $case->{'route'},
   effective_configuration => \@configuration,
   fixture_reference => clone_json($profiles->{'reference'}),
   fixture_timezone_data => clone_json($fixture->{'timezone_data'}),
   perl_version => "$^V",
   perl_archname => $Config::Config{'archname'},
   os_name => $^O,
   loaded_entry_module_file => $INC{$module_file},
   load_warnings => \@load_warnings,
   load_stdout => $load_stdout,
   configuration_call_completed => $setup_ok ? JSON::PP::true : JSON::PP::false,
   ($setup_ok ? (configuration_return => $setup_return,
                  configuration_return_type => native_type($setup_return)) : ()),
   configuration_exception => $setup_ok ? undef : "$@",
   configuration_warnings => \@setup_warnings,
   configuration_stdout => $setup_stdout,
   dependent_operation_executed => $setup_ok ? JSON::PP::true : JSON::PP::false,
);

if ($setup_ok) {
   my @args = @{clone_json($case->{'arguments'})};
   my %call = (
      arguments => clone_json($case->{'arguments'}),
      return_context => $case->{'return_context'},
   );
   if ($receiver) {
      my $initial = $receiver->err();
      my $clear_return = $receiver->err(1);
      $call{'error_observer'} = {
         operation => 'Base::err',
         initial => $initial,
         clear_call_completed => JSON::PP::true,
         clear_return => $clear_return,
         clear_return_type => native_type($clear_return),
         before => $receiver->err(),
      };
   } else {
      $call{'error_observer'} = {
         operation => 'none documented by the functional facade',
         called => JSON::PP::false,
      };
   }
   my(@warnings,$stdout);
   $stdout = '';
   my $ok;
   {
      local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
      open local *STDOUT, '>', \$stdout or die $!;
      if ($case->{'return_context'} eq 'list') {
         my @return;
         $ok = eval {
            @return = $receiver ? $callable->($receiver,@args) : $callable->(@args);
            1;
         };
         if ($ok) {
            $call{'return'} = \@return;
            $call{'return_type'} = 'list';
            $call{'return_count'} = scalar @return;
            $call{'return_element_types'} = [map { native_type($_) } @return];
         }
      } else {
         my $return;
         $ok = eval {
            $return = $receiver ? scalar($callable->($receiver,@args)) : scalar($callable->(@args));
            1;
         };
         if ($ok) {
            @call{'return','return_type'} = ($return,native_type($return));
         }
      }
   }
   $call{'call_completed'} = $ok ? JSON::PP::true : JSON::PP::false;
   $call{'exception'} = $ok ? undef : "$@";
   $call{'warnings'} = \@warnings;
   $call{'stdout'} = $stdout;
   $call{'error_observer'}{'after'} = $receiver->err() if $receiver;
   $out{'call'} = \%call;
}

{
   no strict 'refs';
   $out{'observed_distribution_version'} = ${$module.'::VERSION'};
   if ($case->{'route'} eq 'base') {
      $out{'observed_backend_version'} = $receiver ? $receiver->version() : undef;
   } else {
      $out{'observed_backend_version'} = &{$module.'::DateManipVersion'}();
   }
}
$out{'loaded_date_manip_module_files'} = {
   map { $_ => $INC{$_} }
   sort grep { m{^Date/Manip/.*\.pm$} } keys %INC
};
die "wrong distribution" if $out{'observed_distribution_version'} ne
                            $profiles->{'reference'}{'distribution_version'};
my $expected_backend = $case->{'route'} eq 'base' ? '7.00' : $fixture->{'backend_version'};
die "wrong backend" if $out{'observed_backend_version'} ne $expected_backend;
print JSON::PP->new->canonical->utf8->encode(\%out), "\n";
