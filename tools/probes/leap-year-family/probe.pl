#!/usr/bin/env perl
# Original reference-research probe for public leap-year entrypoints.
use strict;
use warnings;
use Config ();
use FindBin qw($Bin);
use JSON::PP;

my $case_id = shift @ARGV // die "case ID required\n";
die "unexpected arguments\n" if @ARGV;
my $root = "$Bin/../../..";

sub read_json {
    my ($path) = @_;
    open my $fh, '<', $path or die $!;
    return decode_json(do { local $/; <$fh> });
}

my $manifest = read_json("$root/docs/research/leap-year-family/cases.json");
my ($case) = grep { $_->{case_id} eq $case_id } @{$manifest->{cases}};
die "unknown case ID\n" unless $case;
my $profiles = read_json("$root/docs/automation/reference-profiles.json");
my $fixture_name = $case->{profile} eq 'base' ? 'oo' : $case->{profile};
my ($fixture) = grep { $_->{name} eq $fixture_name } @{$profiles->{profiles}};
die "unknown reference profile\n" unless $fixture;

sub value_type {
    my ($value) = @_;
    return 'undefined' unless defined $value;
    return ref($value) || 'scalar';
}

sub capture_call {
    my ($context, $code) = @_;
    my (@warnings, $exception, $completed, $scalar, @list);
    my $stdout = '';
    {
        local $SIG{__WARN__} = sub { push @warnings, $_[0] };
        open local *STDOUT, '>', \$stdout or die $!;
        $completed = eval {
            if ($context eq 'list') {
                @list = $code->();
            } else {
                $scalar = scalar $code->();
            }
            1;
        };
        $exception = $completed ? undef : "$@";
    }
    my %record = (
        call_completed => $completed ? JSON::PP::true : JSON::PP::false,
        context => $context,
        exception => $exception,
        warnings => \@warnings,
        stdout => $stdout,
    );
    if ($completed && $context eq 'list') {
        $record{return} = \@list;
        $record{return_type} = 'list';
        $record{return_count} = scalar @list;
        $record{return_element_types} = [ map { value_type($_) } @list ];
    } elsif ($completed) {
        $record{return} = $scalar;
        $record{return_type} = value_type($scalar);
    }
    return \%record;
}

my %module_for = (
    base => 'Date::Manip::Base',
    dm6  => 'Date::Manip::DM6',
    dm5  => 'Date::Manip::DM5',
);
my %method_for = (
    base => 'leapyear',
    dm6  => 'Date_LeapYear',
    dm5  => 'Date_LeapYear',
);
my $profile = $case->{profile};
my $module = $module_for{$profile} // die "unknown binding profile\n";
my (@load_warnings, $load_exception, $load_completed);
my $load_stdout = '';
{
    local $SIG{__WARN__} = sub { push @load_warnings, $_[0] };
    open local *STDOUT, '>', \$load_stdout or die $!;
    $load_completed = $profile eq 'base'
        ? eval "require $module; require Date::Manip::Date; 1"
        : eval "require $module; 1";
    $load_exception = $load_completed ? undef : "$@";
}

my %out = (
    case_id => $case_id,
    operation_id => $case->{operation_id},
    profile => $profile,
    group => $case->{group},
    classification => $case->{classification},
    input => $case->{input},
    perl_version => "$^V",
    perl_archname => $Config::Config{archname},
    distribution_version => do { no strict 'refs'; ${$module . '::VERSION'} },
    module => $module,
    callable => $method_for{$profile},
    module_load => {
        call_completed => $load_completed ? JSON::PP::true : JSON::PP::false,
        exception => $load_exception,
        warnings => \@load_warnings,
        stdout => $load_stdout,
    },
);
die "module load failed\n" unless $load_completed;
die "wrong Date-Manip version\n" unless $out{distribution_version} eq '7.00';

my @configuration = @{$fixture->{configuration}};
push @configuration, 'YYtoYYYY=' . $case->{yy_to_yyyy} if exists $case->{yy_to_yyyy};
$out{yy_to_yyyy} = $case->{yy_to_yyyy} if exists $case->{yy_to_yyyy};
my ($receiver, $function);
if ($profile eq 'base') {
    my $date = Date::Manip::Date->new();
    $out{configuration} = capture_call('scalar', sub {
        my @pairs = map { split /=/, $_, 2 } @configuration;
        return $date->config(@pairs);
    });
    die "wrong tzdata\n" unless $date->tz->tzdata eq 'tzdata2026c';
    $receiver = $date->base();
} else {
    my $initializer = $module->can('Date_Init') // die "missing public initializer\n";
    $out{configuration} = capture_call('scalar', sub { return $initializer->(@configuration) });
    $function = $module->can($method_for{$profile}) // die "missing public leap-year callable\n";
}

sub invoke {
    my ($context, $shape, $value) = @_;
    my @arguments = $shape eq 'omitted' ? () :
                    $shape eq 'undefined' ? (undef) : ($value);
    my (@warnings, $exception, $completed, $scalar, @list);
    my $stdout = '';
    {
        local $SIG{__WARN__} = sub { push @warnings, $_[0] };
        open local *STDOUT, '>', \$stdout or die $!;
        $completed = eval {
            if ($context eq 'list') {
                @list = $receiver
                    ? $receiver->leapyear(@arguments)
                    : $function->(@arguments);
            } else {
                $scalar = $receiver
                    ? scalar $receiver->leapyear(@arguments)
                    : scalar $function->(@arguments);
            }
            1;
        };
        $exception = $completed ? undef : "$@";
    }
    my %result = (
        call_completed => $completed ? JSON::PP::true : JSON::PP::false,
        context => $context,
        exception => $exception,
        warnings => \@warnings,
        stdout => $stdout,
    );
    if ($completed && $context eq 'list') {
        $result{return} = \@list;
        $result{return_type} = 'list';
        $result{return_count} = scalar @list;
        $result{return_element_types} = [ map { value_type($_) } @list ];
    } elsif ($completed) {
        $result{return} = $scalar;
        $result{return_type} = value_type($scalar);
    }
    return \%result;
}

if ($case->{input}{shape} eq 'inclusive-range') {
    my @years;
    for my $year ($case->{input}{first} .. $case->{input}{last}) {
        push @years, {
            year => $year,
            scalar => invoke('scalar', 'number', $year),
            list => invoke('list', 'number', $year),
        };
    }
    $out{years} = \@years;
} else {
    $out{scalar} = invoke('scalar', $case->{input}{shape}, $case->{input}{value});
    $out{list} = invoke('list', $case->{input}{shape}, $case->{input}{value});
}

$out{object_error_after} = scalar $receiver->err() if $receiver;
$out{loaded_module_path} = $INC{join('/', split(/::/, $module)) . '.pm'};
print JSON::PP->new->canonical->encode(\%out), "\n";
