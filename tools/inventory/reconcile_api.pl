#!/usr/bin/env perl
use v5.16;
use strict;
use warnings;
use File::Find qw(find);
use File::Path qw(make_path);
use File::Spec;
use Getopt::Long qw(GetOptions);
use JSON::PP qw(encode_json);

# This is an original research enumerator.  It reads only the project's
# declaration CSV and release metadata; it does not copy source text or tests.
my %arg = (
   inventory => 'docs/planning/perl-api-inventory.csv',
   source    => '/tmp/Date-Manip-7.00',
   outdir    => 'docs/research/api',
);
GetOptions(
   'inventory=s' => \$arg{inventory},
   'source=s'    => \$arg{source},
   'outdir=s'    => \$arg{outdir},
   'check'        => \$arg{check},
) or die "usage: $0 [--inventory FILE] [--source DIR] [--outdir DIR] [--check]\n";

sub release_version {
   my ($path) = @_;
   open my $fh, '<', $path or die "cannot read release marker $path: $!\n";
   my $text = do { local $/; <$fh> };
   return $1 if $text =~ /\$VERSION\s*=\s*['\"]([^'\"]+)['\"]/;
   die "no VERSION marker found in $path\n";
}
my %release_marker;
for my $file (qw(lib/Date/Manip.pm lib/Date/Manip/DM5.pm lib/Date/Manip/DM6.pm)) {
   my $path = File::Spec->catfile($arg{source}, split m{/}, $file);
   $release_marker{$file} = release_version($path);
   die "expected Date-Manip 7.00 in $path; found $release_marker{$file}\n" unless $release_marker{$file} eq '7.00';
}

my %functional = (
   DateManipVersion     => 'meta.reference-version',
   Date_Init            => 'config.apply-settings',
   ParseDateString      => 'date.parse-text',
   ParseDate            => 'date.parse-leading-tokens',
   ParseDateFormat      => 'date.parse-pattern',
   ParseDateDelta       => 'delta.parse-text',
   ParseRecur           => 'recur.parse-and-enumerate',
   DateCalc             => 'arithmetic.calculate',
   Date_Cmp             => 'date.compare',
   UnixDate             => 'date.render-pattern',
   Delta_Format         => 'delta.render-fields',
   Date_GetPrev         => 'date.find-previous',
   Date_GetNext         => 'date.find-next',
   Date_SetTime         => 'date.replace-time',
   Date_SetDateField    => 'date.replace-field',
   Date_IsHoliday       => 'business.holiday-labels',
   Date_IsWorkDay       => 'business.is-working-date',
   Events_List          => 'events.list',
   Date_NextWorkDay     => 'business.next-working-date',
   Date_PrevWorkDay     => 'business.previous-working-date',
   Date_NearestWorkDay  => 'business.nearest-working-date',
   Date_DayOfWeek       => 'calendar.weekday',
   Date_SecsSince1970   => 'epoch.local-civil-seconds',
   Date_SecsSince1970GMT=> 'epoch.utc-civil-seconds',
   Date_DaysSince1BC    => 'calendar.day-ordinal',
   Date_DayOfYear       => 'calendar.day-of-year',
   Date_NthDayOfYear    => 'calendar.date-from-day-of-year',
   Date_DaysInMonth     => 'calendar.days-in-month',
   Date_DaysInYear      => 'calendar.days-in-year',
   Date_WeekOfYear      => 'calendar.week-number',
   Date_LeapYear        => 'calendar.is-leap-year',
   Date_DaySuffix       => 'date.localized-day-ordinal',
   Date_ConvTZ          => 'zone.convert-canonical-text',
   Date_TimeZone        => 'zone.current',
);

my %object = (
   'Date::Manip::Obj' => {
      new => 'object.create', new_config => 'context.create', new_date => 'date.create',
      new_delta => 'delta.create', new_recur => 'recur.create', base => 'context.base-service',
      tz => 'context.zone-service', config => 'config.apply-settings', get_config => 'config.read-settings',
      err => 'error.read-state', is_date => 'object.kind-check', is_delta => 'object.kind-check',
      is_recur => 'object.kind-check', version => 'meta.reference-version',
   },
   'Date::Manip::Base' => {
      days_since_1BC => 'calendar.day-ordinal', day_of_week => 'calendar.weekday',
      leapyear => 'calendar.is-leap-year', days_in_year => 'calendar.days-in-year',
      days_in_month => 'calendar.days-in-month', day_of_year => 'calendar.day-of-year',
      nth_day_of_week => 'calendar.nth-weekday',
      check => 'calendar.validate-date', check_time => 'calendar.validate-time',
      secs_since_1970 => 'epoch.local-civil-seconds',
      week1_day1 => 'calendar.week-year-start', weeks_in_year => 'calendar.weeks-in-year',
      week_of_year => 'calendar.week-number', calc_date_date => 'arithmetic.date-difference',
      calc_date_days => 'arithmetic.date-plus-days', calc_date_delta => 'arithmetic.date-plus-delta',
      calc_date_time => 'arithmetic.date-plus-time', calc_time_time => 'arithmetic.combine-times',
      cmp => 'date.compare', split => 'value.split-fields', join => 'value.join-fields',
   },
   'Date::Manip::Date' => {
      is_date => 'object.kind-check', input => 'date.read-input', parse => 'date.parse-text',
      parse_time => 'time.parse-text', parse_date => 'date.parse-date-only', parse_format => 'date.parse-pattern',
      value => 'date.read-value', cmp => 'date.compare', prev => 'date.find-previous',
      next => 'date.find-next', calc => 'arithmetic.calculate', secs_since_1970_GMT => 'epoch.utc-instant-seconds',
      week_of_year => 'calendar.week-number', complete => 'date.complete-missing-fields', convert => 'zone.convert-value',
      is_business_day => 'business.is-working-date', list_holidays => 'business.list-holidays',
      holiday => 'business.holiday-labels', next_business_day => 'business.next-working-date',
      prev_business_day => 'business.previous-working-date', nearest_business_day => 'business.nearest-working-date',
      list_events => 'events.list', set => 'date.replace-field', printf => 'date.render-pattern',
   },
   'Date::Manip::Delta' => {
      is_delta => 'object.kind-check', config => 'config.apply-settings', value => 'delta.read-value',
      input => 'delta.read-input', parse => 'delta.parse-text', printf => 'delta.render-pattern',
      type => 'delta.read-type', calc => 'arithmetic.calculate', convert => 'delta.convert-type',
      cmp => 'delta.compare', set => 'delta.replace-fields',
   },
   'Date::Manip::Recur' => {
      is_recur => 'object.kind-check', parse => 'recur.parse', frequency => 'recur.set-frequency',
      start => 'recur.set-start', end => 'recur.set-end', basedate => 'recur.set-base-date',
      modifiers => 'recur.set-modifiers', nth => 'recur.occurrence-at-index',
      next => 'recur.next-occurrence', prev => 'recur.previous-occurrence', dates => 'recur.list-occurrences',
   },
   'Date::Manip::TZ' => {
      tzdata => 'meta.zone-data-version', tzcode => 'meta.zone-rule-version',
      define_alias => 'zone.define-alias', define_abbrev => 'zone.define-abbreviation',
      define_offset => 'zone.define-fixed-offset', curr_zone => 'zone.current',
      curr_zone_methods => 'zone.current-discovery-methods', zone => 'zone.resolve',
      all_periods => 'zone.list-all-periods', periods => 'zone.list-periods', date_period => 'zone.period-for-date',
      convert => 'zone.convert-value', convert_to_gmt => 'zone.convert-to-utc',
      convert_from_gmt => 'zone.convert-from-utc', convert_to_local => 'zone.convert-to-local',
      convert_from_local => 'zone.convert-from-local',
   },
);

open my $fh, '<', $arg{inventory} or die "cannot read $arg{inventory}: $!\n";
my $header = <$fh> // die "empty inventory\n";
chomp $header;
$header =~ s/\r\z//;
my @expected = qw(module callable source_path line exported pod_named family disposition profile scenario_ids status);
die "unexpected inventory header\n" unless $header eq join(',', @expected);
my @rows;
while (my $line = <$fh>) {
   chomp $line;
   $line =~ s/\r\z//;
   next unless length $line;
   my @field = split /,/, $line, scalar(@expected);
   die "malformed inventory record $.\n" unless @field == @expected;
   my %r; @r{@expected} = @field;
   $r{declaration_id} = join(':', $r{module}, $r{callable}, $r{line});
   if ($r{exported} eq 'yes') {
      $r{disposition} = 'public-functional-export';
      $r{portable_operation_id} = $functional{$r{callable}} // die "missing functional map for $r{declaration_id}\n";
      $r{coverage_route} = 'direct-portable-contract';
   } elsif ($r{module} eq 'Date::Manip::DM5' && $r{callable} eq 'EraseHolidays') {
      $r{disposition} = 'legacy-compatibility-unexported';
      $r{portable_operation_id} = 'legacy.erase-holidays';
      $r{coverage_route} = 'binding-compatibility-review';
   } elsif ($r{module} eq 'Date::Manip::TZdata') {
      $r{disposition} = $r{callable} eq 'new' ? 'tooling-declared-constructor' : 'tooling-private-helper';
      $r{portable_operation_id} = undef;
      $r{coverage_route} = 'excluded-generation-tool; zone-data-results-remain-observable';
   } elsif ($r{callable} =~ /^_/) {
      $r{disposition} = 'private-helper';
      $r{portable_operation_id} = undef;
      $r{coverage_route} = 'excluded-private-api';
      $r{status} = 'excluded-private-api';
   } elsif (exists $object{$r{module}} && exists $object{$r{module}}{$r{callable}}) {
      $r{disposition} = 'public-oo-method';
      $r{portable_operation_id} = $object{$r{module}}{$r{callable}};
      $r{coverage_route} = 'direct-portable-contract';
   } else {
      die "unclassified non-private declaration $r{declaration_id}\n";
   }
   $r{source_discovery} = {
      declaration_csv => 1,
      pod_name_match  => $r{pod_named} eq 'yes' ? JSON::PP::true : JSON::PP::false,
      export_list      => $r{exported} eq 'yes' ? JSON::PP::true : JSON::PP::false,
   };
   push @rows, \%r;
}
die "expected 423 declaration rows; found " . scalar(@rows) . "\n" unless @rows == 423;

my (%by_disposition, %by_family, %operations);
for my $r (@rows) {
   ++$by_disposition{$r->{disposition}};
   ++$by_family{$r->{family}};
   if (defined $r->{portable_operation_id}) {
      $operations{$r->{portable_operation_id}}{id} = $r->{portable_operation_id};
      push @{ $operations{$r->{portable_operation_id}}{bindings} }, {
         module => $r->{module}, callable => $r->{callable}, profile => $r->{profile},
         disposition => $r->{disposition},
      };
   }
}
my @data_modules;
find({ no_chdir => 1, wanted => sub {
   return unless /\.pm\z/;
   my $path = $File::Find::name;
   my ($kind) = $path =~ m{/Date/Manip/(Lang|Offset|TZ)/};
   push @data_modules, { path => $path, kind => lc($kind) } if $kind;
}}, File::Spec->catdir($arg{source}, 'lib'));
my %data_counts;
++ $data_counts{$_->{kind}} for @data_modules;

my $map = {
   schema_version => 1,
   reference => { distribution => 'Date-Manip', version => '7.00', source_root => $arg{source} },
   source_guard => { version_markers => \%release_marker },
   method => 'CSV declaration records reconciled with export/POD flags; runtime evidence is separate',
   limits => [
      'The CSV is a lexical declaration inventory, not an AST or call graph.',
      'A POD-name match is evidence of documentation, not a complete signature or behavior contract.',
      'Private family routes identify review obligations; they do not prove a particular caller reaches every branch.',
      'Generated data modules are counted from the release tree but their data rows are not copied here.',
   ],
   totals => { declarations => scalar(@rows), dispositions => \%by_disposition, families => \%by_family, portable_operation_ids => scalar(keys %operations) },
   non_declaration_surface => { generated_module_counts => \%data_counts, records => \@data_modules },
   facade_aliases => {
      module => 'Date::Manip', disposition => 'dynamic-backend-facade',
      note => 'The facade delegates functional names through its selected backend; this is a binding entry point, not a separate portable operation.',
      profiles => [
         { profile => 'dm6-reference', backend_module => 'Date::Manip::DM6', aliases => [ map { { callable => $_, portable_operation_id => $functional{$_} } } sort grep { exists $functional{$_} } keys %functional ] },
         { profile => 'dm5-compatibility', backend_module => 'Date::Manip::DM5', aliases => [ map { { callable => $_, portable_operation_id => $functional{$_} } } sort grep { $_ ne 'ParseDateFormat' } keys %functional ] },
      ],
   },
   declarations => \@rows,
   operations => [ map {
      my $op = $operations{$_};
      $op->{specification_status} = 'inventory-routed; behavioral partitions pending';
      $op;
   } sort keys %operations ],
};

if ($arg{check}) {
   die "source root is missing lib/Date/Manip.pm\n" unless -f File::Spec->catfile($arg{source}, 'lib', 'Date', 'Manip.pm');
   print "ok: 423 declarations; " . scalar(keys %operations) . " operation identifiers\n";
   exit 0;
}
make_path($arg{outdir});
my $output = File::Spec->catfile($arg{outdir}, 'contract-map.json');
open my $out, '>', $output or die "cannot write $output: $!\n";
print {$out} JSON::PP->new->canonical->pretty->encode($map);
close $out or die "cannot close $output: $!\n";
print "$output\n";
