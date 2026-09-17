#!/usr/bin/env perl
# Original numeric coverage inventory; never exports upstream source text.
use strict;
use warnings;
use Devel::Cover::DB;
use JSON::PP;
use Cwd qw(abs_path);
my ($database, $library) = @ARGV;
die "usage: locations.pl DATABASE DATE_MANIP_LIBRARY\n" unless @ARGV == 2;
die 'missing database directory' unless -d $database;
$library = abs_path($library) or die 'missing library';
my $db = Devel::Cover::DB->new(db => $database);
my @rows;
my %totals;
for my $file (sort $db->cover->items) {
    my $absolute = abs_path($file) or die "missing measured file: $file";
    next unless $absolute eq "$library/Date/Manip.pm" || index($absolute, "$library/Date/Manip/") == 0;
    my $relative = substr($absolute, length($library) + 1);
    my $measured = $db->cover->file($file);
    for my $kind (qw(statement branch)) {
        my $criteria = $measured->$kind;
        next unless $criteria;
        for my $location (sort {$a <=> $b} $criteria->items) {
            my $ordinal = 0;
            for my $criterion (@{$criteria->location($location)}) {
                for my $outcome (0 .. $criterion->total - 1) {
                    my $hits = $criterion->covered($outcome) || 0;
                    my $annotation = $criterion->uncoverable($outcome) ? 1 : 0;
                    die 'invalid hit count' unless $hits =~ /^\d+$/;
                    $totals{$kind}{total}++;
                    $totals{$kind}{executed}++ if $hits > 0;
                    $totals{$kind}{unexecuted}++ if $hits == 0;
                    $totals{$kind}{annotated}++ if $annotation;
                    push @rows, {
                        file => $relative, kind => $kind, location => 0 + $location,
                        criterion_index => $ordinal, outcome_index => $outcome,
                        hits => 0 + $hits, upstream_annotation => $annotation,
                    } if !$hits || $annotation;
                }
                $ordinal++;
            }
        }
    }
}
die 'no measured Date::Manip statements' unless $totals{statement}{total};
print JSON::PP->new->canonical->pretty->encode({
    schema_version => 1,
    scope => 'Measured Date::Manip files only; unloaded modules have no fabricated criteria',
    disposition => 'Every listed unexecuted outcome requires review; annotations are not approved exclusions',
    source_text_included => JSON::PP::false,
    totals => \%totals, outstanding => \@rows,
});
