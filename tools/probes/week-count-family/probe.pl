#!/usr/bin/env perl
# Original public-call observations, not expected-value calculations.
use strict;
use warnings;
use JSON::PP;
use FindBin qw($Bin);
use Config;
use Date::Manip::Base;
die 'wrong reference' unless $Date::Manip::Base::VERSION eq '7.00';
open my $fh, '<', "$Bin/../../../docs/research/week-count-family/cases.json" or die $!;
my $manifest = decode_json(do {local $/; <$fh>});
my @rows;
for my $case (@{$manifest->{cases}}) {
    my $base = Date::Manip::Base->new;
    my @warnings;
    local $SIG{__WARN__} = sub {push @warnings, "$_[0]"};
    $base->config(firstday => $case->{first_day}, week1ofyear => $case->{rule});
    die 'configuration warning' if @warnings;
    my @results;
    for my $year (@{$manifest->{years}}) {
        my %row = (year => $year);
        my $completed = eval {
            $row{first} = scalar $base->weeks_in_year($year);
            $row{repeated} = scalar $base->weeks_in_year($year);
            $row{listed} = [$base->weeks_in_year($year)];
            1;
        };
        die $@ unless $completed;
        push @results, \%row;
    }
    push @rows, {request => $case, results => \@results, warnings => \@warnings};
}
my %loaded = map {$_ => $INC{$_}} grep {m{^Date/Manip(?:/|\.pm$)}} keys %INC;
print JSON::PP->new->canonical->encode({version=>$Date::Manip::Base::VERSION,
    perl_version=>"$^V", perl_archname=>$Config{archname}, loaded=>\%loaded,
    observations=>\@rows}), "\n";
