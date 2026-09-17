#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP ();
use FindBin qw($Bin);
use Date::Manip::Date;
sub read_json {
 my ($path)=@_; open my $f,'<:raw',$path or die $!;
 return JSON::PP->new->decode(do {local $/; <$f>});
}
my $id=shift @ARGV // die 'case required'; die 'extra arguments' if @ARGV;
my $root="$Bin/../../..";
my $cases=read_json("$root/docs/research/input-history/cases.json");
my ($case)=grep {$_->{case_id} eq $id} @{$cases->{cases}}; die 'unknown case' unless $case;
my $profiles=read_json("$root/docs/automation/reference-profiles.json");
my ($profile)=grep {$_->{name} eq 'oo'} @{$profiles->{profiles}};
my (@warnings,$stdout,$exception,%out); $stdout='';
{
 local $SIG{__WARN__}=sub {push @warnings,"$_[0]"};
 local *STDOUT; open STDOUT,'>',\$stdout or die $!;
 eval {
  die 'wrong version' unless $Date::Manip::Date::VERSION eq '7.00';
  my $date=Date::Manip::Date->new;
  $out{configuration_return}=$date->config(map {split /=/, $_, 2} @{$profile->{configuration}});
  $out{configuration_error}=$date->err;
  die 'configuration failed' if $out{configuration_error};
  $out{version}=$date->version; $out{tzdata}=$date->tz->tzdata; $out{tzcode}=$date->tz->tzcode;
  if (defined $case->{initial}) {
   $out{initialization_status}=$date->parse($case->{initial});
   $out{initialization_error}=$date->err;
   die 'initialization failed' if $out{initialization_status};
  }
  $out{actions}=[];
  for my $action (@{$case->{actions}}) {
   my $method=$action->{method}; die 'unsupported public operation' unless $method =~ /\A(?:parse|parse_date|parse_time|parse_format|set|convert|err)\z/;
   my $result=$date->$method(@{$action->{arguments}});
   push @{$out{actions}}, {result=>$result,defined=>defined($result)?1:0,error=>$date->err};
  }
  $out{error_before_input}=$date->err;
  $out{input_scalar}=scalar $date->input;
  $out{error_after_scalar}=$date->err;
  $out{input_list}=[$date->input];
  $out{error_after_list}=$date->err;
  $out{value}=scalar $date->value;
  $out{error_after_value}=$date->err;
  1;
 } or $exception="$@";
}
print JSON::PP->new->canonical->encode({case_id=>$id,request=>$case,observation=>\%out,warnings=>\@warnings,call_stdout=>$stdout,exception=>$exception}),"\n";
