@draft @portable @calendar @week-rules-edges @compatibility
Feature: Legacy week-number override behavior
  These literal numbers preserve current and legacy public behavior, including
  omitted, absent, and invalid overrides that still produce a numeric result.

  Background:
    Given the proleptic Gregorian civil calendar in UTC
    And the language is English with the fixed reference time 2040-02-28 10:20:30
    And weekday numbers 1 through 7 mean Monday through Sunday
    And rule janN makes week one the week containing January N
    And profile current object means the stateful current date-value interface
    And profile current functional means the current functional interface
    And profile legacy functional means the versioned legacy functional interface
    And the observable result is one legacy week number

  Scenario Outline: Observe a configured legacy week number
    Given <profile> uses rule <rule> and configured first weekday <configured first>
    When I request the <request>
    Then the observable number is <outcome>
    And its review classification is <classification>

    Examples:
      | case | profile | rule | configured first | request | outcome | classification |
      | WRE-OO-JAN4-F1-OMITTED | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday omitted | 0 | observed-compatibility |
      | WRE-OO-JAN4-F1-UNDEFINED | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday absent value | 0 | observed-compatibility |
      | WRE-OO-JAN4-F1-1 | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday 1 | 0 | documented |
      | WRE-OO-JAN4-F1-2 | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday 2 | 0 | documented |
      | WRE-OO-JAN4-F1-3 | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday 3 | 0 | documented |
      | WRE-OO-JAN4-F1-4 | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday 4 | 1 | documented |
      | WRE-OO-JAN4-F1-5 | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday 5 | 1 | documented |
      | WRE-OO-JAN4-F1-6 | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday 6 | 1 | documented |
      | WRE-OO-JAN4-F1-7 | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday 7 | 1 | documented |
      | WRE-OO-JAN4-F1-0 | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday 0 | 0 | observed-compatibility |
      | WRE-OO-JAN4-F1-8 | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday 8 | 0 | observed-compatibility |
      | WRE-OO-JAN4-F1-NEG1 | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday -1 | 0 | observed-compatibility |
      | WRE-OO-JAN4-F1-EMPTY | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday "" | 0 | observed-compatibility |
      | WRE-OO-JAN4-F1-NAME | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday "Monday" | 0 | observed-compatibility |
      | WRE-OO-JAN4-F1-FRACTION | current object | jan4 | 1 | week number for 2040-01-01 with first-weekday 1.5 | 0 | observed-compatibility |
      | WRE-OO-JAN4-F7-OMITTED | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday omitted | 1 | observed-compatibility |
      | WRE-OO-JAN4-F7-UNDEFINED | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday absent value | 1 | observed-compatibility |
      | WRE-OO-JAN4-F7-1 | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday 1 | 0 | documented |
      | WRE-OO-JAN4-F7-2 | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday 2 | 0 | documented |
      | WRE-OO-JAN4-F7-3 | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday 3 | 0 | documented |
      | WRE-OO-JAN4-F7-4 | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday 4 | 1 | documented |
      | WRE-OO-JAN4-F7-5 | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday 5 | 1 | documented |
      | WRE-OO-JAN4-F7-6 | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday 6 | 1 | documented |
      | WRE-OO-JAN4-F7-7 | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday 7 | 1 | documented |
      | WRE-OO-JAN4-F7-0 | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday 0 | 1 | observed-compatibility |
      | WRE-OO-JAN4-F7-8 | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday 8 | 1 | observed-compatibility |
      | WRE-OO-JAN4-F7-NEG1 | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday -1 | 1 | observed-compatibility |
      | WRE-OO-JAN4-F7-EMPTY | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday "" | 1 | observed-compatibility |
      | WRE-OO-JAN4-F7-NAME | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday "Monday" | 1 | observed-compatibility |
      | WRE-OO-JAN4-F7-FRACTION | current object | jan4 | 7 | week number for 2040-01-01 with first-weekday 1.5 | 1 | observed-compatibility |
      | WRE-OO-JAN1-F1-OMITTED | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday omitted | 1 | observed-compatibility |
      | WRE-OO-JAN1-F1-UNDEFINED | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday absent value | 1 | observed-compatibility |
      | WRE-OO-JAN1-F1-1 | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday 1 | 1 | documented |
      | WRE-OO-JAN1-F1-2 | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday 2 | 1 | documented |
      | WRE-OO-JAN1-F1-3 | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday 3 | 1 | documented |
      | WRE-OO-JAN1-F1-4 | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday 4 | 1 | documented |
      | WRE-OO-JAN1-F1-5 | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday 5 | 1 | documented |
      | WRE-OO-JAN1-F1-6 | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday 6 | 1 | documented |
      | WRE-OO-JAN1-F1-7 | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday 7 | 1 | documented |
      | WRE-OO-JAN1-F1-0 | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday 0 | 1 | observed-compatibility |
      | WRE-OO-JAN1-F1-8 | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday 8 | 1 | observed-compatibility |
      | WRE-OO-JAN1-F1-NEG1 | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday -1 | 1 | observed-compatibility |
      | WRE-OO-JAN1-F1-EMPTY | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday "" | 1 | observed-compatibility |
      | WRE-OO-JAN1-F1-NAME | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday "Monday" | 1 | observed-compatibility |
      | WRE-OO-JAN1-F1-FRACTION | current object | jan1 | 1 | week number for 2040-01-01 with first-weekday 1.5 | 1 | observed-compatibility |
      | WRE-OO-JAN1-F7-OMITTED | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday omitted | 1 | observed-compatibility |
      | WRE-OO-JAN1-F7-UNDEFINED | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday absent value | 1 | observed-compatibility |
      | WRE-OO-JAN1-F7-1 | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday 1 | 1 | documented |
      | WRE-OO-JAN1-F7-2 | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday 2 | 1 | documented |
      | WRE-OO-JAN1-F7-3 | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday 3 | 1 | documented |
      | WRE-OO-JAN1-F7-4 | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday 4 | 1 | documented |
      | WRE-OO-JAN1-F7-5 | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday 5 | 1 | documented |
      | WRE-OO-JAN1-F7-6 | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday 6 | 1 | documented |
      | WRE-OO-JAN1-F7-7 | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday 7 | 1 | documented |
      | WRE-OO-JAN1-F7-0 | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday 0 | 1 | observed-compatibility |
      | WRE-OO-JAN1-F7-8 | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday 8 | 1 | observed-compatibility |
      | WRE-OO-JAN1-F7-NEG1 | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday -1 | 1 | observed-compatibility |
      | WRE-OO-JAN1-F7-EMPTY | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday "" | 1 | observed-compatibility |
      | WRE-OO-JAN1-F7-NAME | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday "Monday" | 1 | observed-compatibility |
      | WRE-OO-JAN1-F7-FRACTION | current object | jan1 | 7 | week number for 2040-01-01 with first-weekday 1.5 | 1 | observed-compatibility |
      | WRE-DM6-JAN4-F1-OMITTED | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday omitted | 0 | observed-compatibility |
      | WRE-DM6-JAN4-F1-UNDEFINED | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday absent value | 0 | observed-compatibility |
      | WRE-DM6-JAN4-F1-1 | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 1 | 0 | documented |
      | WRE-DM6-JAN4-F1-2 | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 2 | 0 | documented |
      | WRE-DM6-JAN4-F1-3 | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 3 | 0 | documented |
      | WRE-DM6-JAN4-F1-4 | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 4 | 1 | documented |
      | WRE-DM6-JAN4-F1-5 | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 5 | 1 | documented |
      | WRE-DM6-JAN4-F1-6 | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 6 | 1 | documented |
      | WRE-DM6-JAN4-F1-7 | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 7 | 1 | documented |
      | WRE-DM6-JAN4-F1-0 | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 0 | 0 | observed-compatibility |
      | WRE-DM6-JAN4-F1-8 | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 8 | 0 | observed-compatibility |
      | WRE-DM6-JAN4-F1-NEG1 | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday -1 | 0 | observed-compatibility |
      | WRE-DM6-JAN4-F1-EMPTY | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday "" | 0 | observed-compatibility |
      | WRE-DM6-JAN4-F1-NAME | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday "Monday" | 0 | observed-compatibility |
      | WRE-DM6-JAN4-F1-FRACTION | current functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 1.5 | 0 | observed-compatibility |
      | WRE-DM6-JAN4-F7-OMITTED | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday omitted | 1 | observed-compatibility |
      | WRE-DM6-JAN4-F7-UNDEFINED | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday absent value | 1 | observed-compatibility |
      | WRE-DM6-JAN4-F7-1 | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 1 | 0 | documented |
      | WRE-DM6-JAN4-F7-2 | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 2 | 0 | documented |
      | WRE-DM6-JAN4-F7-3 | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 3 | 0 | documented |
      | WRE-DM6-JAN4-F7-4 | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 4 | 1 | documented |
      | WRE-DM6-JAN4-F7-5 | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 5 | 1 | documented |
      | WRE-DM6-JAN4-F7-6 | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 6 | 1 | documented |
      | WRE-DM6-JAN4-F7-7 | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 7 | 1 | documented |
      | WRE-DM6-JAN4-F7-0 | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 0 | 1 | observed-compatibility |
      | WRE-DM6-JAN4-F7-8 | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 8 | 1 | observed-compatibility |
      | WRE-DM6-JAN4-F7-NEG1 | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday -1 | 1 | observed-compatibility |
      | WRE-DM6-JAN4-F7-EMPTY | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday "" | 1 | observed-compatibility |
      | WRE-DM6-JAN4-F7-NAME | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday "Monday" | 1 | observed-compatibility |
      | WRE-DM6-JAN4-F7-FRACTION | current functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 1.5 | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F1-OMITTED | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday omitted | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F1-UNDEFINED | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday absent value | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F1-1 | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 1 | 1 | documented |
      | WRE-DM6-JAN1-F1-2 | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 2 | 1 | documented |
      | WRE-DM6-JAN1-F1-3 | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 3 | 1 | documented |
      | WRE-DM6-JAN1-F1-4 | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 4 | 1 | documented |
      | WRE-DM6-JAN1-F1-5 | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 5 | 1 | documented |
      | WRE-DM6-JAN1-F1-6 | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 6 | 1 | documented |
      | WRE-DM6-JAN1-F1-7 | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 7 | 1 | documented |
      | WRE-DM6-JAN1-F1-0 | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 0 | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F1-8 | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 8 | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F1-NEG1 | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday -1 | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F1-EMPTY | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday "" | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F1-NAME | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday "Monday" | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F1-FRACTION | current functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 1.5 | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F7-OMITTED | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday omitted | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F7-UNDEFINED | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday absent value | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F7-1 | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 1 | 1 | documented |
      | WRE-DM6-JAN1-F7-2 | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 2 | 1 | documented |
      | WRE-DM6-JAN1-F7-3 | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 3 | 1 | documented |
      | WRE-DM6-JAN1-F7-4 | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 4 | 1 | documented |
      | WRE-DM6-JAN1-F7-5 | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 5 | 1 | documented |
      | WRE-DM6-JAN1-F7-6 | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 6 | 1 | documented |
      | WRE-DM6-JAN1-F7-7 | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 7 | 1 | documented |
      | WRE-DM6-JAN1-F7-0 | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 0 | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F7-8 | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 8 | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F7-NEG1 | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday -1 | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F7-EMPTY | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday "" | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F7-NAME | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday "Monday" | 1 | observed-compatibility |
      | WRE-DM6-JAN1-F7-FRACTION | current functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 1.5 | 1 | observed-compatibility |
      | WRE-DM5-JAN4-F1-OMITTED | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday omitted | 1 | observed-compatibility |
      | WRE-DM5-JAN4-F1-UNDEFINED | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday absent value | 1 | observed-compatibility |
      | WRE-DM5-JAN4-F1-1 | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 1 | 0 | documented |
      | WRE-DM5-JAN4-F1-2 | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 2 | 0 | documented |
      | WRE-DM5-JAN4-F1-3 | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 3 | 0 | documented |
      | WRE-DM5-JAN4-F1-4 | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 4 | 1 | documented |
      | WRE-DM5-JAN4-F1-5 | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 5 | 1 | documented |
      | WRE-DM5-JAN4-F1-6 | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 6 | 1 | documented |
      | WRE-DM5-JAN4-F1-7 | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 7 | 1 | documented |
      | WRE-DM5-JAN4-F1-0 | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 0 | 1 | observed-compatibility |
      | WRE-DM5-JAN4-F1-8 | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 8 | 0 | observed-compatibility |
      | WRE-DM5-JAN4-F1-NEG1 | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday -1 | 1 | observed-compatibility |
      | WRE-DM5-JAN4-F1-EMPTY | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday "" | 1 | observed-compatibility |
      | WRE-DM5-JAN4-F1-NAME | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday "Monday" | 1 | observed-compatibility |
      | WRE-DM5-JAN4-F1-FRACTION | legacy functional | jan4 | 1 | week number for 2040-01-01 with first-weekday 1.5 | 0 | observed-compatibility |
      | WRE-DM5-JAN4-F7-OMITTED | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday omitted | 1 | observed-compatibility |
      | WRE-DM5-JAN4-F7-UNDEFINED | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday absent value | 1 | observed-compatibility |
      | WRE-DM5-JAN4-F7-1 | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 1 | 0 | documented |
      | WRE-DM5-JAN4-F7-2 | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 2 | 0 | documented |
      | WRE-DM5-JAN4-F7-3 | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 3 | 0 | documented |
      | WRE-DM5-JAN4-F7-4 | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 4 | 1 | documented |
      | WRE-DM5-JAN4-F7-5 | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 5 | 1 | documented |
      | WRE-DM5-JAN4-F7-6 | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 6 | 1 | documented |
      | WRE-DM5-JAN4-F7-7 | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 7 | 1 | documented |
      | WRE-DM5-JAN4-F7-0 | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 0 | 1 | observed-compatibility |
      | WRE-DM5-JAN4-F7-8 | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 8 | 0 | observed-compatibility |
      | WRE-DM5-JAN4-F7-NEG1 | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday -1 | 1 | observed-compatibility |
      | WRE-DM5-JAN4-F7-EMPTY | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday "" | 1 | observed-compatibility |
      | WRE-DM5-JAN4-F7-NAME | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday "Monday" | 1 | observed-compatibility |
      | WRE-DM5-JAN4-F7-FRACTION | legacy functional | jan4 | 7 | week number for 2040-01-01 with first-weekday 1.5 | 0 | observed-compatibility |
      | WRE-DM5-JAN1-F1-OMITTED | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday omitted | 2 | observed-compatibility |
      | WRE-DM5-JAN1-F1-UNDEFINED | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday absent value | 2 | observed-compatibility |
      | WRE-DM5-JAN1-F1-1 | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 1 | 1 | documented |
      | WRE-DM5-JAN1-F1-2 | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 2 | 1 | documented |
      | WRE-DM5-JAN1-F1-3 | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 3 | 1 | documented |
      | WRE-DM5-JAN1-F1-4 | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 4 | 1 | documented |
      | WRE-DM5-JAN1-F1-5 | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 5 | 1 | documented |
      | WRE-DM5-JAN1-F1-6 | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 6 | 1 | documented |
      | WRE-DM5-JAN1-F1-7 | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 7 | 1 | documented |
      | WRE-DM5-JAN1-F1-0 | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 0 | 2 | observed-compatibility |
      | WRE-DM5-JAN1-F1-8 | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 8 | 1 | observed-compatibility |
      | WRE-DM5-JAN1-F1-NEG1 | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday -1 | 2 | observed-compatibility |
      | WRE-DM5-JAN1-F1-EMPTY | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday "" | 2 | observed-compatibility |
      | WRE-DM5-JAN1-F1-NAME | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday "Monday" | 2 | observed-compatibility |
      | WRE-DM5-JAN1-F1-FRACTION | legacy functional | jan1 | 1 | week number for 2040-01-01 with first-weekday 1.5 | 1 | observed-compatibility |
      | WRE-DM5-JAN1-F7-OMITTED | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday omitted | 2 | observed-compatibility |
      | WRE-DM5-JAN1-F7-UNDEFINED | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday absent value | 2 | observed-compatibility |
      | WRE-DM5-JAN1-F7-1 | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 1 | 1 | documented |
      | WRE-DM5-JAN1-F7-2 | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 2 | 1 | documented |
      | WRE-DM5-JAN1-F7-3 | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 3 | 1 | documented |
      | WRE-DM5-JAN1-F7-4 | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 4 | 1 | documented |
      | WRE-DM5-JAN1-F7-5 | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 5 | 1 | documented |
      | WRE-DM5-JAN1-F7-6 | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 6 | 1 | documented |
      | WRE-DM5-JAN1-F7-7 | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 7 | 1 | documented |
      | WRE-DM5-JAN1-F7-0 | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 0 | 2 | observed-compatibility |
      | WRE-DM5-JAN1-F7-8 | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 8 | 1 | observed-compatibility |
      | WRE-DM5-JAN1-F7-NEG1 | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday -1 | 2 | observed-compatibility |
      | WRE-DM5-JAN1-F7-EMPTY | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday "" | 2 | observed-compatibility |
      | WRE-DM5-JAN1-F7-NAME | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday "Monday" | 2 | observed-compatibility |
      | WRE-DM5-JAN1-F7-FRACTION | legacy functional | jan1 | 7 | week number for 2040-01-01 with first-weekday 1.5 | 1 | observed-compatibility |
