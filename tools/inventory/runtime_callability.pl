#!/usr/bin/env perl
use v5.16;
use strict;
use warnings;
use File::Path qw(make_path);
use File::Spec;
use Getopt::Long qw(GetOptions);
use JSON::PP qw();

my %arg = (inventory => 'docs/planning/perl-api-inventory.csv', source => '/tmp/Date-Manip-7.00', outdir => 'docs/research/api');
GetOptions('inventory=s' => \$arg{inventory}, 'source=s' => \$arg{source}, 'outdir=s' => \$arg{outdir}, 'check' => \$arg{check})
   or die "usage: $0 [--inventory FILE] [--source DIR] [--outdir DIR] [--check]\n";
for my $file (qw(lib/Date/Manip.pm lib/Date/Manip/DM5.pm lib/Date/Manip/DM6.pm)) {
   my $path = File::Spec->catfile($arg{source}, split m{/}, $file);
   open my $version_fh, '<', $path or die "cannot read release marker $path: $!\n";
   my $text = do { local $/; <$version_fh> };
   my ($version) = $text =~ /\$VERSION\s*=\s*['\"]([^'\"]+)['\"]/;
   die "expected Date-Manip 7.00 in $path\n" unless defined $version && $version eq '7.00';
}
unshift @INC, File::Spec->catdir($arg{source}, 'lib');

sub facade_probe {
   my ($profile, $use_dm5) = @_;
   local $ENV{DATE_MANIP};
   if ($use_dm5) { $ENV{DATE_MANIP} = 'DM5' } else { delete $ENV{DATE_MANIP} }
   my $program = q{
      no strict 'refs';
      my @exports = @Date::Manip::EXPORT;
      my @unresolved = grep { !Date::Manip->can($_) } @exports;
      print JSON::PP::encode_json({ exports => \@exports, unresolved => \@unresolved, isa => \@Date::Manip::ISA });
   };
   open my $pipe, '-|', $^X, '-I' . File::Spec->catdir($arg{source}, 'lib'), '-MDate::Manip', '-MJSON::PP', '-e', $program
      or die "cannot run Date::Manip facade probe: $!\n";
   my $json = do { local $/; <$pipe> };
   close $pipe or die "Date::Manip facade probe failed for $profile\n";
   my $result = JSON::PP::decode_json($json);
   $result->{profile} = $profile;
   return $result;
}

open my $fh, '<', $arg{inventory} or die "cannot read $arg{inventory}: $!\n";
<$fh>;
my (%declared, %packages, %public_candidate);
while (my $line = <$fh>) {
   chomp $line;
   $line =~ s/\r\z//;
   next unless length $line;
   my ($module, $callable, undef, undef, $exported, $pod_named) = split /,/, $line, 7;
   $declared{$module}{$callable} = 1;
   $packages{$module} = 1;
   $public_candidate{$module}{$callable} = 1 if $exported eq 'yes' || $pod_named eq 'yes';
}
my @modules = sort keys %packages;
my (@module_results, @callables, @receiver_matrix);
for my $module (@modules) {
   my $loaded = eval "require $module; 1";
   my $error = $@;
   no strict 'refs'; ## no critic (ProhibitNoStrict)
   my @isa = @{"${module}::ISA"};
   my @exports = @{"${module}::EXPORT"};
   my %exports = map { $_ => 1 } @exports;
   my @direct_codes = sort grep { defined *{"${module}::$_"}{CODE} } keys %{"${module}::"};
   my @undeclared_direct_codes = grep { !$declared{$module}{$_} } @direct_codes;
   push @module_results, {
      module => $module, loaded => $loaded ? JSON::PP::true : JSON::PP::false,
      error => $loaded ? undef : "$error", isa => \@isa, exports => \@exports, direct_code_symbols => \@direct_codes,
      undeclared_direct_code_symbols => \@undeclared_direct_codes,
   };
      for my $name (sort keys %{ $declared{$module} }) {
      push @callables, {
         module => $module, callable => $name, loaded => $loaded ? JSON::PP::true : JSON::PP::false,
         direct_code => defined *{"${module}::$name"}{CODE} ? JSON::PP::true : JSON::PP::false,
         can_call => $loaded && $module->can($name) ? JSON::PP::true : JSON::PP::false,
         exported_at_runtime => $exports{$name} ? JSON::PP::true : JSON::PP::false,
         public_candidate => $public_candidate{$module}{$name} ? JSON::PP::true : JSON::PP::false,
      };
   }
}
my %receiver_modules = (
   'Date::Manip::Base'  => [qw(Date::Manip::Obj Date::Manip::Base)],
   'Date::Manip::Date'  => [qw(Date::Manip::Obj Date::Manip::Date)],
   'Date::Manip::Delta' => [qw(Date::Manip::Obj Date::Manip::Delta)],
   'Date::Manip::Recur' => [qw(Date::Manip::Obj Date::Manip::Recur)],
   'Date::Manip::TZ'    => [qw(Date::Manip::Obj Date::Manip::TZ)],
);
for my $receiver (sort keys %receiver_modules) {
   for my $origin (@{ $receiver_modules{$receiver} }) {
      for my $name (sort keys %{ $public_candidate{$origin} // {} }) {
         no strict 'refs'; ## no critic (ProhibitNoStrict)
         push @receiver_matrix, {
            receiver => $receiver, declared_in => $origin, callable => $name,
            direct_on_receiver => defined *{"${receiver}::$name"}{CODE} ? JSON::PP::true : JSON::PP::false,
            can_call => $receiver->can($name) ? JSON::PP::true : JSON::PP::false,
         };
      }
   }
}
my $failed = scalar grep { !$_->{loaded} } @module_results;
my $missing = scalar grep { $_->{loaded} && (!$_->{can_call} || !$_->{direct_code}) } @callables;
my $receiver_missing = scalar grep { !$_->{can_call} } @receiver_matrix;
my @facades = (facade_probe('dm6-default', 0), facade_probe('dm5-selected', 1));
my $facade_missing = scalar grep { @{ $_->{unresolved} } } @facades;
my %facade_count = map { $_->{profile} => scalar @{ $_->{exports} } } @facades;
if ($arg{check}) {
   die "runtime load failures: $failed\n" if $failed;
   die "declared source symbols not direct callable symbols: $missing\n" if $missing;
   die "expected inherited OO callables not callable: $receiver_missing\n" if $receiver_missing;
   die "facade aliases unresolved: $facade_missing\n" if $facade_missing;
   die "unexpected facade export counts\n" unless $facade_count{'dm6-default'} == 34 && $facade_count{'dm5-selected'} == 33;
   print "ok: " . scalar(@callables) . " declared symbols, " . scalar(@receiver_matrix) . " OO receiver routes, and facade aliases callable\n";
   exit 0;
}
make_path($arg{outdir});
my $outpath = File::Spec->catfile($arg{outdir}, 'runtime-callability.json');
open my $out, '>', $outpath or die "cannot write $outpath: $!\n";
print {$out} JSON::PP->new->canonical->pretty->encode({
   schema_version => 1, reference => { distribution => 'Date-Manip', version => '7.00', source_root => $arg{source} },
   method => 'Package loading plus direct symbol-table and can() checks; no API method was invoked.',
   limits => ['can() confirms runtime resolution only; it does not establish argument shapes, behavior, or support status.', 'Undeclared direct symbols are retained for review because a symbol-table scan cannot itself distinguish imported support, generated code, and intentional public aliases.'],
   modules => \@module_results, callables => \@callables, receiver_matrix => \@receiver_matrix, facade_probes => \@facades,
});
close $out or die "cannot close $outpath: $!\n";
print "$outpath\n";
