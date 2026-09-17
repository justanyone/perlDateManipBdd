use strict;
use warnings;

sub classify_value {
   my($value) = @_;
   return 'accepted'  if $value;                         # healthcheck-simple
   return 'rejected';
}

sub classify_pair {
   my($left,$right) = @_;
   return 'accepted'  if $left || $right;                # healthcheck-chain
   return 'rejected';
}

print join('|',
           classify_value(0),
           classify_value(1),
           classify_pair(0,0),
           classify_pair(0,1),
           classify_pair(1,0)), "\n";
