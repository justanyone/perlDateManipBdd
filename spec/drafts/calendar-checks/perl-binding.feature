@source-binding @perl-binding @excluded-from-portable-handoff
Feature: Native Base calendar validation carriers and diagnostics
  These scenarios preserve Perl context, warnings, exceptions, and error-observer reads.
  They are not requirements for another language implementation.

  Background:
    Given Perl loads Date-Manip 7.00 from the pinned local installation
    And each case uses a fresh process and temporary working directory
    And the configured Base error observer is cleared before each native call

  Scenario Outline: Preserve scalar and list context results without inventing returns
    Given the native request for <operation> has typed input <input>
    When Perl invokes the public method once in scalar context and once in list context
    Then the scalar native outcome is <scalar native>
    And the list native outcome is <list native>
    And the scalar diagnostic is <scalar diagnostic>
    And the list diagnostic is <list diagnostic>
    And the public error text after each call is <scalar error after> and <list error after>

    Examples:
      | case | operation | input | scalar native | list native | scalar diagnostic | list diagnostic | scalar error after | list error after |
      | CC-T-MIDNIGHT-NUMERIC | calendar.validate-time | {"carrier":"ordered-fields","fields":[0,0,0]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-T-MIDNIGHT-ONE-DIGIT | calendar.validate-time | {"carrier":"ordered-fields","fields":["0","0","0"]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-T-MIDNIGHT-PADDED | calendar.validate-time | {"carrier":"ordered-fields","fields":["00","00","00"]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-T-LAST-SECOND | calendar.validate-time | {"carrier":"ordered-fields","fields":[23,59,59]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-T-24-EXACT | calendar.validate-time | {"carrier":"ordered-fields","fields":[24,0,0]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-T-24-MINUTE | calendar.validate-time | {"carrier":"ordered-fields","fields":[24,1,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-T-HOUR-25 | calendar.validate-time | {"carrier":"ordered-fields","fields":[25,0,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-T-MINUTE-60 | calendar.validate-time | {"carrier":"ordered-fields","fields":[12,60,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-T-SECOND-60 | calendar.validate-time | {"carrier":"ordered-fields","fields":[12,0,60]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-T-NEGATIVE | calendar.validate-time | {"carrier":"ordered-fields","fields":[-1,0,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-T-FRACTION | calendar.validate-time | {"carrier":"ordered-fields","fields":[1.5,0,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-T-WHITESPACE | calendar.validate-time | {"carrier":"ordered-fields","fields":[" 1",0,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-T-NONNUMERIC | calendar.validate-time | {"carrier":"ordered-fields","fields":["x",0,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-T-MISSING-FIELD | calendar.validate-time | {"carrier":"ordered-fields","fields":[12,30]} | scalar 0 | list [0] | warnings ["Use of uninitialized value $s in concatenation (.) or string"] | warnings ["Use of uninitialized value $s in concatenation (.) or string"] | "" | "" |
      | CC-T-UNDEFINED-FIELD | calendar.validate-time | {"carrier":"ordered-fields","fields":[12,null,0]} | scalar 0 | list [0] | warnings ["Use of uninitialized value $mn in concatenation (.) or string"] | warnings ["Use of uninitialized value $mn in concatenation (.) or string"] | "" | "" |
      | CC-T-EXTRA-FIELD | calendar.validate-time | {"carrier":"ordered-fields","fields":[12,30,15,99]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-D-ORDINARY | calendar.validate-date | {"carrier":"ordered-fields","fields":[2039,5,17,9,7,5]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-D-LEAP-DAY | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040,2,29,0,0,0]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-D-LOWER-ENDPOINT | calendar.validate-date | {"carrier":"ordered-fields","fields":[1,1,1,0,0,0]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-D-UPPER-ENDPOINT | calendar.validate-date | {"carrier":"ordered-fields","fields":[9999,12,31,24,0,0]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-D-APRIL-END | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040,4,30,23,59,59]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-D-YEAR-ZERO | calendar.validate-date | {"carrier":"ordered-fields","fields":[0,1,1,0,0,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-D-YEAR-10000 | calendar.validate-date | {"carrier":"ordered-fields","fields":[10000,1,1,0,0,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-D-MONTH-ZERO | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040,0,1,0,0,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-D-MONTH-13 | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040,13,1,0,0,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-D-DAY-ZERO | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040,1,0,0,0,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-D-COMMON-FEB29 | calendar.validate-date | {"carrier":"ordered-fields","fields":[2039,2,29,0,0,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-D-APRIL31 | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040,4,31,0,0,0]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-D-24-SECOND | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040,1,1,24,0,1]} | scalar 0 | list [0] | none | none | "" | "" |
      | CC-D-FRACTIONAL-YEAR | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040.5,1,1,0,0,0]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-D-WHITESPACE-YEAR | calendar.validate-date | {"carrier":"ordered-fields","fields":[" 2040",1,1,0,0,0]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-D-NONNUMERIC-YEAR | calendar.validate-date | {"carrier":"ordered-fields","fields":["x",1,1,0,0,0]} | scalar 0 | list [0] | warnings ["Argument \"x\" isn't numeric in integer lt (<)"] | warnings ["Argument \"x\" isn't numeric in integer lt (<)"] | "" | "" |
      | CC-D-MISSING-TIME | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040,1,1]} | scalar 0 | list [0] | warnings ["Use of uninitialized value $h in concatenation (.) or string","Use of uninitialized value $mn in concatenation (.) or string","Use of uninitialized value $s in concatenation (.) or string"] | warnings ["Use of uninitialized value $h in concatenation (.) or string","Use of uninitialized value $mn in concatenation (.) or string","Use of uninitialized value $s in concatenation (.) or string"] | "" | "" |
      | CC-D-EXTRA-FIELD | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040,1,1,0,0,0,99]} | scalar 1 | list [1] | none | none | "" | "" |
      | CC-D-UNDEFINED-DAY | calendar.validate-date | {"carrier":"ordered-fields","fields":[2040,1,null,0,0,0]} | scalar 0 | list [0] | warnings ["Use of uninitialized value $d in integer lt (<)"] | warnings ["Use of uninitialized value $d in integer lt (<)"] | "" | "" |
      | CC-D-SCALAR-CARRIER | calendar.validate-date | {"carrier":"text scalar","value":"2040-01-01"} | no return | no return | exception "Can't use string (\"2040-01-01\") as an ARRAY ref while \"strict refs\" in use" | exception "Can't use string (\"2040-01-01\") as an ARRAY ref while \"strict refs\" in use" | "" | "" |
