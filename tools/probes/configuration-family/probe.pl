#!/usr/bin/env perl
# Original research probe.  It uses public Date::Manip routes and records raw channels.
use strict;
use warnings;
use JSON::PP qw(decode_json);
use Config ();
use FindBin qw($Bin);

my $id = shift @ARGV // die "case ID required\n";
die "unexpected arguments\n" if @ARGV;
sub read_json { open my $fh, '<', $_[0] or die "$!\n"; return decode_json(do { local $/; <$fh> }); }
my $cases = read_json("$Bin/../../../docs/research/configuration-family/cases.json");
my ($case) = grep { $_->{case_id} eq $id } @{$cases->{cases}};
die "unknown case\n" unless $case;
my $profiles = read_json("$Bin/../../../docs/automation/reference-profiles.json");
my ($profile) = grep { $_->{name} eq $case->{profile} } @{$profiles->{profiles}};
die "unknown profile\n" unless $profile;
my @warnings; local $SIG{__WARN__}=sub { push @warnings, "$_[0]" };
my %out=(case_id=>$id, profile=>$case->{profile}, operation_id=>$case->{operation_id}, contract_ids=>$case->{contract_ids}, partition_ids=>$case->{partition_ids}, request=>$case->{request}, perl_version=>"$^V", perl_archname=>$Config::Config{archname}, warnings=>\@warnings);
my $module=$case->{profile} eq 'dm5' ? 'Date::Manip::DM5' : $case->{profile} eq 'dm6' ? 'Date::Manip::DM6' : 'Date::Manip::Date';
eval "require $module; 1" or die $@;
{ no strict 'refs'; $out{distribution_version}=${$module.'::VERSION'}; }
die "wrong reference version\n" unless $out{distribution_version} eq '7.00';
sub date_with_profile { my $d=Date::Manip::Date->new(); my @p=map { split /=/, $_,2 } @{$profile->{configuration}}; $d->config(@p); return $d; }
# A configuration snapshot must not ask an unset value for its date: that query sets
# the receiver error and would turn the observer into the thing being observed.
sub snap { my ($o)=@_; my $error_before_reads=$o->err; return { class=>ref($o), error_before_reads=>$error_before_reads, config_names=>[ sort $o->get_config ] }; }
sub run {
 my $r=$case->{request};
 if ($case->{operation_id} eq 'config.apply-settings') {
   if ($case->{profile} eq 'dm6' || $case->{profile} eq 'dm5') { my $m=$case->{profile} eq 'dm5' ? 'Date::Manip::DM5' : 'Date::Manip::DM6'; no strict 'refs'; my $f=$m.'::Date_Init'; my $setup=&{$f}(@{$profile->{configuration}}); $out{setup_return}=$setup; my $v=&{$f}(map { $_->[0].'='.$_->[1] } @{$r->{settings}}); return {initializer_return=>$v}; }
   my $d=date_with_profile(); my $before=snap($d); my $return=$d->config(map { @$_ } @{$r->{settings}}); return {return=>$return,before=>$before,after=>snap($d), queried=>[ map { [$_, scalar $d->get_config($_)] } @{$r->{read}//[]} ]};
 }
 if ($case->{operation_id} eq 'config.read-settings') { my $d=date_with_profile(); $d->config(map { @$_ } @{$r->{settings}//[]}); my @ask=@{$r->{names}//[]}; return { scalar=>scalar $d->get_config(@ask), list=>[ $d->get_config(@ask) ], error=>$d->err }; }
 if ($case->{operation_id} eq 'error.read-state') { my $d=date_with_profile(); my $before=$d->err; my $status=$d->parse($r->{bad_text}); my $after=$d->err; my $clear=$d->err($r->{clear}); return {before=>$before,status=>$status,after=>$after,clear_return=>$clear,post_clear=>$d->err}; }
 if ($case->{operation_id} eq 'object.kind-check') { my $d=date_with_profile(); my $delta=$d->new_delta(); my $recur=$d->new_recur(); return {date=>[map { $d->$_() } qw(is_date is_delta is_recur)],delta=>[map { $delta->$_() } qw(is_date is_delta is_recur)],recur=>[map { $recur->$_() } qw(is_date is_delta is_recur)]}; }
 if ($case->{operation_id} eq 'context.create') { my $d=date_with_profile(); $d->config(DateFormat=>'US'); my $derived=$d->new_config(undef,[DateFormat=>'non-US']); $d->config(DateFormat=>'US'); return {source=>scalar($d->get_config('dateformat')),derived=>scalar($derived->get_config('dateformat')),derived_class=>ref($derived)}; }
 if ($case->{operation_id} eq 'context.base-service' || $case->{operation_id} eq 'context.zone-service') { my $d=date_with_profile(); my $delta=$d->new_delta(); my $method=$case->{operation_id} eq 'context.base-service' ? 'base' : 'tz'; return {date=>ref($d->$method()),delta=>ref($delta->$method())}; }
 die "unknown operation\n";
}
my $stdout=''; my $ok; { open local *STDOUT,'>',\$stdout or die $!; $ok=eval { $out{raw_return}=run();1 }; $out{exception}=$ok?undef:"$@"; }
$out{call_stdout}=$stdout; print JSON::PP->new->canonical->encode(\%out),"\n";
