@draft @calendar @year-day @reference-observed @perl-binding @excluded-from-portable-handoff
Feature: Perl carriers and diagnostics for year-day conversion calls
  This feature records source-binding evidence. Argument specifications and
  native result carriers use JSON notation; null is Perl undef only here.

  Background:
    Given each row runs in a fresh process and temporary directory
    And the environment is exactly PATH "/usr/bin:/bin", TZ "Etc/UTC", LANG "C.UTF-8", LC_ALL "C.UTF-8", and the pinned PERL5LIB
    And every listed conversion call completes without an exception or captured stdout
    And every probe process has empty process stderr

  Scenario: Public setup calls have exact native outcomes
    Then the setup records are:
      | profile          | constructor result    | configuration result | version | zone metadata                 | service result       | module-load warnings |
      | calendar service | Date::Manip::Date     | undefined            | 7.00    | tzdata2026c and tzcode2026c   | Date::Manip::Base    | 0                    |
      | current functional | not requested       | defined empty text   | 7.00    | not exposed by this binding   | not requested        | 0                    |
      | legacy functional  | not requested       | undefined            | 5.66    | not exposed by this binding   | not requested        | 1                    |

  Scenario Outline: Native scalar and list carriers remain exact for <case>
    Given the exact native argument specification <arguments>
    When profile "<profile>" invokes public callable "<callable>" once in scalar context and once in list context
    Then the scalar carrier is <scalar>
    And the list carrier is <list>
    And the two calls emit <scalar warnings> and <list warnings> operation warnings respectively
    And the public error observer state is "<errors>"

    Examples:
      | case | profile | callable | arguments | scalar | list | scalar warnings | list warnings | errors |
      | YDC-FWD-BASE-COMMON-JAN1 | calendar service | day_of_year | [{"type":"field-list","value":[2039,1,1]}] | scalar 1 | list [1] | 0 | 0 | empty before/after |
      | YDC-FWD-BASE-COMMON-MAR1 | calendar service | day_of_year | [{"type":"field-list","value":[2039,3,1]}] | scalar 60 | list [60] | 0 | 0 | empty before/after |
      | YDC-FWD-BASE-LEAP-FEB29 | calendar service | day_of_year | [{"type":"field-list","value":[2040,2,29]}] | scalar 60 | list [60] | 0 | 0 | empty before/after |
      | YDC-FWD-BASE-LEAP-MAR1 | calendar service | day_of_year | [{"type":"field-list","value":[2040,3,1]}] | scalar 61 | list [61] | 0 | 0 | empty before/after |
      | YDC-FWD-BASE-COMMON-END | calendar service | day_of_year | [{"type":"field-list","value":[2039,12,31]}] | scalar 365 | list [365] | 0 | 0 | empty before/after |
      | YDC-FWD-BASE-LEAP-END | calendar service | day_of_year | [{"type":"field-list","value":[2040,12,31]}] | scalar 366 | list [366] | 0 | 0 | empty before/after |
      | YDC-FWD-BASE-NOON | calendar service | day_of_year | [{"type":"field-list","value":[2040,2,29,12,0,0]}] | scalar 60.5 | list [60.5] | 0 | 0 | empty before/after |
      | YDC-FWD-BASE-HALF-SECOND | calendar service | day_of_year | [{"type":"field-list","value":[2040,2,29,12,0,0.5]}] | scalar 60.500005787037 | list [60.500005787037] | 0 | 0 | empty before/after |
      | YDC-FWD-DM6-LEAP-FEB29 | current functional | Date_DayOfYear | [{"type":"number","value":2},{"type":"number","value":29},{"type":"number","value":2040}] | scalar 60 | list [60] | 0 | 0 | no observer |
      | YDC-FWD-DM5-LEAP-FEB29 | legacy functional | Date_DayOfYear | [{"type":"number","value":2},{"type":"number","value":29},{"type":"number","value":2040}] | scalar 60 | list [60] | 0 | 0 | no observer |
      | YDC-FWD-DM6-SHORT-C19 | current functional | Date_DayOfYear | [{"type":"number","value":3},{"type":"number","value":1},{"type":"text","value":"00"}] | scalar 61 | list [61] | 0 | 0 | no observer |
      | YDC-FWD-DM5-SHORT-C19 | legacy functional | Date_DayOfYear | [{"type":"number","value":3},{"type":"number","value":1},{"type":"text","value":"00"}] | scalar 60 | list [60] | 0 | 0 | no observer |
      | YDC-FWD-BASE-INVALID-CIVIL | calendar service | day_of_year | [{"type":"field-list","value":[2039,2,29]}] | scalar 60 | list [60] | 0 | 0 | empty before/after |
      | YDC-FWD-BASE-MISSING-DAY | calendar service | day_of_year | [{"type":"field-list","value":[2040,2]}] | scalar 31 | list [31] | 1 | 1 | empty before/after |
      | YDC-FWD-BASE-NONNUMERIC-MONTH | calendar service | day_of_year | [{"type":"field-list","value":[2040,"x",1]}] | scalar 366 | list [366] | 1 | 1 | empty before/after |
      | YDC-INV-BASE-COMMON-FIRST | calendar service | day_of_year | [{"type":"number","value":2039},{"type":"number","value":1}] | array reference [2039,1,1] | list [[2039,1,1]] | 0 | 0 | empty before/after |
      | YDC-INV-BASE-COMMON-FEB28 | calendar service | day_of_year | [{"type":"number","value":2039},{"type":"number","value":59}] | array reference [2039,2,28] | list [[2039,2,28]] | 0 | 0 | empty before/after |
      | YDC-INV-BASE-COMMON-MAR1 | calendar service | day_of_year | [{"type":"number","value":2039},{"type":"number","value":60}] | array reference [2039,3,1] | list [[2039,3,1]] | 0 | 0 | empty before/after |
      | YDC-INV-BASE-LEAP-FEB29 | calendar service | day_of_year | [{"type":"number","value":2040},{"type":"number","value":60}] | array reference [2040,2,29] | list [[2040,2,29]] | 0 | 0 | empty before/after |
      | YDC-INV-BASE-COMMON-END | calendar service | day_of_year | [{"type":"number","value":2039},{"type":"number","value":365}] | array reference [2039,12,31] | list [[2039,12,31]] | 0 | 0 | empty before/after |
      | YDC-INV-BASE-LEAP-END | calendar service | day_of_year | [{"type":"number","value":2040},{"type":"number","value":366}] | array reference [2040,12,31] | list [[2040,12,31]] | 0 | 0 | empty before/after |
      | YDC-INV-BASE-FIRST-NOON | calendar service | day_of_year | [{"type":"number","value":2040},{"type":"number","value":1.5}] | array reference [2040,1,1,12,0,0] | list [[2040,1,1,12,0,0]] | 0 | 0 | empty before/after |
      | YDC-INV-BASE-SUBSECOND | calendar service | day_of_year | [{"type":"number","value":2040},{"type":"number","value":60.50000578703704}] | array reference [2040,2,29,12,0,"0.50"] | list [[2040,2,29,12,0,"0.50"]] | 0 | 0 | empty before/after |
      | YDC-INV-DM6-COMMON-END | current functional | Date_NthDayOfYear | [{"type":"number","value":2039},{"type":"number","value":365}] | scalar 6 | list [2039,12,31,0,0,0] | 0 | 0 | no observer |
      | YDC-INV-DM5-COMMON-END | legacy functional | Date_NthDayOfYear | [{"type":"number","value":2039},{"type":"number","value":365}] | scalar 0 | list [2039,12,31,0,0,0] | 0 | 0 | no observer |
      | YDC-INV-DM6-FRACTION | current functional | Date_NthDayOfYear | [{"type":"number","value":2040},{"type":"number","value":60.5}] | scalar 6 | list [2040,2,29,12,0,0] | 0 | 0 | no observer |
      | YDC-INV-DM5-FRACTION | legacy functional | Date_NthDayOfYear | [{"type":"number","value":2040},{"type":"number","value":60.5}] | scalar 0 | list [2040,2,29,12,0,0] | 0 | 0 | no observer |
      | YDC-INV-DM6-LEAP-LAST-NOON | current functional | Date_NthDayOfYear | [{"type":"number","value":2040},{"type":"number","value":366.5}] | scalar 6 | list [2040,12,31,12,0,0] | 0 | 0 | no observer |
      | YDC-INV-DM5-LEAP-LAST-NOON | legacy functional | Date_NthDayOfYear | [{"type":"number","value":2040},{"type":"number","value":366.5}] | scalar 0 | list [2040,12,31,12,0,0] | 0 | 0 | no observer |
      | YDC-EDGE-BASE-COMMON-366 | calendar service | day_of_year | [{"type":"number","value":2039},{"type":"number","value":366}] | array reference [2039,13,1] | list [[2039,13,1]] | 0 | 0 | empty before/after |
      | YDC-EDGE-BASE-LEAP-367 | calendar service | day_of_year | [{"type":"number","value":2040},{"type":"number","value":367}] | array reference [2040,13,1] | list [[2040,13,1]] | 0 | 0 | empty before/after |
      | YDC-EDGE-BASE-ZERO | calendar service | day_of_year | [{"type":"number","value":2040},{"type":"number","value":0}] | array reference [2040,1,0] | list [[2040,1,0]] | 0 | 0 | empty before/after |
      | YDC-EDGE-DM6-COMMON-366 | current functional | Date_NthDayOfYear | [{"type":"number","value":2039},{"type":"number","value":366}] | scalar 6 | list [2039,13,1,0,0,0] | 0 | 0 | no observer |
      | YDC-EDGE-DM5-COMMON-366 | legacy functional | Date_NthDayOfYear | [{"type":"number","value":2039},{"type":"number","value":366}] | undefined | list [] | 0 | 0 | no observer |
      | YDC-EDGE-DM6-OMITTED | current functional | Date_NthDayOfYear | [] | scalar 6 | list [null,1,0,0,0,0] | 6 | 6 | no observer |
      | YDC-EDGE-DM5-OMITTED | legacy functional | Date_NthDayOfYear | [] | scalar 0 | list ["2040",1,1,0,0,0] | 0 | 0 | no observer |
      | YDC-EDGE-DM6-ABSENT | current functional | Date_NthDayOfYear | [{"type":"absent"},{"type":"absent"}] | scalar 6 | list [null,1,0,0,0,0] | 6 | 6 | no observer |
      | YDC-EDGE-BASE-NEGATIVE | calendar service | day_of_year | [{"type":"number","value":2040},{"type":"number","value":-1}] | array reference [2040,1,-1] | list [[2040,1,-1]] | 0 | 0 | empty before/after |
      | YDC-EDGE-DM6-NONNUMERIC | current functional | Date_NthDayOfYear | [{"type":"number","value":2040},{"type":"text","value":"x"}] | scalar 6 | list [2040,1,0,0,0,0] | 1 | 1 | no observer |
      | YDC-EDGE-DM5-NONNUMERIC | legacy functional | Date_NthDayOfYear | [{"type":"number","value":2040},{"type":"text","value":"x"}] | undefined | list [] | 1 | 1 | no observer |

  Scenario Outline: Warning-producing calls preserve their first native diagnostic for <case>
    Given native case "<case>"
    Then each call emits exactly <count> warnings
    And its first warning begins with "<first warning>"

    Examples:
      | case                            | count | first warning                                      |
      | YDC-FWD-BASE-MISSING-DAY        | 1     | Use of uninitialized value $d in addition (+)      |
      | YDC-FWD-BASE-NONNUMERIC-MONTH   | 1     | Argument "x" isn't numeric in numeric gt (>)       |
      | YDC-EDGE-DM6-OMITTED            | 6     | Use of uninitialized value $y in integer modulus (%) |
      | YDC-EDGE-DM6-ABSENT             | 6     | Use of uninitialized value $y in integer modulus (%) |
      | YDC-EDGE-DM6-NONNUMERIC         | 1     | Argument "x" isn't numeric in int                  |
      | YDC-EDGE-DM5-NONNUMERIC         | 1     | Argument "x" isn't numeric in addition (+)         |

  Scenario: Loading the legacy binding emits its exact deprecation warning
    Then the sole module-load warning is exactly "Date::Manip::DM5 is deprecated and will be removed from the Date::Manip package starting in version 7.00 at (eval 42) line 1."
