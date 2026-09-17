#!/usr/bin/env perl
# Original public Date_DaySuffix observation probe; not an expectation oracle.
use strict;
use warnings;
use JSON::PP;
use Config ();
use FindBin qw($Bin);

sub read_json {
   open my $fh, '<', $_[0] or die $!;
   return decode_json(do { local $/; <$fh> });
}
sub clone_json { decode_json(encode_json($_[0])) }
sub native_type {
   my($value) = @_;
   return 'undefined' if !defined $value;
   return ref($value) || 'text';
}
sub public_text {
   my($value) = @_;
   return undef if !defined $value;
   return $value if ref($value);
   return q{} . $value;
}

my $root = "$Bin/../../..";
my $id = shift @ARGV // die "case ID required";
die "unexpected arguments" if @ARGV;
my $manifest = read_json("$root/docs/research/day-ordinal-family/cases.json");
my($case) = grep { $_->{'case_id'} eq $id } @{$manifest->{'cases'}};
die "unknown case ID" if !$case;
my $requests = $manifest->{'request_sets'}{$case->{'request_set'}};
die "missing request set" if !$requests;
my $profiles = read_json("$root/docs/automation/reference-profiles.json");
my($fixture) = grep { $_->{'name'} eq $case->{'profile'} } @{$profiles->{'profiles'}};
die "missing profile fixture" if !$fixture;

my $package = $case->{'profile'} eq 'dm6' ? 'Date::Manip::DM6' : 'Date::Manip::DM5';
(my $module_file = "$package.pm") =~ s{::}{/}g;
my(@load_warnings,$load_stdout);
$load_stdout = '';
my $load_ok;
{
   local $SIG{__WARN__} = sub { push @load_warnings, "$_[0]" };
   open local *STDOUT, '>', \$load_stdout or die $!;
   $load_ok = eval "require $package; 1";
}
die "module load failed: $@" if !$load_ok;

no strict 'refs';
my @configuration = map {
   /^Language=/ ? "Language=$case->{'language'}" : $_
} @{$fixture->{'configuration'}};
my(@setup_warnings,$setup_stdout,$setup_return);
$setup_stdout = '';
my $setup_ok;
{
   local $SIG{__WARN__} = sub { push @setup_warnings, "$_[0]" };
   open local *STDOUT, '>', \$setup_stdout or die $!;
   $setup_ok = eval {
      $setup_return = &{$package.'::Date_Init'}(@configuration);
      1;
   };
}

my %out = (
   case_id => $id,
   operation_id => $case->{'operation_id'},
   request => $case,
   request_set => $requests,
   profile => $case->{'profile'},
   effective_configuration => \@configuration,
   fixture_expected_distribution_version => $profiles->{'reference'}{'distribution_version'},
   fixture_expected_backend_version => $fixture->{'backend_version'},
   fixture_timezone_data => $fixture->{'timezone_data'},
   perl_version => "$^V",
   perl_archname => $Config::Config{'archname'},
   os_name => $^O,
   loaded_module_file => $INC{$module_file},
   loaded_date_manip_module_files => {
      map { $_ => $INC{$_} }
      sort grep { m{^Date/Manip/.*\.pm$} } keys %INC
   },
   observed_distribution_version => ${$package.'::VERSION'},
   observed_backend_version => &{$package.'::DateManipVersion'}(),
   load_warnings => \@load_warnings,
   load_stdout => $load_stdout,
   configuration_call_completed => $setup_ok ? JSON::PP::true : JSON::PP::false,
   ($setup_ok ? (configuration_return => public_text($setup_return),
   configuration_return_type => native_type($setup_return)) : ()),
   configuration_exception => $setup_ok ? undef : "$@",
   configuration_warnings => \@setup_warnings,
   configuration_stdout => $setup_stdout,
   error_observer => 'Date_DaySuffix exposes no documented facade error observer',
   dependent_operations_executed => $setup_ok ? JSON::PP::true : JSON::PP::false,
   calls => [],
);

sub observe_call {
   my($request,$context) = @_;
   my @args = @{clone_json($request->{'arguments'})};
   my %call = (
      request_id => $request->{'request_id'},
      arguments => clone_json($request->{'arguments'}),
      context => $context,
      error_observer => 'not exposed by the documented facade',
   );
   my @warnings;
   my $stdout = '';
   my $ok;
   {
      local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
      open local *STDOUT, '>', \$stdout or die $!;
      if ($context eq 'scalar') {
         my $return;
         $ok = eval { $return = &{$package.'::Date_DaySuffix'}(@args); 1 };
         if ($ok) {
            $call{'return'} = public_text($return);
            $call{'return_type'} = native_type($return);
         }
      } else {
         my @return;
         $ok = eval { @return = &{$package.'::Date_DaySuffix'}(@args); 1 };
         if ($ok) {
            $call{'return'} = [map { public_text($_) } @return];
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
   return \%call;
}

if ($setup_ok) {
   for my $request (@$requests) {
      push @{$out{'calls'}}, {
         request_id => $request->{'request_id'},
         arguments => clone_json($request->{'arguments'}),
         scalar_call => observe_call($request,'scalar'),
         list_call => observe_call($request,'list'),
      };
   }
}

die "wrong distribution" if $out{'observed_distribution_version'} ne
                            $out{'fixture_expected_distribution_version'};
die "wrong backend" if $out{'observed_backend_version'} ne
                       $out{'fixture_expected_backend_version'};
print JSON::PP->new->canonical->utf8->encode(\%out), "\n";
