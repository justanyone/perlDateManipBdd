#!/usr/bin/env perl
# Original fixed-input research probe for public object lifecycle behavior.
use strict;
use warnings;
use utf8;
use JSON::PP qw(decode_json);
use Digest::SHA qw(sha256_hex);
use Config ();
use FindBin qw($Bin);

my $case_id = shift @ARGV // die "case ID required\n";
die "unexpected arguments\n" if @ARGV;
my $fixture_path = "$Bin/../../../docs/research/object-lifecycle-family/cases.json";
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
    require Date::Manip::Delta;
    require Date::Manip::Recur;
    die "distribution version mismatch\n" unless $Date::Manip::Date::VERSION eq $fixtures->{reference}{distribution_version};
    my $reference = Date::Manip::Date->new();
    my $tz = $reference->tz();
    die "tzdata mismatch\n" unless $tz->tzdata() eq $fixtures->{reference}{tzdata};
    die "tzcode mismatch\n" unless $tz->tzcode() eq $fixtures->{reference}{tzcode};
    ($setup, my $anchor) = configured_date();
    if ($setup->{exception} || $setup->{error_after} ne '') {
      $raw_return = { dependent_calls_executed => JSON::PP::false };
    } else {
      $raw_return = run_case($case->{action}, $anchor);
      $raw_return->{dependent_calls_executed} = JSON::PP::true;
    }
    1;
  };
  $exception = "$@" unless $ok;
}

my $record = {
  schema_version => 1,
  case_id => $case_id,
  profile => 'oo',
  operation_id => $case->{operation_id},
  contract_ids => $case->{contract_ids},
  partition_ids => $case->{partition_ids},
  mapping_status => $case->{mapping_status},
  cross_reference => $case->{cross_reference},
  request => { action => $case->{action} },
  fixture_sha256 => $fixture_sha256,
  reference_assertions => {
    distribution_version => $Date::Manip::Date::VERSION,
    backend_version => $Date::Manip::Date::VERSION,
    tzdata => $fixtures->{reference}{tzdata},
    tzcode => $fixtures->{reference}{tzcode},
  },
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

sub configured_date {
  my $d = Date::Manip::Date->new();
  my ($status, $exception);
  my $error_before = $d->err();
  {
    local $@;
    my $ok = eval { $status = $d->config(config_pairs()); 1 };
    $exception = "$@" unless $ok;
  }
  my $setup = {
    class => ref($d), status => $status, exception => $exception,
    error_before => $error_before, error_after => $d->err(),
    effective => {
      language => scalar($d->get_config('language')),
      encoding => scalar($d->get_config('encoding')),
      dateformat => scalar($d->get_config('dateformat')),
    },
  };
  return ($setup, $d);
}

sub scalar_value {
  my ($obj, @args) = @_;
  my $before = $obj->err();
  my ($value, $exception);
  {
    local $@;
    my $ok = eval { $value = $obj->value(@args); 1 };
    $exception = "$@" unless $ok;
  }
  return { error_before => $before, value => $value, defined => defined($value) ? JSON::PP::true : JSON::PP::false, error_after => $obj->err(), exception => $exception };
}

sub list_value {
  my ($obj, @args) = @_;
  my $before = $obj->err();
  my (@value, $exception);
  {
    local $@;
    my $ok = eval { @value = $obj->value(@args); 1 };
    $exception = "$@" unless $ok;
  }
  return { error_before => $before, value => \@value, count => scalar(@value), error_after => $obj->err(), exception => $exception };
}

sub scalar_getter {
  my ($obj, $method, @args) = @_;
  my $before = $obj->err();
  my ($value, $exception);
  {
    local $@;
    my $ok = eval { $value = $obj->$method(@args); 1 };
    $exception = "$@" unless $ok;
  }
  return { error_before => $before, value => $value, defined => defined($value) ? JSON::PP::true : JSON::PP::false, error_after => $obj->err(), exception => $exception };
}

sub list_getter {
  my ($obj, $method, @args) = @_;
  my $before = $obj->err();
  my (@value, $exception);
  {
    local $@;
    my $ok = eval { @value = $obj->$method(@args); 1 };
    $exception = "$@" unless $ok;
  }
  return { error_before => $before, value => \@value, count => scalar(@value), error_after => $obj->err(), exception => $exception };
}

sub config_call {
  my ($obj, @args) = @_;
  my $before = $obj->err();
  my ($status, $exception);
  {
    local $@;
    my $ok = eval { $status = $obj->config(@args); 1 };
    $exception = "$@" unless $ok;
  }
  return {
    error_before => $before, status => ref($status) ? undef : $status,
    status_defined => defined($status) ? JSON::PP::true : JSON::PP::false,
    status_reference_type => ref($status) || undef,
    error_after => $obj->err(), exception => $exception,
  };
}

sub config_getter {
  my ($obj, @args) = @_;
  my $before = $obj->err();
  my ($value, $exception);
  {
    local $@;
    my $ok = eval { $value = scalar($obj->get_config(@args)); 1 };
    $exception = "$@" unless $ok;
  }
  return {
    error_before => $before, value => $value,
    defined => defined($value) ? JSON::PP::true : JSON::PP::false,
    error_after => $obj->err(), exception => $exception,
  };
}

sub config_pair {
  my ($source, $child) = @_;
  return {
    source => config_getter($source, 'dateformat'),
    child => config_getter($child, 'dateformat'),
  };
}

sub date_object_snapshot {
  my ($value) = @_;
  return {
    defined => JSON::PP::false, class => undef, value => undef,
    error_before => undef, error_after => undef, exception => undef,
  } unless defined($value);
  my $snapshot = scalar_value($value);
  return {
    defined => $snapshot->{defined}, class => ref($value),
    value => $snapshot->{value}, error_before => $snapshot->{error_before},
    error_after => $snapshot->{error_after}, exception => $snapshot->{exception},
  };
}

sub recur_snapshot {
  my ($obj) = @_;
  my $start = $obj->start();
  my $end = $obj->end();
  my ($specified_base, $actual_base) = $obj->basedate();
  my @modifiers = $obj->modifiers();
  return {
    frequency => scalar($obj->frequency()),
    start => date_object_snapshot($start),
    end => date_object_snapshot($end),
    specified_base => date_object_snapshot($specified_base),
    actual_base => date_object_snapshot($actual_base),
    modifiers => \@modifiers,
    error => $obj->err(),
  };
}

sub parse_invalid {
  my ($obj) = @_;
  return $obj->parse('not a valid date phrase') if ref($obj) eq 'Date::Manip::Date';
  return $obj->parse('not a valid delta phrase') if ref($obj) eq 'Date::Manip::Delta';
  return $obj->parse('not a valid recurrence phrase');
}

sub valid_sources {
  my ($anchor) = @_;
  return (
    date => $anchor->new_date('2040-02-29 16:05:09'),
    delta => $anchor->new_delta('0:0:0:1:2:3:4'),
    recur => $anchor->new_recur('0:0:1:0:0:0:0'),
  );
}

sub carrier_snapshot {
  my ($obj) = @_;
  my $class = ref($obj);
  return { class => $class, scalar => scalar_value($obj), list => list_value($obj) } if $class eq 'Date::Manip::Date' || $class eq 'Date::Manip::Delta';
  return { class => $class, frequency_scalar => scalar_getter($obj, 'frequency'), frequency_list => list_getter($obj, 'frequency') };
}

sub run_case {
  my ($action, $anchor) = @_;
  my @opts = config_pairs();

  if ($action eq 'direct-constructors') {
    my $date = Date::Manip::Date->new('2040-02-29 16:05:09', \@opts);
    my $delta = Date::Manip::Delta->new('0:0:0:1:2:3:4', \@opts);
    my $recur = Date::Manip::Recur->new('0:0:1:0:0:0:0', \@opts);
    return { date => carrier_snapshot($date), delta => carrier_snapshot($delta), recur => carrier_snapshot($recur) };
  }

  if ($action eq 'receiver-new-empty') {
    my %source = valid_sources($anchor);
    my %out;
    for my $kind (qw(date delta recur)) {
      my $child = $source{$kind}->new();
      $out{$kind} = { source => carrier_snapshot($source{$kind}), child => carrier_snapshot($child) };
    }
    return \%out;
  }

  if ($action eq 'shortcut-class-matrix') {
    my %source = valid_sources($anchor);
    my %out;
    for my $kind (qw(date delta recur)) {
      $out{$kind} = {
        new_date => ref($source{$kind}->new_date()),
        new_delta => ref($source{$kind}->new_delta()),
        new_recur => ref($source{$kind}->new_recur()),
      };
    }
    return \%out;
  }

  if ($action eq 'shortcut-initial-values') {
    my %source = valid_sources($anchor);
    return {
      date_to_delta => carrier_snapshot($source{date}->new_delta('0:0:0:2:3:4:5')),
      delta_to_recur => carrier_snapshot($source{delta}->new_recur('0:0:0:1:0:0:0')),
      recur_to_date => carrier_snapshot($source{recur}->new_date('2040-03-01 05:06:07')),
    };
  }

  if ($action eq 'cross-kind-class-new') {
    my %source = valid_sources($anchor);
    return {
      delta_to_date => carrier_snapshot(Date::Manip::Date->new($source{delta}, '2040-03-02 06:07:08')),
      recur_to_delta => carrier_snapshot(Date::Manip::Delta->new($source{recur}, '0:0:0:3:4:5:6')),
      date_to_recur => carrier_snapshot(Date::Manip::Recur->new($source{date}, '0:0:0:1:0:0:0')),
    };
  }

  if ($action eq 'config-shared-same-kind') {
    my %source = valid_sources($anchor);
    my %out;
    for my $kind (qw(date delta recur)) {
      my $initial_source_config = config_call($source{$kind}, DateFormat => 'US');
      my $child = $source{$kind}->new();
      my $child_change = config_call($child, DateFormat => 'non-US');
      my $after_child = config_pair($source{$kind}, $child);
      my $source_change = config_call($source{$kind}, DateFormat => 'US');
      my $after_source = config_pair($source{$kind}, $child);
      $out{$kind} = {
        classes => [ref($source{$kind}), ref($child)],
        initial_source_config => $initial_source_config,
        child_change => $child_change, after_child_change => $after_child,
        source_change => $source_change, after_source_change => $after_source,
      };
    }
    return \%out;
  }

  if ($action eq 'config-shared-shortcuts') {
    my %source = valid_sources($anchor);
    my %out;
    for my $kind (qw(date delta recur)) {
      my $initial_source_config = config_call($source{$kind}, DateFormat => 'US');
      my @children = ($source{$kind}->new_date(), $source{$kind}->new_delta(), $source{$kind}->new_recur());
      my $child_change = config_call($children[0], DateFormat => 'non-US');
      $out{$kind} = {
        classes => [map { ref($_) } @children],
        initial_source_config => $initial_source_config,
        child_change => $child_change,
        observed => {
          source => config_getter($source{$kind}, 'dateformat'),
          children => [map { config_getter($_, 'dateformat') } @children],
        },
      };
    }
    return \%out;
  }

  if ($action eq 'config-isolated-kinds') {
    my %source = valid_sources($anchor);
    my %out;
    for my $kind (qw(date delta recur)) {
      my $initial_source_config = config_call($source{$kind}, DateFormat => 'US');
      my $derived = $source{$kind}->new_config([DateFormat => 'non-US']);
      my $initial = config_pair($source{$kind}, $derived);
      my $child_change = config_call($derived, DateFormat => 'US');
      my $after_child = config_pair($source{$kind}, $derived);
      my $source_change = config_call($source{$kind}, DateFormat => 'non-US');
      my $after_source = config_pair($source{$kind}, $derived);
      $out{$kind} = {
        classes => [ref($source{$kind}), ref($derived)],
        initial_source_config => $initial_source_config, initial => $initial,
        child_change => $child_change, after_child_change => $after_child,
        source_change => $source_change, after_source_change => $after_source,
      };
    }
    return \%out;
  }

  if ($action eq 'date-value-contexts') {
    my %out;
    for my $selector ('omitted', 'empty', 'other', 'local', 'gmt') {
      my $scalar_obj = $anchor->new_date('2040-02-29 16:05:09 America/New_York');
      my $list_obj = $anchor->new_date('2040-02-29 16:05:09 America/New_York');
      my @arg = $selector eq 'omitted' ? () : $selector eq 'empty' ? ('') : $selector eq 'other' ? ('OTHER') : ($selector);
      $out{$selector} = { scalar => scalar_value($scalar_obj, @arg), list => list_value($list_obj, @arg) };
    }
    return \%out;
  }

  if ($action eq 'date-value-unset') {
    return { scalar => scalar_value($anchor->new_date()), list => list_value($anchor->new_date()) };
  }

  if ($action eq 'delta-value-contexts') {
    return {
      valid => { scalar => scalar_value($anchor->new_delta('0:0:0:1:2:3:4')), list => list_value($anchor->new_delta('0:0:0:1:2:3:4')) },
      fresh => { scalar => scalar_value($anchor->new_delta()), list => list_value($anchor->new_delta()) },
    };
  }

  if ($action eq 'delta-value-error') {
    my $scalar_obj = $anchor->new_delta(); my $scalar_status = $scalar_obj->parse('not a valid delta phrase');
    my $list_obj = $anchor->new_delta(); my $list_status = $list_obj->parse('not a valid delta phrase');
    return { scalar_parse_status => $scalar_status, scalar => scalar_value($scalar_obj), list_parse_status => $list_status, list => list_value($list_obj) };
  }

  if ($action eq 'recur-carrier-getters') {
    my $valid = $anchor->new_recur('0:0:1:0:0:0:0');
    my $fresh = $anchor->new_recur();
    return {
      valid => {
        frequency_scalar => scalar_getter($valid, 'frequency'), frequency_list => list_getter($valid, 'frequency'),
        start => scalar_getter($valid, 'start'), end => scalar_getter($valid, 'end'), basedate => list_getter($valid, 'basedate'), modifiers => list_getter($valid, 'modifiers'),
      },
      fresh => {
        frequency => scalar_getter($fresh, 'frequency'), start => scalar_getter($fresh, 'start'),
        end => scalar_getter($fresh, 'end'), basedate => list_getter($fresh, 'basedate'), modifiers => list_getter($fresh, 'modifiers'),
      },
    };
  }

  if ($action eq 'date-set') {
    my $good = $anchor->new_date('2040-02-29 16:05:09');
    my $good_before = scalar_value($good);
    my $good_status = $good->set('d', 1);
    my $good_error = $good->err();
    my $good_value = scalar_value($good);
    my $raw = $anchor->new_date('2040-02-29 16:05:09');
    my $raw_before = scalar_value($raw);
    my $raw_status = $raw->set('d', 31);
    my $raw_error = $raw->err();
    my $raw_value = scalar_value($raw);
    my $bad_date = $anchor->new_date('2040-02-29 16:05:09');
    my $bad_date_before = scalar_value($bad_date);
    my $bad_date_status = $bad_date->set('date', [2040, 2, 31, 16, 5, 9]);
    my $bad_date_error = $bad_date->err();
    my $bad_date_value = scalar_value($bad_date);
    my $bad_field = $anchor->new_date('2040-02-29 16:05:09');
    my $bad_field_before = scalar_value($bad_field);
    my $bad_field_status = $bad_field->set('bogus', 1);
    my $bad_field_error = $bad_field->err();
    my $bad_field_value = scalar_value($bad_field);
    return {
      success => { before => $good_before, status => $good_status, error_after_set => $good_error, getter => $good_value },
      individual_day_31 => { before => $raw_before, status => $raw_status, error_after_set => $raw_error, getter => $raw_value },
      impossible_whole_date => { before => $bad_date_before, status => $bad_date_status, error_after_set => $bad_date_error, getter => $bad_date_value },
      unknown_field => { before => $bad_field_before, status => $bad_field_status, error_after_set => $bad_field_error, getter => $bad_field_value },
    };
  }

  if ($action eq 'delta-set') {
    my $good = $anchor->new_delta('0:0:0:1:2:3:4');
    my $good_before = scalar_value($good);
    my $good_status = $good->set({ h => 5 });
    my $good_error = $good->err();
    my $good_value = scalar_value($good);
    my $bad = $anchor->new_delta('0:0:0:1:2:3:4');
    my $bad_before = scalar_value($bad);
    my $bad_status = $bad->set({ bogus => 9 });
    my $bad_error = $bad->err();
    my $bad_value = scalar_value($bad);
    return { success => { before => $good_before, status => $good_status, error_after_set => $good_error, getter => $good_value }, invalid => { before => $bad_before, status => $bad_status, error_after_set => $bad_error, getter => $bad_value } };
  }

  if ($action eq 'err-lifecycle') {
    my %source = valid_sources($anchor);
    my %out;
    for my $kind (qw(date delta recur)) {
      my $status = parse_invalid($source{$kind});
      my $after_failure = $source{$kind}->err();
      my $false_return = $source{$kind}->err(0);
      my $after_false = $source{$kind}->err();
      my $true_return = $source{$kind}->err(1);
      my $after_true = $source{$kind}->err();
      $out{$kind} = { status => $status, after_failure => $after_failure, false_return => $false_return, after_false => $after_false, true_return => $true_return, true_return_defined => defined($true_return) ? JSON::PP::true : JSON::PP::false, after_true => $after_true };
    }
    return \%out;
  }

  if ($action eq 'err-isolation') {
    my %source = valid_sources($anchor);
    my %out;
    for my $kind (qw(date delta recur)) {
      my $source_before = $source{$kind}->err();
      my $sibling = $source{$kind}->new();
      my $status = parse_invalid($sibling);
      $out{$kind} = { source_before => $source_before, sibling_status => $status, sibling_error => $sibling->err(), source_after => $source{$kind}->err() };
    }
    return \%out;
  }

  if ($action eq 'method-callability') {
    my %source = valid_sources($anchor);
    my %out;
    for my $kind (qw(date delta recur)) {
      $out{$kind} = { map { $_ => $source{$kind}->can($_) ? JSON::PP::true : JSON::PP::false } qw(new new_config new_date new_delta new_recur value set clear reset clone err config get_config) };
    }
    return \%out;
  }

  if ($action eq 'invalid-constructors') {
    my $date = Date::Manip::Date->new('not a valid date phrase', \@opts);
    my $delta = Date::Manip::Delta->new('not a valid delta phrase', \@opts);
    my $recur = Date::Manip::Recur->new('not a valid recurrence phrase', \@opts);
    return {
      date => { class => ref($date), error_before_getter => $date->err(), getter => scalar_value($date) },
      delta => { class => ref($delta), error_before_getter => $delta->err(), getter => scalar_value($delta) },
      recur => { class => ref($recur), error_before_getter => $recur->err(), frequency => scalar_getter($recur, 'frequency') },
    };
  }

  if ($action eq 'recur-carrier-set') {
    my $recur = $anchor->new_recur();
    my $frequency_status = $recur->frequency('0:0:0:1:0:0:0');
    my $start_status = $recur->start('2040-03-01 08:00:00');
    my $end_status = $recur->end('2040-03-05 08:00:00');
    my $base_status = $recur->basedate('2040-02-29 08:00:00');
    my $after_range_and_base = recur_snapshot($recur);
    my $modifiers_status = $recur->modifiers('fd1', 'bd2');
    my $after_modifiers = recur_snapshot($recur);
    my $replace_status = $recur->frequency('0:0:0:2:0:0:0');
    my $after_frequency_replace = recur_snapshot($recur);
    return {
      setter_statuses => {
        frequency => $frequency_status, start => $start_status, end => $end_status,
        basedate => $base_status, modifiers => $modifiers_status,
      },
      after_range_and_base => $after_range_and_base,
      after_modifiers => $after_modifiers,
      frequency_replace_status => $replace_status,
      after_frequency_replace => $after_frequency_replace,
    };
  }

  die "unknown action\n";
}
