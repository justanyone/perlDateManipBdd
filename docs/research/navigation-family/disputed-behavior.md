# Minimal public-call reproducers

These snippets isolate observed compatibility behavior. They invoke only public
entrypoints and assume the pinned library in `local/date-manip-7.00/lib/perl5`.
They are research reproducers, not portable algorithms.

## Object status does not reflect a DST-gap set failure

```perl
use Date::Manip::Date;
my $ctx = Date::Manip::Date->new;
$ctx->config('Defaults', 1, 'ForceDate', '2040-02-28-10:20:30,Etc/UTC',
             'Language', 'English', 'DateFormat', 'US');
my $d = $ctx->new_date('2024-03-10 01:30:00 America/New_York');
my $status = $d->next(undef, 0, [2, 30, 0]);
print "$status\n", $d->err, "\n", $d->value, "\n";
```

The pinned result is status `0`, immediate error
`[set] Invalid date/timezone`, and an empty value carrier.

## Current facade invalid time exception

```perl
use Date::Manip::DM6 qw(Date_Init Date_GetNext);
Date_Init('Defaults=1', 'ForceDate=2040-02-28-10:20:30,Etc/UTC',
          'Language=English', 'DateFormat=US');
my $value = Date_GetNext('2040-11-23 18:15:00 Etc/UTC', 5, 1, '25:00');
```

The pinned call raises an undefined-array-reference exception instead of returning
the facade's usual empty failure text.

## Compatibility facade missing predicate exception

```perl
use Date::Manip::DM5 qw(Date_Init Date_GetPrev);
Date_Init('IgnoreGlobalCnf=1', 'PersonalCnf=', 'PersonalCnfPath=',
          'ForceDate=2040-02-28-10:20:30', 'TZ=Etc/UTC',
          'Language=English', 'DateFormat=US');
my $value = Date_GetPrev('2040-11-23 18:15:00', undef, 0);
```

The pinned call raises `ERROR: invalid arguments in Date_GetPrev.` rather than
returning the current facade's empty failure text.

## Extra arguments diverge

```perl
use Date::Manip::DM6 qw(Date_Init Date_GetNext);
Date_Init('Defaults=1', 'ForceDate=2040-02-28-10:20:30,Etc/UTC',
          'Language=English', 'DateFormat=US');
my $value = Date_GetNext('2040-11-23 18:15:00 Etc/UTC', 5, 1, 12, 0, 0, 9);
```

The current facade returns empty text. The analogous DM5 call returns
`2040112312:00:00`, and the OO method ignores a fourth method argument. These are
kept as disputed compatibility observations rather than required portable rules.
