@draft @delta @grammar @format
Feature: Parse and render bounded interval syntax families
  This draft records repeatable observations and awaits semantic review.

  Background:
    Given each case starts in a fresh isolated arithmetic configuration:
      | setting             | value                              |
      | language            | English                            |
      | character encoding  | ASCII                              |
      | local time zone     | Etc/UTC                            |
      | reference date-time | 2040-02-28 10:20:30 Etc/UTC        |
      | numeric date order  | month before day                   |
      | omitted time        | midnight                           |
      | first weekday       | Monday                             |
      | first week          | the week containing January 4     |
      | work week           | Monday through Friday              |
      | work hours          | 09:00 through 17:00                |
      | 24-hour workday     | disabled                           |
      | holidays            | none                               |
      | events              | none                               |
    And interval normalization uses these relationships:
      | larger unit                         | smaller-unit value |
      | minute                              | 60 seconds         |
      | hour                                | 60 minutes         |
      | standard day                        | 24 hours           |
      | standard week                       | 7 days             |
      | year for year-month normalization   | 12 months          |
      | year for estimated conversion       | 365.2425 days      |
      | configured business day             | 8 hours            |
      | configured business week            | 5 days             |
    And interval field records are ordered year, month, week, day, hour, minute, second

  @DELTA-GRAMMAR-PRODUCTIONS
  Scenario Outline: Parse one bounded grammar production for <case>
    When I parse interval text "<text>" with default options
    Then the status is <status>
    And the serialized interval result is <fields>
    And the error result is <error>

    Examples:
      | case                             | text                                                        | status | fields                    | error                                      |
      | DELTA-GRAMMAR-COMPACT-1          | 1                                                           | 0      | text "0:0:0:0:0:0:1"    | empty text                                 |
      | DELTA-GRAMMAR-COMPACT-2          | 1:2                                                         | 0      | text "0:0:0:0:0:1:2"    | empty text                                 |
      | DELTA-GRAMMAR-COMPACT-3          | 1:2:3                                                       | 0      | text "0:0:0:0:1:2:3"    | empty text                                 |
      | DELTA-GRAMMAR-COMPACT-4          | 1:2:3:4                                                     | 0      | text "0:0:0:1:2:3:4"    | empty text                                 |
      | DELTA-GRAMMAR-COMPACT-5          | 1:2:3:4:5                                                   | 0      | text "0:0:1:2:3:4:5"    | empty text                                 |
      | DELTA-GRAMMAR-COMPACT-6          | 1:2:3:4:5:6                                                 | 0      | text "0:1:2:3:4:5:6"    | empty text                                 |
      | DELTA-GRAMMAR-COMPACT-7          | 1:2:3:4:5:6:7                                               | 0      | text "1:2:3:4:5:6:7"    | empty text                                 |
      | DELTA-GRAMMAR-EMPTY-INTERIOR     | 1::3                                                        | 0      | text "0:0:0:0:1:0:3"    | empty text                                 |
      | DELTA-GRAMMAR-SIGNED-FIELD       | 1:-2:3                                                      | 0      | text "0:0:0:0:0:57:57"  | empty text                                 |
      | DELTA-GRAMMAR-NO-SPACE           | 1:2:3                                                       | 0      | text "0:0:0:0:1:2:3"    | empty text                                 |
      | DELTA-GRAMMAR-EXPANDED-ORDERED   | 1 year 2 months 3 weeks 4 days 5 hours 6 minutes 7 seconds | 0      | text "1:2:3:4:5:6:7"    | empty text                                 |
      | DELTA-GRAMMAR-EXPANDED-NUMBER    | two days                                                    | 0      | text "0:0:0:2:0:0:0"    | empty text                                 |
      | DELTA-GRAMMAR-SIGN-INHERITANCE   | -1 year 2 days                                              | 0      | text "-1:0:0:2:0:0:0"   | empty text                                 |
      | DELTA-GRAMMAR-UNITLESS-SECOND    | 1 minute 30                                                 | 0      | text "0:0:0:0:0:1:30"   | empty text                                 |
      | DELTA-GRAMMAR-SEPARATOR          | 1 day, 2 hours                                              | 0      | text "0:0:0:1:2:0:0"    | empty text                                 |
      | DELTA-GRAMMAR-MIXED              | 1 year 2:3                                                  | 1      | empty text                | text "[parse] Invalid delta string"       |
      | DELTA-GRAMMAR-RELATIVE-AFTER     | 2 days from now                                             | 0      | text "0:0:0:2:0:0:0"    | empty text                                 |
      | DELTA-GRAMMAR-RELATIVE-BEFORE    | 2 days ago                                                  | 0      | text "0:0:0:-2:0:0:0"   | empty text                                 |
      | DELTA-GRAMMAR-MODE-WORD          | 2 business days                                             | 0      | text "0:0:0:2:0:0:0"    | empty text                                 |
      | DELTA-GRAMMAR-LEGACY-ACCURACY    | 2 approximate days                                          | 1      | empty text                | text "[parse] Invalid delta string"       |

  @DELTA-FORMAT-FIELDS-ROUNDING
  Scenario: Render every single field and basic range precision forms
    Given an interval with fields "1:2:3:4:5:6:7"
    When I render patterns "%yv", "%Mv", "%wv", "%dv", "%hv", "%mv", "%sv", "%syy", "%.0sym", and "%.2sym"
    Then the rendered values are "1", "2", "3", "4", "5", "6", "7", "31556952", "38994804", and "38994804.00"

  @DELTA-FORMAT-ALL-RANGES
  Scenario: Render the exact ordered bulk request for all inclusive source ranges
    Given an interval with fields "1:2:3:4:5:6:7"
    When I render the ordered patterns "%syy", "%syM", "%syw", "%syd", "%syh", "%sym", "%sys", "%sMM", "%sMw", "%sMd", "%sMh", "%sMm", "%sMs", "%sww", "%swd", "%swh", "%swm", "%sws", "%sdd", "%sdh", "%sdm", "%sds", "%shh", "%shm", "%shs", "%smm", "%sms", and "%sss"
    Then the ordered rendered values are:
      | pattern | value    |
      | %syy    | 31556952 |
      | %syM    | 36816444 |
      | %syw    | 38630844 |
      | %syd    | 38976444 |
      | %syh    | 38994444 |
      | %sym    | 38994804 |
      | %sys    | 38994811 |
      | %sMM    | 5259492  |
      | %sMw    | 7073892  |
      | %sMd    | 7419492  |
      | %sMh    | 7437492  |
      | %sMm    | 7437852  |
      | %sMs    | 7437859  |
      | %sww    | 1814400  |
      | %swd    | 2160000  |
      | %swh    | 2178000  |
      | %swm    | 2178360  |
      | %sws    | 2178367  |
      | %sdd    | 345600   |
      | %sdh    | 363600   |
      | %sdm    | 363960   |
      | %sds    | 363967   |
      | %shh    | 18000    |
      | %shm    | 18360    |
      | %shs    | 18367    |
      | %smm    | 360      |
      | %sms    | 367      |
      | %sss    | 7        |
