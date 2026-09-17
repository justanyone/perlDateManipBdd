#!/usr/bin/env perl
# Original public-call observation only; this is not a fixture generator.
use strict;
use warnings;
use Config ();
use FindBin qw($Bin);
use JSON::PP ();

sub read_json {
  my ($path) = @_;
  open my $fh, '<:raw', $path or die "read $path: $!";
  return JSON::PP->new->decode(do { local $/; <$fh> });
}
sub carrier {
  my ($value) = @_;
  return { defined => JSON::PP::false, type => 'absent', value => undef } unless defined $value;
  return { defined => JSON::PP::true, type => ref($value) || 'text', value => $value };
}
sub loaded_module_paths {
  my %found;
  for my $module (sort grep { m{\ADate/Manip/.+\.pm\z} } keys %INC) {
    $found{$module} = $INC{$module};
  }
  return \%found;
}

my $case_id = shift @ARGV // die 'case ID required';
die 'unexpected arguments' if @ARGV;
my $root = "$Bin/../../..";
my $corpus = read_json("$root/docs/research/replace-time-family/cases.json");
my ($case) = grep { $_->{case_id} eq $case_id } @{$corpus->{cases}};
die "unknown case $case_id" unless $case;
my $all_profiles = read_json("$root/docs/automation/reference-profiles.json");
my ($profile) = grep { $_->{name} eq $case->{backend} } @{$all_profiles->{profiles}};
die "missing profile for $case->{backend}" unless $profile;

my @warnings;
my ($call_stdout, $exception, $stage) = ('', undef, 'load');
my %out = (
  case_id => $case_id,
  request => $case,
  operation_id => 'date.replace-time',
  profile_expected => $profile->{configuration},
  fixture_expected_distribution_version => $all_profiles->{reference}{distribution_version},
  fixture_expected_backend_version => $profile->{backend_version},
  runtime => { perl_version => "$^V", perl_archname => $Config::Config{archname}, os_name => $^O },
);
{
  local $SIG{__WARN__} = sub { push @warnings, "$_[0]" };
  local *STDOUT;
  open STDOUT, '>', \$call_stdout or die "capture STDOUT: $!";
  my $ok = eval {
    my $package = $case->{backend} eq 'dm6' ? 'Date::Manip::DM6' :
                  $case->{backend} eq 'dm5' ? 'Date::Manip::DM5' : die 'unsupported backend';
    eval "require $package; 1" or die $@;
    no strict 'refs';
    (my $package_file = "$package.pm") =~ s{::}{/}g;
    $out{public_symbol} = $package . '::Date_SetTime';
    $out{loaded_binding_file} = $INC{$package_file};
    $out{observed_distribution_version} = ${$package . '::VERSION'};
    $out{observed_backend_version} = &{$package . '::DateManipVersion'}();
    die 'wrong distribution version' unless $out{observed_distribution_version} eq $out{fixture_expected_distribution_version};
    die 'wrong backend version' unless $out{observed_backend_version} eq $out{fixture_expected_backend_version};
    $stage = 'configuration';
    $out{configuration_return} = carrier(&{$package . '::Date_Init'}(@{$profile->{configuration}}));
    $out{configured_zone} = &{$package . '::Date_TimeZone'}();
    die 'configured zone differs from fixture' unless lc($out{configured_zone}) =~ /\A(?:etc\/)?utc\z/;
    $out{loaded_module_paths} = loaded_module_paths();
    die 'binding module did not load' unless exists $out{loaded_module_paths}{$package_file};
    $stage = 'scalar call';
    my ($scalar, $scalar_exception);
    eval { $scalar = &{$package . '::Date_SetTime'}(@{$case->{arguments}}); 1 } or $scalar_exception = "$@";
    $out{scalar_context} = { exception => $scalar_exception };
    $out{scalar_context}{return} = carrier($scalar) unless $scalar_exception;
    $stage = 'list call';
    my (@list, $list_exception);
    eval { @list = &{$package . '::Date_SetTime'}(@{$case->{arguments}}); 1 } or $list_exception = "$@";
    $out{list_context} = { exception => $list_exception };
    $out{list_context}{items} = [map { carrier($_) } @list] unless $list_exception;
    $stage = 'done';
    1;
  };
  $exception = $ok ? undef : "$@";
}
$out{exception} = $exception;
$out{exception_stage} = $exception ? $stage : undef;
$out{warnings} = \@warnings;
$out{call_stdout} = $call_stdout;
print JSON::PP->new->canonical->encode(\%out), "\n";
