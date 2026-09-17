#!/usr/bin/env perl
use strict;
use warnings;
use Date::Manip::Date;

my $date = Date::Manip::Date->new();
$date->config('Defaults',1, 'ForceDate','2040-02-28-10:20:30,Etc/UTC',
              'Language','English', 'Encoding','ASCII', 'DefaultTime','midnight');
$date->parse('2039-12-31 07:08:09 America/New_York');
print "before local: ", scalar($date->value('local')), "\n";
print "parse_date status: ", $date->parse_date('2040-02-29'), "\n";
print "parsed-zone after: ", scalar($date->value()), "\n";
print "local after: ", scalar($date->value('local')), "\n";
