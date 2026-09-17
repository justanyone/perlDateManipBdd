#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP ();
use Config;
use FindBin qw($Bin);
use Date::Manip::Date;
my $path="$Bin/../../../docs/research/completeness-family/cases.json";
open my $f,'<:raw',$path or die $!;
my $fixture=JSON::PP->new->decode(do {local $/;<$f>});
my $id=shift @ARGV // die 'case required';die 'extra arguments' if @ARGV;
my ($case)=grep {$_->{case_id} eq $id} @{$fixture->{cases}};die 'unknown case' unless $case;
die 'wrong release' unless $Date::Manip::Date::VERSION eq '7.00';
my (@warnings,@results,%o); my $stdout='';my $exception;
{
 local $SIG{__WARN__}=sub {push @warnings,"$_[0]"}; local *STDOUT;open STDOUT,'>',\$stdout or die $!;
 eval {
  my $date=Date::Manip::Date->new;
  $o{configuration_return}=$date->config(map {split /=/,$_,2} @{$fixture->{configuration}});
  $o{configuration_error}=$date->err;
  die 'setup failed' if @warnings || $o{configuration_error};
  $o{version}=$date->version;$o{tzdata}=$date->tz->tzdata;$o{tzcode}=$date->tz->tzcode;
  $o{zone}=$date->tz->zone;
  if ($case->{parse_requested}) {$o{parse_status}=$date->parse($case->{parse_text});}
  $o{error_after_setup}=$date->err;
  for my $selector (@{$fixture->{selectors}}) {
   my $before=$date->err;my @call_warnings;my $ret;
   {local $SIG{__WARN__}=sub {push @call_warnings,"$_[0]"};$ret=$date->complete(@{$selector->{arguments}});}
   push @results,{request=>$selector,value=>$ret,defined=>defined($ret)?1:0,error_before=>$before,error_after=>$date->err,warnings=>\@call_warnings};
  }
  1;
 } or $exception="$@";
}
print JSON::PP->new->canonical->encode({case=>$case,configuration=>$fixture->{configuration},observation=>\%o,queries=>\@results,warnings=>\@warnings,stdout=>$stdout,exception=>$exception,perl=>"$^V",os=>$^O,arch=>$Config{archname},distribution=>$Date::Manip::Date::VERSION,loaded=>{map {$_=>$INC{$_}} grep {m{^Date/Manip}} keys %INC}}),"\n";
