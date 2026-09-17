#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP;
use FindBin qw($Bin);
sub read_json { open my $fh,'<',$_[0] or die $!; return decode_json(do {local $/;<$fh>}); }
my $root="$Bin/../../..";
my $id=shift @ARGV // die 'case required';
my $manifest=read_json("$root/docs/research/config-files-family/cases.json");
my ($case)=grep { $_->{case_id} eq $id } @{$manifest->{cases}};
die 'unknown case' unless $case;
my $profiles=read_json("$root/docs/automation/reference-profiles.json");
my ($profile)=grep { $_->{name} eq $case->{profile} } @{$profiles->{profiles}};
my %out=(case_id=>$id,request=>$case,perl_version=>"$^V");
my (@warnings,$stdout);
{
 local $SIG{__WARN__}=sub {push @warnings,"$_[0]"};
 open local *STDOUT,'>',\$stdout or die $!;
 my $ok=eval {
  my $date;
  if ($case->{profile} eq 'oo') {
   require Date::Manip::Date;
   die 'wrong reference' unless $Date::Manip::Date::VERSION eq '7.00';
   $date=Date::Manip::Date->new();
   $out{setup_return}=$date->config(map {split /=/,$_,2} @{$profile->{configuration}});
   $out{setup_error}=$date->err();
   die 'setup failed' if $out{setup_return} || $out{setup_error};
   $out{backend_version}=$date->version();
  } else {
   require Date::Manip::DM6;
   die 'wrong reference' unless $Date::Manip::DM6::VERSION eq '7.00';
   $out{setup_return}=Date::Manip::DM6::Date_Init(@{$profile->{configuration}});
   die 'setup failed' if $out{setup_return};
   $out{backend_version}=Date::Manip::DM6::DateManipVersion();
  }
  my $configured=eval {
   if ($date) {$out{configuration_return}=$date->config(map {@$_} @{$case->{settings}});}
   else {$out{configuration_return}=Date::Manip::DM6::Date_Init(map {join '=',@$_} @{$case->{settings}});}
   1;
  };
  $out{configuration_exception}=$configured?undef:"$@";
  $out{configuration_warnings}=[@warnings];
  @warnings=();
  # Explicitly observe state after a configuration exception as well as success.
  if ($date) {
   $out{error_after_configuration}=$date->err();
   $out{date_order}=$date->get_config('dateformat');
   $out{parse_status}=$date->parse($case->{parse_text});
   $out{parse_error}=$date->err();
   if (defined($out{parse_status}) && "$out{parse_status}" eq '0') {
    $out{value}=scalar $date->value();$out{error_after_value}=$date->err();
   }
  } else {
   $out{value}=Date::Manip::DM6::ParseDate($case->{parse_text});
  }
  1;
 };
 $out{exception}=$ok?undef:"$@";
}
$out{later_warnings}=\@warnings;$out{call_stdout}=$stdout//'';
print JSON::PP->new->canonical->ascii->encode(\%out),"\n";
