#!/usr/bin/env perl
# Original public-call research. No upstream algorithms or private calls.
use strict;
use warnings;
use JSON::PP;
use FindBin qw($Bin);
use Config;
use Date::Manip::Base;
my $root = "$Bin/../../..";
sub read_json {
    open my $fh, '<', $_[0] or die $!;
    return decode_json(do { local $/; <$fh> });
}
sub native_type {
    my ($value) = @_;
    return 'undefined' if !defined $value;
    return ref($value) || 'scalar';
}
my $manifest = read_json("$root/docs/research/week-count-edges/cases.json");
my ($id) = @ARGV;
die 'one case required' unless @ARGV == 1;
my ($case) = grep { $_->{case_id} eq $id } @{$manifest->{cases}};
die 'unknown case' unless $case;
my $profiles = read_json("$root/docs/automation/reference-profiles.json");
my ($profile) = grep { $_->{name} eq 'oo' } @{$profiles->{profiles}};
my $base = Date::Manip::Base->new;
die 'wrong reference' unless $Date::Manip::Base::VERSION eq '7.00';
sub capture {
    my ($call) = @_;
    my (@warnings, $stdout, $value, $exception, $ok);
    $stdout = '';
    {
        local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
        open my $out, '>', \$stdout or die $!;
        local *STDOUT = $out;
        $ok = eval { $value = $call->(); 1 };
        $exception = $ok ? undef : "$@";
    }
    my %row = (call_completed => $ok ? JSON::PP::true : JSON::PP::false,
               exception => $exception, warnings => \@warnings, stdout => $stdout);
    if ($ok) {
        $row{return} = $value;
        $row{return_type} = native_type($value);
    }
    return \%row;
}
my @configuration_entries = grep { !/^ForceDate=/ } @{$profile->{configuration}};
my @configuration = map { split /=/, $_, 2 } @configuration_entries;
my $setup = capture(sub { scalar $base->config(@configuration) });
die 'setup interrupted' unless $setup->{call_completed};
die 'setup diagnostics' if @{$setup->{warnings}} || $setup->{stdout} ne '';
my @steps;
for my $request (@{$case->{steps}}) {
    my @arguments = @{$request->{arguments}};
    my $before = $base->err;
    my $scalar = capture(sub {
        return scalar $base->config(@arguments) if $request->{operation} eq 'config';
        return scalar $base->weeks_in_year(@arguments);
    });
    my $after = $base->err;
    my %step = (request => $request, error_before => $before, scalar => $scalar, error_after => $after);
    if ($request->{operation} eq 'weeks_in_year') {
        $step{repeated_scalar} = capture(sub { scalar $base->weeks_in_year(@arguments) });
        $step{list} = capture(sub { [$base->weeks_in_year(@arguments)] });
    }
    push @steps, \%step;
}
my %loaded = map { $_ => $INC{$_} } grep { m{^Date/Manip(?:/|\.pm$)} } keys %INC;
print JSON::PP->new->canonical->encode({
    case_id => $id, request => $case, fixture => $profile,
    requested_configuration => \@configuration_entries, setup => $setup,
    version => $Date::Manip::Base::VERSION, reference => $profiles->{reference},
    perl_version => "$^V", os_name => $^O,
    perl_archname => $Config{archname}, loaded => \%loaded, steps => \@steps,
}), "\n";
