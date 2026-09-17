#!/usr/bin/env perl
# Original sequence probe for public Date::Manip::Date calls.
use strict;
use warnings;
use JSON::PP;
use Config ();
use FindBin qw($Bin);

sub read_json {
   open my $fh, '<', $_[0] or die $!;
   return decode_json(do { local $/; <$fh> });
}
sub scalar_type {
   my($kind,$value) = @_;
   return 'absent' if ! defined $value;
   return 'number' if $kind eq 'status';
   return 'text';
}

my $root = "$Bin/../../..";
my $id = shift @ARGV // die "case ID required";
die 'unexpected arguments' if @ARGV;
my $corpus = read_json("$root/docs/research/parse-cache-family/cases.json");
my($case) = grep { $_->{'case_id'} eq $id } @{$corpus->{'cases'}};
die 'unknown case' if ! $case;
my $profiles = read_json("$root/docs/automation/reference-profiles.json");
my($fixture) = grep { $_->{'name'} eq 'oo' } @{$profiles->{'profiles'}};
die 'missing fixture' if ! $fixture;

my @warnings;
local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
my %out = (
   case_id => $id,
   operation_ids => [
      'date.parse-text', 'date.read-value', 'error.read-state',
      ((grep { $_->[0] eq 'parse_date' } @{$case->{'actions'}}) ? ('date.parse-date-only') : ()),
      ((grep { $_->[0] eq 'parse_time' } @{$case->{'actions'}}) ? ('time.parse-text') : ()),
   ],
   profile => 'oo',
   distribution_version => undef,
   backend_version => '7.00',
   perl_version => "$^V",
   perl_archname => $Config::Config{'archname'},
   os_name => $^O,
   request => $case,
   warnings => \@warnings,
   sequence => [],
);
my $stdout = '';
{
   open local *STDOUT, '>', \$stdout or die $!;
   my $stage = 'load';
   my $ok = eval {
      require Date::Manip::Date;
      $out{'distribution_version'} = $Date::Manip::Date::VERSION;
      die 'wrong distribution' if $out{'distribution_version'} ne '7.00';
      my $date = Date::Manip::Date->new();
      $stage = 'configuration';
      $out{'configuration_status'} = $date->config(map { split /=/, $_, 2 } @{$fixture->{'configuration'}});
      $out{'configuration_error'} = scalar $date->err();
      $out{'tzdata'} = scalar $date->tz()->tzdata();
      die 'wrong tzdata' if $out{'tzdata'} ne 'tzdata2026c';

      $stage = 'initialization';
      my $initial_status = $date->parse($corpus->{'initial_text'});
      push @{$out{'sequence'}}, {
         index => 0, action => 'initialize', input => $corpus->{'initial_text'},
         error_before => '', result => $initial_status, result_type => 'number',
         error_after => scalar $date->err(),
      };
      die 'invalid initial value' if $initial_status;

      my $index = 0;
      for my $action (@{$case->{'actions'}}) {
         ++$index;
         my($name,@args) = @$action;
         $stage = "action $index $name";
         my $before = scalar $date->err();
         my %row = (index=>$index, action=>$name, arguments=>\@args, error_before=>$before);
         my $warning_start = scalar @warnings;
         my $action_ok = eval {
         if ($name eq 'parse' || $name eq 'parse_date' || $name eq 'parse_time') {
            my $result = $date->$name(@args);
            $row{'result'} = $result;
            $row{'result_type'} = scalar_type('status',$result);
         } elsif ($name eq 'value') {
            my($carrier,$context) = @args;
            my $selector = $carrier eq 'parsed' ? undef : $carrier;
            if ($context eq 'list') {
               my @result = defined($selector) ? $date->value($selector) : $date->value();
               $row{'result'} = \@result;
               $row{'result_type'} = 'list';
            } else {
               my $result = defined($selector) ? scalar($date->value($selector)) : scalar($date->value());
               $row{'result'} = $result;
               $row{'result_type'} = defined($result) ? 'text' : 'absent';
            }
         } elsif ($name eq 'clear_error') {
            $row{'result'} = scalar $date->err(1);
            $row{'result_type'} = 'absent';
         } else {
            die "unknown action: $name";
         }
         1;
         };
         if (! $action_ok) {
            $row{'action_exception'} = "$@";
            $row{'result'} = undef;
            $row{'result_type'} = 'absent';
         } else {
            $row{'action_exception'} = undef;
         }
         $row{'warnings'} = [@warnings[$warning_start .. $#warnings]];
         $row{'error_after'} = scalar $date->err();
         push @{$out{'sequence'}}, \%row;
      }
      1;
   };
   $out{'exception'} = $ok ? undef : "$@";
   $out{'exception_stage'} = $ok ? undef : $stage;
}
$out{'call_stdout'} = $stdout;
print JSON::PP->new->canonical->encode(\%out), "\n";
