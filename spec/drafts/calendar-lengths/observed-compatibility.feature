@observed-compatibility @calendar-lengths @disputed-invalid-inputs
Feature: Calendar length compatibility outside the portable valid domain
  These rows retain every observed public result for undocumented carriers, short-year handling,
  and invalid values. They do not define those values as valid calendar requests.

  Background:
    Given the calendar zone is "Etc/UTC" and the reference clock is "2040-02-28 10:20:30"

  Scenario Outline: Retain the generic public outcome of each compatibility request
    Given I use the <profile> with short-year setting <configuration>
    When I perform <operation> with arguments <arguments>
    Then the observed public result is <result>
    But partition <partition> remains outside the portable valid calendar domain

    Examples:
      | case | profile | configuration | operation | arguments | result | partition |
      | CL-BASE-M0-2039-SCALAR | current calendar arithmetic profile | pinned default | calendar.days-in-month | [2039,0] | number 31 | month-zero-scalar |
      | CL-BASE-M0-2040-SCALAR | current calendar arithmetic profile | pinned default | calendar.days-in-month | [2040,0] | number 31 | month-zero-scalar |
      | CL-BASE-SHORT-M-DEFAULT | current calendar arithmetic profile | pinned default | calendar.days-in-month | ["00",2] | number 29 | short-year |
      | CL-BASE-SHORT-Y-DEFAULT | current calendar arithmetic profile | pinned default | calendar.days-in-year | ["00"] | number 366 | short-year |
      | CL-BASE-SHORT-M-C19 | current calendar arithmetic profile | C19 | calendar.days-in-month | ["00",2] | number 29 | short-year |
      | CL-BASE-SHORT-Y-C19 | current calendar arithmetic profile | C19 | calendar.days-in-year | ["00"] | number 366 | short-year |
      | CL-BASE-SHORT-M-C20 | current calendar arithmetic profile | C20 | calendar.days-in-month | ["00",2] | number 29 | short-year |
      | CL-BASE-SHORT-Y-C20 | current calendar arithmetic profile | C20 | calendar.days-in-year | ["00"] | number 366 | short-year |
      | CL-BASE-INVALID-M-OMITTED | current calendar arithmetic profile | pinned default | calendar.days-in-month | [] | number 31 | invalid-month |
      | CL-BASE-INVALID-M-UNDEFINED | current calendar arithmetic profile | pinned default | calendar.days-in-month | [2040,null] | number 31 | invalid-month |
      | CL-BASE-INVALID-M-TEXT | current calendar arithmetic profile | pinned default | calendar.days-in-month | [2040,"x"] | number 32 | invalid-month |
      | CL-BASE-INVALID-M-FRACTION | current calendar arithmetic profile | pinned default | calendar.days-in-month | [2040,2.5] | number 29 | invalid-month |
      | CL-BASE-INVALID-M-NEGATIVE | current calendar arithmetic profile | pinned default | calendar.days-in-month | [2040,-1] | number 31 | invalid-month |
      | CL-BASE-INVALID-M-HIGH | current calendar arithmetic profile | pinned default | calendar.days-in-month | [2040,13] | number 30 | invalid-month |
      | CL-BASE-INVALID-M-YEAR-OMITTED | current calendar arithmetic profile | pinned default | calendar.days-in-month | [2040] | number 31 | invalid-year-for-month |
      | CL-BASE-INVALID-M-YEAR-UNDEFINED | current calendar arithmetic profile | pinned default | calendar.days-in-month | [null,2] | number 29 | invalid-year-for-month |
      | CL-BASE-INVALID-M-YEAR-TEXT | current calendar arithmetic profile | pinned default | calendar.days-in-month | ["x",2] | number 29 | invalid-year-for-month |
      | CL-BASE-INVALID-M-YEAR-NEGATIVE | current calendar arithmetic profile | pinned default | calendar.days-in-month | [-1,2] | number 28 | invalid-year-for-month |
      | CL-BASE-INVALID-M-YEAR-HIGH | current calendar arithmetic profile | pinned default | calendar.days-in-month | [10000,2] | number 29 | invalid-year-for-month |
      | CL-BASE-INVALID-Y-OMITTED | current calendar arithmetic profile | pinned default | calendar.days-in-year | [] | number 366 | invalid-year |
      | CL-BASE-INVALID-Y-UNDEFINED | current calendar arithmetic profile | pinned default | calendar.days-in-year | [null] | number 366 | invalid-year |
      | CL-BASE-INVALID-Y-TEXT | current calendar arithmetic profile | pinned default | calendar.days-in-year | ["x"] | number 366 | invalid-year |
      | CL-BASE-INVALID-Y-FRACTION | current calendar arithmetic profile | pinned default | calendar.days-in-year | [2040.5] | number 366 | invalid-year |
      | CL-BASE-INVALID-Y-ZERO | current calendar arithmetic profile | pinned default | calendar.days-in-year | [0] | number 366 | invalid-year |
      | CL-BASE-INVALID-Y-NEGATIVE | current calendar arithmetic profile | pinned default | calendar.days-in-year | [-1] | number 365 | invalid-year |
      | CL-BASE-INVALID-Y-HIGH | current calendar arithmetic profile | pinned default | calendar.days-in-year | [10000] | number 366 | invalid-year |
      | CL-DM6-M0-2039-LIST | current functional profile | pinned default | calendar.days-in-month | [0,2039] | ordered numbers [31,28,31,30,31,30,31,31,30,31,30,31] | month-zero-list |
      | CL-DM6-M0-2039-SCALAR | current functional profile | pinned default | calendar.days-in-month | [0,2039] | number 31 | month-zero-scalar |
      | CL-DM6-M0-2040-LIST | current functional profile | pinned default | calendar.days-in-month | [0,2040] | ordered numbers [31,29,31,30,31,30,31,31,30,31,30,31] | month-zero-list |
      | CL-DM6-M0-2040-SCALAR | current functional profile | pinned default | calendar.days-in-month | [0,2040] | number 31 | month-zero-scalar |
      | CL-DM6-SHORT-M-DEFAULT | current functional profile | pinned default | calendar.days-in-month | [2,"00"] | number 29 | short-year |
      | CL-DM6-SHORT-Y-DEFAULT | current functional profile | pinned default | calendar.days-in-year | ["00"] | number 366 | short-year |
      | CL-DM6-SHORT-M-C19 | current functional profile | C19 | calendar.days-in-month | [2,"00"] | number 29 | short-year |
      | CL-DM6-SHORT-Y-C19 | current functional profile | C19 | calendar.days-in-year | ["00"] | number 366 | short-year |
      | CL-DM6-SHORT-M-C20 | current functional profile | C20 | calendar.days-in-month | [2,"00"] | number 29 | short-year |
      | CL-DM6-SHORT-Y-C20 | current functional profile | C20 | calendar.days-in-year | ["00"] | number 366 | short-year |
      | CL-DM6-INVALID-M-OMITTED | current functional profile | pinned default | calendar.days-in-month | [] | number 31 | invalid-month |
      | CL-DM6-INVALID-M-UNDEFINED | current functional profile | pinned default | calendar.days-in-month | [null,2040] | number 31 | invalid-month |
      | CL-DM6-INVALID-M-TEXT | current functional profile | pinned default | calendar.days-in-month | ["x",2040] | number 32 | invalid-month |
      | CL-DM6-INVALID-M-FRACTION | current functional profile | pinned default | calendar.days-in-month | [2.5,2040] | number 29 | invalid-month |
      | CL-DM6-INVALID-M-NEGATIVE | current functional profile | pinned default | calendar.days-in-month | [-1,2040] | number 31 | invalid-month |
      | CL-DM6-INVALID-M-HIGH | current functional profile | pinned default | calendar.days-in-month | [13,2040] | number 30 | invalid-month |
      | CL-DM6-INVALID-M-YEAR-OMITTED | current functional profile | pinned default | calendar.days-in-month | [2] | number 29 | invalid-year-for-month |
      | CL-DM6-INVALID-M-YEAR-UNDEFINED | current functional profile | pinned default | calendar.days-in-month | [2,null] | number 29 | invalid-year-for-month |
      | CL-DM6-INVALID-M-YEAR-TEXT | current functional profile | pinned default | calendar.days-in-month | [2,"x"] | number 29 | invalid-year-for-month |
      | CL-DM6-INVALID-M-YEAR-NEGATIVE | current functional profile | pinned default | calendar.days-in-month | [2,-1] | number 28 | invalid-year-for-month |
      | CL-DM6-INVALID-M-YEAR-HIGH | current functional profile | pinned default | calendar.days-in-month | [2,10000] | number 29 | invalid-year-for-month |
      | CL-DM6-INVALID-Y-OMITTED | current functional profile | pinned default | calendar.days-in-year | [] | number 366 | invalid-year |
      | CL-DM6-INVALID-Y-UNDEFINED | current functional profile | pinned default | calendar.days-in-year | [null] | number 366 | invalid-year |
      | CL-DM6-INVALID-Y-TEXT | current functional profile | pinned default | calendar.days-in-year | ["x"] | number 366 | invalid-year |
      | CL-DM6-INVALID-Y-FRACTION | current functional profile | pinned default | calendar.days-in-year | [2040.5] | number 366 | invalid-year |
      | CL-DM6-INVALID-Y-ZERO | current functional profile | pinned default | calendar.days-in-year | [0] | number 366 | invalid-year |
      | CL-DM6-INVALID-Y-NEGATIVE | current functional profile | pinned default | calendar.days-in-year | [-1] | number 365 | invalid-year |
      | CL-DM6-INVALID-Y-HIGH | current functional profile | pinned default | calendar.days-in-year | [10000] | number 366 | invalid-year |
      | CL-DM5-M0-2039-LIST | legacy functional profile | pinned default | calendar.days-in-month | [0,2039] | ordered numbers [0] | month-zero-list |
      | CL-DM5-M0-2039-SCALAR | legacy functional profile | pinned default | calendar.days-in-month | [0,2039] | number 0 | month-zero-scalar |
      | CL-DM5-M0-2040-LIST | legacy functional profile | pinned default | calendar.days-in-month | [0,2040] | ordered numbers [0] | month-zero-list |
      | CL-DM5-M0-2040-SCALAR | legacy functional profile | pinned default | calendar.days-in-month | [0,2040] | number 0 | month-zero-scalar |
      | CL-DM5-INVALID-M-OMITTED | legacy functional profile | pinned default | calendar.days-in-month | [] | number 0 | invalid-month |
      | CL-DM5-INVALID-M-UNDEFINED | legacy functional profile | pinned default | calendar.days-in-month | [null,2040] | number 0 | invalid-month |
      | CL-DM5-INVALID-M-TEXT | legacy functional profile | pinned default | calendar.days-in-month | ["x",2040] | number 0 | invalid-month |
      | CL-DM5-INVALID-M-FRACTION | legacy functional profile | pinned default | calendar.days-in-month | [2.5,2040] | number 29 | invalid-month |
      | CL-DM5-INVALID-M-NEGATIVE | legacy functional profile | pinned default | calendar.days-in-month | [-1,2040] | number 31 | invalid-month |
      | CL-DM5-INVALID-M-HIGH | legacy functional profile | pinned default | calendar.days-in-month | [13,2040] | an absent value | invalid-month |
      | CL-DM5-INVALID-M-YEAR-OMITTED | legacy functional profile | pinned default | calendar.days-in-month | [2] | number 29 | invalid-year-for-month |
      | CL-DM5-INVALID-M-YEAR-UNDEFINED | legacy functional profile | pinned default | calendar.days-in-month | [2,null] | number 29 | invalid-year-for-month |
      | CL-DM5-INVALID-M-YEAR-TEXT | legacy functional profile | pinned default | calendar.days-in-month | [2,"x"] | no result because the request fails | invalid-year-for-month |
      | CL-DM5-INVALID-M-YEAR-NEGATIVE | legacy functional profile | pinned default | calendar.days-in-month | [2,-1] | number 28 | invalid-year-for-month |
      | CL-DM5-INVALID-M-YEAR-HIGH | legacy functional profile | pinned default | calendar.days-in-month | [2,10000] | no result because the request fails | invalid-year-for-month |
      | CL-DM5-INVALID-Y-OMITTED | legacy functional profile | pinned default | calendar.days-in-year | [] | number 366 | invalid-year |
      | CL-DM5-INVALID-Y-UNDEFINED | legacy functional profile | pinned default | calendar.days-in-year | [null] | number 366 | invalid-year |
      | CL-DM5-INVALID-Y-TEXT | legacy functional profile | pinned default | calendar.days-in-year | ["x"] | no result because the request fails | invalid-year |
      | CL-DM5-INVALID-Y-FRACTION | legacy functional profile | pinned default | calendar.days-in-year | [2040.5] | no result because the request fails | invalid-year |
      | CL-DM5-INVALID-Y-ZERO | legacy functional profile | pinned default | calendar.days-in-year | [0] | number 366 | invalid-year |
      | CL-DM5-INVALID-Y-NEGATIVE | legacy functional profile | pinned default | calendar.days-in-year | [-1] | number 365 | invalid-year |
      | CL-DM5-INVALID-Y-HIGH | legacy functional profile | pinned default | calendar.days-in-year | [10000] | no result because the request fails | invalid-year |
