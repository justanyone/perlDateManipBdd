@portable @calendar-lengths @observed-reference
Feature: Ordered month lengths and configured legacy short years
  An all-month request returns January through December in order.
  A legacy short-year configuration selects the hundred-year window before Gregorian classification.

  Background:
    Given the calendar zone is "Etc/UTC" and the reference clock is "2040-02-28 10:20:30"
    And the calendar uses the proleptic Gregorian leap-year rule

  Scenario Outline: Return all month lengths in calendar order
    Given I use the <profile>
    When I request all month lengths for year <year>
    Then the calendar.days-in-month result is <result>

    Examples:
      | case | profile | year | result |
      | CL-BASE-M0-2039-LIST | current calendar arithmetic profile | 2039 | ordered numbers [31,28,31,30,31,30,31,31,30,31,30,31] |
      | CL-BASE-M0-2040-LIST | current calendar arithmetic profile | 2040 | ordered numbers [31,29,31,30,31,30,31,31,30,31,30,31] |

  Scenario Outline: Apply the configured legacy short-year window
    Given I use the <profile> with short-year setting <configuration>
    When I perform <operation> with arguments <arguments>
    Then the result is <result>

    Examples:
      | case | profile | configuration | operation | arguments | result |
      | CL-DM5-SHORT-M-DEFAULT | legacy functional profile | pinned default | calendar.days-in-month | [2,"00"] | number 29 |
      | CL-DM5-SHORT-Y-DEFAULT | legacy functional profile | pinned default | calendar.days-in-year | ["00"] | number 366 |
      | CL-DM5-SHORT-M-C19 | legacy functional profile | C19 | calendar.days-in-month | [2,"00"] | number 28 |
      | CL-DM5-SHORT-Y-C19 | legacy functional profile | C19 | calendar.days-in-year | ["00"] | number 365 |
      | CL-DM5-SHORT-M-C20 | legacy functional profile | C20 | calendar.days-in-month | [2,"00"] | number 29 |
      | CL-DM5-SHORT-Y-C20 | legacy functional profile | C20 | calendar.days-in-year | ["00"] | number 366 |
