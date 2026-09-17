#!/usr/bin/env perl
# Original fixed-input research probe for the Date::Manip language profiles.
use strict;
use warnings;
use utf8;
use JSON::PP qw(decode_json);
use Digest::SHA qw(sha256_hex);
use Config ();
use FindBin qw($Bin);

my ($profile, $mode, $language_id) = @ARGV;
die "profile, mode, and language ID required\n" unless defined $language_id;
die "unexpected arguments\n" if @ARGV > 3;
die "unknown profile\n" unless $profile eq 'dm6' || $profile eq 'dm5';
die "unknown mode\n" unless ($profile eq 'dm6' && ($mode eq 'ascii' || $mode eq 'utf8'))
                              || ($profile eq 'dm5' && ($mode eq 'legacy-default' || $mode eq 'legacy-international'));

open my $fixture_fh, '<:raw', "$Bin/../../../docs/research/language-family/cases.json" or die $!;
my $fixture_bytes = do { local $/; <$fixture_fh> };
my $fixture_sha256 = sha256_hex($fixture_bytes);
my $fixtures = decode_json($fixture_bytes);
my ($language) = grep { $_->{id} eq $language_id } @{$fixtures->{languages}};
die "unknown language ID\n" unless $language;
my $input_mode = $mode eq 'ascii' || $mode eq 'legacy-default' ? 'ascii' : 'utf8';
my $inputs = $language->{$input_mode};

my @warnings;
my $call_stdout = '';
my $result;
{
  local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
  local *STDOUT;
  open STDOUT, '>:encoding(UTF-8)', \$call_stdout or die $!;
  $result = $profile eq 'dm6' ? probe_dm6() : probe_dm5();
}

my $record = {
  schema_version       => 1,
  case_id              => join('-', 'LANG', uc($profile), uc($mode), $language_id =~ s/^lang\.//r),
  operation_id         => 'language.canonical-runtime-corpus',
  contract_ids         => $profile eq 'dm6'
                          ? ['date.parse-text', 'date.render-pattern', 'config.apply-settings']
                          : $result->{dependent_operations_executed}
                            ? ['date.parse-leading-tokens', 'date.render-pattern', 'config.apply-settings']
                            : ['config.apply-settings'],
  partition_ids        => ["language.$language_id", "language.profile.$profile", "language.mode.$mode"],
  profile              => $profile,
  mode                 => $mode,
  language_id          => $language_id,
  canonical_language   => $language->{canonical},
  fixture              => {
    fixed_clock       => $fixtures->{fixed_clock},
    target_date       => $fixtures->{target_date},
    target_weekday    => $fixtures->{target_weekday},
    date_order        => $fixtures->{date_order},
    input_mode        => $input_mode,
    full_date         => $inputs->{full_date},
    weekday_date      => $inputs->{weekday_date},
    tomorrow          => $inputs->{tomorrow},
    special           => $inputs->{special},
    special_rule      => $language->{special_rule},
    render_source     => '2040-02-29 16:05:09',
    render_pattern    => '%A|%B',
  },
  fixture_sha256       => $fixture_sha256,
  environment          => { LANG => 'C.UTF-8', LC_ALL => 'C.UTF-8', TZ => 'Etc/UTC', PERL_HASH_SEED => '0', PERL_PERTURB_KEYS => '0', cwd => 'fresh temporary directory' },
  distribution_version => $profile eq 'dm6' ? $Date::Manip::Date::VERSION : $Date::Manip::DM5::VERSION,
  perl_version         => "$^V",
  perl_archname        => $Config::Config{archname},
  raw_return           => $result,
  warnings             => \@warnings,
  call_stdout          => $call_stdout,
};

binmode STDOUT, ':encoding(UTF-8)';
print JSON::PP->new->canonical->utf8(0)->encode($record), "\n";

sub dm6_date {
  require Date::Manip::Date;
  my $d = Date::Manip::Date->new();
  my $encoding = $mode eq 'ascii' ? 'ASCII' : 'UTF-8';
  my $config_exception;
  my $config_status;
  {
    local $@;
    my $ok = eval {
      $config_status = $d->config(
        Defaults   => 1,
        ForceDate => '2040-02-28-10:20:30,Etc/UTC',
        Language  => $language->{canonical},
        Encoding  => $encoding,
        DateFormat => 'non-US',
      );
      1;
    };
    $config_exception = "$@" unless $ok;
  }
  return ($d, {
    requested => ['Defaults=1', 'ForceDate=2040-02-28-10:20:30,Etc/UTC', "Language=$language->{canonical}", "Encoding=$encoding", 'DateFormat=non-US'],
    status => $config_status,
    error => $d->err,
    exception => $config_exception,
    effective => {
      language => scalar($d->get_config('language')),
      encoding => scalar($d->get_config('encoding')),
      date_format => scalar($d->get_config('dateformat')),
    },
  });
}

sub dm6_parse {
  my ($text) = @_;
  my ($d, $setup) = dm6_date();
  my ($status, $exception);
  {
    local $@;
    my $ok = eval { $status = $d->parse($text); 1 };
    $exception = "$@" unless $ok;
  }
  my $error = $d->err;
  my $value = defined($status) && "$status" eq '0' && $error eq '' ? scalar($d->value) : undef;
  return { input => $text, status => $status, value => $value, error => $error, exception => $exception, setup => $setup };
}

sub probe_dm6 {
  require Date::Manip::Date;
  die "Date::Manip distribution mismatch\n" unless $Date::Manip::Date::VERSION eq $fixtures->{reference_assertions}{distribution_version};
  my $reference_date = Date::Manip::Date->new();
  my $reference_tz = $reference_date->tz();
  my $tzdata = $reference_tz->tzdata();
  my $tzcode = $reference_tz->tzcode();
  die "tzdata mismatch\n" unless $tzdata eq $fixtures->{reference_assertions}{tzdata};
  die "tzcode mismatch\n" unless $tzcode eq $fixtures->{reference_assertions}{tzcode};
  my $full = dm6_parse($inputs->{full_date});
  my $weekday = dm6_parse($inputs->{weekday_date});
  my $tomorrow = dm6_parse($inputs->{tomorrow});
  my $special = defined $inputs->{special} ? dm6_parse($inputs->{special}) : undef;
  $special->{case_id} = join('-', 'LANG', 'DM6', uc($mode), $language_id =~ s/^lang\.//r, 'PREPROCESS') if defined $special;
  my ($d, $setup) = dm6_date();
  my ($parse_status, $rendered, $exception);
  {
    local $@;
    my $ok = eval {
      $parse_status = $d->parse('2040-02-29 16:05:09');
      $rendered = $d->printf('%A|%B') if defined($parse_status) && "$parse_status" eq '0' && $d->err eq '';
      1;
    };
    $exception = "$@" unless $ok;
  }
  my $render = { parse_status => $parse_status, value => $rendered, error => $d->err, exception => $exception, setup => $setup };
  return {
    backend_version => $Date::Manip::Date::VERSION,
    reference_assertions => { distribution_version => $Date::Manip::Date::VERSION, backend_version => $Date::Manip::Date::VERSION, tzdata => $tzdata, tzcode => $tzcode },
    full_date => $full,
    matching_weekday => $weekday,
    tomorrow => $tomorrow,
    rendering => $render,
    special_preprocessing => $special,
  };
}

sub probe_dm5 {
  require Date::Manip::DM5;
  die "Date::Manip distribution mismatch\n" unless $Date::Manip::DM5::VERSION eq $fixtures->{reference_assertions}{distribution_version};
  my $backend_version = Date::Manip::DM5::DateManipVersion();
  die "DM5 backend mismatch\n" unless $backend_version eq $fixtures->{reference_assertions}{dm5_backend_version};
  my $int_charset = $mode eq 'legacy-international' ? 1 : 0;
  my @settings = (
    'IgnoreGlobalCnf=1', 'PersonalCnf=', 'PersonalCnfPath=',
    'ForceDate=2040-02-28-10:20:30', 'TZ=Etc/UTC',
    "Language=$language->{canonical}", 'DateFormat=non-US', 'Internal=0',
    "IntCharSet=$int_charset", 'TodayIsMidnight=1', 'EraseHolidays=1',
  );
  my ($init_status, $init_exception);
  {
    local $@;
    my $ok = eval { $init_status = Date::Manip::DM5::Date_Init(@settings); 1 };
    $init_exception = "$@" unless $ok;
  }
  if (defined $init_exception) {
    return {
      backend_version => $backend_version,
      reference_assertions => { distribution_version => $Date::Manip::DM5::VERSION, backend_version => $backend_version, timezone_data => 'not exposed by DM5' },
      setup => { requested => \@settings, status => $init_status, exception => $init_exception },
      dependent_operations_executed => JSON::PP::false,
      full_date => undef,
      matching_weekday => undef,
      tomorrow => undef,
      rendering => undef,
      special_preprocessing => undef,
    };
  }
  my $parse = sub {
    my ($text) = @_;
    my ($value, $exception);
    {
      local $@;
      my $ok = eval { $value = Date::Manip::DM5::ParseDate($text); 1 };
      $exception = "$@" unless $ok;
    }
    return { input => $text, value => $value, defined => defined($value) ? JSON::PP::true : JSON::PP::false, exception => $exception };
  };
  my $rendered;
  my $render_exception;
  if (!defined $init_exception) {
    local $@;
    my $ok = eval { $rendered = Date::Manip::DM5::UnixDate('2040022916:05:09', '%A|%B'); 1 };
    $render_exception = "$@" unless $ok;
  }
  my $special = defined($inputs->{special}) ? $parse->($inputs->{special}) : undef;
  $special->{case_id} = join('-', 'LANG', 'DM5', uc($mode), $language_id =~ s/^lang\.//r, 'PREPROCESS') if defined $special;
  return {
    backend_version => $backend_version,
    reference_assertions => { distribution_version => $Date::Manip::DM5::VERSION, backend_version => $backend_version, timezone_data => 'not exposed by DM5' },
    setup => { requested => \@settings, status => $init_status, exception => $init_exception },
    dependent_operations_executed => JSON::PP::true,
    full_date => $parse->($inputs->{full_date}),
    matching_weekday => $parse->($inputs->{weekday_date}),
    tomorrow => $parse->($inputs->{tomorrow}),
    rendering => { value => $rendered, defined => defined($rendered) ? JSON::PP::true : JSON::PP::false, exception => $render_exception },
    special_preprocessing => $special,
  };
}
