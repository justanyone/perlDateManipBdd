#!/usr/bin/env perl
# Original public-call observation probe; never used as an expectation oracle.
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
sub public_return_value {
   my($value) = @_;
   return undef if !defined $value;
   return $value if ref($value);
   # These public methods return textual scalars.  Force a plain string so
   # JSON::PP does not serialize Perl's special false-but-defined scalar as a
   # JSON boolean; the empty string and undef are distinct observations.
   return q{} . $value;
}

my $root = "$Bin/../../..";
my $id = shift @ARGV // die "case ID required";
die "unexpected arguments" if @ARGV;
my $manifest = read_json("$root/docs/research/value-serialization-family/cases.json");
my($case) = grep { $_->{'case_id'} eq $id } @{$manifest->{'cases'}};
die "unknown case ID" if !$case;
my $profiles = read_json("$root/docs/automation/reference-profiles.json");
my($fixture) = grep { $_->{'name'} eq 'oo' } @{$profiles->{'profiles'}};
die "missing OO fixture" if !$fixture;

require Date::Manip::Date;
my %out = (
   case_id => $id,
   operation_id => $case->{'operation_id'},
   request => $case,
   profile => 'oo',
   fixture_expected_distribution_version => $profiles->{'reference'}{'distribution_version'},
   fixture_expected_timezone_data => $fixture->{'timezone_data'},
   perl_version => "$^V",
   perl_archname => $Config::Config{'archname'},
   os_name => $^O,
   observed_distribution_version => $Date::Manip::Date::VERSION,
   observed_module_versions => {
      'Date::Manip::Date' => $Date::Manip::Date::VERSION,
      'Date::Manip::Base' => $Date::Manip::Base::VERSION,
      'Date::Manip::Obj' => $Date::Manip::Obj::VERSION,
   },
   loaded_modules => {
      'Date::Manip::Date' => $INC{'Date/Manip/Date.pm'},
      'Date::Manip::Base' => $INC{'Date/Manip/Base.pm'},
      'Date::Manip::Obj' => $INC{'Date/Manip/Obj.pm'},
   },
);

sub fresh_base {
   my $date = Date::Manip::Date->new();
   my $status = $date->config(map { split /=/, $_, 2 } @{$fixture->{'configuration'}});
   my $error = scalar $date->err();
   die "fixture configuration failed: $error" if defined($status) && $status;
   my($override_status,$override_error);
   if (exists $case->{'printable'}) {
      $override_status = $date->config('Printable', $case->{'printable'});
      $override_error = scalar $date->err();
      die "Printable configuration failed: $override_error"
         if defined($override_status) && $override_status;
   }
   my $base = $date->base();
   return ($date,$base,{
      configuration_return => $status,
      configuration_return_type => native_type($status),
      configuration_error => $error,
      printable_override_performed => exists($case->{'printable'}) ? JSON::PP::true : JSON::PP::false,
      printable_override_return => $override_status,
      printable_override_return_type => native_type($override_status),
      printable_override_error => $override_error,
   });
}

sub args_for_call {
   my $input = clone_json($case->{'input'});
   my @args = ($case->{'kind'}, $input);
   if ($case->{'options_style'} eq 'map') {
      push @args, clone_json($case->{'options'});
   } elsif ($case->{'options_style'} eq 'legacy') {
      push @args, $case->{'legacy_option'};
   } elsif ($case->{'options_style'} ne 'none') {
      die "unknown options style";
   }
   return @args;
}

sub observe_context {
   my($context) = @_;
   my($date,$base,$setup) = fresh_base();
   my %call = (%$setup, context => $context);
   $call{'error_before_call'} = scalar $base->err();
   my @warnings;
   my $stdout = '';
   my $ok;
   {
      local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
      open local *STDOUT, '>', \$stdout or die $!;
      my @args = args_for_call();
      if ($context eq 'scalar') {
         my $return;
         $ok = eval { $return = $base->${\$case->{'method'}}(@args); 1 };
         if ($ok) {
            $call{'return'} = public_return_value($return);
            $call{'return_type'} = native_type($return);
         }
      } else {
         my @return;
         $ok = eval { @return = $base->${\$case->{'method'}}(@args); 1 };
         if ($ok) {
            $call{'return'} = [map { public_return_value($_) } @return];
            $call{'return_type'} = 'list';
            $call{'return_count'} = scalar @return;
            $call{'return_element_types'} = [map { native_type($_) } @return];
         }
      }
      $call{'exception'} = $ok ? undef : "$@";
      $call{'call_completed'} = $ok ? JSON::PP::true : JSON::PP::false;
      $call{'error_after_call'} = scalar $base->err();
   }
   $call{'warnings'} = \@warnings;
   $call{'stdout'} = $stdout;
   $call{'observed_backend_version'} = scalar $date->version();
   $call{'observed_tzdata'} = scalar $date->tz()->tzdata();
   $call{'observed_tzcode'} = scalar $date->tz()->tzcode();
   return \%call;
}

$out{'scalar_call'} = observe_context('scalar');
$out{'list_call'} = observe_context('list');
die "wrong distribution" if $out{'observed_distribution_version'} ne $out{'fixture_expected_distribution_version'};
die "wrong backend" if $out{'scalar_call'}{'observed_backend_version'} ne $profiles->{'reference'}{'distribution_version'};
die "wrong tzdata" if $out{'scalar_call'}{'observed_tzdata'} ne $fixture->{'timezone_data'}{'tzdata'};
$out{'loaded_modules'} = {map {$_ => $INC{$_}} grep {m{^Date/Manip}} keys %INC};
print JSON::PP->new->canonical->encode(\%out), "\n";
