#!/usr/bin/env perl
# Original research probe. Not a BDD step implementation or expectation generator.
use strict;
use warnings;
use JSON::PP;
use Config ();
use FindBin qw($Bin);
my $case = shift @ARGV // die "case ID required\n";
die "unexpected arguments\n" if @ARGV;
open my $fh, '<', "$Bin/../../docs/automation/reference-profiles.json" or die $!;
my $fixtures = decode_json(do { local $/; <$fh> });
my $profile = $case =~ /dm5$/ ? 'dm5' : $case =~ /dm6$/ ? 'dm6' : 'oo';
my ($fixture) = grep { $_->{name} eq $profile } @{$fixtures->{profiles}};
my @warnings;
local $SIG{__WARN__} = sub { push @warnings, $_[0] };
my %out = (case_id => $case, profile => $profile, distribution_version => '7.00', perl_version => "$^V", perl_archname => $Config::Config{archname}, warnings => \@warnings);
my $frequency = '0:0:0:1:0:0:0';
my $anchor = '2040-04-13 12:34:56';
if ($case =~ /^endpoint-(dm5|dm6)$/) {
    my $module = $profile eq 'dm5' ? 'Date::Manip::DM5' : 'Date::Manip::DM6';
    eval "require $module; 1" or die $@;
    $module->import();
    no strict 'refs';
    die 'wrong distribution' unless ${$module.'::VERSION'} eq '7.00';
    $out{configuration_return} = Date_Init(@{$fixture->{configuration}});
    my $end = '2040-04-15 12:34:56';
    $out{input} = {frequency=>$frequency,anchor=>$anchor,start=>$anchor,end=>$end};
    my @dates = ParseRecur($frequency,$anchor,$anchor,$end);
    $out{dates}=\@dates;
} else {
    require Date::Manip::Recur;
    die 'wrong distribution' unless $Date::Manip::Recur::VERSION eq '7.00';
    my $r = Date::Manip::Recur->new();
    my @config = map { split /=/, $_, 2 } @{$fixture->{configuration}};
    $out{configuration_return}=$r->config(@config);
    die 'wrong tzdata' unless $r->tz->tzdata eq 'tzdata2026c';
    if ($case eq 'anchor-positional-text') {
        $out{parse_status}=$r->parse($frequency,$anchor);
    } elsif ($case eq 'anchor-positional-value') {
        my $date=$r->new_date();
        die 'anchor parse failed' if $date->parse($anchor);
        $out{parse_status}=$r->parse($frequency,$date);
    } else {
        $out{frequency_status}=$r->frequency($frequency);
        $out{anchor_status}=$r->basedate($anchor);
        die 'initial recurrence failed' if $out{frequency_status} || $out{anchor_status};
    }
    $out{initial_error}=$r->err();
    if ($case =~ /^weekday-([1-7])$/) {
        my $modifier='PD'.$1;
        $out{input}={frequency=>$frequency,anchor=>$anchor,modifier=>$modifier};
        $out{modifier_status}=$r->modifiers($modifier);
    } elsif ($case eq 'modifier-clears-anchor') {
        $out{input}={frequency=>$frequency,anchor=>$anchor,modifiers=>['FD1'],operation_order=>['frequency','anchor','modifier']};
        $out{modifier_status}=$r->modifiers('FD1');
    } elsif ($case eq 'modifier-uppercase-string') {
        $out{input}={frequency=>$frequency,anchor=>$anchor,modifiers=>['FD1,ND2'],carrier=>'one string'};
        $out{modifier_status}=$r->modifiers('FD1,ND2');
    } elsif ($case eq 'modifier-uppercase-list') {
        $out{input}={frequency=>$frequency,anchor=>$anchor,modifiers=>['FD1','ND2'],carrier=>'two arguments'};
        $out{modifier_status}=$r->modifiers('FD1','ND2');
    } elsif ($case eq 'modifier-lowercase-list') {
        $out{input}={frequency=>$frequency,anchor=>$anchor,modifiers=>['fd1','nd2'],carrier=>'two arguments'};
        $out{modifier_status}=$r->modifiers('fd1','nd2');
    } elsif ($case =~ /^anchor-(?:positional-text|positional-value|setter)$/) {
        $out{input}={frequency=>$frequency,anchor=>$anchor,carrier=>$case};
    } else { die "unknown case $case\n"; }
    $out{error_after_modifiers}=$r->err();
    $out{stored_modifiers}=[$r->modifiers()];
    my ($stored_anchor,$effective_anchor)=$r->basedate();
    $out{anchor_after_modifiers}=defined($stored_anchor) ? $stored_anchor->value('local') : undef;
    if ($case =~ /^(weekday-|modifier-)/ && $case ne 'modifier-clears-anchor') {
        # For modifier semantics, explicitly set the anchor after the modifier.
        # The separate lifecycle case observes the clearing without repair.
        $out{final_setup_anchor_status}=$r->basedate($anchor);
    }
    my ($date,$error)=$r->nth(0);
    $out{lookup_error}=$error;
    $out{date}=defined($date) ? $date->value('local') : undef;
    $out{error_after_lookup}=$r->err();
}
print JSON::PP->new->canonical->encode(\%out),"\n";
