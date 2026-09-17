#!/usr/bin/env perl
# Original research probe: public Date::Manip calls only; records rather than approves outputs.
use strict;
use warnings;
use JSON::PP qw(decode_json encode_json);
use Config ();
use FindBin qw($Bin);

my $id = shift @ARGV // die "case ID required\n";
die "unexpected arguments\n" if @ARGV;
sub read_json { open my $f, '<', $_[0] or die "$!\n"; return decode_json(do { local $/; <$f> }); }
my $input = read_json("$Bin/../../../docs/research/arithmetic-family/cases.json");
my $extended = read_json("$Bin/../../../docs/research/arithmetic-family/extended-cases.json");
my $edges = read_json("$Bin/../../../docs/research/arithmetic-family/edge-cases.json");
my ($case) = grep { $_->{case_id} eq $id } (@{$input->{cases}}, @{$extended->{cases}}, @{$edges->{cases}});
die "unknown case ID: $id\n" unless $case;
my $profiles = read_json("$Bin/../../../docs/automation/reference-profiles.json");
my ($profile) = grep { $_->{name} eq $case->{profile} } @{$profiles->{profiles}};
die "unknown profile\n" unless $profile;

my @setup_warnings;
my @call_warnings;
my $warning_bucket = \@setup_warnings;
local $SIG{__WARN__} = sub { push @$warning_bucket, "$_[0]" };
my %out = (case_id=>$id, operation_id=>$case->{operation_id}, contract_ids=>$case->{contract_ids},
  partition_ids=>$case->{partition_ids}, profile=>$case->{profile}, request=>$case->{request},
  perl_version=>"$^V", perl_archname=>$Config::Config{archname},
  setup_warnings=>\@setup_warnings, warnings=>\@call_warnings);
my @cfg=map { split /=/, $_, 2 } @{$profile->{configuration}};
my ($date,$base);
if ($case->{profile} eq 'oo') {
  require Date::Manip::Date;
  require Date::Manip::Delta;
  $out{selected_backend}='Date::Manip::Date';
  $out{distribution_version}=$Date::Manip::Date::VERSION;
  die "wrong reference version\n" unless $out{distribution_version} eq '7.00';
  $date=Date::Manip::Date->new();
  $out{configuration_return}=$date->config(@cfg);
  $out{configuration_error}=$date->err;
  $out{profile_configuration}=$profile->{configuration};
} elsif ($case->{profile} eq 'dm6' || $case->{profile} eq 'dm5') {
  my $module=$case->{profile} eq 'dm5' ? 'Date::Manip::DM5' : 'Date::Manip::DM6';
  eval "require $module; 1" or die $@;
  no strict 'refs';
  $out{selected_backend}=$module;
  $out{distribution_version}=${$module.'::VERSION'};
  die "wrong reference version\n" unless $out{distribution_version} eq '7.00';
  my $init=$module.'::Date_Init';
  $out{configuration_return}=&{$init}(@{$profile->{configuration}});
  $out{configuration_error}=undef;
  $out{profile_configuration}=$profile->{configuration};
} else { die "unsupported profile\n"; }
if ($case->{holiday_lines}) {
  open my $holiday_file, '>', 'arithmetic-holidays.conf' or die "$!\n";
  print {$holiday_file} "Language = English\nDateFormat = US\nWorkWeekBeg = 1\nWorkWeekEnd = 5\nWorkDayBeg = 09:00\nWorkDayEnd = 17:00\nWorkDay24Hr = 0\n*Holidays\n", join("\n", @{$case->{holiday_lines}}), "\n";
  close $holiday_file or die "$!\n";
  $out{holiday_configuration_return}=$date->config('ConfigFile','arithmetic-holidays.conf');
  $out{holiday_configuration_error}=$date->err;
}
$base=$date->base() if $date;
$warning_bucket = \@call_warnings;
sub delta { my ($text,$opts)=@_; my $d=$date->new_delta(); my $status=defined $opts ? $d->parse($text,$opts) : $d->parse($text); return ($d,$status); }
sub snap { my ($d)=@_; my $error=$d->err;
  my $skip=$d->is_date() && length($error);
  my %snapshot=(input=>$d->input, error=>$error, value_read_performed=>$skip ? JSON::PP::false : JSON::PP::true);
  if (!$skip) { $snapshot{value_scalar}=scalar($d->value); $snapshot{value_list}=[$d->value]; }
  $snapshot{error_after_reads}=$d->err;
  $snapshot{type}={ map { $_=>$d->type($_) } qw(exact semi approx estimated standard business) } if $d->can('type');
  return \%snapshot; }
sub run {
  my $kind=$case->{kind}; my $r=$case->{request};
  if ($kind eq 'base') { my $m=$r->{method}; return $base->$m(@{$r->{args}}); }
  if ($kind eq 'delta_parse') { my $d=$date->new_delta(); my $before=snap($d); my $s=exists $r->{opts} ? $d->parse($r->{text},$r->{opts}) : $d->parse($r->{text}); return {status=>$s,before=>$before,after=>snap($d)}; }
  if ($kind eq 'delta_set') { my ($d,$s)=delta($r->{initial}); my $before=snap($d); my $status=$d->set($r->{set}); return {initial_status=>$s,status=>$status,before=>$before,after=>snap($d)}; }
  if ($kind eq 'delta_convert') { my ($d,$s)=delta($r->{initial},$r->{opts}); my $before=snap($d); my $ret=$d->convert($r->{to}); return {initial_status=>$s,return=>$ret,before=>$before,after=>snap($d)}; }
  if ($kind eq 'delta_printf') { my ($d,$s)=delta($r->{initial},$r->{opts}); my @v=$d->printf(@{$r->{patterns}}); return {initial_status=>$s,scalar=>scalar($d->printf(@{$r->{patterns}})),list=>\@v,after=>snap($d)}; }
  if ($kind eq 'delta_cmp') { my ($a,$as)=delta($r->{left},$r->{left_opts}); my ($b,$bs)=delta($r->{right},$r->{right_opts}); return {left_status=>$as,right_status=>$bs,result=>$a->cmp($b),left=>snap($a),right=>snap($b)}; }
  if ($kind eq 'date_method') { my $d=$date->new_date(); my $status=$d->parse($r->{date}); my $before=snap($d); my $method=$r->{method}; my $value=$d->$method(@{$r->{args}//[]}); return {parse_status=>$status,return=>$value,before=>$before,after=>snap($d)}; }
  if ($kind eq 'oo_calc') {
    my $left=$r->{left_kind} && $r->{left_kind} eq 'delta' ? $date->new_delta() : $date->new_date();
    my $right=$r->{right_kind} && $r->{right_kind} eq 'date' ? $date->new_date() : $date->new_delta();
    my $ls=exists $r->{left_opts} ? $left->parse($r->{left},$r->{left_opts}) : $left->parse($r->{left});
    my $rs=exists $r->{right_opts} ? $right->parse($r->{right},$r->{right_opts}) : $right->parse($r->{right});
    my $left_before=snap($left); my $right_before=snap($right);
    my $answer=$left->calc($right,@{$r->{tail}//[]});
    my $left_after=$left->can('type') ? snap($left) : (length($left->err) ? undef : scalar($left->value));
    my $right_after=$right->can('type') ? snap($right) : (length($right->err) ? undef : scalar($right->value));
    my $answer_error_before_value=$answer ? $answer->err : undef;
    return {answer_error_before_value=>$answer_error_before_value,left_status=>$ls,right_status=>$rs,left_before=>$left_before,right_before=>$right_before,class=>ref($answer),value=>($answer ? scalar($answer->value) : undef),error=>($answer ? $answer->err : undef),left_after=>$left_after,right_after=>$right_after};
  }
  if ($kind eq 'dm_calc') { my $m=$case->{profile} eq 'dm5' ? 'Date::Manip::DM5' : 'Date::Manip::DM6'; no strict 'refs'; my $f=$m.'::DateCalc'; my $err=''; my @args=@{$r->{args}}; splice @args,2,0,\$err; my $answer=&{$f}(@args); return {value=>$answer,error_reference=>$err}; }
  if ($kind eq 'dm_parse') { my $m=$case->{profile} eq 'dm5' ? 'Date::Manip::DM5' : 'Date::Manip::DM6'; no strict 'refs'; my $f=$m.'::ParseDateDelta'; my $input=$r->{text}; my $answer=&{$f}($input,@{$r->{tail}//[]}); return {value=>$answer,input_after=>$input}; }
  if ($kind eq 'dm_format') { my $m=$case->{profile} eq 'dm5' ? 'Date::Manip::DM5' : 'Date::Manip::DM6'; no strict 'refs'; my $f=$m.'::Delta_Format'; my @v=&{$f}(@{$r->{args}}); return {scalar=>scalar(&{$f}(@{$r->{args}})),list=>\@v}; }
  if ($kind eq 'new_delta') { my $d=$date->new_delta(@{$r->{args}//[]}); return snap($d); }
  die "unknown kind $kind\n";
}
my $stdout=''; my $ok;
{ open local *STDOUT, '>', \$stdout or die $!; $ok=eval { $out{raw_return}=run(); 1 }; $out{exception}=$ok ? undef : "$@"; }
$out{call_stdout}=$stdout;
print JSON::PP->new->canonical->encode(\%out),"\n";
