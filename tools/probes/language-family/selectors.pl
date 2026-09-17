#!/usr/bin/env perl
# Original public language selection and localized parse/render research.
use strict;
use warnings;
use utf8;
use JSON::PP qw(decode_json);
use Config ();
use FindBin qw($Bin);
sub read_json {
    open my $fh, '<:raw', $_[0] or die $!;
    return decode_json(do { local $/; <$fh> });
}
my $selector = shift @ARGV // die "selector required\n";
die "unexpected arguments\n" if @ARGV;
my $family = "$Bin/../../../docs/research/language-family";
my $inventory = read_json("$family/selector-inventory.json");
my ($language) = grep {
    my $row = $_; scalar grep { $_ eq $selector } ($row->{canonical}, @{$row->{aliases}})
} @{$inventory->{languages}};
die "unknown selector\n" unless $language;
my $fixtures = read_json("$family/cases.json");
my ($fixture) = grep { $_->{id} eq $language->{id} } @{$fixtures->{languages}};
die "missing original language input\n" unless $fixture;
my %record = (
    selector => $selector, language_id => $language->{id}, canonical => $language->{canonical},
    profile => 'oo', contract_ids => ['config.apply-settings','config.read-settings','date.parse-text','date.read-value','date.render-pattern'],
    request => { text => $fixture->{utf8}{full_date}, pattern => '%A|%B' },
    perl_version => "$^V", perl_archname => $Config::Config{archname},
);
my (@warnings, $stdout);
{
    local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
    open local *STDOUT, '>:encoding(UTF-8)', \$stdout or die $!;
    my $ok = eval {
        require Date::Manip::Date;
        die 'wrong distribution' unless $Date::Manip::Date::VERSION eq '7.00';
        $record{distribution_version} = $Date::Manip::Date::VERSION;
        my $date = Date::Manip::Date->new();
        my @config = (Defaults=>1, ForceDate=>'2040-02-28-10:20:30,Etc/UTC',
                      Language=>$selector, Encoding=>'UTF-8', DateFormat=>'non-US');
        $record{configuration} = \@config;
        $record{configuration_return} = $date->config(@config);
        $record{configuration_error} = $date->err();
        die 'configuration failed' if $record{configuration_return} || $record{configuration_error} ne '';
        $record{timezone_data} = { tzdata => $date->tz()->tzdata(), tzcode => $date->tz()->tzcode() };
        die 'wrong timezone data' unless $record{timezone_data}{tzdata} eq 'tzdata2026c'
                                  && $record{timezone_data}{tzcode} eq 'tzcode2026c';
        $record{selected_language} = $date->get_config('language');
        $record{parse_status} = $date->parse($record{request}{text});
        $record{parse_error} = $date->err();
        $record{dependent_reads_executed} = JSON::PP::false;
        if (defined($record{parse_status}) && "$record{parse_status}" eq '0') {
            $record{dependent_reads_executed} = JSON::PP::true;
            $record{value} = scalar $date->value();
            $record{error_after_value} = $date->err();
            $record{rendered} = scalar $date->printf($record{request}{pattern});
            $record{error_after_render} = $date->err();
        }
        1;
    };
    $record{exception} = $ok ? undef : "$@";
}
$record{warnings} = \@warnings;
$record{call_stdout} = $stdout // '';
print JSON::PP->new->canonical->ascii->encode(\%record), "\n";
