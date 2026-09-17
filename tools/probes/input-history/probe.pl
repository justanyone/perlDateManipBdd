#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP ();
use FindBin qw($Bin);
use Config ();
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
die 'missing OO profile' unless $profile;
my @profile_pairs=map {split /=/, $_, 2} @{$profile->{configuration}};
my @profile_keys=map {$profile_pairs[$_]} grep {$_ % 2 == 0} 0..$#profile_pairs;

sub loaded_module_paths {
 my @required=qw(Date/Manip/Date.pm Date/Manip/Obj.pm Date/Manip/TZ.pm Date/Manip/Zones.pm);
 my %paths;
 for my $module (@required) {
  die "required module not loaded: $module" unless $INC{$module};
  $paths{$module}=$INC{$module};
 }
 my @zone_data=sort grep {m{\ADate/Manip/TZ/.+\.pm\z}} keys %INC;
 die 'Etc/UTC zone data module was not loaded' unless grep {$_ eq 'Date/Manip/TZ/etutc00.pm'} @zone_data;
 $paths{$_}=$INC{$_} for @zone_data;
 return \%paths;
}

my (@warnings,$stdout,$exception,%out); $stdout='';
{
 local $SIG{__WARN__}=sub {push @warnings,"$_[0]"};
 local *STDOUT; open STDOUT,'>',\$stdout or die $!;
 eval {
  die 'wrong version' unless $Date::Manip::Date::VERSION eq '7.00';
  my $date;
  if (exists $case->{constructor_initial}) {
   $date=Date::Manip::Date->new($case->{constructor_initial},\@profile_pairs);
   $out{configuration_call_executed}=0;
   $out{construction_mode}='constructor text with ordered public configuration options';
  } else {
   $date=Date::Manip::Date->new;
   $out{configuration_call_executed}=1;
   $out{configuration_return}=$date->config(@profile_pairs);
   $out{construction_mode}='empty constructor followed by ordered public configuration';
  }
  $out{configuration_error}=$date->err;
  die 'configuration failed' if $out{configuration_error};
  $out{version}=$date->version; $out{package_version}=$Date::Manip::Date::VERSION;
  $out{tzdata}=$date->tz->tzdata; $out{tzcode}=$date->tz->tzcode;
  $out{configured_zone}=$date->tz->zone;
  $out{profile_expected}=$profile->{configuration};
  $out{profile_echo}=[map {[$_,scalar $date->get_config($_)]} @profile_keys];
  $out{runtime}={perl_version=>"$^V",perl_archname=>$Config::Config{archname},os_name=>$^O};
  $out{loaded_module_paths}=loaded_module_paths();
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
