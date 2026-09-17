#!/usr/bin/env perl
# Original fixed-input research probe for the public Date::Manip::Date set method.
use strict;
use warnings;
use utf8;
use JSON::PP qw(decode_json);
use Digest::SHA qw(sha256_hex);
use Config ();
use FindBin qw($Bin);

my $case_id = shift @ARGV // die "case ID required\n";
die "unexpected arguments\n" if @ARGV;
my $fixture_path = "$Bin/../../../docs/research/date-set-family/cases.json";
open my $fixture_fh, '<:raw', $fixture_path or die $!;
my $fixture_bytes = do { local $/; <$fixture_fh> };
my $fixture_sha256 = sha256_hex($fixture_bytes);
my $fixtures = decode_json($fixture_bytes);
my ($case) = grep { $_->{case_id} eq $case_id } @{$fixtures->{cases}};
die "unknown case ID\n" unless $case;

my @warnings;
my $call_stdout = '';
my ($setup, $raw_return, $exception);
{
  local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
  local *STDOUT;
  open STDOUT, '>:encoding(UTF-8)', \$call_stdout or die $!;
  local $@;
  my $ok = eval {
    require Date::Manip::Date;
    die "distribution version mismatch\n" unless $Date::Manip::Date::VERSION eq $fixtures->{reference}{distribution_version};
    my $reference = Date::Manip::Date->new();
    my ($tz, $tz_call) = public_object($reference, 'tz');
    my $tzdata_call = public_scalar($tz, 'tzdata');
    my $tzcode_call = public_scalar($tz, 'tzcode');
    die "tzdata mismatch\n" unless $tzdata_call->{value} eq $fixtures->{reference}{tzdata};
    die "tzcode mismatch\n" unless $tzcode_call->{value} eq $fixtures->{reference}{tzcode};
    ($setup, my $anchor) = configured_anchor();
    $setup->{reference} = {
      constructor => {
        returned_reference_type => ref($reference),
        error_after => $reference->err(),
        exception => undef,
      },
      zone_service => $tz_call,
      tzdata => $tzdata_call,
      tzcode => $tzcode_call,
    };
    if ($setup->{exception} || $setup->{error_after} ne '') {
      $raw_return = { dependent_calls_executed => JSON::PP::false };
    } else {
      $raw_return = run_case($case, $anchor);
      $raw_return->{dependent_calls_executed} = JSON::PP::true;
    }
    1;
  };
  $exception = "$@" unless $ok;
}

my @contract_ids = ('object.create', 'context.zone-service', 'meta.zone-data-version', 'meta.zone-rule-version', 'config.apply-settings', 'config.read-settings', 'date.create');
push @contract_ids, 'date.parse-text' if $case->{receiver}{state} eq 'error';
push @contract_ids, ('date.replace-field', 'date.read-value', 'error.read-state');
my $record = {
  schema_version => 1,
  case_id => $case_id,
  profile => 'oo',
  operation_id => 'date.replace-field',
  contract_ids => \@contract_ids,
  partition_ids => ["date.replace-field.$case->{group}", "date.replace-field.$case->{classification}"],
  request => {
    receiver => $case->{receiver},
    arguments => $case->{arguments},
    classification => $case->{classification},
  },
  fixture_sha256 => $fixture_sha256,
  reference_assertions => $fixtures->{reference},
  profile_configuration => $fixtures->{profile}{configuration},
  setup => $setup,
  raw_return => $raw_return,
  exception => $exception,
  warnings => \@warnings,
  call_stdout => $call_stdout,
  environment => {
    LANG => 'C.UTF-8', LC_ALL => 'C.UTF-8', TZ => 'Etc/UTC',
    PERL_HASH_SEED => '0', PERL_PERTURB_KEYS => '0',
    cwd => 'fresh temporary directory',
  },
  perl_version => "$^V",
  perl_archname => $Config::Config{archname},
};
binmode STDOUT, ':encoding(UTF-8)';
print JSON::PP->new->canonical->utf8(0)->encode($record), "\n";

sub config_pairs {
  my @pairs;
  for my $setting (@{$fixtures->{profile}{configuration}}) {
    push @pairs, split(/=/, $setting, 2);
  }
  return @pairs;
}

sub public_scalar {
  my ($obj, $method, @args) = @_;
  my $error_before = $obj->err();
  my ($value, $call_exception);
  {
    local $@;
    my $ok = eval { $value = $obj->$method(@args); 1 };
    $call_exception = "$@" unless $ok;
  }
  return {
    error_before => $error_before,
    value => ref($value) ? undef : $value,
    value_defined => defined($value) ? JSON::PP::true : JSON::PP::false,
    value_reference_type => ref($value) || undef,
    error_after => $obj->err(),
    exception => $call_exception,
  };
}

sub public_object {
  my ($obj, $method, @args) = @_;
  my $error_before = $obj->err();
  my ($value, $call_exception);
  {
    local $@;
    my $ok = eval { $value = $obj->$method(@args); 1 };
    $call_exception = "$@" unless $ok;
  }
  return ($value, {
    error_before => $error_before,
    value_defined => defined($value) ? JSON::PP::true : JSON::PP::false,
    value_reference_type => ref($value) || undef,
    error_after => $obj->err(),
    exception => $call_exception,
  });
}

sub public_list {
  my ($obj, $method, @args) = @_;
  my $error_before = $obj->err();
  my (@value, $call_exception);
  {
    local $@;
    my $ok = eval { @value = $obj->$method(@args); 1 };
    $call_exception = "$@" unless $ok;
  }
  return {
    error_before => $error_before,
    value => \@value,
    count => scalar(@value),
    error_after => $obj->err(),
    exception => $call_exception,
  };
}

sub config_call {
  my ($obj, @args) = @_;
  return public_scalar($obj, 'config', @args);
}

sub configured_anchor {
  my $anchor = Date::Manip::Date->new();
  my $config = config_call($anchor, config_pairs());
  return ({
    class => ref($anchor),
    config => $config,
    effective => {
      language => public_scalar($anchor, 'get_config', 'language'),
      encoding => public_scalar($anchor, 'get_config', 'encoding'),
      dateformat => public_scalar($anchor, 'get_config', 'dateformat'),
    },
    error_after => $anchor->err(),
    exception => $config->{exception},
  }, $anchor);
}

sub value_snapshot {
  my ($obj, $include_converted) = @_;
  my $snapshot = {
    scalar => public_scalar($obj, 'value'),
    list => public_list($obj, 'value'),
  };
  if ($include_converted) {
    $snapshot->{local} = public_scalar($obj, 'value', 'local');
    $snapshot->{gmt} = public_scalar($obj, 'value', 'gmt');
  }
  $snapshot->{final_error} = $obj->err();
  return $snapshot;
}

sub make_receiver {
  my ($case, $anchor) = @_;
  my $state = $case->{receiver}{state};
  my $anchor_error_before_create = $anchor->err();
  my ($obj, $creation_exception);
  {
    local $@;
    my $ok = eval {
      if ($state eq 'unset') {
        $obj = $anchor->new_date();
      } elsif ($state eq 'error') {
        $obj = $anchor->new_date('2040-02-29 16:05:09 Etc/UTC');
      } else {
        $obj = $anchor->new_date($case->{receiver}{text});
      }
      1;
    };
    $creation_exception = "$@" unless $ok;
  }
  die $creation_exception if $creation_exception;
  my $receiver_error_after_create = $obj->err();
  my $preparation = $state eq 'error'
    ? public_scalar($obj, 'parse', $case->{receiver}{preparation_text})
    : undef;
  return ($obj, {
    state => $state,
    class => ref($obj),
    input => $case->{receiver}{text},
    creation => {
      anchor_error_before => $anchor_error_before_create,
      anchor_error_after => $anchor->err(),
      receiver_error_after => $receiver_error_after_create,
      returned_reference_type => ref($obj),
      exception => $creation_exception,
    },
    error_preparation => $preparation,
    error_before_set => $obj->err(),
  });
}

sub set_call {
  my ($obj, $args) = @_;
  my $error_before = $obj->err();
  my ($status, $call_exception);
  {
    local $@;
    my $ok = eval { $status = $obj->set(@$args); 1 };
    $call_exception = "$@" unless $ok;
  }
  return {
    error_before => $error_before,
    call_completed => $call_exception ? JSON::PP::false : JSON::PP::true,
    ($call_exception ? () : (status => $status, status_defined => defined($status) ? JSON::PP::true : JSON::PP::false)),
    error_after => $obj->err(),
    exception => $call_exception,
  };
}

sub run_case {
  my ($case, $anchor) = @_;
  my ($obj, $receiver) = make_receiver($case, $anchor);
  my $before = $case->{receiver}{state} eq 'valid' ? value_snapshot($obj, 0) : undef;
  my $call = set_call($obj, $case->{arguments});
  my $after = value_snapshot($obj, 1);
  return {
    receiver => $receiver,
    before => $before,
    call => $call,
    after => $after,
  };
}
