# Research-side mapping: reference APIs to portable behavior

Reference: CPAN Date-Manip 7.00. Source identifiers below are discovery and adapter
information; they are not part of the implementation handoff. All mapping rows are
planned unless linked to an observation. Names are not copied implementations.

## Modern functional interface: all 34 exports

| Family | Perl entry point(s) | Generic contract and adapter obligation |
| --- | --- | --- |
| META | `DateManipVersion` | Report reference capabilities/version; never require the new library to claim a Perl version |
| CONFIG | `Date_Init` | Apply named context settings; capture configuration failure and warnings; translate key/value arguments |
| PARSE | `ParseDateString` | Interpret all date text; capture empty result on failure; functional output is converted to configured local zone |
| PARSE | `ParseDate` | Interpret text or leading token sequence; array input consumes matched tokens; expose remaining tokens explicitly |
| PARSE | `ParseDateFormat` | Interpret text with explicit format; separate pattern errors from input mismatch where observable |
| FORMAT | `UnixDate` | Render a date with one/multiple patterns; enumerate scalar/list differences and output order |
| DELTA | `ParseDateDelta` | Interpret interval text with mode; token consumption and canonical representation need separate cases |
| DELTA | `Delta_Format` | Render/convert interval fields with precision and mode; keep unit/normalization semantics |
| ARITH | `DateCalc` | Split date-plus-interval, date-separation, and interval-combination; preserve legacy inferred-operand operation separately; capture error out-parameter |
| RECUR | `ParseRecur` | Split recurrence description from occurrence enumeration; scalar and list context do different jobs; arguments may override inline components |
| COMPARE | `Date_Cmp` | Compare dates; translate signed ordering result to before/equal/after; invalid values are not equality |
| NAVIGATE | `Date_GetPrev`, `Date_GetNext` | Find matching earlier/later date using predicates and inclusion flag |
| FIELDS | `Date_SetTime`, `Date_SetDateField` | Replace named date/time fields; capture invalid and overflow behavior |
| BUSINESS | `Date_IsHoliday`, `Date_IsWorkDay` | Query holiday labels and working-day status; no holiday is not a parse failure |
| BUSINESS | `Date_NextWorkDay`, `Date_PrevWorkDay`, `Date_NearestWorkDay` | Move by business dates/time; specify zero-offset behavior and tie preference |
| EVENTS | `Events_List` | Query named event occurrences/intervals; inventory all selection and output modes |
| CALENDAR | `Date_DayOfWeek` | Civil date to weekday; argument order is month/day/year, output Monday=1 through Sunday=7 |
| EPOCH | `Date_SecsSince1970`, `Date_SecsSince1970GMT` | Distinct local-origin and UTC-origin quantities; both take civil fields interpreted in configured local zone; probe non-UTC differences |
| CALENDAR | `Date_DaysSince1BC` | Civil day ordinal with explicitly stated origin, range and inclusivity |
| CALENDAR | `Date_DayOfYear`, `Date_NthDayOfYear` | Convert between civil fields and year ordinal; the inverse accepts fractional day positions |
| CALENDAR | `Date_DaysInYear`, `Date_DaysInMonth`, `Date_LeapYear` | Calendar properties; translate numeric predicates to Boolean |
| CALENDAR | `Date_WeekOfYear` | Legacy week-number calculation with first-weekday argument; do not relabel as ISO week/year |
| FORMAT | `Date_DaySuffix` | Localized ordinal-day representation; inventory supported languages and special endings |
| ZONE | `Date_TimeZone` | Resolve configured/discovered zone; keep host-discovery cases isolated |
| ZONE | `Date_ConvTZ` | Convert canonical date text between zones; normalize to typed source/destination values; verify omitted-zone behavior |

Initial case-to-call evidence is in [observations.md](observations.md). Every grouped
row expands to individual contract variants in the next phase; a group is not itself
a complete test case.

## OO and lower-level public capabilities

The declaration scan found the following non-underscore methods. Classification is
provisional until documentation and runtime inheritance are reconciled. Shared
methods need scenarios on each relevant receiving type, not just on their defining
module. Constructors have multiple sharing/copying forms.

| Module | Declared public candidates | Portable mapping |
| --- | --- | --- |
| `Obj` | `new`, `new_config`, `new_date`, `new_delta`, `new_recur` | Create/derive values and contexts; sharing versus independent overrides; constructor parsing |
| `Obj` | `base`, `tz` | Access context/timezone services; expose behavior, not object identity |
| `Obj` | `config`, `get_config`, `err` | Change/query settings and error state; clearing and subsequent-call behavior |
| `Obj` | `is_date`, `is_delta`, `is_recur`, `version` | Value kind and capability metadata |
| `Base` | `days_since_1BC`, `day_of_week`, `leapyear`, `days_in_year`, `days_in_month`, `day_of_year`, `nth_day_of_week` | Calendar inspection and ordinal conversions, including invalid civil fields |
| `Base` | `week1_day1`, `weeks_in_year`, `week_of_year` | Configurable week system, start of week-year, week count and numbering |
| `Base` | `secs_since_1970`, `check`, `check_time` | Epoch calculation and civil/time validation with exact supported ranges |
| `Base` | `calc_date_date`, `calc_date_days`, `calc_date_delta`, `calc_date_time`, `calc_time_time`, `cmp` | Component arithmetic/comparison and carries; retain distinctions from zoned/elapsed arithmetic |
| `Base` | `split`, `join` | Decode/encode supported date/time/offset/interval representations; generic typed values |
| `Date` | `is_date`, `input`, `value`, `complete` | Kind, original input, extracted fields/value and completion status/default filling |
| `Date` | `parse`, `parse_date`, `parse_time`, `parse_format` | Full/date-only/time-only/pattern interpretation; partial mutation must be characterized |
| `Date` | `cmp`, `set`, `prev`, `next` | Ordering, field update and matching-date navigation |
| `Date` | `calc`, `secs_since_1970_GMT`, `week_of_year` | Typed arithmetic, instant epoch and week/year information |
| `Date` | `convert`, `printf` | Zone conversion and rendering; unlike functional parsing, OO parsing can retain input zone |
| `Date` | `is_business_day`, `list_holidays`, `holiday`, `next_business_day`, `prev_business_day`, `nearest_business_day` | Business/holiday queries and navigation, including state mutation |
| `Date` | `list_events` | Event intervals/occurrences and selection modes |
| `Delta` | `is_delta`, `config`, `input`, `value`, `set` | Interval kind/settings/fields and explicit mutation |
| `Delta` | `parse`, `printf`, `type`, `calc`, `convert`, `cmp` | Interval parsing/rendering, exact/semi/approximate/estimated and business types, algebra/conversion/comparison |
| `Recur` | `is_recur`, `parse`, `frequency`, `start`, `end`, `basedate`, `modifiers` | Build/query a recurrence; requested versus effective anchor; changing frequency resets other state |
| `Recur` | `nth`, `next`, `prev`, `dates` | Indexed/directional occurrence selection and bounded enumeration |
| `TZ` | `tzdata`, `tzcode`, `curr_zone`, `curr_zone_methods` | Dataset identity and zone discovery with controlled environment |
| `TZ` | `define_alias`, `define_abbrev`, `define_offset`, `zone` | User-defined zone resolution, ambiguity/candidate selection and validation |
| `TZ` | `all_periods`, `periods`, `date_period` | Zone transition periods, range inclusion and gap/overlap mapping |
| `TZ` | `convert`, `convert_to_gmt`, `convert_from_gmt`, `convert_to_local`, `convert_from_local` | Zoned transformations with DST and ambiguity handling |

`TZdata::new` and its helpers belong to an internal generation tool: its own POD
expressly says it is not a supported public API. `TZ_Base` supplies internal support.
Track these as tooling/indirect coverage; do not translate their algorithms into the
portable spec. Data-only language/offset/timezone modules still create user-visible
coverage obligations even though they declare no named subroutines.

## Legacy backend and alias treatment

DM5 has 33 exports: the same exported names as DM6 except `ParseDateFormat`.
Test each common functional mapping under an explicitly named DM5 profile, recording
differences in syntax, option support, errors, timezone rules and results. Do not
infer equality from identical names. `EraseHolidays` is an additional non-underscore,
unexported declaration; keep it under review instead of silently promoting it to
a portable operation or dropping it. Library entry-point backend selection is a
binding test, not an algorithm the later language must reproduce.

## Adapter invariants to specify before implementation

- **Context:** isolate import-time/global state. Define when settings are shared by
  two values and when changes are confined to a derived context.
- **Arguments:** represent positional parameters and optional slots as named fields.
  Preserve omitted versus supplied-empty values. Explicitly select list/scalar
  context in the Perl call; never let the assertion choose it accidentally.
- **Returns:** a successful parse method can return numeric zero; an empty list can
  mean no occurrences or an error. Decode each operation using all its channels.
  Do not equate Perl truthiness with success.
- **Error out-parameters:** record initial and final values; some successful calls
  may leave them unchanged. This plan's successful `DateCalc` probes left an initially
  undefined error parameter undefined. Do not generalize that to a guaranteed zero.
- **State:** record token consumption, field changes, retained timezone and error
  state. Expose meaningful effects in the abstract result, without mandating pointer
  mutation or shared-object layout in another language.
- **Normalization:** reorder date arguments, decode strings/lists, convert weekday
  integers and attach explicit type/zone information only where justified. Do not
  clamp dates, calculate expected values, drop precision, or fix upstream bugs here.
- **Observability:** capture exceptions, return values, warnings and standard output
  separately. Classify diagnostics using stable categories; exact Perl warning text
  belongs only in a binding compatibility profile when justified.

## Inventory caveats

[perl-api-inventory.csv](perl-api-inventory.csv) contains 423 lexical declaration
records from all release `lib/**/*.pm` files: 257 underscore-prefixed and 166 other
names. There are 67 exported records across the two backends, representing overlapping
names. `pod_named` means a matching POD item exists, not proof of public support.

The CSV's family assignment is an initial routing aid; a private helper may contribute
to multiple families. Every row is `discovered-not-specified`; blank scenario IDs
mean work remains, not exclusion. The scan cannot prove absence of dynamically
installed methods, aliases or inherited entries. The next phase must add those
records and explicit contract variants, including declarations outside the library
tree when assessing tools/examples. No upstream implementation text is stored here.
