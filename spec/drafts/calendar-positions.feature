@draft @calendar
Feature: Ordinal and weekday positions in a calendar
  Ordinal day 1 is January 1; a fractional day represents a fraction of 24 hours.
  Weekdays are named explicitly, and negative occurrence numbers count backward.

  Background:
    Given English input, time zone "Etc/UTC", and reference clock "2040-02-28 10:20:30"
    And numeric dates use month then day, with midnight for omitted time
    And weeks start on Monday and week one contains January 4
    And working days are Monday through Friday from 09:00 through 17:00 with no holidays or events

  Scenario Outline: Query the ordinal day for <case>
    Given calendar-query profile "<profile>"
    When I request the ordinal day of "<date-time>"
    Then the result is <ordinal>

    Examples:
      | case | profile | date-time | ordinal |
      | ORDINAL-033 | calendar-service | 2040-01-01 00:00:00 | 1 |
      | ORDINAL-034 | current-text | 2040-01-01 00:00:00 | 1 |
      | ORDINAL-035 | legacy-text | 2040-01-01 00:00:00 | 1 |
      | ORDINAL-036 | calendar-service | 2040-02-29 00:00:00 | 60 |
      | ORDINAL-037 | current-text | 2040-02-29 00:00:00 | 60 |
      | ORDINAL-038 | legacy-text | 2040-02-29 00:00:00 | 60 |
      | ORDINAL-039 | calendar-service | 2040-12-31 00:00:00 | 366 |
      | ORDINAL-040 | current-text | 2040-12-31 00:00:00 | 366 |
      | ORDINAL-041 | legacy-text | 2040-12-31 00:00:00 | 366 |

  Scenario Outline: Select a weekday occurrence for <case>
    When I request occurrence <occurrence> of "<weekday>" in "<scope>"
    Then the selected civil date is "<result>"
    And "absent" means no matching civil date was returned

    Examples:
      | case | occurrence | weekday | scope | result |
      | NTH-WEEKDAY-1 | 1 | Tuesday | 2040-04 | 2040-04-03 |
      | NTH-WEEKDAY-2 | -1 | Tuesday | 2040-04 | 2040-04-24 |
      | NTH-WEEKDAY-3 | 5 | Tuesday | 2040-04 | absent |
      | NTH-WEEKDAY-4 | 5 | Sunday | 2040-02 | absent |
      | NTH-WEEKDAY-6 | 54 | Tuesday | 2040-None | absent |
      | NTH-WEEKDAY-7 | -53 | Tuesday | 2040-None | absent |

  @ORDINAL-FRACTIONAL
  Scenario: Include a noon clock in an ordinal-day query
    When I request the ordinal day of "2040-02-29 12:00:00" through the calendar service
    Then the result is 60.5

  Scenario Outline: Recover date fields from an ordinal for <case>
    Given ordinal-conversion profile "<profile>"
    When I request civil fields for year 2040 and ordinal day <ordinal>
    Then the civil date is "<date>"
    And the returned clock is "<clock>"
    And "absent" means the result contains date fields only

    Examples:
      | case | profile | ordinal | date | clock |
      | ORDINAL-INVERSE-1-BASE | calendar-service | 1 | 2040-01-01 | absent |
      | ORDINAL-INVERSE-1-DM6 | current-text | 1 | 2040-01-01 | 00:00:00 |
      | ORDINAL-INVERSE-1-DM5 | legacy-text | 1 | 2040-01-01 | 00:00:00 |
      | ORDINAL-INVERSE-60-BASE | calendar-service | 60 | 2040-02-29 | absent |
      | ORDINAL-INVERSE-60-DM6 | current-text | 60 | 2040-02-29 | 00:00:00 |
      | ORDINAL-INVERSE-60-DM5 | legacy-text | 60 | 2040-02-29 | 00:00:00 |
      | ORDINAL-INVERSE-60.5-BASE | calendar-service | 60.5 | 2040-02-29 | 12:00:00 |
      | ORDINAL-INVERSE-60.5-DM6 | current-text | 60.5 | 2040-02-29 | 12:00:00 |
      | ORDINAL-INVERSE-60.5-DM5 | legacy-text | 60.5 | 2040-02-29 | 12:00:00 |
      | ORDINAL-INVERSE-366-BASE | calendar-service | 366 | 2040-12-31 | absent |
      | ORDINAL-INVERSE-366-DM6 | current-text | 366 | 2040-12-31 | 00:00:00 |
      | ORDINAL-INVERSE-366-DM5 | legacy-text | 366 | 2040-12-31 | 00:00:00 |

  Scenario Outline: Find the first day of a week-year for <case>
    When I request the start of week-year <year> through the calendar service
    Then the civil date is "<date>"

    Examples:
      | case | year | date |
      | WEEK-YEAR-START-2039 | 2039 | 2039-01-03 |
      | WEEK-YEAR-START-2040 | 2040 | 2040-01-02 |
      | WEEK-YEAR-START-2041 | 2041 | 2040-12-31 |
      | WEEK-YEAR-START-2042 | 2042 | 2041-12-30 |

  Scenario Outline: Count complete weeks belonging to a week-year for <case>
    When I request the number of weeks in week-year <year> through the calendar service
    Then the count is 52

    Examples:
      | case | year |
      | WEEK-YEAR-LENGTH-2039 | 2039 |
      | WEEK-YEAR-LENGTH-2040 | 2040 |
      | WEEK-YEAR-LENGTH-2041 | 2041 |
      | WEEK-YEAR-LENGTH-2042 | 2042 |

  @NTH-WEEKDAY-5 @compatibility @semantic-review-pending
  Scenario: A zero weekday occurrence selects the first occurrence in the reference profile
    When I request occurrence 0 of "Tuesday" in "2040-04"
    Then the selected civil date is "2040-04-03"
