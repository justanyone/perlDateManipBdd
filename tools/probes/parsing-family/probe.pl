#!/usr/bin/env perl
# Original input/output research; this is not a conformance expectation generator.
use strict;
use warnings;
use JSON::PP;
use Config ();
use FindBin qw($Bin);
sub read_json {
    open my $fh, '<', $_[0] or die $!;
    return decode_json(do { local $/; <$fh> });
}
my $root = "$Bin/../../..";
my $id = shift @ARGV // die "case ID required";
die 'unexpected arguments' if @ARGV;
my $cases = read_json("$root/docs/research/parsing-family/cases.json");
my ($case) = grep { $_->{case_id} eq $id } @{$cases->{cases}};
die 'unknown case' unless $case;
my $profiles = read_json("$root/docs/automation/reference-profiles.json");
my ($fixture) = grep { $_->{name} eq $case->{profile} } @{$profiles->{profiles}};
die 'missing fixture' unless $fixture;
my @warnings;
local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
my %out = (case_id=>$id, profile=>$case->{profile}, request=>$case,
    perl_version=>"$^V", perl_archname=>$Config::Config{archname}, warnings=>\@warnings);
my @configuration = (@{$fixture->{configuration}}, @{$case->{configuration}});
my $stdout = '';
{
    open local *STDOUT, '>', \$stdout or die $!;
    my $stage = 'load';
    my $ok = eval {
        if ($case->{profile} eq 'oo') {
            require Date::Manip::Date;
            $out{distribution_version} = $Date::Manip::Date::VERSION;
            die 'wrong distribution' unless $out{distribution_version} eq '7.00';
            my $d = Date::Manip::Date->new();
            $stage = 'configuration';
            $out{configuration_return} = $d->config(map { split /=/, $_, 2 } @configuration);
            $out{error_after_configuration} = scalar $d->err();
            $out{tzdata} = scalar $d->tz->tzdata();
            die 'wrong tzdata' unless $out{tzdata} eq 'tzdata2026c';
            $stage = 'parse';
            $out{status} = $d->parse($case->{text}, @{$case->{options}});
            $out{error_after_parse} = scalar $d->err();
            # A failed parse has no valid value; reading it would create a new error.
            if (!$out{status}) {
                $out{value} = scalar $d->value('local');
                $out{zone} = scalar $d->tz()->zone();
                $out{error_after_value_read} = scalar $d->err();
            }
        } else {
            my $module = $case->{profile} eq 'dm5' ? 'Date::Manip::DM5' : 'Date::Manip::DM6';
            eval "require $module; 1" or die $@;
            no strict 'refs';
            $out{distribution_version} = ${$module.'::VERSION'};
            die 'wrong distribution' unless $out{distribution_version} eq '7.00';
            $stage = 'configuration';
            $out{configuration_return} = &{$module.'::Date_Init'}(@configuration);
            $stage = 'parse';
            $out{value} = &{$module.'::ParseDateString'}($case->{text}, @{$case->{options}});
        }
        1;
    };
    $out{exception} = $ok ? undef : "$@";
    $out{exception_stage} = $ok ? undef : $stage;
}
$out{call_stdout} = $stdout;
print JSON::PP->new->canonical->encode(\%out), "\n";
