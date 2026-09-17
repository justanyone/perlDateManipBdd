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

sub lookup_row {
    my ($r, $index) = @_;
    my ($date, $error) = $r->nth($index);
    return { index => $index, date => date_value($date), lookup_error => $error, object_error => scalar $r->err() };
}

sub frequency_shape {
    my ($label, $frequency, $base) = @_;
    my $r = new_recur();
    my %row = (label => $label, frequency_text => $frequency);
    $row{frequency_status} = $r->frequency($frequency);
    $row{base_input} = $base if defined $base;
    $row{base_status} = $r->basedate($base) if defined $base && !$row{frequency_status};
    $row{state} = recurrence_state($r);
    $row{nth_zero} = lookup_row($r, 0) unless $row{frequency_status};
    return \%row;
}

sub setter_row {
    my ($field, $carrier) = @_;
    my $r = new_recur();
    my $date_text = $field eq 'start' ? '2040-04-13 00:00:00' :
                    $field eq 'end' ? '2040-04-15 23:59:59' :
                    '2040-04-13 12:34:56';
    my $value = $date_text;
    if ($carrier eq 'typed-date') {
        $value = $r->new_date();
        my $parse_status = $value->parse($date_text);
        die "typed date setup failed for $field\n" if $parse_status;
    }
    my %row = (field => $field, carrier => $carrier, input => $date_text);
    $row{frequency_status} = $r->frequency('0:0:0:1:0:0:0');
    $row{setter_status} = $r->$field($value);
    $row{state} = recurrence_state($r);
    return \%row;
}

if ($case =~ /^modifier-(pd|pt|nd|nt|wd|fd|bd|fw|bw|cwd|cwn|cwp|nwd|pwd|dwd|ibd|nbd|iw|nw|easter)$/) {
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
} elsif ($case eq 'frequency-numeric-and-written-shapes') {
    $out{shapes} = [
        frequency_shape('daily-two-day-interval', '0:0:0:2:0:0:0', '2040-04-13 12:34:56'),
        frequency_shape('monthly-selected-day', '0:1*0:31:0:0:0', '2040-01-31 12:34:56'),
        frequency_shape('weekly-selected-weekday', '0:0:1*5:0:0:0', '2040-04-13 12:34:56'),
        frequency_shape('fixed-calendar-selection', '*2040:4:0:13:12:34:56', undef),
        frequency_shape('written-weekday-in-month', 'every Tuesday in June 2040', undef),
        frequency_shape('written-ordinal-weekday', '2nd Tuesday in June 2040', undef),
        frequency_shape('written-last-day', 'last day of every month in 2040', undef),
        frequency_shape('written-ordinal-day-interval', 'every 2nd day in 2040', undef),
    ];
} elsif ($case eq 'frequency-invalid-and-recovery') {
    my $r = new_recur();
    $out{valid_status} = $r->frequency('0:0:0:1:0:0:0');
    $out{state_after_valid} = recurrence_state($r);
    $out{invalid_frequency_status} = $r->frequency('0:0:0:bad:0:0:0');
    $out{state_after_invalid_frequency} = recurrence_state($r);
    $out{recovery_status} = $r->frequency('0:0:0:2:0:0:0');
    $out{state_after_recovery} = recurrence_state($r);
    my @invalid_frequencies;
    for my $text ('0:0:0:bad:0:0:0', '0:0:0:1:0:0', '0:0*0:1*0:0:0:0', '0:0:1*9:0:0:0') {
        my $item = new_recur();
        my $status = $item->frequency($text);
        push @invalid_frequencies, { frequency_text => $text, status => $status, state => recurrence_state($item) };
    }
    $out{invalid_frequency_rows} = \@invalid_frequencies;
    my @invalids;
    for my $field (qw(start end basedate)) {
        my $item = new_recur();
        $item->frequency('0:0:0:1:0:0:0');
        my $status = $item->$field('not a date');
        push @invalids, { field => $field, status => $status, state => recurrence_state($item) };
    }
    $out{invalid_date_fields} = \@invalids;
} elsif ($case eq 'typed-setter-equivalence') {
    my @rows;
    for my $field (qw(start end basedate)) {
        push @rows, setter_row($field, 'text'), setter_row($field, 'typed-date');
    }
    $out{setter_rows} = \@rows;
} elsif ($case eq 'range-and-attempt-limits') {
    $out{input} = {
        recur_range => 'day', range_frequency => '0:0:0:1:0:0:0',
        max_recur_attempts => 1, impossible_frequency => '1*2:0:30:0:0:0',
        requested_anchor => '2040-02-01 00:00:00', operation => 'next',
    };
    my $range = new_recur();
    $out{recur_range_config_status} = $range->config('RecurRange', 'day');
    $out{range_parse_status} = $range->parse('0:0:0:1:0:0:0');
    $out{range_state} = recurrence_state($range);
    $out{range_dates} = [ map { date_value($_) } $range->dates() ];
    $out{range_dates_error} = scalar $range->err();
    my $attempt = new_recur();
    $out{max_attempts_config_status} = $attempt->config('MaxRecurAttempts', '1');
    $out{attempt_frequency_status} = $attempt->frequency('1*2:0:30:0:0:0');
    $out{attempt_base_status} = $attempt->basedate('2040-02-01 00:00:00');
    my ($attempt_date, $attempt_error);
    my $attempt_completed = eval { ($attempt_date, $attempt_error) = $attempt->next(); 1 };
    my $attempt_exception = $attempt_completed ? undef : $@;
    my %attempt_next = (
        call_completed => $attempt_completed ? JSON::PP::true : JSON::PP::false,
        object_error => scalar $attempt->err(), exception => $attempt_exception,
    );
    if ($attempt_completed) {
        $attempt_next{date} = date_value($attempt_date);
        $attempt_next{lookup_error} = $attempt_error;
    }
    $out{attempt_next} = \%attempt_next;
    $out{attempt_state} = recurrence_state($attempt);
} elsif ($case eq 'modifier-boundaries-order-and-recovery') {
    my @boundary_rows;
    for my $token (qw(PD0 PD8 FD0 FW0 IW0 IW8)) {
        my $r = new_recur();
        my %row = (modifier => $token);
        $row{frequency_status} = $r->frequency('0:0:0:1:0:0:0');
        $row{modifier_status} = $r->modifiers($token);
        $row{base_status} = $r->basedate('2040-04-13 12:34:56');
        $row{state} = recurrence_state($r);
        $row{nth_zero} = lookup_row($r, 0);
        push @boundary_rows, \%row;
    }
    $out{modifier_boundaries} = \@boundary_rows;
    my @order_rows;
    for my $label ('move-then-filter', 'filter-then-move') {
        my $r = new_recur();
        $r->frequency('0:0:0:1:0:0:0');
        my @tokens = $label eq 'move-then-filter' ? ('fd1', 'ibd') : ('ibd', 'fd1');
        my $status = $r->modifiers(@tokens);
        my $base_status = $r->basedate('2040-04-13 12:34:56');
        push @order_rows, { order => \@tokens, modifier_status => $status, base_status => $base_status, state => recurrence_state($r), nth_zero => lookup_row($r, 0) };
    }
    $out{modifier_order} = \@order_rows;
    my $recovery = new_recur();
    $recovery->frequency('0:0:0:1:0:0:0');
    $out{initial_modifier_status} = $recovery->modifiers('FD1');
    $out{initial_base_status} = $recovery->basedate('2040-04-13 12:34:56');
    $out{state_before_rejected_modifier} = recurrence_state($recovery);
    $out{append_modifier_status} = $recovery->modifiers('+', 'nd2');
    $out{append_base_status} = $recovery->basedate('2040-04-13 12:34:56');
    $out{state_after_append} = recurrence_state($recovery);
    $out{append_nth_zero} = lookup_row($recovery, 0);
    $out{rejected_modifier_status} = $recovery->modifiers('unknown');
    $out{state_after_rejected_modifier} = recurrence_state($recovery);
    $out{recovery_modifier_status} = $recovery->modifiers('BD1');
    $out{recovery_base_status} = $recovery->basedate('2040-04-13 12:34:56');
    $out{state_after_modifier_recovery} = recurrence_state($recovery);
    $out{recovery_nth_zero} = lookup_row($recovery, 0);
    $out{full_recovery_frequency_status} = $recovery->frequency('0:0:0:1:0:0:0');
    $out{full_recovery_modifier_status} = $recovery->modifiers('bd1');
    $out{full_recovery_base_status} = $recovery->basedate('2040-04-13 12:34:56');
    $out{state_after_full_recovery} = recurrence_state($recovery);
    $out{full_recovery_nth_zero} = lookup_row($recovery, 0);
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
