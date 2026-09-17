#!/usr/bin/env perl
# Original public Base check/check_time probe; not an expectation oracle.
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

my $root = "$Bin/../../..";
my $id = shift @ARGV // die "case ID required";
die "unexpected arguments" if @ARGV;
my $manifest = read_json("$root/docs/research/calendar-check-family/cases.json");
my($case) = grep { $_->{'case_id'} eq $id } @{$manifest->{'cases'}};
die "unknown case ID" if !$case;
my $profiles = read_json("$root/docs/automation/reference-profiles.json");
my($fixture) = grep { $_->{'name'} eq 'oo' } @{$profiles->{'profiles'}};
die "missing oo fixture" if !$fixture;

my(@load_warnings,$load_stdout);
$load_stdout = '';
my $load_ok;
{
   local $SIG{__WARN__} = sub { push @load_warnings, "$_[0]" };
   open local *STDOUT, '>', \$load_stdout or die $!;
   $load_ok = eval { require Date::Manip::Date; 1 };
}
die "module load failed: $@" if !$load_ok;

my($date,$base,$setup_return,@setup_warnings,$setup_stdout);
$setup_stdout = '';
my $setup_ok;
{
   local $SIG{__WARN__} = sub { push @setup_warnings, "$_[0]" };
   open local *STDOUT, '>', \$setup_stdout or die $!;
   $setup_ok = eval {
      $date = Date::Manip::Date->new();
      my @pairs = map { split /=/, $_, 2 } @{$fixture->{'configuration'}};
      $setup_return = $date->config(@pairs);
      $base = $date->base();
      1;
   };
}

my %out = (
   case_id => $id,
   operation_id => $case->{'operation_id'},
   request => clone_json($case),
   profile => 'oo',
   effective_configuration => clone_json($fixture->{'configuration'}),
   fixture_reference => clone_json($profiles->{'reference'}),
   fixture_timezone_data => clone_json($fixture->{'timezone_data'}),
   perl_version => "$^V",
   perl_archname => $Config::Config{'archname'},
   os_name => $^O,
   load_warnings => \@load_warnings,
   load_stdout => $load_stdout,
   configuration_call_completed => $setup_ok ? JSON::PP::true : JSON::PP::false,
   ($setup_ok ? (configuration_return => $setup_return,
                  configuration_return_type => native_type($setup_return)) : ()),
   configuration_exception => $setup_ok ? undef : "$@",
   configuration_warnings => \@setup_warnings,
   configuration_stdout => $setup_stdout,
   dependent_operations_executed => $setup_ok ? JSON::PP::true : JSON::PP::false,
   calls => [],
);

sub call_arguments {
   my($input) = @_;
   if ($input->{'carrier'} eq 'ordered-fields') {
      my $fields = clone_json($input->{'fields'});
      return ($fields);
   }
   if ($input->{'carrier'} eq 'text scalar') {
      return ($input->{'value'});
   }
   die "unknown input carrier";
}

sub observe_context {
   my($context,$method,$input) = @_;
   my @args = call_arguments($input);
   my %call = (
      context => $context,
      input => clone_json($input),
   );
   my $initial = $base->err();
   my $clear_return = $base->err(1);
   $call{'error_observer'} = {
      operation => 'Base::err',
      initial => $initial,
      clear_call_completed => JSON::PP::true,
      clear_return => $clear_return,
      clear_return_type => native_type($clear_return),
      before => $base->err(),
   };
   my(@warnings,$stdout);
   $stdout = '';
   my $ok;
   {
      local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
      open local *STDOUT, '>', \$stdout or die $!;
      if ($context eq 'scalar') {
         my $return;
         $ok = eval { $return = $base->$method(@args); 1 };
         if ($ok) {
            $call{'return'} = $return;
            $call{'return_type'} = native_type($return);
         }
      } else {
         my @return;
         $ok = eval { @return = $base->$method(@args); 1 };
         if ($ok) {
            $call{'return'} = \@return;
            $call{'return_type'} = 'list';
            $call{'return_count'} = scalar @return;
            $call{'return_element_types'} = [map { native_type($_) } @return];
         }
      }
   }
   $call{'call_completed'} = $ok ? JSON::PP::true : JSON::PP::false;
   $call{'exception'} = $ok ? undef : "$@";
   $call{'warnings'} = \@warnings;
   $call{'stdout'} = $stdout;
   $call{'error_observer'}{'after'} = $base->err();
   return \%call;
}

if ($setup_ok) {
   my $method = $case->{'operation_id'} eq 'calendar.validate-time' ? 'check_time' : 'check';
   push @{$out{'calls'}}, observe_context('scalar',$method,$case->{'input'});
   push @{$out{'calls'}}, observe_context('list',$method,$case->{'input'});
}

$out{'observed_distribution_version'} = $Date::Manip::Date::VERSION;
$out{'observed_backend_version'} = $base ? $base->version() : undef;
$out{'loaded_date_manip_module_files'} = {
   map { $_ => $INC{$_} }
   sort grep { m{^Date/Manip/.*\.pm$} } keys %INC
};
die "wrong distribution" if $out{'observed_distribution_version'} ne
                            $profiles->{'reference'}{'distribution_version'};
die "wrong backend" if $out{'observed_backend_version'} ne '7.00';
print JSON::PP->new->canonical->utf8->encode(\%out), "\n";
