#!/usr/bin/env perl
# Original syntax audit using the pinned runner's public parser.
use strict;
use warnings;
use JSON::PP ();
use Test::BDD::Cucumber::Parser;
die 'expected Test::BDD::Cucumber parser0.87' unless $Test::BDD::Cucumber::Parser::VERSION eq '0.87';
die 'feature paths required' unless @ARGV;
my @rows;
for my $path (@ARGV) {
 my ($feature,$error); my @warnings;
 {local $SIG{__WARN__}=sub {push @warnings,"$_[0]"}; eval {$feature=Test::BDD::Cucumber::Parser->parse_file($path);1} or $error="$@";}
 my %row=(path=>$path,error=>$error,warnings=>\@warnings);
 if ($feature) {
  $row{scenario_count}=scalar @{$feature->scenarios};
  $row{expanded_count}=0;
  for my $s (@{$feature->scenarios}) {
   my $n=0;
   $n+=scalar @{$_->data} for @{$s->datasets};
   $row{expanded_count}+=@{$s->datasets} ? $n : 1;
  }
 }
 push @rows,\%row;
}
print JSON::PP->new->canonical->pretty->encode(\@rows);
my $failed = grep {$_->{error} || @{$_->{warnings}}} @rows;
exit($failed ? 1 : 0);
