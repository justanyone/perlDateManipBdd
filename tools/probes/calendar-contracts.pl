#!/usr/bin/env perl
# Original research driver. Calls public interfaces and records literal outputs.
use strict;
use warnings;
use JSON::PP;
use Config ();
use FindBin qw($Bin);
my $id=shift @ARGV // die "case ID required\n";
die "unexpected arguments\n" if @ARGV;
sub read_json {
    open my $f,'<',$_[0] or die $!;
    return decode_json(do {local $/; <$f>});
}
my $cases=read_json("$Bin/../../docs/research/inputs/calendar.json");
my ($case)=grep {$_->{case_id} eq $id} @{$cases->{cases}};
die "unknown case\n" unless $case;
my $fixtures=read_json("$Bin/../../docs/automation/reference-profiles.json");
my $profile=$case->{profile};
my $fixture_profile=$profile eq 'base' ? 'oo' : $profile;
my ($fixture)=grep {$_->{name} eq $fixture_profile} @{$fixtures->{profiles}};
my @warnings;
local $SIG{__WARN__}=sub {push @warnings,$_[0]};
my %out=(case_id=>$id,operation_id=>$case->{operation_id},profile=>$profile,
         perl_version=>"$^V",perl_archname=>$Config::Config{archname},warnings=>\@warnings);
my %modules=(base=>'Date::Manip::Base',oo=>'Date::Manip::Date',dm6=>'Date::Manip::DM6',dm5=>'Date::Manip::DM5');
my $module=$modules{$profile} // die 'unknown profile';
eval "require $module; 1" or die $@;
{
    no strict 'refs';
    $out{distribution_version}=${$module.'::VERSION'};
}
die 'wrong reference version' unless $out{distribution_version} eq '7.00';
my $receiver;
if ($profile eq 'base' || $profile eq 'oo') {
    require Date::Manip::Date;
    $receiver=Date::Manip::Date->new();
    my @config=map {split /=/, $_, 2} @{$fixture->{configuration}};
    $out{configuration_return}=$receiver->config(@config);
    $receiver=$receiver->base() if $profile eq 'base';
    $out{initial_parse_status}=$receiver->parse($case->{initial_date}) if exists $case->{initial_date};
} else {
    my $initializer=$module->can('Date_Init') // die 'missing initializer';
    $out{configuration_return}=$initializer->(@{$fixture->{configuration}});
}
my $method=$case->{method};
my @args=@{$case->{arguments}};
my $code=$module->can($method) // die 'missing public callable';
my $stdout='';
{
    open local *STDOUT,'>',\$stdout or die $!;
    my $ok=eval {
        if ($case->{return_context} eq 'list') {
            my @value=$receiver ? $receiver->$method(@args) : $code->(@args);
            $out{raw_return}={list=>\@value};
        } else {
            my $value=$receiver ? scalar($receiver->$method(@args)) : scalar($code->(@args));
            $out{raw_return}={scalar=>$value};
        }
        1;
    };
    $out{exception}=$ok ? undef : "$@";
}
$out{call_stdout}=$stdout;
if ($receiver) {
    $out{object_error}=$receiver->err();
    $out{date_after}=$receiver->value('local') if $profile eq 'oo';
}
print JSON::PP->new->canonical->encode(\%out),"\n";
