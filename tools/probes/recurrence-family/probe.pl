#!/usr/bin/env perl
# Original reference-research probe. It is not a BDD adapter or an expectation generator.
use strict;
use warnings;
use Config ();
use FindBin qw($Bin);
use JSON::PP;

my $case = shift @ARGV // die "case ID required\n";
die "unexpected arguments\n" if @ARGV;

my $root = "$Bin/../../..";
open my $profile_fh, '<', "$root/docs/automation/reference-profiles.json" or die $!;
my $profiles = decode_json(do { local $/; <$profile_fh> });

my @warnings;
local $SIG{__WARN__} = sub { push @warnings, $_[0] };
my %out = (
    case_id              => $case,
    distribution_version => '7.00',
    perl_version         => "$^V",
    perl_archname        => $Config::Config{archname},
    warnings             => \@warnings,
);

sub profile {
    my ($name) = @_;
    my ($p) = grep { $_->{name} eq $name } @{$profiles->{profiles}};
    die "unknown profile $name\n" unless $p;
    return $p;
}

sub date_value {
    my ($date) = @_;
    return undef unless defined $date;
    return scalar $date->value('local');
}

sub new_recur {
    my $p = profile('oo');
    require Date::Manip::Recur;
    die 'wrong distribution' unless $Date::Manip::Recur::VERSION eq '7.00';
    my $r = Date::Manip::Recur->new();
    my @pairs = map { split /=/, $_, 2 } @{$p->{configuration}};
    $out{configuration_return} = $r->config(@pairs);
    die 'wrong tzdata' unless $r->tz->tzdata eq 'tzdata2026c';
    return $r;
}

sub install_frequency {
    my ($r, $frequency, $base) = @_;
    $out{frequency_status} = $r->frequency($frequency);
    $out{base_status} = $r->basedate($base) if defined $base;
}

sub recurrence_state {
    my ($r) = @_;
    my ($base, $actual) = $r->basedate();
    return {
        frequency => scalar $r->frequency(),
        start     => date_value(scalar $r->start()),
        end       => date_value(scalar $r->end()),
        base      => date_value($base),
        actual_base => date_value($actual),
        modifiers => [ $r->modifiers() ],
        error     => scalar $r->err(),
    };
}

sub stored_state {
    my ($r) = @_;
    $out{state} = recurrence_state($r);
}

sub nth_values {
    my ($r, @indices) = @_;
    my @rows;
    for my $index (@indices) {
        my ($date, $error) = $r->nth($index);
        push @rows, { index => $index, date => date_value($date), lookup_error => $error, object_error => scalar $r->err() };
    }
    $out{nth} = \@rows;
}

sub modifier_case {
    my ($token, $base) = @_;
    my $r = new_recur();
    my $frequency = '0:0:0:1:0:0:0';
    $out{input} = { frequency => $frequency, base => $base, modifier => $token };
    $out{frequency_status} = $r->frequency($frequency);
    $out{modifier_status} = $r->modifiers($token);
    $out{base_status} = $r->basedate($base);
    stored_state($r);
    nth_values($r, 0);
}

if ($case =~ /^modifier-(.+)$/) {
    my %cases = (
        pd  => ['PD1',    '2040-04-13 12:34:56'],
        pt  => ['PT5',    '2040-04-13 12:34:56'],
        nd  => ['ND1',    '2040-04-13 12:34:56'],
        nt  => ['NT5',    '2040-04-13 12:34:56'],
        wd  => ['WD1',    '2040-04-13 12:34:56'],
        fd  => ['FD1',    '2040-04-13 12:34:56'],
        bd  => ['BD1',    '2040-04-13 12:34:56'],
        fw  => ['FW1',    '2040-04-13 12:34:56'],
        bw  => ['BW1',    '2040-04-15 12:34:56'],
        cwd => ['CWD',    '2040-04-14 12:34:56'],
        cwn => ['CWN',    '2040-04-14 12:34:56'],
        cwp => ['CWP',    '2040-04-14 12:34:56'],
        nwd => ['NWD',    '2040-04-14 12:34:56'],
        pwd => ['PWD',    '2040-04-14 12:34:56'],
        dwd => ['DWD',    '2040-04-14 12:34:56'],
        ibd => ['IBD',    '2040-04-13 12:34:56'],
        nbd => ['NBD',    '2040-04-14 12:34:56'],
        iw  => ['IW5',    '2040-04-13 12:34:56'],
        nw  => ['NW5',    '2040-04-13 12:34:56'],
        easter => ['EASTER', '2040-04-13 12:34:56'],
    );
    die "unknown modifier case $case\n" unless $cases{$1};
    modifier_case(@{$cases{$1}});
} elsif ($case eq 'create-and-empty-read') {
    my $r = new_recur();
    stored_state($r);
    $out{kind_is_recurrence} = $r->is_recur() ? JSON::PP::true : JSON::PP::false;
} elsif ($case eq 'create-from-date-context') {
    my $r = new_recur();
    my $source = $r->new_date();
    $out{source_parse_status} = $source->parse('2040-04-13 12:34:56');
    $out{source_value_before} = date_value($source);
    my $child = $source->new_recur('0:0:0:1:0:0:0');
    $out{child_kind_is_recurrence} = $child->is_recur() ? JSON::PP::true : JSON::PP::false;
    $out{child_frequency} = scalar $child->frequency();
    $out{source_value_after} = date_value($source);
    $out{child_error} = scalar $child->err();
} elsif ($case eq 'parse-serialized-and-recovery') {
    my $r = new_recur();
    $out{valid_parse_status} = $r->parse('0:0:0:1:0:0:0*FD1*2040-04-13 12:34:56*2040-04-13 00:00:00*2040-04-15 23:59:59');
    $out{state_after_valid_parse} = recurrence_state($r);
    my @valid_nth;
    for my $index (0, 1) {
        my ($date, $error) = $r->nth($index);
        push @valid_nth, { index => $index, date => date_value($date), lookup_error => $error, object_error => scalar $r->err() };
    }
    $out{nth_after_valid_parse} = \@valid_nth;
    $out{invalid_parse_status} = $r->parse('not a recurrence');
    $out{error_after_invalid} = scalar $r->err();
    $out{state_after_invalid_parse} = recurrence_state($r);
    $out{recovery_status} = $r->parse('0:0:0:1:0:0:0**2040-04-13 12:34:56*2040-04-13 00:00:00*2040-04-15 23:59:59');
    stored_state($r);
    nth_values($r, 0);
} elsif ($case eq 'field-read-replace') {
    my $r = new_recur();
    $out{reads_before_set} = {
        frequency => scalar $r->frequency(), start => date_value(scalar $r->start()),
        end => date_value(scalar $r->end()), modifiers => [ $r->modifiers() ],
    };
    $out{frequency_status} = $r->frequency('0:0:0:1:0:0:0');
    $out{start_status} = $r->start('2040-04-13 00:00:00');
    $out{end_status} = $r->end('2040-04-15 23:59:59');
    $out{base_status} = $r->basedate('2040-04-13 12:34:56');
    $out{modifiers_status} = $r->modifiers('FD1');
    $out{base_after_modifier_status} = $r->basedate('2040-04-13 12:34:56');
    $out{state_before_replacement} = recurrence_state($r);
    $out{replacement_frequency_status} = $r->frequency('0:0:0:2:0:0:0');
    stored_state($r);
} elsif ($case eq 'nth-missing-and-indexes') {
    my $r = new_recur();
    install_frequency($r, '0:1*0:31:0:0:0', '2040-01-31 12:34:56');
    nth_values($r, -1, 0, 1, 2);
    stored_state($r);
} elsif ($case eq 'navigation-and-bounds') {
    my $r = new_recur();
    install_frequency($r, '0:1*0:31:0:0:0', '2040-01-31 12:34:56');
    $out{start_status} = $r->start('2040-01-01 00:00:00');
    $out{end_status} = $r->end('2040-05-31 23:59:59');
    my @calls;
    for my $direction (qw(next next next prev prev)) {
        my ($date, $error) = $r->$direction();
        push @calls, { direction => $direction, date => date_value($date), lookup_error => $error, object_error => scalar $r->err() };
    }
    $out{navigation} = \@calls;
    stored_state($r);
} elsif ($case eq 'dates-temporary-range-and-empty-filter') {
    my $r = new_recur();
    install_frequency($r, '0:0:0:1:0:0:0', '2040-04-13 12:34:56');
    $out{start_status} = $r->start('2040-04-13 00:00:00');
    $out{end_status} = $r->end('2040-04-16 23:59:59');
    $out{temporary_dates} = [ map { date_value($_) } $r->dates('2040-04-14 00:00:00', '2040-04-15 23:59:59') ];
    $out{error_after_temporary_dates} = scalar $r->err();
    $out{stored_dates} = [ map { date_value($_) } $r->dates() ];
    $out{error_after_stored_dates} = scalar $r->err();
    stored_state($r);
    my $filtered = new_recur();
    install_frequency($filtered, '0:0:0:1:0:0:0', '2040-04-13 12:34:56');
    $out{filter_modifier_status} = $filtered->modifiers('NBD');
    $out{filter_base_status} = $filtered->basedate('2040-04-13 12:34:56');
    $out{empty_dates} = [ map { date_value($_) } $filtered->dates('2040-04-13 00:00:00', '2040-04-13 23:59:59') ];
    $out{empty_dates_error} = scalar $filtered->err();
} elsif ($case =~ /^functional-(dm5|dm6)-(description|endpoint)$/) {
    my ($backend, $mode) = ($1, $2);
    my $p = profile($backend);
    my $module = $backend eq 'dm5' ? 'Date::Manip::DM5' : 'Date::Manip::DM6';
    eval "require $module; 1" or die $@;
    $module->import();
    no strict 'refs';
    die 'wrong distribution' unless ${$module . '::VERSION'} eq '7.00';
    $out{profile} = $backend;
    $out{configuration_return} = Date_Init(@{$p->{configuration}});
    my $frequency = '0:0:0:1:0:0:0';
    if ($mode eq 'description') {
        $out{input} = { frequency => $frequency, result_mode => 'scalar description' };
        $out{scalar_result} = scalar ParseRecur($frequency);
    } else {
        my $base = '2040-04-13 12:34:56';
        my $end = '2040-04-15 12:34:56';
        $out{input} = { frequency => $frequency, base => $base, start => $base, end => $end, result_mode => 'list occurrences' };
        $out{dates} = [ ParseRecur($frequency, $base, $base, $end) ];
    }
} else {
    die "unknown case $case\n";
}

print JSON::PP->new->canonical->encode(\%out), "\n";
