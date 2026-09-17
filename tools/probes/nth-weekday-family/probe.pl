#!/usr/bin/env perl
# Original public nth-weekday probe; private helpers are never called directly.
use strict;
use warnings;
use Config ();
use FindBin qw($Bin);
use JSON::PP ();
use Scalar::Util qw(looks_like_number);

sub read_json {open my$fh,'<:raw',$_[0] or die"read $_[0]: $!";JSON::PP->new->decode(do{local$/;<$fh>})}
sub clone_json {JSON::PP->new->decode(JSON::PP->new->encode($_[0]))}
sub native_type {!defined$_[0]?'undefined':(ref($_[0])||'scalar')}
sub public_value {
   return undef if !defined$_[0];
   return [map{public_value($_)}@{$_[0]}] if ref($_[0])eq'ARRAY';
   return {map{$_=>public_value($_[0]->{$_})}keys%{$_[0]}} if ref($_[0])eq'HASH';
   return 0+$_[0] if !ref($_[0])&&looks_like_number($_[0]);return"$_[0]";
}
sub module_paths {+{map{$_=>$INC{$_}}sort grep{m{\ADate/Manip/.+\.pm\z}}keys%INC}}

my$root="$Bin/../../..";my$id=shift@ARGV//die"case ID required";die"unexpected arguments"if@ARGV;
my$manifest=read_json("$root/docs/research/nth-weekday-family/cases.json");
my($case)=grep{$_->{'case_id'}eq$id}@{$manifest->{'cases'}};die"unknown case ID: $id"if!$case;
my$profiles=read_json("$root/docs/automation/reference-profiles.json");
my($fixture)=grep{$_->{'name'}eq'oo'}@{$profiles->{'profiles'}};die"missing fixture"if!$fixture;

my(@load_warnings,$load_exception);my$load_stdout='';
{local$SIG{__WARN__}=sub{push@load_warnings,"$_[0]"};open local*STDOUT,'>',\$load_stdout or die$!;
 my$ok=eval{require Date::Manip::Base;1};$load_exception=$ok?undef:"$@";}
die"load failed: $load_exception"if$load_exception;

my$base;my$current_arguments;
my@configuration=grep{$_!~/^ForceDate=/}@{$fixture->{'configuration'}};
my(@setup_warnings,$setup_return,$setup_exception);my$setup_stdout='';my$setup_ok;
{local$SIG{__WARN__}=sub{push@setup_warnings,"$_[0]"};open local*STDOUT,'>',\$setup_stdout or die$!;
 $setup_ok=eval{$base=Date::Manip::Base->new;my@pairs;for my$item(@configuration){my($n,$v)=split(/=/,$item,2);push@pairs,$n,$v}
  $setup_return=$base->config(@pairs);1};$setup_exception=$setup_ok?undef:"$@";}

sub invoke_current {my@args=@{$current_arguments};return$base->nth_day_of_week(@args)}
sub capture_scalar {
   my$error_before=shift;my(@warnings,$return,$exception);my$stdout='';my$ok;
   {local$SIG{__WARN__}=sub{push@warnings,"$_[0]"};open local*STDOUT,'>',\$stdout or die$!;
    $ok=eval{$return=invoke_current();1};$exception=$ok?undef:"$@";}
   return{context=>'scalar',call_completed=>$ok?JSON::PP::true:JSON::PP::false,
    ($ok?(return=>public_value($return),return_type=>native_type($return)):()),exception=>$exception,
    warnings=>\@warnings,stdout=>$stdout,public_error_before=>$error_before,public_error_after=>$base->err};
}
sub capture_list {
   my$error_before=shift;my(@warnings,@return,$exception);my$stdout='';my$ok;
   {local$SIG{__WARN__}=sub{push@warnings,"$_[0]"};open local*STDOUT,'>',\$stdout or die$!;
    $ok=eval{@return=invoke_current();1};$exception=$ok?undef:"$@";}
   return{context=>'list',call_completed=>$ok?JSON::PP::true:JSON::PP::false,
    ($ok?(return=>[map{public_value($_)}@return],return_type=>'list',return_count=>scalar(@return),
      return_element_types=>[map{native_type($_)}@return]):()),exception=>$exception,
    warnings=>\@warnings,stdout=>$stdout,public_error_before=>$error_before,public_error_after=>$base->err};
}

$current_arguments=$case->{'arguments'};
my$scalar=$setup_ok?capture_scalar($base->err):undef;
my$list=$setup_ok?capture_list($base->err):undef;
my%out=(case_id=>$id,operation_id=>'calendar.nth-weekday',profile=>'base',
 binding=>clone_json($manifest->{'binding'}),request=>clone_json($case->{'portable_request'}),
 binding_arguments=>clone_json($case->{'arguments'}),perl_version=>"$^V",perl_archname=>$Config::Config{'archname'},os_name=>$^O,
 fixture_reference=>clone_json($profiles->{'reference'}),fixture_profile=>clone_json($fixture),
 load_warnings=>\@load_warnings,load_stdout=>$load_stdout,
 setup=>{call_completed=>$setup_ok?JSON::PP::true:JSON::PP::false,
  ($setup_ok?(return=>public_value($setup_return),return_type=>native_type($setup_return)):()),
  exception=>$setup_exception,warnings=>\@setup_warnings,stdout=>$setup_stdout,requested_configuration=>\@configuration},
 scalar=>$scalar,list=>$list,observed_distribution_version=>$setup_ok?$base->version:undef,
 loaded_entry_module=>$INC{'Date/Manip/Base.pm'},loaded_date_manip_module_files=>module_paths(),
 error_protocol=>'public Base error text before and after each call');
print JSON::PP->new->canonical->utf8->encode(\%out),"\n";
