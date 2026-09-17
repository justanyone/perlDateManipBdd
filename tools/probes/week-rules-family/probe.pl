#!/usr/bin/env perl
# Public Base::week_of_year matrix observation; no private call is made.
use strict;
use warnings;
use Config ();
use Digest::SHA qw(sha256_hex);
use FindBin qw($Bin);
use JSON::PP ();

sub read_json {
  my ($path) = @_; open my $fh, '<:raw', $path or die "read $path: $!";
  return JSON::PP->new->decode(do { local $/; <$fh> });
}
sub carrier {
  my ($value) = @_;
  return {defined=>JSON::PP::false, type=>'absent', value=>undef} unless defined $value;
  return {defined=>JSON::PP::true, type=>ref($value) || 'text', value=>$value};
}
sub module_paths {
  return {map {$_ => $INC{$_}} sort grep {m{\ADate/Manip/.+\.pm\z}} keys %INC};
}

my $root = "$Bin/../../..";
my $manifest_path = "$root/docs/research/week-rules-family/matrix-manifest.json";
my $manifest_bytes; { open my $fh, '<:raw', $manifest_path or die $!; $manifest_bytes = do {local $/; <$fh>}; }
my $manifest = JSON::PP->new->decode($manifest_bytes);
my @warnings;
my ($call_stdout, $exception, $stage) = ('', undef, 'load');
my %out = (
  operation_id => 'calendar.week-number', manifest_sha256 => sha256_hex($manifest_bytes),
  runtime => {perl_version=>"$^V", perl_archname=>$Config::Config{archname}, os_name=>$^O},
  request_summary => {configurations=>scalar(@{$manifest->{configurations}}), years=>scalar(@{$manifest->{years}}), dates_per_year=>scalar(@{$manifest->{date_order}})},
);
{
  local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
  local *STDOUT; open STDOUT, '>', \$call_stdout or die "capture STDOUT: $!";
  my $ok = eval {
    require Date::Manip::Base;
    die 'wrong Date::Manip version' unless $Date::Manip::Base::VERSION eq '7.00';
    $out{distribution_version} = $Date::Manip::Base::VERSION;
    my %inverse_selected = map {$_=>1} @{$manifest->{selected_inverse_configurations}};
    $out{configurations} = [];
    for my $config (@{$manifest->{configurations}}) {
      $stage = "configure $config->{case_id}";
      my $base = Date::Manip::Base->new;
      my ($config_return, $config_exception);
      eval {$config_return = $base->config('firstday',$config->{first_day},'week1ofyear',$config->{week1_of_year}); 1} or $config_exception = "$@";
      die "configuration failed for $config->{case_id}: $config_exception" if $config_exception;
      my $entry = {case_id=>$config->{case_id}, first_day=>$config->{first_day}, week1_of_year=>$config->{week1_of_year}, configuration_return=>carrier($config_return), years=>[]};
      for my $year (@{$manifest->{years}}) {
        $stage = "forward $config->{case_id}/$year->{year}";
        my @forward;
        for my $date (@{$manifest->{date_order}}) {
          my @pair = $base->week_of_year([$year->{year},$date->{month},$date->{day}]);
          die "unexpected forward arity" unless @pair == 2;
          push @forward, \@pair;
        }
        my $record = {year=>$year->{year}, forward=>\@forward};
        if ($inverse_selected{$config->{case_id}}) {
          $stage = "inverse $config->{case_id}/$year->{year}";
          my @inverse;
          for my $week (@{$manifest->{inverse_weeks}}) {
            my $ymd = $base->week_of_year($year->{year},$week);
            die "inverse did not return an array reference" unless ref($ymd) eq 'ARRAY' && @$ymd == 3;
            push @inverse, [$week, @$ymd];
          }
          $record->{inverse} = \@inverse;
        }
        push @{$entry->{years}}, $record;
      }
      push @{$out{configurations}}, $entry;
    }
    $out{loaded_module_paths} = module_paths();
    1;
  };
  $exception = $ok ? undef : "$@";
}
$out{exception}=$exception; $out{exception_stage}=$exception ? $stage : undef;
$out{warnings}=\@warnings; $out{call_stdout}=$call_stdout;
print JSON::PP->new->canonical->encode(\%out), "\n";
