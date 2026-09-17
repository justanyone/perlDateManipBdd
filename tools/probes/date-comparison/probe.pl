#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP ();
use Config;
use FindBin qw($Bin);
sub load {open my $f,'<:raw',$_[0] or die $!;return JSON::PP->new->decode(do{local $/;<$f>});}
my $root="$Bin/../../..";my $cases=load("$root/docs/research/date-comparison/cases.json");my $id=shift @ARGV;die 'arguments' if @ARGV;
my ($c)=grep {$_->{case_id} eq $id} @{$cases->{cases}};die 'unknown case' unless $c;
my $profile=$c->{profile};my $profiles=load("$root/docs/automation/reference-profiles.json");
my ($settings)=grep {$_->{name} eq ($profile eq 'base'?'oo':$profile)} @{$profiles->{profiles}};
my (%o,@warnings,$exception);my $stdout='';
{
 local $SIG{__WARN__}=sub {push @warnings,"$_[0]"};local *STDOUT;open STDOUT,'>',\$stdout or die $!;
 eval {
  if ($profile eq 'oo' || $profile eq 'base') {
   require Date::Manip::Date;die 'release mismatch' unless $Date::Manip::Date::VERSION eq '7.00';
   my $anchor=Date::Manip::Date->new;
   $o{config_return}=$anchor->config(map {split /=/,$_,2} @{$settings->{configuration}});$o{config_error}=$anchor->err;
   die 'configuration failure' if $o{config_error};
   $o{version}=$anchor->version;$o{tzdata}=$anchor->tz->tzdata;$o{tzcode}=$anchor->tz->tzcode;
   if ($profile eq 'base') {
    my $base=$anchor->base;$o{error_before}=$base->err;
    $o{result}=$base->cmp($c->{left},$c->{right});$o{error_after}=$base->err;
   } else {
    my $left=$anchor->new_date;my $right=$anchor->new_date;
    $o{parse_left}=$left->parse($c->{left});$o{parse_right}=$right->parse($c->{right});
    $o{errors_before}=[$left->err,$right->err];
    $o{result}=$left->cmp($right);
    $o{errors_after}=[$left->err,$right->err];
   }
  } else {
   my $module=$profile eq 'dm6'?'Date::Manip::DM6':'Date::Manip::DM5';
   (my $file="$module.pm") =~ s{::}{/}g;require $file;
   no strict 'refs';die 'release mismatch' unless ${"${module}::VERSION"} eq '7.00';
   $o{config_return}=&{"${module}::Date_Init"}(@{$settings->{configuration}});
   $o{version}=&{"${module}::DateManipVersion"}();
   $o{result}=&{"${module}::Date_Cmp"}($c->{left},$c->{right});
  }
  $o{result_defined}=defined($o{result})?1:0;
  1;
 } or $exception="$@";
}
print JSON::PP->new->canonical->encode({case=>$c,configuration=>$settings->{configuration},observation=>\%o,warnings=>\@warnings,stdout=>$stdout,exception=>$exception,runtime=>{perl=>"$^V",arch=>$Config{archname},os=>$^O},loaded=>{map {$_=>$INC{$_}}grep {m{^Date/Manip}}keys %INC}}),"\n";
