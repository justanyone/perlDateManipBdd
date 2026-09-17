#!/usr/bin/env perl
# Original public holiday-list observations.
use strict;
use warnings;
use JSON::PP;
use FindBin qw($Bin);
use Config;
use Date::Manip::Date;
sub read_json {
    open my $fh, '<', $_[0] or die $!;
    return decode_json(do { local $/; <$fh> });
}
sub capture {
    my ($call) = @_;
    my ($value, $ok, $exception, @warnings);
    my $stdout = '';
    {
        local $SIG{__WARN__} = sub {push @warnings, "$_[0]"};
        open my $out, '>', \$stdout or die $!;
        local *STDOUT = $out;
        $ok = eval {$value = $call->(); 1};
        $exception = $ok ? undef : "$@";
    }
    my %result = (call_completed => $ok ? JSON::PP::true : JSON::PP::false,
                  warnings => \@warnings, stdout => $stdout, exception => $exception);
    $result{return} = $value if $ok;
    return \%result;
}
my ($id) = @ARGV;
die 'one case required' unless @ARGV == 1;
my $manifest = read_json("$Bin/../../../docs/research/holiday-list-family/cases.json");
my ($case) = grep {$_->{case_id} eq $id} @{$manifest->{cases}};
die 'unknown case' unless $case;
my %fixtures = (standard => 'fixture.conf', leap => 'leap-fixture.conf', empty => 'empty-fixture.conf');
my $fixture_name = $fixtures{$case->{fixture}} or die 'unknown fixture';
die 'wrong reference' unless $Date::Manip::Date::VERSION eq '7.00';
my %contexts;
for my $context (qw(scalar list)) {
    my $date = Date::Manip::Date->new;
    my %record;
    $record{configuration} = capture(sub {scalar $date->config(ConfigFile => "$Bin/$fixture_name")});
    die 'fixture setup failed' unless $record{configuration}{call_completed};
    die 'fixture warning' if @{$record{configuration}{warnings}};
    if (defined $case->{receiver_input}) {
        $record{receiver_parse} = capture(sub {scalar $date->parse($case->{receiver_input})});
    }
    $record{error_before} = capture(sub {scalar $date->err});
    my @arguments = @{$case->{arguments}};
    my @dates;
    if ($context eq 'scalar') {
        $record{call} = capture(sub {scalar $date->list_holidays(@arguments)});
    } else {
        $record{call} = capture(sub {@dates = $date->list_holidays(@arguments); return scalar @dates});
        $record{call}{return_count} = delete $record{call}{return} if $record{call}{call_completed};
        $record{error_after} = capture(sub {scalar $date->err});
        if ($record{call}{call_completed}) {
            $record{returned_dates} = [map {
                my $value = $_;
                {class => ref($value),
                 error => capture(sub {scalar $value->err}),
                 text => capture(sub {scalar $value->value}),
                 labels => capture(sub {[$value->holiday]})}
            } @dates];
        }
    }
    $record{error_after} = capture(sub {scalar $date->err}) if $context eq 'scalar';
    $contexts{$context} = \%record;
}
my %loaded = map {$_ => $INC{$_}} grep {m{^Date/Manip(?:/|\.pm$)}} keys %INC;
print JSON::PP->new->canonical->encode({request => $case, contexts => \%contexts,
    version => $Date::Manip::Date::VERSION, perl_version => "$^V", perl_archname => $Config{archname},
    loaded => \%loaded}), "\n";
