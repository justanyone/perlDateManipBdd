#!/usr/bin/env perl
# Original reference probe for public year/day conversion entrypoints.
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
    open my $fh, '<', $path or die "$path: $!";
    return decode_json(do { local $/; <$fh> });
}

sub native_type {
    my ($value) = @_;
    return 'undefined' unless defined $value;
    return ref($value) || 'scalar';
}

sub capture {
    my ($context, $code) = @_;
    my (@warnings, $exception, $scalar, @list);
    my $stdout = '';
    my $completed;
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
        stdout => $stdout,
        warnings => \@warnings,
    );
    if ($completed && $context eq 'list') {
        $record{return} = \@list;
        $record{return_type} = 'list';
        $record{return_count} = scalar @list;
        $record{return_element_types} = [ map { native_type($_) } @list ];
    } elsif ($completed) {
        $record{return} = $scalar;
        $record{return_type} = native_type($scalar);
    }
    return \%record;
}

sub decode_arguments {
    my ($spec) = @_;
    my @args;
    for my $item (@$spec) {
        my $type = $item->{type};
        if ($type eq 'absent') {
            push @args, undef;
        } elsif ($type eq 'field-list') {
            push @args, [ @{$item->{value}} ];
        } elsif ($type eq 'number' || $type eq 'text') {
            push @args, $item->{value};
        } else {
            die "unsupported argument specification\n";
        }
    }
    return @args;
}

my $manifest = read_json("$root/docs/research/year-day-conversion-family/cases.json");
my ($case) = grep { $_->{case_id} eq $case_id } @{$manifest->{cases}};
die "unknown case ID\n" unless $case;
my $profiles = read_json("$root/docs/automation/reference-profiles.json");
my $fixture_name = $case->{profile} eq 'base' ? 'oo' : $case->{profile};
my ($fixture) = grep { $_->{name} eq $fixture_name } @{$profiles->{profiles}};
die "missing reference profile\n" unless $fixture;

my %module_for = (
    base => 'Date::Manip::Base',
    dm6 => 'Date::Manip::DM6',
    dm5 => 'Date::Manip::DM5',
);
my $profile = $case->{profile};
my $module = $module_for{$profile} // die "unknown profile\n";
my (@load_warnings, $load_exception, $load_completed);
my $load_stdout = '';
{
    local $SIG{__WARN__} = sub { push @load_warnings, $_[0] };
    open local *STDOUT, '>', \$load_stdout or die $!;
    $load_completed = $profile eq 'base'
        ? eval 'require Date::Manip::Date; require Date::Manip::Base; 1'
        : eval "require $module; 1";
    $load_exception = $load_completed ? undef : "$@";
}
die "module load failed: $load_exception" unless $load_completed;

my %output = (
    case_id => $case_id,
    operation_id => $case->{operation_id},
    profile => $profile,
    group => $case->{group},
    classification => $case->{classification},
    argument_spec => $case->{argument_spec},
    request => $case->{request},
    module => $module,
    perl_version => "$^V",
    perl_archname => $Config::Config{archname},
    distribution_version => do { no strict 'refs'; ${$module . '::VERSION'} },
    module_load => {
        call_completed => JSON::PP::true,
        exception => undef,
        stdout => $load_stdout,
        warnings => \@load_warnings,
    },
);
$output{yy_to_yyyy} = $case->{yy_to_yyyy} if exists $case->{yy_to_yyyy};
die "wrong Date-Manip version\n" unless $output{distribution_version} eq '7.00';

my @configuration = @{$fixture->{configuration}};
push @configuration, 'YYtoYYYY=' . $case->{yy_to_yyyy} if exists $case->{yy_to_yyyy};
$output{fixture_profile} = $fixture;
$output{requested_configuration} = [@configuration];
my ($receiver, $function);

if ($profile eq 'base') {
    my $date;
    $output{constructor} = capture('scalar', sub {
        $date = Date::Manip::Date->new();
        return ref($date);
    });
    die "constructor did not return a date object\n" unless $date;
    $output{configuration} = capture('scalar', sub {
        my @pairs = map { split /=/, $_, 2 } @configuration;
        return $date->config(@pairs);
    });
    $output{version} = capture('scalar', sub { return $date->version() });
    my $tz;
    $output{zone_service} = capture('scalar', sub {
        $tz = $date->tz();
        return ref($tz);
    });
    $output{tzdata} = capture('scalar', sub { return $tz->tzdata() });
    $output{tzcode} = capture('scalar', sub { return $tz->tzcode() });
    $output{base_service} = capture('scalar', sub {
        $receiver = $date->base();
        return ref($receiver);
    });
    die "base service was not returned\n" unless $receiver;
    $output{callable} = 'day_of_year';
} else {
    my $initializer = $module->can('Date_Init') // die "missing public initializer\n";
    $output{configuration} = capture('scalar', sub { return $initializer->(@configuration) });
    my $version = $module->can('DateManipVersion') // die "missing public version call\n";
    $output{version} = capture('scalar', sub { return $version->() });
    my $callable = $case->{operation_id} eq 'calendar.day-of-year'
        ? 'Date_DayOfYear' : 'Date_NthDayOfYear';
    $function = $module->can($callable) // die "missing public conversion call\n";
    $output{callable} = $callable;
}

my @arguments = decode_arguments($case->{argument_spec});
for my $context (qw(scalar list)) {
    my %sequence;
    if ($receiver) {
        $sequence{error_before} = capture('scalar', sub { return $receiver->err() });
    }
    $sequence{call} = capture($context, sub {
        return $receiver
            ? $receiver->day_of_year(@arguments)
            : $function->(@arguments);
    });
    if ($receiver) {
        $sequence{error_after} = capture('scalar', sub { return $receiver->err() });
    }
    $output{$context} = \%sequence;
}

$output{loaded_module_path} = $profile eq 'base'
    ? $INC{'Date/Manip/Base.pm'}
    : $INC{join('/', split(/::/, $module)) . '.pm'};
print JSON::PP->new->canonical->encode(\%output), "\n";
