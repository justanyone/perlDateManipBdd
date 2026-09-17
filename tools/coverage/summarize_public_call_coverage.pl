#!/usr/bin/env perl
# Original summary for the public-call coverage pilot.  It intentionally
# records unloaded modules instead of treating them as zero-valued rows.
use strict;
use warnings;
use Cwd qw(abs_path getcwd);
use Digest::SHA qw(sha256_hex);
use File::Find qw(find);
use File::Spec;
use Getopt::Long qw(GetOptions);
use JSON::PP ();

my ($module_root, $cover_json, $plain_directory, $covered_directory, $output,
    $reference_version, $cover_version, $perl_archname, $cover_module,
    $pilot_script, $runner_script, $summary_script, $execution_path);
GetOptions(
  'module-root=s'       => \$module_root,
  'cover-json=s'        => \$cover_json,
  'plain-directory=s'   => \$plain_directory,
  'covered-directory=s' => \$covered_directory,
  'reference-version=s' => \$reference_version,
  'cover-version=s'     => \$cover_version,
  'perl-archname=s'     => \$perl_archname,
  'execution-path=s'    => \$execution_path,
  'cover-module=s'      => \$cover_module,
  'pilot-script=s'      => \$pilot_script,
  'runner-script=s'     => \$runner_script,
  'summary-script=s'    => \$summary_script,
  'output=s'            => \$output,
) or die "invalid options\n";
for my $required ($module_root, $cover_json, $plain_directory, $covered_directory, $output,
                  $reference_version, $cover_version, $perl_archname, $cover_module,
                  $pilot_script, $runner_script, $summary_script, $execution_path) {
  die "all options are required\n" unless defined $required && length $required;
}

$module_root = abs_path($module_root) or die "module root does not exist\n";
die "module root must end in /Date\n" unless $module_root =~ m{/Date\z};
die "Date-Manip release mismatch\n" unless $reference_version eq '7.00';
die "Devel-Cover release mismatch\n" unless $cover_version eq '1.52';
for my $path ($cover_json, $plain_directory, $covered_directory) {
  die "missing input: $path\n" unless -e $path;
}
my $prefix = "$module_root/Manip";

sub read_json {
  my ($path) = @_;
  open my $fh, '<:raw', $path or die "cannot read $path: $!\n";
  local $/;
  return JSON::PP->new->decode(<$fh>);
}

sub file_sha256 {
  my ($path) = @_;
  open my $fh, '<:raw', $path or die "cannot hash $path: $!\n";
  my $sha = Digest::SHA->new(256);
  $sha->addfile($fh);
  return $sha->hexdigest;
}

my @source_files;
find({
  no_chdir => 1,
  wanted   => sub { push @source_files, $File::Find::name if -f $_ && /\.pm\z/ },
}, $module_root);
@source_files = sort map { abs_path($_) } @source_files;
my %source = map { $_ => 1 } @source_files;

my @manifest = map {
  my $relative = File::Spec->abs2rel($_, $module_root);
  { path => $relative, sha256 => file_sha256($_) }
} @source_files;
my $manifest_sha256 = sha256_hex(join '', map { "$_->{path}\0$_->{sha256}\n" } @manifest);

my $coverage = read_json($cover_json);
die "Devel::Cover JSON has no summary\n" unless ref $coverage->{summary} eq 'HASH';
my (%target_summary, @non_target_summary);
for my $reported_path (sort keys %{ $coverage->{summary} }) {
  next if $reported_path eq 'Total';
  my $absolute = File::Spec->rel2abs($reported_path, getcwd());
  $absolute = abs_path($absolute) if -e $absolute;
  if (defined $absolute && $source{$absolute}) {
    $target_summary{$absolute} = $coverage->{summary}{$reported_path};
  } else {
    push @non_target_summary, $reported_path;
  }
}

my @loaded = sort keys %target_summary;
die "no target library files were instrumented\n" unless @loaded;
my @unloaded = grep { !exists $target_summary{$_} } @source_files;
my %totals = map { $_ => { covered => 0, error => 0, uncoverable => 0, total => 0 } }
  qw(statement branch);
for my $file (@loaded) {
  for my $criterion (qw(statement branch)) {
    my $row = $target_summary{$file}{$criterion} || {};
    for my $field (qw(covered error uncoverable total)) {
      my $value = $row->{$field} // 0;
      die "invalid coverage count for $file $criterion $field\n"
        if ref($value) || "$value" !~ /\A[0-9]+\z/;
    }
    die "inconsistent coverage denominator for $file $criterion\n"
      unless ($row->{total} // 0) == ($row->{covered} // 0) + ($row->{error} // 0) + ($row->{uncoverable} // 0);
    $totals{$criterion}{$_} += $row->{$_} || 0 for qw(covered error uncoverable total);
  }
}
for my $criterion (qw(statement branch)) {
  my $row = $totals{$criterion};
  $row->{effective_denominator} = $row->{covered} + $row->{error};
  $row->{raw_percentage} = $row->{total} ? 100 * $row->{covered} / $row->{total} : undef;
  $row->{tool_effective_percentage} = $row->{effective_denominator}
    ? 100 * $row->{covered} / $row->{effective_denominator} : undef;
}

my @fidelity;
for my $profile (qw(oo dm6 dm5)) {
  my $plain_path = "$plain_directory/plain-$profile.json";
  my $covered_path = "$covered_directory/covered-$profile.json";
  my $plain_stderr_path = "$plain_directory/plain-$profile.stderr";
  my $covered_stderr_path = "$covered_directory/covered-$profile.stderr";
  die "missing pilot output for $profile\n"
    unless -f $plain_path && -f $covered_path && -f $plain_stderr_path && -f $covered_stderr_path;
  open my $plain_fh, '<:raw', $plain_path or die $!;
  open my $covered_fh, '<:raw', $covered_path or die $!;
  local $/;
  my $plain_bytes = <$plain_fh>;
  my $covered_bytes = <$covered_fh>;
  my $plain = JSON::PP->new->decode($plain_bytes);
  my $covered = JSON::PP->new->decode($covered_bytes);
  open my $plain_stderr_fh, '<:raw', $plain_stderr_path or die $!;
  open my $covered_stderr_fh, '<:raw', $covered_stderr_path or die $!;
  my $plain_stderr = <$plain_stderr_fh>;
  my $covered_stderr = <$covered_stderr_fh>;
  die "pilot did not complete its public requests for $profile\n"
    if defined($plain->{exception}) || ref($plain->{result}) ne 'HASH';
  die "instrumentation changed the pilot result for $profile\n"
    unless $plain_bytes eq $covered_bytes;
  die "instrumentation changed process stderr for $profile\n"
    unless $plain_stderr eq $covered_stderr;
  push @fidelity, {
    profile => $profile,
    byte_identical_json_stdout => $plain_bytes eq $covered_bytes ? JSON::PP::true : JSON::PP::false,
    plain_sha256 => sha256_hex($plain_bytes),
    covered_sha256 => sha256_hex($covered_bytes),
    byte_identical_process_stderr => $plain_stderr eq $covered_stderr ? JSON::PP::true : JSON::PP::false,
    plain_stderr_sha256 => sha256_hex($plain_stderr),
    covered_stderr_sha256 => sha256_hex($covered_stderr),
    process_stderr => $plain_stderr,
    exception => $plain->{exception},
    warnings => $plain->{warnings},
    call_stdout => $plain->{call_stdout},
  };
}

my $result = {
  schema_version => 1,
  status => 'public-call instrumentation pilot; not a full-suite or completion coverage result',
  coverage_tool => { name => 'Devel::Cover', version => $cover_version, criteria => [qw(statement branch)] },
  verified_runtime => {
    date_manip_version => $reference_version,
    perl_archname => $perl_archname,
    installed_modules_sha256 => {
      'Date/Manip.pm' => file_sha256("$module_root/Manip.pm"),
      'Devel/Cover.pm' => file_sha256($cover_module),
    },
    tooling_sha256 => {
      public_call_pilot => file_sha256($pilot_script),
      runner => file_sha256($runner_script),
      summarizer => file_sha256($summary_script),
    },
    clean_environment => {
      PATH => $execution_path,
      LANG => 'C.UTF-8',
      LC_ALL => 'C.UTF-8',
      TZ => 'Etc/UTC',
      inherited_environment => JSON::PP::false,
      fresh_working_directory_per_plain_and_covered_profile => JSON::PP::true,
    },
  },
  collection_scope => {
    public_entrypoints_only => JSON::PP::true,
    source_module_root => $module_root,
    source_inventory_file_count => scalar @source_files,
    source_inventory_manifest_sha256 => $manifest_sha256,
    source_inventory => \@manifest,
    reported_target_source_file_count => scalar @loaded,
    reported_target_source_files => [ map { File::Spec->abs2rel($_, $module_root) } @loaded ],
    unloaded_source_file_count => scalar @unloaded,
    unloaded_source_files => [ map { File::Spec->abs2rel($_, $module_root) } @unloaded ],
    non_target_summary_files_filtered => \@non_target_summary,
    denominator_note => 'Devel::Cover creates criteria only for modules that loaded. Unloaded Date::Manip modules are listed separately and are not fabricated as zero-valued coverage rows.',
  },
  totals => \%totals,
  fidelity => \@fidelity,
  exclusions_requiring_final_review => [
    'No Date::Manip source file was excluded from the inventory.',
    'Unloaded source files have no Devel::Cover criterion rows in this pilot; they must be loaded through public calls before a final coverage claim.',
    'The installed upstream source has three Devel::Cover uncoverable annotations in Date::Manip::Obj (two statements and one false branch). This pilot reports them separately and does not approve them as final exclusions.',
    'The Devel::Cover JSON report also contains the pilot program; it is filtered only when calculating Date::Manip totals.',
  ],
};

open my $out, '>:raw', $output or die "cannot write $output: $!\n";
print {$out} JSON::PP->new->canonical->pretty->encode($result) or die "cannot write $output: $!\n";
close $out or die "cannot close $output: $!\n";
