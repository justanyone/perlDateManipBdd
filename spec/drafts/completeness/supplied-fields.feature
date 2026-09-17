@draft @reference-dm700 @observed-compatibility
Feature: Distinguish supplied fields from defaults through completeness queries
  Completeness is an observed property of the parsed value. A true result does
  not promise that every field appeared literally in the user's text.

  Background:
    Given a fresh English ASCII context with local zone "Etc/UTC"
    And the fixed clock is "2040-02-28 10:20:30 Etc/UTC"
    And numeric dates use month/day/year order and omitted clocks use midnight
    And no value getter is called before the completeness queries
    And I use these ordered completeness requests:
      | request | meaning |
      | all | omit the selector and query the complete value |
      | month | query month using selector m |
      | day | query day using selector d |
      | hour | query hour using selector h |
      | minute | query minute using selector mn |
      | second | query second using selector s |
      | empty | supply an empty text selector |
      | zero | supply numeric selector 0 |
      | absent | supply an absent selector value |
      | year-unsupported | supply text selector y |
      | uppercase | supply text selector M |
      | unknown | supply text selector bogus |
    And result 1 means true, 0 means false, and null means no result
    And error text is read immediately before and after each query

  Scenario Outline: Read completeness flags without changing error state for <case>
    Given a newly constructed empty date value
    When I perform <setup> using input <input>
    Then the setup status is <status> where null means no parse was requested
    And the error before querying is <error>
    When I perform every completeness request in the stated order
    Then the ordered query results are <results>
    And the error before and after every query is <error>

    Examples:
      | case | setup | input | status | error | results |
      | COMP-FULL | full parsing | "2040-02-29 16:05:09" | 0 | "" | [1,1,1,1,1,1,1,1,1,0,0,0] |
      | COMP-MINUTE | full parsing | "2040-02-29 16:05" | 0 | "" | [0,1,1,1,1,0,0,0,0,0,0,0] |
      | COMP-DATE | full parsing | "2040-02-29" | 0 | "" | [0,1,1,0,0,0,0,0,0,0,0,0] |
      | COMP-YEAR-MONTH | full parsing | "2040-02" | 0 | "" | [0,1,0,0,0,0,0,0,0,0,0,0] |
      | COMP-YEAR | full parsing | "2040" | 0 | "" | [0,0,0,0,0,0,0,0,0,0,0,0] |
      | COMP-MONTH-DAY | full parsing | "February 29" | 0 | "" | [1,1,1,1,1,1,1,1,1,0,0,0] |
      | COMP-TIME | full parsing | "16:05:09" | 0 | "" | [1,1,1,1,1,1,1,1,1,0,0,0] |
      | COMP-RELATIVE | full parsing | "tomorrow" | 0 | "" | [1,1,1,1,1,1,1,1,1,0,0,0] |
      | COMP-UNSET | no parsing | null | null | "" | [null,null,null,null,null,null,null,null,null,null,null,null] |
      | COMP-INVALID | full parsing | "not a date" | 1 | "[parse] Invalid date string" | [null,null,null,null,null,null,null,null,null,null,null,null] |
      | COMP-EMPTY | full parsing | "" | 1 | "[parse] Empty date string" | [null,null,null,null,null,null,null,null,null,null,null,null] |
