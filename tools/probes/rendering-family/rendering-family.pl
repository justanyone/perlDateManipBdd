#!/usr/bin/env perl
# Original research probe. One requested public backend is loaded per process.
use strict;
use warnings;
use Config ();
use JSON::PP qw(decode_json encode_json);
use FindBin qw($Bin);
my $id = shift @ARGV // die "case ID required\n";
die "unexpected arguments\n" if @ARGV;
sub read_json { open my $f, '<', $_[0] or die "$!\n"; return decode_json(do { local $/; <$f> }); }
my $catalogue = read_json("$Bin/../../../docs/research/rendering-family/cases.json");
my ($case) = grep { $_->{case_id} eq $id } @{$catalogue->{cases}};
die "unknown case ID\n" unless $case;
my $profiles = read_json("$Bin/../../../docs/automation/reference-profiles.json");
my $kind = $case->{profile} =~ /^dm5/ ? 'dm5' : $case->{profile} eq 'dm6' ? 'dm6' : 'oo';
my ($fixture) = grep { $_->{name} eq $kind } @{$profiles->{profiles}};
die "missing fixture\n" unless $fixture;
my @warnings;
local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
my %out = (case_id=>$id, operation_id=>$case->{operation_id}, contract_ids=>$case->{contract_ids}, partition_ids=>$case->{partition_ids}, profile=>$case->{profile}, fixture_profile=>$fixture->{name}, request=>{date=>$case->{date},patterns=>$case->{patterns}}, perl_version=>"$^V", perl_archname=>$Config::Config{archname}, warnings=>\@warnings);
sub require_release { my ($v) = @_; die "wrong reference version: $v\n" unless defined($v) && $v eq '7.00'; }
sub run {
  my ($c) = @_;
  if ($kind eq 'oo') {
    require Date::Manip::Date;
    $out{distribution_version}=$Date::Manip::Date::VERSION; require_release($out{distribution_version});
    my @cfg=map { split /=/, $_, 2 } @{$fixture->{configuration}};
    push @cfg, ('Use_POSIX_Printf','1') if $c->{profile} eq 'oo-posix';
    push @cfg, ('TZ','America/New_York') if $c->{profile} eq 'oo-zone';
    my $d=Date::Manip::Date->new(); my $config_error=$d->config(@cfg); my $tz=$d->tz();
    $out{timezone_data}={tzdata=>$tz->tzdata(),tzcode=>$tz->tzcode()}; die "unexpected tzdata\n" unless $out{timezone_data}{tzdata} eq 'tzdata2026c';
    my $status=$d->parse($c->{date});
    return {configuration_diagnostic=>$config_error,parse_status=>$status,value=>scalar($d->value('local')),scalar_text=>scalar($d->printf(@{$c->{patterns}})),list_texts=>[$d->printf(@{$c->{patterns}})],error_state=>$d->err};
  }
  if ($kind eq 'dm6') {
    require Date::Manip::DM6;
    $out{distribution_version}=$Date::Manip::DM6::VERSION; require_release($out{distribution_version});
    my $config_error=Date::Manip::DM6::Date_Init(@{$fixture->{configuration}}); my $tz=$Date::Manip::DM6::dmt;
    $out{timezone_data}={tzdata=>$tz->tzdata(),tzcode=>$tz->tzcode()}; die "unexpected tzdata\n" unless $out{timezone_data}{tzdata} eq 'tzdata2026c';
    return {configuration_diagnostic=>$config_error,scalar_text=>scalar(Date::Manip::DM6::UnixDate($c->{date},@{$c->{patterns}})),list_texts=>[Date::Manip::DM6::UnixDate($c->{date},@{$c->{patterns}})]};
  }
  require Date::Manip::DM5;
  $out{distribution_version}=$Date::Manip::DM5::VERSION; require_release($out{distribution_version});
  my $config_error=Date::Manip::DM5::Date_Init(@{$fixture->{configuration}});
  return {configuration_diagnostic=>$config_error,scalar_text=>scalar(Date::Manip::DM5::UnixDate($c->{date},@{$c->{patterns}})),list_texts=>[Date::Manip::DM5::UnixDate($c->{date},@{$c->{patterns}})]};
}
my $stdout=''; my $ok;
{ open local *STDOUT, '>', \$stdout or die $!; $ok=eval { $out{raw_return}=run($case); 1 }; $out{exception}=$ok ? undef : "$@"; }
$out{call_stdout}=$stdout;
print JSON::PP->new->canonical->encode(\%out),"\n";
