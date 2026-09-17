@draft @parsing
Feature: Interpret complete and truncated date text in explicit compatibility profiles
  Each row starts with a fresh context. The current-value profile returns a stored
  date value; current-text and legacy-text return a date from a text request.
  Their implementation bindings are kept in the research map.

  Background:
    Given a fresh English date-parsing context with:
      | setting | value |
      | time zone | Etc/UTC |
      | reference clock | 2040-02-28 10:20:30 |
      | numeric date order | month then day |
      | omitted time | midnight |
      | first weekday | Monday |
      | first week | week containing January 4 |
      | working days | Monday through Friday |
      | working hours | 09:00 through 17:00 |
      | holidays and events | none |
    And no grammar family is disabled

  @compatibility @semantic-review-pending
  Scenario Outline: Interpret date text for <case>
    Given date-parsing profile "<profile>"
    And the month-year interpretation setting is "<month-year mode>"
    When I interpret the complete text "<text>" as a date
    Then parsing succeeds with local date-time "<expected date-time>" in "Etc/UTC"

    Examples:
      | case | profile | month-year mode | text | expected date-time |
      | PARSE-COMMON-NAMED-JOINED-02-DEFAULT-DM5 | legacy-text | default | Feb2940 | 2940-02-01 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-01-DISABLED-OO | current-value | default | Feb2040 | 2040-02-20 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-01-DISABLED-DM6 | current-text | default | Feb2040 | 2040-02-20 00:00:00 |
      | PARSE-INVALID-MIXED-DASHES-DM5 | legacy-text | default | 2040-0229 | 2040-02-29 00:00:00 |

  @compatibility @semantic-review-pending
  Scenario Outline: Reject date text for <case>
    Given date-parsing profile "<profile>"
    And the month-year interpretation setting is "<month-year mode>"
    When I interpret the complete text "<text>" as a date
    Then parsing rejects the text and returns no date value

    Examples:
      | case | profile | month-year mode | text |
      | PARSE-COMMON-NAMED-JOINED-12-DEFAULT-OO | current-value | default | 40 Feb29 |
      | PARSE-COMMON-NAMED-JOINED-12-DEFAULT-DM6 | current-text | default | 40 Feb29 |
      | PARSE-COMMON-NAMED-JOINED-12-DEFAULT-DM5 | legacy-text | default | 40 Feb29 |

