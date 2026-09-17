#!/usr/bin/env perl
# Original calendar.weekday probe using only documented public entry points.
use strict;
use warnings;
use Config ();
use FindBin qw($Bin);
use JSON::PP ();
use Scalar::Util qw(looks_like_number);

sub read_json {
   open my $fh, '<:raw', $_[0] or die "read $_[0]: $!";
   return JSON::PP->new->decode(do { local $/; <$fh> });
}
sub clone_json { JSON::PP->new->decode(JSON::PP->new->encode($_[0])) }
sub native_type { !defined $_[0] ? 'undefined' : (ref($_[0]) || 'scalar') }
sub public_value {
   return undef if !defined $_[0];
   return [map { public_value($_) } @{$_[0]}] if ref($_[0]) eq 'ARRAY';
   return {map { $_ => public_value($_[0]->{$_}) } keys %{$_[0]}} if ref($_[0]) eq 'HASH';
   return 0 + $_[0] if !ref($_[0]) && looks_like_number($_[0]);
   return "$_[0]";
}
sub module_paths { +{map {$_ => $INC{$_}} sort grep {m{\ADate/Manip/.+\.pm\z}} keys %INC} }

my $root="$Bin/../../..";
my $id=shift @ARGV // die "case ID required";
die "unexpected arguments" if @ARGV;
my $manifest=read_json("$root/docs/research/weekday-family/cases.json");
my($case)=grep {$_->{'case_id'} eq $id} @{$manifest->{'cases'}};
die "unknown case ID: $id" if !$case;
my $profiles=read_json("$root/docs/automation/reference-profiles.json");
my $fixture_name=$case->{'profile'} eq 'dm5' ? 'dm5' : 'oo';
my($fixture)=grep {$_->{'name'} eq $fixture_name} @{$profiles->{'profiles'}};
die "missing profile fixture" if !$fixture;

my(@load_warnings,$load_exception);my$load_stdout='';
{
   local$SIG{__WARN__}=sub{push@load_warnings,"$_[0]"};
   open local*STDOUT,'>',\$load_stdout or die$!;
   my$ok=eval{
      require Date::Manip::Base if $case->{'profile'} eq 'base';
      require Date::Manip::DM6 if $case->{'profile'} eq 'dm6';
      require Date::Manip::DM5 if $case->{'profile'} eq 'dm5';
      1;
   };
   $load_exception=$ok?undef:"$@";
}
die "load failed: $load_exception" if $load_exception;

my %out=(case_id=>$id,operation_id=>'calendar.weekday',profile=>$case->{'profile'},
 request=>clone_json($case->{'portable_request'}),binding=>clone_json($case->{'binding'}),
 perl_version=>"$^V",perl_archname=>$Config::Config{'archname'},os_name=>$^O,
 fixture_reference=>clone_json($profiles->{'reference'}),fixture_profile=>clone_json($fixture),
 load_warnings=>\@load_warnings,load_stdout=>$load_stdout,setup=>undef,invocations=>[]);
my($base,$function,$version,$entry,$error_observer,$current_request);
sub invoke_current;

sub capture_scalar {
   my($error_before)=@_;my(@warnings,$return,$exception);my$stdout='';my$ok;
   {local$SIG{__WARN__}=sub{push@warnings,"$_[0]"};open local*STDOUT,'>',\$stdout or die$!;
    $ok=eval{$return=invoke_current();1};$exception=$ok?undef:"$@";}
   return {context=>'scalar',call_completed=>$ok?JSON::PP::true:JSON::PP::false,
     ($ok?(return=>public_value($return),return_type=>native_type($return)):()),
     exception=>$exception,warnings=>\@warnings,stdout=>$stdout,
     (defined$error_before?(public_error_before=>$error_before):())};
}
sub capture_list {
   my($error_before)=@_;my(@warnings,@return,$exception);my$stdout='';my$ok;
   {local$SIG{__WARN__}=sub{push@warnings,"$_[0]"};open local*STDOUT,'>',\$stdout or die$!;
    $ok=eval{@return=invoke_current();1};$exception=$ok?undef:"$@";}
   return {context=>'list',call_completed=>$ok?JSON::PP::true:JSON::PP::false,
     ($ok?(return=>[map{public_value($_)}@return],return_type=>'list',return_count=>scalar(@return),
            return_element_types=>[map{native_type($_)}@return]):()),
     exception=>$exception,warnings=>\@warnings,stdout=>$stdout,
     (defined$error_before?(public_error_before=>$error_before):())};
}

my @configuration=@{$fixture->{'configuration'}};
@configuration=grep {$_ !~ /^ForceDate=/} @configuration if $case->{'profile'} eq 'base';
push @configuration,"YYtoYYYY=$case->{'setup'}{'short_year_rule'}" if exists$case->{'setup'}{'short_year_rule'};
my(@setup_warnings,$setup_return,$setup_exception);my$setup_stdout='';my$setup_ok;
{
   local$SIG{__WARN__}=sub{push@setup_warnings,"$_[0]"};open local*STDOUT,'>',\$setup_stdout or die$!;
   $setup_ok=eval{
      if($case->{'profile'} eq 'base'){
         $base=Date::Manip::Base->new;
         my@pairs;for my$item(@configuration){my($name,$value)=split(/=/,$item,2);push@pairs,$name,$value}
         $setup_return=$base->config(@pairs);$version=$base->version;$entry=$INC{'Date/Manip/Base.pm'};
         $error_observer=sub{$base->err};
      }else{
         my$pkg=$case->{'profile'} eq 'dm6'?'Date::Manip::DM6':'Date::Manip::DM5';no strict 'refs';
         $setup_return=&{$pkg.'::Date_Init'}(@configuration);
         $function=$pkg.'::Date_DayOfWeek';$version=&{$pkg.'::DateManipVersion'}();
         (my$file="$pkg.pm")=~s{::}{/}g;$entry=$INC{$file};
      }
      1;
   };$setup_exception=$setup_ok?undef:"$@";
}
$out{'setup'}={call_completed=>$setup_ok?JSON::PP::true:JSON::PP::false,
  ($setup_ok?(return=>public_value($setup_return),return_type=>native_type($setup_return)):()),
  exception=>$setup_exception,warnings=>\@setup_warnings,stdout=>$setup_stdout,
  requested_configuration=>\@configuration};

sub invoke_current {
   my$request=$current_request;
   if($case->{'profile'} eq 'base'){
      my$carrier=$request->{'carrier'};
      return $base->day_of_week() if $carrier eq 'omitted';
      return $base->day_of_week(undef) if $carrier eq 'undefined';
      if($carrier eq 'date-list'){
         my@value=@{$request->{'value'}};my@extra=@{$request->{'extra_method_arguments'}||[]};
         return $base->day_of_week(\@value,@extra);
      }
      if($carrier eq 'text'){my$value=$request->{'value'};return $base->day_of_week($value)}
      if($carrier eq 'mapping'){my%value=%{$request->{'value'}};return $base->day_of_week(\%value)}
      if($carrier eq 'nested-list'){my@value=map{ref$_ eq'ARRAY'?[ @$_ ]:$_}@{$request->{'value'}};return $base->day_of_week(\@value)}
      die "unknown base carrier $carrier";
   }
   no strict 'refs';
   if($request->{'carrier'} eq 'functional-fields'){
      my@arguments=@{$request->{'arguments'}};return &{$function}(@arguments);
   }
   my$value=clone_json($request->{'value'});return &{$function}($value);
}

if($setup_ok){
   for my$request(@{$case->{'invocations'}}){
      $current_request=$request;my$error_before=$error_observer?$error_observer->():undef;
      my$scalar=capture_scalar($error_before);$scalar->{'public_error_after'}=$error_observer?$error_observer->():undef if$error_observer;
      $error_before=$error_observer?$error_observer->():undef;
      my$list=capture_list($error_before);$list->{'public_error_after'}=$error_observer?$error_observer->():undef if$error_observer;
      push@{$out{'invocations'}},{binding_request=>clone_json($request),scalar=>$scalar,list=>$list};
   }
}
$out{'observed_distribution_version'}='7.00';$out{'observed_backend_version'}=$version;
$out{'loaded_entry_module'}=$entry;$out{'loaded_date_manip_module_files'}=module_paths();
$out{'error_protocol'}=$error_observer?'public Base error text before and after each call':'no documented functional error observer';
print JSON::PP->new->canonical->utf8->encode(\%out),"\n";
