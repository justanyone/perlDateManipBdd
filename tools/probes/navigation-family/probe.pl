#!/usr/bin/env perl
# Original fixed-input probe for public previous/next navigation calls.
use strict;
use warnings;
use utf8;
use JSON::PP qw(decode_json);
use Digest::SHA qw(sha256_hex);
use Config ();
use FindBin qw($Bin);

my $case_id = shift @ARGV // die "case ID required\n";
die "unexpected arguments\n" if @ARGV;
my $fixture_path = "$Bin/../../../docs/research/navigation-family/cases.json";
open my $fixture_fh, '<:raw', $fixture_path or die $!;
my $fixture_bytes = do { local $/; <$fixture_fh> };
my $fixture_sha256 = sha256_hex($fixture_bytes);
my $fixtures = decode_json($fixture_bytes);
my ($case) = grep { $_->{case_id} eq $case_id } @{$fixtures->{cases}};
die "unknown case ID\n" unless $case;
my $profiles = read_json("$Bin/../../../docs/automation/reference-profiles.json");
my ($profile) = grep { $_->{name} eq $case->{profile} } @{$profiles->{profiles}};
die "profile missing\n" unless $profile;

my @warnings;
my $call_stdout = '';
my ($raw_return, $exception, $exception_stage);
{
  local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
  local *STDOUT;
  open STDOUT, '>:encoding(UTF-8)', \$call_stdout or die $!;
  local $@;
  my $stage = 'load';
  my $ok = eval {
    if ($case->{profile} eq 'oo') {
      $stage = 'OO public calls';
      $raw_return = run_oo($case, $profile, $fixtures);
    } else {
      $stage = 'functional public calls';
      $raw_return = run_functional($case, $profile, $fixtures);
    }
    1;
  };
  if (!$ok) {
    $exception = stable_exception("$@");
    $exception_stage = $stage;
  }
}

my $primary = $case->{direction} eq 'next' ? 'date.find-next' : 'date.find-previous';
my @contracts = $case->{profile} eq 'oo'
  ? ('object.create','config.apply-settings','config.read-settings','context.zone-service',
     'meta.reference-version','meta.zone-data-version','meta.zone-rule-version','date.create')
  : ('config.apply-settings','meta.reference-version');
push @contracts, 'date.parse-text' if $case->{profile} eq 'oo' && $case->{receiver}{state} eq 'error';
push @contracts, $primary;
push @contracts, ('date.read-value','error.read-state') if $case->{profile} eq 'oo';
my $record = {
  schema_version => 1,
  case_id => $case_id,
  profile => $case->{profile},
  operation_id => $primary,
  contract_ids => \@contracts,
  partition_ids => ["$primary.$case->{classification}", "$primary.$case->{profile}"],
  request => $case,
  fixture_sha256 => $fixture_sha256,
  reference_assertions => $fixtures->{reference},
  raw_return => $raw_return,
  loaded_modules => {map {$_ => $INC{$_}} grep {m{^Date/Manip}} keys %INC},
  exception => $exception,
  exception_stage => $exception_stage,
  warnings => \@warnings,
  call_stdout => $call_stdout,
  environment => {
    LANG => 'C.UTF-8', LC_ALL => 'C.UTF-8', TZ => 'Etc/UTC',
    PERL_HASH_SEED => '0', PERL_PERTURB_KEYS => '0',
    cwd => 'fresh temporary directory',
  },
  perl_version => "$^V",
  perl_archname => $Config::Config{archname},
  os_name => $^O,
  normalization => {
    exceptions => 'Perl reference addresses are replaced with 0xADDR; all other text is retained',
  },
};
binmode STDOUT, ':encoding(UTF-8)';
print JSON::PP->new->canonical->utf8(0)->encode($record), "\n";

sub read_json {
  my ($path) = @_;
  open my $fh, '<:raw', $path or die $!;
  return decode_json(do { local $/; <$fh> });
}

sub type_of {
  my ($value) = @_;
  return 'absent' unless defined $value;
  return ref($value) || 'scalar';
}

sub stable_exception {
  my ($text) = @_;
  return undef unless defined $text;
  $text =~ s/([A-Z][A-Z0-9_:]*)\(0x[0-9a-fA-F]+\)/$1(0xADDR)/g;
  return $text;
}

sub scalar_call {
  my ($obj, $method, @args) = @_;
  my $error_before = $obj->err();
  my ($value, $call_exception);
  { local $@; my $ok = eval { $value = $obj->$method(@args); 1 }; $call_exception = stable_exception("$@") unless $ok; }
  return {
    error_before => $error_before, value => $value, value_type => type_of($value),
    error_after => $obj->err(), exception => $call_exception,
  };
}

sub list_call {
  my ($obj, $method, @args) = @_;
  my $error_before = $obj->err();
  my (@value, $call_exception);
  { local $@; my $ok = eval { @value = $obj->$method(@args); 1 }; $call_exception = stable_exception("$@") unless $ok; }
  return {
    error_before => $error_before, value => \@value, count => scalar(@value),
    error_after => $obj->err(), exception => $call_exception,
  };
}

sub snapshot {
  my ($obj, $converted) = @_;
  my $out = { scalar => scalar_call($obj,'value'), list => list_call($obj,'value') };
  if ($converted) {
    $out->{local} = scalar_call($obj,'value','local');
    $out->{gmt} = scalar_call($obj,'value','gmt');
  }
  $out->{final_error} = $obj->err();
  return $out;
}

sub run_oo {
  my ($case, $profile, $fixtures) = @_;
  require Date::Manip::Date;
  die "distribution mismatch\n" unless $Date::Manip::Date::VERSION eq $fixtures->{reference}{distribution_version};
  my $anchor = Date::Manip::Date->new();
  my @config = map { split(/=/,$_,2) } @{$profile->{configuration}};
  my $config = scalar_call($anchor,'config',@config);
  my $version = scalar_call($anchor,'version');
  my ($tz, $tz_exception);
  { local $@; my $ok = eval { $tz = $anchor->tz(); 1 }; $tz_exception = stable_exception("$@") unless $ok; }
  my $tzdata = scalar_call($tz,'tzdata');
  my $tzcode = scalar_call($tz,'tzcode');
  my $expected_backend = $profile->{backend_version} // $fixtures->{reference}{distribution_version};
  die "backend mismatch\n" unless $version->{value} eq $expected_backend;
  die "tzdata mismatch\n" unless $tzdata->{value} eq $fixtures->{reference}{tzdata};
  die "tzcode mismatch\n" unless $tzcode->{value} eq $fixtures->{reference}{tzcode};
  my $setup = {
    anchor_class => ref($anchor), config => $config, version => $version,
    zone_service => { value_type => ref($tz), exception => $tz_exception },
    tzdata => $tzdata, tzcode => $tzcode,
    effective => {
      language => scalar_call($anchor,'get_config','language'),
      encoding => scalar_call($anchor,'get_config','encoding'),
      dateformat => scalar_call($anchor,'get_config','dateformat'),
    },
  };
  my $state = $case->{receiver}{state};
  my $obj = $state eq 'unset' ? $anchor->new_date()
          : $state eq 'error' ? $anchor->new_date($case->{receiver}{initial_text})
          : $anchor->new_date($case->{receiver}{text});
  my $preparation = $state eq 'error'
    ? scalar_call($obj,'parse',$case->{receiver}{preparation_text}) : undef;
  my $receiver = {
    state => $state, class => ref($obj),
    input => ($case->{receiver}{text} // $case->{receiver}{initial_text}),
    error_preparation => $preparation, error_before_navigation => $obj->err(),
  };
  my $before = $state eq 'valid' ? snapshot($obj,0) : undef;
  my $call = scalar_call($obj,$case->{direction},@{$case->{arguments}});
  my $after = snapshot($obj,1);
  my $after_error_clear;
  if (($call->{value} // 0) != 0 || $call->{error_after} ne '') {
    my $clear = scalar_call($obj,'err',1);
    $after_error_clear = { clear => $clear, state => snapshot($obj,1) };
  }
  return {
    setup => $setup, receiver => $receiver, before => $before, call => $call,
    after => $after, after_error_clear => $after_error_clear,
  };
}

sub run_functional {
  my ($case, $profile, $fixtures) = @_;
  my $module = $case->{profile} eq 'dm5' ? 'Date::Manip::DM5' : 'Date::Manip::DM6';
  eval "require $module; 1" or die $@;
  no strict 'refs';
  my $distribution = ${$module.'::VERSION'};
  my $version_name = $module.'::DateManipVersion';
  my $backend = &{$version_name}();
  die "distribution mismatch\n" unless $distribution eq $fixtures->{reference}{distribution_version};
  die "backend mismatch\n" unless $backend eq $profile->{backend_version};
  my $init_name = $module.'::Date_Init';
  my ($config_status, $config_exception);
  { local $@; my $ok = eval { $config_status = &{$init_name}(@{$profile->{configuration}}); 1 }; $config_exception = stable_exception("$@") unless $ok; }
  my $function = $module.'::'.($case->{direction} eq 'next' ? 'Date_GetNext' : 'Date_GetPrev');
  my ($value, $call_exception);
  { local $@; my $ok = eval { $value = &{$function}($case->{receiver}{text},@{$case->{arguments}}); 1 }; $call_exception = stable_exception("$@") unless $ok; }
  return {
    setup => {
      module => $module, distribution_version => $distribution, backend_version => $backend,
      configuration_status => $config_status, configuration_status_type => type_of($config_status),
      configuration_exception => $config_exception,
    },
    call => {
      callable => $function,
      call_completed => $call_exception ? JSON::PP::false : JSON::PP::true,
      ($call_exception ? () : (value => $value, value_type => type_of($value))),
      exception => $call_exception,
    },
  };
}
