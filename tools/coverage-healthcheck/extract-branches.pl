use strict;
use warnings;

use Devel::Cover::DB;
use JSON::PP;

my($database,$source) = @ARGV;
die "usage: $0 DATABASE SOURCE\n"  if ! defined($source) || @ARGV != 2;

my $database_object = Devel::Cover::DB->new(db => $database)->merge_runs;
my $file = $database_object->cover->file($source)
  or die "source is absent from coverage database: $source\n";
my $branches = $file->branch
  or die "branch criteria are absent for source: $source\n";

my @rows;
for my $line (sort { $a <=> $b } $branches->items) {
   my $index = 0;
   for my $criterion (@{$branches->location($line)}) {
      push @rows, {
         line     => 0 + $line,
         index    => $index++,
         text     => $criterion->text,
         outcomes => [map { 0 + ($criterion->covered($_) || 0) }
                       0 .. $criterion->total - 1],
      };
   }
}

print JSON::PP->new->canonical->encode({branches => \@rows}), "\n";
