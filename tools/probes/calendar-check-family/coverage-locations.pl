#!/usr/bin/env perl
# Numeric measurement only for the pinned public validation routines.
use strict;
use warnings;
use Devel::Cover::DB;
use JSON::PP;
use Cwd qw(abs_path);
use Digest::SHA qw(sha256_hex);
my ($database, $base_path) = @ARGV;
die 'database and pinned Base.pm required' unless @ARGV == 2;
$base_path = abs_path($base_path) or die 'missing Base.pm';
open my $fh, '<', $base_path or die $!;
my $source_hash = sha256_hex(do { local $/; <$fh> });
die 'unexpected Base.pm version' unless $source_hash eq '5fe1f12a7b59c57baf71c86e266b4ea06851eac0ec203a3507d019bcadbea97c';
my $db = Devel::Cover::DB->new(db => $database);
my $file = $db->cover->file($base_path) or die 'Base.pm not measured';
my @rows;
my %totals;
for my $kind (qw(statement branch)) {
    $totals{$kind} = {total => 0, executed => 0};
    my $criteria = $file->$kind;
    for my $line (sort {$a <=> $b} $criteria->items) {
        next if $line < 602 || $line > 623;
        my $index = 0;
        for my $criterion (@{$criteria->location($line)}) {
            for my $outcome (0 .. $criterion->total - 1) {
                my $hits = $criterion->covered($outcome) || 0;
                push @rows, {kind => $kind, line => 0+$line, criterion_index => $index,
                             outcome_index => $outcome, hits => 0+$hits};
                $totals{$kind}{total}++;
                $totals{$kind}{executed}++ if $hits > 0;
            }
            $index++;
        }
    }
    die "no $kind criteria" unless $totals{$kind}{total};
}
print JSON::PP->new->canonical->pretty->encode({
    scope => 'Base.pm public check and check_time, lines 602 through 623 only',
    base_sha256 => $source_hash, totals => \%totals, criteria => \@rows,
    limitation => 'Statement and branch outcomes only; does not measure condition coverage or prove every input representation.',
});
