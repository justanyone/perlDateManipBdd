#!/usr/bin/env perl
# Original public week-number edge probe; never calls a private helper.
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
   return [@{$_[0]}] if ref($_[0]) eq 'ARRAY';
   return {%{$_[0]}} if ref($_[0]) eq 'HASH';
   return 0 + $_[0] if !ref($_[0]) && looks_like_number($_[0]);
   return "$_[0]";
}
sub module_paths { +{map {$_ => $INC{$_}} sort grep {m{\ADate/Manip/.+\.pm\z}} keys %INC} }

my $root = "$Bin/../../..";
my $id = shift @ARGV // die "case ID required";
die "unexpected arguments" if @ARGV;
my $manifest = read_json("$root/docs/research/week-rules-edges/cases.json");
my($case) = grep { $_->{'case_id'} eq $id } @{$manifest->{'cases'}};
die "unknown case ID: $id" if !$case;
my $profiles = read_json("$root/docs/automation/reference-profiles.json");
my($fixture) = grep { $_->{'name'} eq ($case->{'profile'} eq 'base' ? 'oo' : $case->{'profile'}) } @{$profiles->{'profiles'}};
die "missing profile fixture" if !$fixture;

my(@load_warnings,$load_stdout,$load_exception);
$load_stdout = '';
{
   local $SIG{__WARN__} = sub { push @load_warnings, "$_[0]" };
   open local *STDOUT, '>', \$load_stdout or die $!;
   my $ok = eval {
      if ($case->{'profile'} eq 'base') { require Date::Manip::Base; }
      elsif ($case->{'profile'} eq 'oo') { require Date::Manip::Date; }
      elsif ($case->{'profile'} eq 'dm6') { require Date::Manip::DM6; }
      else { require Date::Manip::DM5; }
      1;
   };
   $load_exception = $ok ? undef : "$@";
}
die "load failed: $load_exception" if $load_exception;

my %out = (
   case_id => $id, operation_id => 'calendar.week-number', request => clone_json($case),
   perl_version => "$^V", perl_archname => $Config::Config{'archname'}, os_name => $^O,
   fixture_reference => clone_json($profiles->{'reference'}), fixture_profile => clone_json($fixture),
   load_warnings => \@load_warnings, load_stdout => $load_stdout,
   loaded_entry_module => undef, calls => [],
);

sub capture_scalar {
   my($code,$error_before) = @_;
   my(@warnings,$return,$exception); my $stdout=''; my $ok;
   { local $SIG{__WARN__}=sub {push @warnings,"$_[0]"};
     open local *STDOUT,'>',\$stdout or die $!;
     $ok=eval {$return=$code->();1}; $exception=$ok?undef:"$@"; }
   return {context=>'scalar',call_completed=>$ok?JSON::PP::true:JSON::PP::false,
           ($ok?(return=>public_value($return),return_type=>native_type($return)):()),
           exception=>$exception,warnings=>\@warnings,stdout=>$stdout,
           (defined($error_before)?(public_error_before=>$error_before):())};
}
sub capture_list {
   my($code,$error_before) = @_;
   my(@warnings,@return,$exception); my $stdout=''; my $ok;
   { local $SIG{__WARN__}=sub {push @warnings,"$_[0]"};
     open local *STDOUT,'>',\$stdout or die $!;
     $ok=eval {@return=$code->();1}; $exception=$ok?undef:"$@"; }
   return {context=>'list',call_completed=>$ok?JSON::PP::true:JSON::PP::false,
           ($ok?(return=>[map {public_value($_)} @return],return_type=>'list',
                 return_count=>scalar(@return),return_element_types=>[map {native_type($_)} @return]):()),
           exception=>$exception,warnings=>\@warnings,stdout=>$stdout,
           (defined($error_before)?(public_error_before=>$error_before):())};
}

sub base_argument_code {
   my($base,$request) = @_;
   my $shape=$request->{'shape'};
   if ($shape eq 'inverse' || $shape eq 'raw-arguments') {
      my @args=@{$request->{'method_arguments'}}; return sub {$base->week_of_year(@args)};
   }
   my $carrier=$request->{'argument_carrier'};
   return sub {$base->week_of_year(undef)} if $carrier eq 'undefined';
   if ($carrier eq 'date-list') { my @v=@{$request->{'argument_value'}}; return sub {$base->week_of_year(\@v)}; }
   if ($carrier eq 'hash') { my %v=%{$request->{'argument_value'}}; return sub {$base->week_of_year(\%v)}; }
   my $v=$request->{'argument_value'}; return sub {$base->week_of_year($v)};
}

sub setup_base {
   my $base=Date::Manip::Base->new;
   my(@warnings,$exception,$return);my$stdout='';my$ok;
   { local$SIG{__WARN__}=sub{push@warnings,"$_[0]"}; open local*STDOUT,'>',\$stdout or die$!;
     $ok=eval{$return=$base->config('FirstDay',$case->{'configuration'}{'first_day'},'Week1ofYear',$case->{'configuration'}{'week1_of_year'});1};
     $exception=$ok?undef:"$@"; }
   $out{'setup'}={call_completed=>$ok?JSON::PP::true:JSON::PP::false,
      ($ok?(return=>public_value($return),return_type=>native_type($return)):()),exception=>$exception,
      warnings=>\@warnings,stdout=>$stdout,effective_configuration=>{first_day=>$base->get_config('FirstDay'),week1_of_year=>$base->get_config('Week1ofYear')}};
   return $base;
}

if ($case->{'family'} eq 'base-call') {
   my $base=setup_base(); my $code=base_argument_code($base,$case->{'request'});
   my $scalar=capture_scalar($code,$base->err); $scalar->{'public_error_after'}=$base->err;
   # A fresh receiver prevents the scalar call's cache from changing list-context
   # warnings or failures. The setup is identical and is saved for provenance.
   my $listed_base=setup_base(); my $listed_code=base_argument_code($listed_base,$case->{'request'});
   my $listed=capture_list($listed_code,$listed_base->err); $listed->{'public_error_after'}=$listed_base->err;
   $out{'calls'}=[$scalar,$listed]; $out{'observed_distribution_version'}=$base->version;
   $out{'loaded_entry_module'}=$INC{'Date/Manip/Base.pm'};
} elsif ($case->{'family'} eq 'base-config') {
   my $base=setup_base();
   my $before={first_day=>$base->get_config('FirstDay'),week1_of_year=>$base->get_config('Week1ofYear')};
   my $request=$case->{'request'}; my(@warnings,$return,$exception);my$stdout='';my$ok;
   { local$SIG{__WARN__}=sub{push@warnings,"$_[0]"};open local*STDOUT,'>',\$stdout or die$!;
     $ok=eval{
        if($request->{'value_shape'} eq 'missing'){$return=$base->config($request->{'setting'})}
        elsif($request->{'value_shape'} eq 'undefined'){$return=$base->config($request->{'setting'},undef)}
        else{$return=$base->config($request->{'setting'},$request->{'value'})}
        1;}; $exception=$ok?undef:"$@"; }
   my $after={first_day=>$base->get_config('FirstDay'),week1_of_year=>$base->get_config('Week1ofYear')};
   my @pair=$base->week_of_year([2040,1,1]);
   $out{'configuration_attempt'}={call_completed=>$ok?JSON::PP::true:JSON::PP::false,
      ($ok?(return=>public_value($return),return_type=>native_type($return)):()),exception=>$exception,
      warnings=>\@warnings,stdout=>$stdout,public_error_after=>$base->err,before=>$before,after=>$after,control_week_result=>\@pair};
   $out{'observed_distribution_version'}=$base->version; $out{'loaded_entry_module'}=$INC{'Date/Manip/Base.pm'};
} else {
   my $profile=$case->{'profile'}; my $request=$case->{'request'}; my @date=@{$request->{'civil_date'}};
   my($target,$error_observer,$observed_version,$entry);
   if($profile eq 'oo'){
      my$d=Date::Manip::Date->new; $target=$d;
      my @requested_config=@{$fixture->{'configuration'}};
      my @config;
      for my $item (@requested_config) {
         my($name,$value)=split(/=/,$item,2);
         push @config,$name,$value;
      }
      push @config,'FirstDay',$case->{'configuration'}{'first_day'},'Week1ofYear',$case->{'configuration'}{'week1_of_year'};
      my(@warnings,$return,$exception);my$stdout='';my$ok;
      {local$SIG{__WARN__}=sub{push@warnings,"$_[0]"};open local*STDOUT,'>',\$stdout or die$!;
       $ok=eval{$return=$d->config(@config);1};$exception=$ok?undef:"$@";}
      my $parse=$d->parse(sprintf('%04d-%02d-%02d',@date));
      $out{'setup'}={call_completed=>$ok?JSON::PP::true:JSON::PP::false,
         ($ok?(return=>public_value($return),return_type=>native_type($return)):()),exception=>$exception,
         warnings=>\@warnings,stdout=>$stdout,parse_return=>$parse,parse_error=>$d->err,
         requested_profile_configuration=>\@requested_config,
         effective_configuration=>{first_day=>$d->get_config('FirstDay'),week1_of_year=>$d->get_config('Week1ofYear')}};
      $error_observer=sub{$d->err};$observed_version=$d->version;$entry=$INC{'Date/Manip/Date.pm'};
   } else {
      my$pkg=$profile eq'dm6'?'Date::Manip::DM6':'Date::Manip::DM5'; no strict 'refs';
      my @config=@{$fixture->{'configuration'}};
      if($profile eq'dm6'){push@config,"FirstDay=$case->{'configuration'}{'first_day'}","Week1ofYear=$case->{'configuration'}{'week1_of_year'}"}
      else{push@config,"FirstDay=$case->{'configuration'}{'first_day'}","Jan1Week1=".($case->{'configuration'}{'week1_of_year'} eq'jan1'?1:0)}
      my(@warnings,$return,$exception);my$stdout='';my$ok;
      {local$SIG{__WARN__}=sub{push@warnings,"$_[0]"};open local*STDOUT,'>',\$stdout or die$!;
       $ok=eval{$return=&{$pkg.'::Date_Init'}(@config);1};$exception=$ok?undef:"$@";}
      $out{'setup'}={call_completed=>$ok?JSON::PP::true:JSON::PP::false,
         ($ok?(return=>public_value($return),return_type=>native_type($return)):()),exception=>$exception,
         warnings=>\@warnings,stdout=>$stdout,effective_configuration=>\@config};
      $target=$pkg;$observed_version=&{$pkg.'::DateManipVersion'}();
      (my$file="$pkg.pm")=~s{::}{/}g;$entry=$INC{$file};
   }
   my $invoke=sub{
      if($profile eq'oo'){
         return $target->week_of_year() if $request->{'override_shape'} eq'omitted';
         return $target->week_of_year(undef) if $request->{'override_shape'} eq'undefined';
         return $target->week_of_year($request->{'first_weekday'});
      }
      no strict 'refs';my$fn=$target.'::Date_WeekOfYear';my($y,$m,$d)=@date;
      return &{$fn}($m,$d,$y) if $request->{'override_shape'} eq'omitted';
      return &{$fn}($m,$d,$y,undef) if $request->{'override_shape'} eq'undefined';
      return &{$fn}($m,$d,$y,$request->{'first_weekday'});
   };
   my$error_before=$error_observer?$error_observer->():undef;
   my$scalar=capture_scalar($invoke,$error_before);$scalar->{'public_error_after'}=$error_observer?$error_observer->():undef if$error_observer;
   $error_before=$error_observer?$error_observer->():undef;
   my$listed=capture_list($invoke,$error_before);$listed->{'public_error_after'}=$error_observer?$error_observer->():undef if$error_observer;
   $out{'calls'}=[$scalar,$listed];$out{'observed_distribution_version'}='7.00';
   $out{'observed_backend_version'}=$observed_version;$out{'loaded_entry_module'}=$entry;
   $out{'error_protocol'}=$error_observer?'public Date err before and after each call':'no documented facade error observer';
}
$out{'loaded_date_manip_module_files'}=module_paths();
print JSON::PP->new->canonical->utf8->encode(\%out),"\n";
