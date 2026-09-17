@draft @leap-year @compatibility @disputed @reference-observed
Feature: Characterize invalid and outside-year requests
  Exact native warnings and exceptions are isolated in the excluded Perl-binding feature.

  Background:
    Given the leap-year profile "gregorian-2040" has:
      | setting                   | value                              |
      | calendar                  | proleptic Gregorian                |
      | supported year interval   | 0001 through 9999                  |
      | fixed reference clock     | 2040-02-28 10:20:30 in Etc/UTC     |
      | input language            | English                            |
      | default short-year window | reference year minus 89 through plus 10 |

  Scenario Outline: Characterize an invalid or outside request for <case>
    Given public leap-year profile "<profile>"
    When it classifies <request>
    Then the generic outcome is <outcome>

    Examples:
      | case                         | profile | request                   | outcome                         |
      | LY-EDGE-OMITTED-BASE         | base    | omitted argument          | numeric flag 1                  |
      | LY-EDGE-OMITTED-DM6          | dm6     | omitted argument          | numeric flag 1                  |
      | LY-EDGE-OMITTED-DM5          | dm5     | omitted argument          | numeric flag 1                  |
      | LY-EDGE-UNDEFINED-BASE       | base    | explicit absent value     | numeric flag 1                  |
      | LY-EDGE-UNDEFINED-DM6        | dm6     | explicit absent value     | numeric flag 1                  |
      | LY-EDGE-UNDEFINED-DM5        | dm5     | explicit absent value     | numeric flag 1                  |
      | LY-EDGE-EMPTY-BASE           | base    | empty text                | numeric flag 1                  |
      | LY-EDGE-EMPTY-DM6            | dm6     | empty text                | numeric flag 1                  |
      | LY-EDGE-EMPTY-DM5            | dm5     | empty text                | numeric flag 1                  |
      | LY-EDGE-SPACE-BASE           | base    | text containing one space | numeric flag 1                  |
      | LY-EDGE-SPACE-DM6            | dm6     | text containing one space | numeric flag 1                  |
      | LY-EDGE-SPACE-DM5            | dm5     | text containing one space | call interrupted with no return |
      | LY-EDGE-NONNUMERIC4-BASE     | base    | text "abcd"               | numeric flag 1                  |
      | LY-EDGE-NONNUMERIC4-DM6      | dm6     | text "abcd"               | numeric flag 1                  |
      | LY-EDGE-NONNUMERIC4-DM5      | dm5     | text "abcd"               | numeric flag 1                  |
      | LY-EDGE-NONNUMERIC3-BASE     | base    | text "abc"                | numeric flag 1                  |
      | LY-EDGE-NONNUMERIC3-DM6      | dm6     | text "abc"                | numeric flag 1                  |
      | LY-EDGE-NONNUMERIC3-DM5      | dm5     | text "abc"                | call interrupted with no return |
      | LY-EDGE-FRACTION-BASE        | base    | number 2000.5             | numeric flag 1                  |
      | LY-EDGE-FRACTION-DM6         | dm6     | number 2000.5             | numeric flag 1                  |
      | LY-EDGE-FRACTION-DM5         | dm5     | number 2000.5             | call interrupted with no return |
      | LY-EDGE-ZERO-BASE            | base    | number 0                  | numeric flag 1                  |
      | LY-EDGE-ZERO-DM6             | dm6     | number 0                  | numeric flag 1                  |
      | LY-EDGE-ZERO-DM5             | dm5     | number 0                  | numeric flag 1                  |
      | LY-EDGE-NEGATIVE4-BASE       | base    | number -4                 | numeric flag 1                  |
      | LY-EDGE-NEGATIVE4-DM6        | dm6     | number -4                 | numeric flag 1                  |
      | LY-EDGE-NEGATIVE4-DM5        | dm5     | number -4                 | numeric flag 0                  |
      | LY-EDGE-NEGATIVE400-BASE     | base    | number -400               | numeric flag 1                  |
      | LY-EDGE-NEGATIVE400-DM6      | dm6     | number -400               | numeric flag 1                  |
      | LY-EDGE-NEGATIVE400-DM5      | dm5     | number -400               | numeric flag 1                  |
      | LY-EDGE-NEGATIVE100-BASE     | base    | number -100               | numeric flag 0                  |
      | LY-EDGE-NEGATIVE100-DM6      | dm6     | number -100               | numeric flag 0                  |
      | LY-EDGE-NEGATIVE100-DM5      | dm5     | number -100               | numeric flag 0                  |
      | LY-EDGE-OUTSIDE10000-BASE    | base    | number 10000              | numeric flag 1                  |
      | LY-EDGE-OUTSIDE10000-DM6     | dm6     | number 10000              | numeric flag 1                  |
      | LY-EDGE-OUTSIDE10000-DM5     | dm5     | number 10000              | call interrupted with no return |
