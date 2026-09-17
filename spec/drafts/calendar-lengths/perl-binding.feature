@source-binding @perl-binding @excluded-from-portable-handoff
Feature: Perl carriers and diagnostics for calendar length calls
  These rows preserve Perl calling context, warnings, exceptions, and the Base error observer.
  They are source-binding evidence and are not requirements for another implementation.

  Background:
    Given the Perl process uses Date-Manip 7.00 with PATH "/usr/bin:/bin"
    And each request runs in a fresh process and temporary working directory

  Scenario Outline: Preserve setup returns and module-load diagnostics
    When Perl loads and configures binding route <setup route>
    Then the configuration return is <setup return>
    And the module-load diagnostic is <load diagnostic>

    Examples:
      | setup route | setup return | load diagnostic |
      | base | undefined scalar | no warning |
      | dm6 | empty text | no warning |
      | dm5 | undefined scalar | warning "Date::Manip::DM5 is deprecated and will be removed from the Date::Manip package starting in version 7.00" |

  Scenario Outline: Preserve the native outcome and diagnostic channels
    Given binding route <route> receives arguments <arguments>
    When Perl invokes <operation> in <context> context
    Then its native outcome is <native result>
    And its call diagnostic is <diagnostic>
    And the public error observer is <observer action>

    Examples:
      | case | route | operation | arguments | context | native result | diagnostic | observer action |
      | CL-BASE-M-2039-01 | base | calendar.days-in-month | [2039,1] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2039-02 | base | calendar.days-in-month | [2039,2] | scalar | scalar 28 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2039-03 | base | calendar.days-in-month | [2039,3] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2039-04 | base | calendar.days-in-month | [2039,4] | scalar | scalar 30 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2039-05 | base | calendar.days-in-month | [2039,5] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2039-06 | base | calendar.days-in-month | [2039,6] | scalar | scalar 30 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2039-07 | base | calendar.days-in-month | [2039,7] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2039-08 | base | calendar.days-in-month | [2039,8] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2039-09 | base | calendar.days-in-month | [2039,9] | scalar | scalar 30 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2039-10 | base | calendar.days-in-month | [2039,10] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2039-11 | base | calendar.days-in-month | [2039,11] | scalar | scalar 30 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2039-12 | base | calendar.days-in-month | [2039,12] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2040-01 | base | calendar.days-in-month | [2040,1] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2040-02 | base | calendar.days-in-month | [2040,2] | scalar | scalar 29 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2040-03 | base | calendar.days-in-month | [2040,3] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2040-04 | base | calendar.days-in-month | [2040,4] | scalar | scalar 30 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2040-05 | base | calendar.days-in-month | [2040,5] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2040-06 | base | calendar.days-in-month | [2040,6] | scalar | scalar 30 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2040-07 | base | calendar.days-in-month | [2040,7] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2040-08 | base | calendar.days-in-month | [2040,8] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2040-09 | base | calendar.days-in-month | [2040,9] | scalar | scalar 30 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2040-10 | base | calendar.days-in-month | [2040,10] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2040-11 | base | calendar.days-in-month | [2040,11] | scalar | scalar 30 | no warning or exception | cleared and read before and after |
      | CL-BASE-M-2040-12 | base | calendar.days-in-month | [2040,12] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-Y-1900 | base | calendar.days-in-year | [1900] | scalar | scalar 365 | no warning or exception | cleared and read before and after |
      | CL-BASE-Y-2000 | base | calendar.days-in-year | [2000] | scalar | scalar 366 | no warning or exception | cleared and read before and after |
      | CL-BASE-Y-2039 | base | calendar.days-in-year | [2039] | scalar | scalar 365 | no warning or exception | cleared and read before and after |
      | CL-BASE-Y-2040 | base | calendar.days-in-year | [2040] | scalar | scalar 366 | no warning or exception | cleared and read before and after |
      | CL-BASE-Y-2100 | base | calendar.days-in-year | [2100] | scalar | scalar 365 | no warning or exception | cleared and read before and after |
      | CL-BASE-M0-2039-LIST | base | calendar.days-in-month | [2039,0] | list | list [31,28,31,30,31,30,31,31,30,31,30,31] | no warning or exception | cleared and read before and after |
      | CL-BASE-M0-2039-SCALAR | base | calendar.days-in-month | [2039,0] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-M0-2040-LIST | base | calendar.days-in-month | [2040,0] | list | list [31,29,31,30,31,30,31,31,30,31,30,31] | no warning or exception | cleared and read before and after |
      | CL-BASE-M0-2040-SCALAR | base | calendar.days-in-month | [2040,0] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-SHORT-M-DEFAULT | base | calendar.days-in-month | ["00",2] | scalar | scalar 29 | no warning or exception | cleared and read before and after |
      | CL-BASE-SHORT-Y-DEFAULT | base | calendar.days-in-year | ["00"] | scalar | scalar 366 | no warning or exception | cleared and read before and after |
      | CL-BASE-SHORT-M-C19 | base | calendar.days-in-month | ["00",2] | scalar | scalar 29 | no warning or exception | cleared and read before and after |
      | CL-BASE-SHORT-Y-C19 | base | calendar.days-in-year | ["00"] | scalar | scalar 366 | no warning or exception | cleared and read before and after |
      | CL-BASE-SHORT-M-C20 | base | calendar.days-in-month | ["00",2] | scalar | scalar 29 | no warning or exception | cleared and read before and after |
      | CL-BASE-SHORT-Y-C20 | base | calendar.days-in-year | ["00"] | scalar | scalar 366 | no warning or exception | cleared and read before and after |
      | CL-BASE-INVALID-M-OMITTED | base | calendar.days-in-month | [] | scalar | scalar 31 | warnings ["Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)"] | cleared and read before and after |
      | CL-BASE-INVALID-M-UNDEFINED | base | calendar.days-in-month | [2040,null] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-INVALID-M-TEXT | base | calendar.days-in-month | [2040,"x"] | scalar | scalar 32 | warnings ["Argument \"x\" isn't numeric in integer eq (==)"] | cleared and read before and after |
      | CL-BASE-INVALID-M-FRACTION | base | calendar.days-in-month | [2040,2.5] | scalar | scalar 29 | no warning or exception | cleared and read before and after |
      | CL-BASE-INVALID-M-NEGATIVE | base | calendar.days-in-month | [2040,-1] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-INVALID-M-HIGH | base | calendar.days-in-month | [2040,13] | scalar | scalar 30 | no warning or exception | cleared and read before and after |
      | CL-BASE-INVALID-M-YEAR-OMITTED | base | calendar.days-in-month | [2040] | scalar | scalar 31 | no warning or exception | cleared and read before and after |
      | CL-BASE-INVALID-M-YEAR-UNDEFINED | base | calendar.days-in-month | [null,2] | scalar | scalar 29 | warnings ["Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)"] | cleared and read before and after |
      | CL-BASE-INVALID-M-YEAR-TEXT | base | calendar.days-in-month | ["x",2] | scalar | scalar 29 | warnings ["Argument \"x\" isn't numeric in integer modulus (%)"] | cleared and read before and after |
      | CL-BASE-INVALID-M-YEAR-NEGATIVE | base | calendar.days-in-month | [-1,2] | scalar | scalar 28 | no warning or exception | cleared and read before and after |
      | CL-BASE-INVALID-M-YEAR-HIGH | base | calendar.days-in-month | [10000,2] | scalar | scalar 29 | no warning or exception | cleared and read before and after |
      | CL-BASE-INVALID-Y-OMITTED | base | calendar.days-in-year | [] | scalar | scalar 366 | warnings ["Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)"] | cleared and read before and after |
      | CL-BASE-INVALID-Y-UNDEFINED | base | calendar.days-in-year | [null] | scalar | scalar 366 | warnings ["Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)"] | cleared and read before and after |
      | CL-BASE-INVALID-Y-TEXT | base | calendar.days-in-year | ["x"] | scalar | scalar 366 | warnings ["Argument \"x\" isn't numeric in integer modulus (%)"] | cleared and read before and after |
      | CL-BASE-INVALID-Y-FRACTION | base | calendar.days-in-year | [2040.5] | scalar | scalar 366 | no warning or exception | cleared and read before and after |
      | CL-BASE-INVALID-Y-ZERO | base | calendar.days-in-year | [0] | scalar | scalar 366 | no warning or exception | cleared and read before and after |
      | CL-BASE-INVALID-Y-NEGATIVE | base | calendar.days-in-year | [-1] | scalar | scalar 365 | no warning or exception | cleared and read before and after |
      | CL-BASE-INVALID-Y-HIGH | base | calendar.days-in-year | [10000] | scalar | scalar 366 | no warning or exception | cleared and read before and after |
      | CL-DM6-M-2039-01 | dm6 | calendar.days-in-month | [1,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2039-02 | dm6 | calendar.days-in-month | [2,2039] | scalar | scalar 28 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2039-03 | dm6 | calendar.days-in-month | [3,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2039-04 | dm6 | calendar.days-in-month | [4,2039] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2039-05 | dm6 | calendar.days-in-month | [5,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2039-06 | dm6 | calendar.days-in-month | [6,2039] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2039-07 | dm6 | calendar.days-in-month | [7,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2039-08 | dm6 | calendar.days-in-month | [8,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2039-09 | dm6 | calendar.days-in-month | [9,2039] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2039-10 | dm6 | calendar.days-in-month | [10,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2039-11 | dm6 | calendar.days-in-month | [11,2039] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2039-12 | dm6 | calendar.days-in-month | [12,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2040-01 | dm6 | calendar.days-in-month | [1,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2040-02 | dm6 | calendar.days-in-month | [2,2040] | scalar | scalar 29 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2040-03 | dm6 | calendar.days-in-month | [3,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2040-04 | dm6 | calendar.days-in-month | [4,2040] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2040-05 | dm6 | calendar.days-in-month | [5,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2040-06 | dm6 | calendar.days-in-month | [6,2040] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2040-07 | dm6 | calendar.days-in-month | [7,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2040-08 | dm6 | calendar.days-in-month | [8,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2040-09 | dm6 | calendar.days-in-month | [9,2040] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2040-10 | dm6 | calendar.days-in-month | [10,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2040-11 | dm6 | calendar.days-in-month | [11,2040] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M-2040-12 | dm6 | calendar.days-in-month | [12,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-Y-1900 | dm6 | calendar.days-in-year | [1900] | scalar | scalar 365 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-Y-2000 | dm6 | calendar.days-in-year | [2000] | scalar | scalar 366 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-Y-2039 | dm6 | calendar.days-in-year | [2039] | scalar | scalar 365 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-Y-2040 | dm6 | calendar.days-in-year | [2040] | scalar | scalar 366 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-Y-2100 | dm6 | calendar.days-in-year | [2100] | scalar | scalar 365 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M0-2039-LIST | dm6 | calendar.days-in-month | [0,2039] | list | list [31,28,31,30,31,30,31,31,30,31,30,31] | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M0-2039-SCALAR | dm6 | calendar.days-in-month | [0,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M0-2040-LIST | dm6 | calendar.days-in-month | [0,2040] | list | list [31,29,31,30,31,30,31,31,30,31,30,31] | no warning or exception | not called because the facade exposes none |
      | CL-DM6-M0-2040-SCALAR | dm6 | calendar.days-in-month | [0,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-SHORT-M-DEFAULT | dm6 | calendar.days-in-month | [2,"00"] | scalar | scalar 29 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-SHORT-Y-DEFAULT | dm6 | calendar.days-in-year | ["00"] | scalar | scalar 366 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-SHORT-M-C19 | dm6 | calendar.days-in-month | [2,"00"] | scalar | scalar 29 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-SHORT-Y-C19 | dm6 | calendar.days-in-year | ["00"] | scalar | scalar 366 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-SHORT-M-C20 | dm6 | calendar.days-in-month | [2,"00"] | scalar | scalar 29 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-SHORT-Y-C20 | dm6 | calendar.days-in-year | ["00"] | scalar | scalar 366 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-INVALID-M-OMITTED | dm6 | calendar.days-in-month | [] | scalar | scalar 31 | warnings ["Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)"] | not called because the facade exposes none |
      | CL-DM6-INVALID-M-UNDEFINED | dm6 | calendar.days-in-month | [null,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-INVALID-M-TEXT | dm6 | calendar.days-in-month | ["x",2040] | scalar | scalar 32 | warnings ["Argument \"x\" isn't numeric in integer eq (==)"] | not called because the facade exposes none |
      | CL-DM6-INVALID-M-FRACTION | dm6 | calendar.days-in-month | [2.5,2040] | scalar | scalar 29 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-INVALID-M-NEGATIVE | dm6 | calendar.days-in-month | [-1,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-INVALID-M-HIGH | dm6 | calendar.days-in-month | [13,2040] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-INVALID-M-YEAR-OMITTED | dm6 | calendar.days-in-month | [2] | scalar | scalar 29 | warnings ["Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)"] | not called because the facade exposes none |
      | CL-DM6-INVALID-M-YEAR-UNDEFINED | dm6 | calendar.days-in-month | [2,null] | scalar | scalar 29 | warnings ["Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)"] | not called because the facade exposes none |
      | CL-DM6-INVALID-M-YEAR-TEXT | dm6 | calendar.days-in-month | [2,"x"] | scalar | scalar 29 | warnings ["Argument \"x\" isn't numeric in integer modulus (%)"] | not called because the facade exposes none |
      | CL-DM6-INVALID-M-YEAR-NEGATIVE | dm6 | calendar.days-in-month | [2,-1] | scalar | scalar 28 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-INVALID-M-YEAR-HIGH | dm6 | calendar.days-in-month | [2,10000] | scalar | scalar 29 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-INVALID-Y-OMITTED | dm6 | calendar.days-in-year | [] | scalar | scalar 366 | warnings ["Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)"] | not called because the facade exposes none |
      | CL-DM6-INVALID-Y-UNDEFINED | dm6 | calendar.days-in-year | [null] | scalar | scalar 366 | warnings ["Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)"] | not called because the facade exposes none |
      | CL-DM6-INVALID-Y-TEXT | dm6 | calendar.days-in-year | ["x"] | scalar | scalar 366 | warnings ["Argument \"x\" isn't numeric in integer modulus (%)"] | not called because the facade exposes none |
      | CL-DM6-INVALID-Y-FRACTION | dm6 | calendar.days-in-year | [2040.5] | scalar | scalar 366 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-INVALID-Y-ZERO | dm6 | calendar.days-in-year | [0] | scalar | scalar 366 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-INVALID-Y-NEGATIVE | dm6 | calendar.days-in-year | [-1] | scalar | scalar 365 | no warning or exception | not called because the facade exposes none |
      | CL-DM6-INVALID-Y-HIGH | dm6 | calendar.days-in-year | [10000] | scalar | scalar 366 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2039-01 | dm5 | calendar.days-in-month | [1,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2039-02 | dm5 | calendar.days-in-month | [2,2039] | scalar | scalar 28 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2039-03 | dm5 | calendar.days-in-month | [3,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2039-04 | dm5 | calendar.days-in-month | [4,2039] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2039-05 | dm5 | calendar.days-in-month | [5,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2039-06 | dm5 | calendar.days-in-month | [6,2039] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2039-07 | dm5 | calendar.days-in-month | [7,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2039-08 | dm5 | calendar.days-in-month | [8,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2039-09 | dm5 | calendar.days-in-month | [9,2039] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2039-10 | dm5 | calendar.days-in-month | [10,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2039-11 | dm5 | calendar.days-in-month | [11,2039] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2039-12 | dm5 | calendar.days-in-month | [12,2039] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2040-01 | dm5 | calendar.days-in-month | [1,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2040-02 | dm5 | calendar.days-in-month | [2,2040] | scalar | scalar 29 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2040-03 | dm5 | calendar.days-in-month | [3,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2040-04 | dm5 | calendar.days-in-month | [4,2040] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2040-05 | dm5 | calendar.days-in-month | [5,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2040-06 | dm5 | calendar.days-in-month | [6,2040] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2040-07 | dm5 | calendar.days-in-month | [7,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2040-08 | dm5 | calendar.days-in-month | [8,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2040-09 | dm5 | calendar.days-in-month | [9,2040] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2040-10 | dm5 | calendar.days-in-month | [10,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2040-11 | dm5 | calendar.days-in-month | [11,2040] | scalar | scalar 30 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M-2040-12 | dm5 | calendar.days-in-month | [12,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-Y-1900 | dm5 | calendar.days-in-year | [1900] | scalar | scalar 365 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-Y-2000 | dm5 | calendar.days-in-year | [2000] | scalar | scalar 366 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-Y-2039 | dm5 | calendar.days-in-year | [2039] | scalar | scalar 365 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-Y-2040 | dm5 | calendar.days-in-year | [2040] | scalar | scalar 366 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-Y-2100 | dm5 | calendar.days-in-year | [2100] | scalar | scalar 365 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M0-2039-LIST | dm5 | calendar.days-in-month | [0,2039] | list | list [0] | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M0-2039-SCALAR | dm5 | calendar.days-in-month | [0,2039] | scalar | scalar 0 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M0-2040-LIST | dm5 | calendar.days-in-month | [0,2040] | list | list [0] | no warning or exception | not called because the facade exposes none |
      | CL-DM5-M0-2040-SCALAR | dm5 | calendar.days-in-month | [0,2040] | scalar | scalar 0 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-SHORT-M-DEFAULT | dm5 | calendar.days-in-month | [2,"00"] | scalar | scalar 29 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-SHORT-Y-DEFAULT | dm5 | calendar.days-in-year | ["00"] | scalar | scalar 366 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-SHORT-M-C19 | dm5 | calendar.days-in-month | [2,"00"] | scalar | scalar 28 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-SHORT-Y-C19 | dm5 | calendar.days-in-year | ["00"] | scalar | scalar 365 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-SHORT-M-C20 | dm5 | calendar.days-in-month | [2,"00"] | scalar | scalar 29 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-SHORT-Y-C20 | dm5 | calendar.days-in-year | ["00"] | scalar | scalar 366 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-INVALID-M-OMITTED | dm5 | calendar.days-in-month | [] | scalar | scalar 0 | warnings ["Use of uninitialized value length($y) in integer ne (!=)","Use of uninitialized value $m in array element"] | not called because the facade exposes none |
      | CL-DM5-INVALID-M-UNDEFINED | dm5 | calendar.days-in-month | [null,2040] | scalar | scalar 0 | warnings ["Use of uninitialized value $m in array element"] | not called because the facade exposes none |
      | CL-DM5-INVALID-M-TEXT | dm5 | calendar.days-in-month | ["x",2040] | scalar | scalar 0 | warnings ["Argument \"x\" isn't numeric in array or hash lookup"] | not called because the facade exposes none |
      | CL-DM5-INVALID-M-FRACTION | dm5 | calendar.days-in-month | [2.5,2040] | scalar | scalar 29 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-INVALID-M-NEGATIVE | dm5 | calendar.days-in-month | [-1,2040] | scalar | scalar 31 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-INVALID-M-HIGH | dm5 | calendar.days-in-month | [13,2040] | scalar | undefined scalar | no warning or exception | not called because the facade exposes none |
      | CL-DM5-INVALID-M-YEAR-OMITTED | dm5 | calendar.days-in-month | [2] | scalar | scalar 29 | warnings ["Use of uninitialized value length($y) in integer ne (!=)"] | not called because the facade exposes none |
      | CL-DM5-INVALID-M-YEAR-UNDEFINED | dm5 | calendar.days-in-month | [2,null] | scalar | scalar 29 | warnings ["Use of uninitialized value length($y) in integer ne (!=)"] | not called because the facade exposes none |
      | CL-DM5-INVALID-M-YEAR-TEXT | dm5 | calendar.days-in-month | [2,"x"] | scalar | no return because the call raises an exception | exception "ERROR: Invalid year (x)" | not called because the facade exposes none |
      | CL-DM5-INVALID-M-YEAR-NEGATIVE | dm5 | calendar.days-in-month | [2,-1] | scalar | scalar 28 | warnings ["Argument \"19-1\" isn't numeric in integer lt (<)"] | not called because the facade exposes none |
      | CL-DM5-INVALID-M-YEAR-HIGH | dm5 | calendar.days-in-month | [2,10000] | scalar | no return because the call raises an exception | exception "ERROR: Invalid year (10000)" | not called because the facade exposes none |
      | CL-DM5-INVALID-Y-OMITTED | dm5 | calendar.days-in-year | [] | scalar | scalar 366 | warnings ["Use of uninitialized value length($y) in integer ne (!=)"] | not called because the facade exposes none |
      | CL-DM5-INVALID-Y-UNDEFINED | dm5 | calendar.days-in-year | [null] | scalar | scalar 366 | warnings ["Use of uninitialized value length($y) in integer ne (!=)"] | not called because the facade exposes none |
      | CL-DM5-INVALID-Y-TEXT | dm5 | calendar.days-in-year | ["x"] | scalar | no return because the call raises an exception | exception "ERROR: Invalid year (x)" | not called because the facade exposes none |
      | CL-DM5-INVALID-Y-FRACTION | dm5 | calendar.days-in-year | [2040.5] | scalar | no return because the call raises an exception | exception "ERROR: Invalid year (2040.5)" | not called because the facade exposes none |
      | CL-DM5-INVALID-Y-ZERO | dm5 | calendar.days-in-year | [0] | scalar | scalar 366 | no warning or exception | not called because the facade exposes none |
      | CL-DM5-INVALID-Y-NEGATIVE | dm5 | calendar.days-in-year | [-1] | scalar | scalar 365 | warnings ["Argument \"19-1\" isn't numeric in integer lt (<)"] | not called because the facade exposes none |
      | CL-DM5-INVALID-Y-HIGH | dm5 | calendar.days-in-year | [10000] | scalar | no return because the call raises an exception | exception "ERROR: Invalid year (10000)" | not called because the facade exposes none |

  Scenario Outline: Preserve the Base error clear and read sequence
    Given binding route base receives the request identified by <case>
    When the inherited public error observer is cleared before the request
    Then it reads <error before> before and <error after> after the request

    Examples:
      | case | error before | error after |
      | CL-BASE-M-2039-01 | "" | "" |
      | CL-BASE-M-2039-02 | "" | "" |
      | CL-BASE-M-2039-03 | "" | "" |
      | CL-BASE-M-2039-04 | "" | "" |
      | CL-BASE-M-2039-05 | "" | "" |
      | CL-BASE-M-2039-06 | "" | "" |
      | CL-BASE-M-2039-07 | "" | "" |
      | CL-BASE-M-2039-08 | "" | "" |
      | CL-BASE-M-2039-09 | "" | "" |
      | CL-BASE-M-2039-10 | "" | "" |
      | CL-BASE-M-2039-11 | "" | "" |
      | CL-BASE-M-2039-12 | "" | "" |
      | CL-BASE-M-2040-01 | "" | "" |
      | CL-BASE-M-2040-02 | "" | "" |
      | CL-BASE-M-2040-03 | "" | "" |
      | CL-BASE-M-2040-04 | "" | "" |
      | CL-BASE-M-2040-05 | "" | "" |
      | CL-BASE-M-2040-06 | "" | "" |
      | CL-BASE-M-2040-07 | "" | "" |
      | CL-BASE-M-2040-08 | "" | "" |
      | CL-BASE-M-2040-09 | "" | "" |
      | CL-BASE-M-2040-10 | "" | "" |
      | CL-BASE-M-2040-11 | "" | "" |
      | CL-BASE-M-2040-12 | "" | "" |
      | CL-BASE-Y-1900 | "" | "" |
      | CL-BASE-Y-2000 | "" | "" |
      | CL-BASE-Y-2039 | "" | "" |
      | CL-BASE-Y-2040 | "" | "" |
      | CL-BASE-Y-2100 | "" | "" |
      | CL-BASE-M0-2039-LIST | "" | "" |
      | CL-BASE-M0-2039-SCALAR | "" | "" |
      | CL-BASE-M0-2040-LIST | "" | "" |
      | CL-BASE-M0-2040-SCALAR | "" | "" |
      | CL-BASE-SHORT-M-DEFAULT | "" | "" |
      | CL-BASE-SHORT-Y-DEFAULT | "" | "" |
      | CL-BASE-SHORT-M-C19 | "" | "" |
      | CL-BASE-SHORT-Y-C19 | "" | "" |
      | CL-BASE-SHORT-M-C20 | "" | "" |
      | CL-BASE-SHORT-Y-C20 | "" | "" |
      | CL-BASE-INVALID-M-OMITTED | "" | "" |
      | CL-BASE-INVALID-M-UNDEFINED | "" | "" |
      | CL-BASE-INVALID-M-TEXT | "" | "" |
      | CL-BASE-INVALID-M-FRACTION | "" | "" |
      | CL-BASE-INVALID-M-NEGATIVE | "" | "" |
      | CL-BASE-INVALID-M-HIGH | "" | "" |
      | CL-BASE-INVALID-M-YEAR-OMITTED | "" | "" |
      | CL-BASE-INVALID-M-YEAR-UNDEFINED | "" | "" |
      | CL-BASE-INVALID-M-YEAR-TEXT | "" | "" |
      | CL-BASE-INVALID-M-YEAR-NEGATIVE | "" | "" |
      | CL-BASE-INVALID-M-YEAR-HIGH | "" | "" |
      | CL-BASE-INVALID-Y-OMITTED | "" | "" |
      | CL-BASE-INVALID-Y-UNDEFINED | "" | "" |
      | CL-BASE-INVALID-Y-TEXT | "" | "" |
      | CL-BASE-INVALID-Y-FRACTION | "" | "" |
      | CL-BASE-INVALID-Y-ZERO | "" | "" |
      | CL-BASE-INVALID-Y-NEGATIVE | "" | "" |
      | CL-BASE-INVALID-Y-HIGH | "" | "" |
