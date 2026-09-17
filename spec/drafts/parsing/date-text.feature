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

  Scenario Outline: Interpret date text for <case>
    Given date-parsing profile "<profile>"
    And the month-year interpretation setting is "<month-year mode>"
    When I interpret the complete text "<text>" as a date
    Then parsing succeeds with local date-time "<expected date-time>" in "Etc/UTC"

    Examples:
      | case | profile | month-year mode | text | expected date-time |
      | PARSE-ISO-DATE-COMPLETE-01-DEFAULT-OO | current-value | default | 20400229 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-01-DEFAULT-DM6 | current-text | default | 20400229 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-01-DEFAULT-DM5 | legacy-text | default | 20400229 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-02-DEFAULT-OO | current-value | default | 2040-02-29 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-02-DEFAULT-DM6 | current-text | default | 2040-02-29 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-02-DEFAULT-DM5 | legacy-text | default | 2040-02-29 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-03-DEFAULT-OO | current-value | default | 400229 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-03-DEFAULT-DM6 | current-text | default | 400229 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-04-DEFAULT-OO | current-value | default | 40-02-29 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-04-DEFAULT-DM6 | current-text | default | 40-02-29 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-04-DEFAULT-DM5 | legacy-text | default | 40-02-29 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-05-DEFAULT-OO | current-value | default | -400229 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-05-DEFAULT-DM6 | current-text | default | -400229 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-06-DEFAULT-OO | current-value | default | -40-02-29 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-06-DEFAULT-DM6 | current-text | default | -40-02-29 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-07-DEFAULT-OO | current-value | default | --0229 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-07-DEFAULT-DM6 | current-text | default | --0229 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-08-DEFAULT-OO | current-value | default | --02-29 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-08-DEFAULT-DM6 | current-text | default | --02-29 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-09-DEFAULT-OO | current-value | default | ---29 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-09-DEFAULT-DM6 | current-text | default | ---29 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-10-DEFAULT-OO | current-value | default | 2040060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-10-DEFAULT-DM6 | current-text | default | 2040060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-10-DEFAULT-DM5 | legacy-text | default | 2040060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-11-DEFAULT-OO | current-value | default | 2040-060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-11-DEFAULT-DM6 | current-text | default | 2040-060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-11-DEFAULT-DM5 | legacy-text | default | 2040-060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-12-DEFAULT-OO | current-value | default | 40060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-12-DEFAULT-DM6 | current-text | default | 40060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-12-DEFAULT-DM5 | legacy-text | default | 40060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-13-DEFAULT-OO | current-value | default | 40-060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-13-DEFAULT-DM6 | current-text | default | 40-060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-13-DEFAULT-DM5 | legacy-text | default | 40-060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-14-DEFAULT-OO | current-value | default | -40060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-14-DEFAULT-DM6 | current-text | default | -40060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-15-DEFAULT-OO | current-value | default | -40-060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-15-DEFAULT-DM6 | current-text | default | -40-060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-16-DEFAULT-OO | current-value | default | -060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-16-DEFAULT-DM6 | current-text | default | -060 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-17-DEFAULT-OO | current-value | default | 2040W093 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-17-DEFAULT-DM6 | current-text | default | 2040W093 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-17-DEFAULT-DM5 | legacy-text | default | 2040W093 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-18-DEFAULT-OO | current-value | default | 2040-W09-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-18-DEFAULT-DM6 | current-text | default | 2040-W09-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-18-DEFAULT-DM5 | legacy-text | default | 2040-W09-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-19-DEFAULT-OO | current-value | default | 40W093 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-19-DEFAULT-DM6 | current-text | default | 40W093 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-19-DEFAULT-DM5 | legacy-text | default | 40W093 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-20-DEFAULT-OO | current-value | default | 40-W09-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-20-DEFAULT-DM6 | current-text | default | 40-W09-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-20-DEFAULT-DM5 | legacy-text | default | 40-W09-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-21-DEFAULT-OO | current-value | default | -40W093 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-21-DEFAULT-DM6 | current-text | default | -40W093 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-22-DEFAULT-OO | current-value | default | -40-W09-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-22-DEFAULT-DM6 | current-text | default | -40-W09-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-23-DEFAULT-OO | current-value | default | -0W093 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-23-DEFAULT-DM6 | current-text | default | -0W093 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-24-DEFAULT-OO | current-value | default | -0-W09-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-24-DEFAULT-DM6 | current-text | default | -0-W09-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-25-DEFAULT-OO | current-value | default | -W093 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-25-DEFAULT-DM6 | current-text | default | -W093 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-26-DEFAULT-OO | current-value | default | -W09-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-26-DEFAULT-DM6 | current-text | default | -W09-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-27-DEFAULT-OO | current-value | default | -W-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-27-DEFAULT-DM6 | current-text | default | -W-3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-28-DEFAULT-OO | current-value | default | ---3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-COMPLETE-28-DEFAULT-DM6 | current-text | default | ---3 | 2040-02-29 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-01-DEFAULT-OO | current-value | default | 2040-02 | 2040-02-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-01-DEFAULT-DM6 | current-text | default | 2040-02 | 2040-02-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-01-DEFAULT-DM5 | legacy-text | default | 2040-02 | 2040-02-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-02-DEFAULT-OO | current-value | default | 2040 | 2040-01-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-02-DEFAULT-DM6 | current-text | default | 2040 | 2040-01-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-02-DEFAULT-DM5 | legacy-text | default | 2040 | 2040-01-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-03-DEFAULT-OO | current-value | default | 20 | 2000-01-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-03-DEFAULT-DM6 | current-text | default | 20 | 2000-01-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-03-DEFAULT-DM5 | legacy-text | default | 20 | 2020-01-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-04-DEFAULT-OO | current-value | default | -4002 | 2040-02-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-04-DEFAULT-DM6 | current-text | default | -4002 | 2040-02-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-05-DEFAULT-OO | current-value | default | -40-02 | 2040-02-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-05-DEFAULT-DM6 | current-text | default | -40-02 | 2040-02-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-06-DEFAULT-OO | current-value | default | -40 | 2040-01-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-06-DEFAULT-DM6 | current-text | default | -40 | 2040-01-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-07-DEFAULT-OO | current-value | default | --02 | 2040-02-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-07-DEFAULT-DM6 | current-text | default | --02 | 2040-02-01 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-08-DEFAULT-OO | current-value | default | 2040W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-08-DEFAULT-DM6 | current-text | default | 2040W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-08-DEFAULT-DM5 | legacy-text | default | 2040W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-09-DEFAULT-OO | current-value | default | 2040-W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-09-DEFAULT-DM6 | current-text | default | 2040-W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-09-DEFAULT-DM5 | legacy-text | default | 2040-W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-10-DEFAULT-OO | current-value | default | 40W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-10-DEFAULT-DM6 | current-text | default | 40W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-10-DEFAULT-DM5 | legacy-text | default | 40W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-11-DEFAULT-OO | current-value | default | 40-W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-11-DEFAULT-DM6 | current-text | default | 40-W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-11-DEFAULT-DM5 | legacy-text | default | 40-W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-12-DEFAULT-OO | current-value | default | -40W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-12-DEFAULT-DM6 | current-text | default | -40W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-13-DEFAULT-OO | current-value | default | -40-W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-13-DEFAULT-DM6 | current-text | default | -40-W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-14-DEFAULT-OO | current-value | default | -W09 | 2040-02-27 00:00:00 |
      | PARSE-ISO-DATE-TRUNCATED-14-DEFAULT-DM6 | current-text | default | -W09 | 2040-02-27 00:00:00 |
      | PARSE-COMMON-NUMERIC-01-DEFAULT-OO | current-value | default | 2/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NUMERIC-01-DEFAULT-DM6 | current-text | default | 2/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NUMERIC-01-DEFAULT-DM5 | legacy-text | default | 2/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NUMERIC-02-DEFAULT-OO | current-value | default | 2/29/40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NUMERIC-02-DEFAULT-DM6 | current-text | default | 2/29/40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NUMERIC-02-DEFAULT-DM5 | legacy-text | default | 2/29/40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NUMERIC-03-DEFAULT-OO | current-value | default | 2/29/2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NUMERIC-03-DEFAULT-DM6 | current-text | default | 2/29/2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NUMERIC-03-DEFAULT-DM5 | legacy-text | default | 2/29/2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NUMERIC-04-DEFAULT-OO | current-value | default | 2040/2/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NUMERIC-04-DEFAULT-DM6 | current-text | default | 2040/2/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NUMERIC-04-DEFAULT-DM5 | legacy-text | default | 2040/2/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NUMERIC-05-DEFAULT-OO | current-value | default | 2040:02:29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NUMERIC-05-DEFAULT-DM6 | current-text | default | 2040:02:29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-01-DEFAULT-OO | current-value | default | Feb/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-01-DEFAULT-DM6 | current-text | default | Feb/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-01-DEFAULT-DM5 | legacy-text | default | Feb/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-02-DEFAULT-OO | current-value | default | Feb/29/40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-02-DEFAULT-DM6 | current-text | default | Feb/29/40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-02-DEFAULT-DM5 | legacy-text | default | Feb/29/40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-03-DEFAULT-OO | current-value | default | Feb/29/2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-03-DEFAULT-DM6 | current-text | default | Feb/29/2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-03-DEFAULT-DM5 | legacy-text | default | Feb/29/2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-04-DEFAULT-OO | current-value | default | 29/Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-04-DEFAULT-DM6 | current-text | default | 29/Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-04-DEFAULT-DM5 | legacy-text | default | 29/Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-05-DEFAULT-OO | current-value | default | 29/Feb/40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-05-DEFAULT-DM6 | current-text | default | 29/Feb/40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-05-DEFAULT-DM5 | legacy-text | default | 29/Feb/40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-06-DEFAULT-OO | current-value | default | 29/Feb/2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-06-DEFAULT-DM6 | current-text | default | 29/Feb/2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-06-DEFAULT-DM5 | legacy-text | default | 29/Feb/2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-07-DEFAULT-OO | current-value | default | 2040/Feb/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-07-DEFAULT-DM6 | current-text | default | 2040/Feb/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-07-DEFAULT-DM5 | legacy-text | default | 2040/Feb/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-08-DEFAULT-OO | current-value | default | Feb/29 40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-08-DEFAULT-DM6 | current-text | default | Feb/29 40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-08-DEFAULT-DM5 | legacy-text | default | Feb/29 40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-09-DEFAULT-OO | current-value | default | Feb/29 2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-09-DEFAULT-DM6 | current-text | default | Feb/29 2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-09-DEFAULT-DM5 | legacy-text | default | Feb/29 2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-10-DEFAULT-OO | current-value | default | 29/Feb 40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-10-DEFAULT-DM6 | current-text | default | 29/Feb 40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-10-DEFAULT-DM5 | legacy-text | default | 29/Feb 40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-11-DEFAULT-OO | current-value | default | 29/Feb 2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-11-DEFAULT-DM6 | current-text | default | 29/Feb 2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-11-DEFAULT-DM5 | legacy-text | default | 29/Feb 2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-12-DEFAULT-OO | current-value | default | 40 Feb/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-12-DEFAULT-DM6 | current-text | default | 40 Feb/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-13-DEFAULT-OO | current-value | default | 2040 Feb/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-13-DEFAULT-DM6 | current-text | default | 2040 Feb/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-13-DEFAULT-DM5 | legacy-text | default | 2040 Feb/29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-14-DEFAULT-OO | current-value | default | 40 29/Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-14-DEFAULT-DM6 | current-text | default | 40 29/Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-15-DEFAULT-OO | current-value | default | 2040 29/Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-15-DEFAULT-DM6 | current-text | default | 2040 29/Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-SEPARATED-15-DEFAULT-DM5 | legacy-text | default | 2040 29/Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-01-DEFAULT-OO | current-value | default | Feb29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-01-DEFAULT-DM6 | current-text | default | Feb29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-01-DEFAULT-DM5 | legacy-text | default | Feb29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-02-DEFAULT-OO | current-value | default | Feb2940 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-02-DEFAULT-DM6 | current-text | default | Feb2940 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-03-DEFAULT-OO | current-value | default | Feb292040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-03-DEFAULT-DM6 | current-text | default | Feb292040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-03-DEFAULT-DM5 | legacy-text | default | Feb292040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-04-DEFAULT-OO | current-value | default | 29Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-04-DEFAULT-DM6 | current-text | default | 29Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-04-DEFAULT-DM5 | legacy-text | default | 29Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-05-DEFAULT-OO | current-value | default | 29Feb40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-05-DEFAULT-DM6 | current-text | default | 29Feb40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-05-DEFAULT-DM5 | legacy-text | default | 29Feb40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-06-DEFAULT-OO | current-value | default | 29Feb2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-06-DEFAULT-DM6 | current-text | default | 29Feb2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-06-DEFAULT-DM5 | legacy-text | default | 29Feb2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-07-DEFAULT-OO | current-value | default | 2040Feb29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-07-DEFAULT-DM6 | current-text | default | 2040Feb29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-07-DEFAULT-DM5 | legacy-text | default | 2040Feb29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-08-DEFAULT-OO | current-value | default | Feb29 40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-08-DEFAULT-DM6 | current-text | default | Feb29 40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-08-DEFAULT-DM5 | legacy-text | default | Feb29 40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-09-DEFAULT-OO | current-value | default | Feb29 2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-09-DEFAULT-DM6 | current-text | default | Feb29 2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-09-DEFAULT-DM5 | legacy-text | default | Feb29 2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-10-DEFAULT-OO | current-value | default | 29Feb 40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-10-DEFAULT-DM6 | current-text | default | 29Feb 40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-10-DEFAULT-DM5 | legacy-text | default | 29Feb 40 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-11-DEFAULT-OO | current-value | default | 29Feb 2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-11-DEFAULT-DM6 | current-text | default | 29Feb 2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-11-DEFAULT-DM5 | legacy-text | default | 29Feb 2040 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-13-DEFAULT-OO | current-value | default | 2040 Feb29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-13-DEFAULT-DM6 | current-text | default | 2040 Feb29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-13-DEFAULT-DM5 | legacy-text | default | 2040 Feb29 | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-14-DEFAULT-OO | current-value | default | 40 29Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-14-DEFAULT-DM6 | current-text | default | 40 29Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-15-DEFAULT-OO | current-value | default | 2040 29Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-15-DEFAULT-DM6 | current-text | default | 2040 29Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-NAMED-JOINED-15-DEFAULT-DM5 | legacy-text | default | 2040 29Feb | 2040-02-29 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-01-DISABLED-DM5 | legacy-text | default | Feb2040 | 2040-02-01 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-01-FIRST-OO | current-value | first | Feb2040 | 2040-02-01 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-01-FIRST-DM6 | current-text | first | Feb2040 | 2040-02-01 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-01-LAST-OO | current-value | last | Feb2040 | 2040-02-29 23:59:59 |
      | PARSE-COMMON-MONTHYEAR-01-LAST-DM6 | current-text | last | Feb2040 | 2040-02-29 23:59:59 |
      | PARSE-COMMON-MONTHYEAR-02-DISABLED-DM5 | legacy-text | default | 2040Feb | 2040-02-01 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-02-FIRST-OO | current-value | first | 2040Feb | 2040-02-01 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-02-FIRST-DM6 | current-text | first | 2040Feb | 2040-02-01 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-02-LAST-OO | current-value | last | 2040Feb | 2040-02-29 23:59:59 |
      | PARSE-COMMON-MONTHYEAR-02-LAST-DM6 | current-text | last | 2040Feb | 2040-02-29 23:59:59 |
      | PARSE-COMMON-MONTHYEAR-03-DISABLED-DM5 | legacy-text | default | Feb/2040 | 2040-02-01 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-03-FIRST-OO | current-value | first | Feb/2040 | 2040-02-01 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-03-FIRST-DM6 | current-text | first | Feb/2040 | 2040-02-01 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-03-LAST-OO | current-value | last | Feb/2040 | 2040-02-29 23:59:59 |
      | PARSE-COMMON-MONTHYEAR-03-LAST-DM6 | current-text | last | Feb/2040 | 2040-02-29 23:59:59 |
      | PARSE-COMMON-MONTHYEAR-04-DISABLED-DM5 | legacy-text | default | 2040/Feb | 2040-02-01 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-04-FIRST-OO | current-value | first | 2040/Feb | 2040-02-01 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-04-FIRST-DM6 | current-text | first | 2040/Feb | 2040-02-01 00:00:00 |
      | PARSE-COMMON-MONTHYEAR-04-LAST-OO | current-value | last | 2040/Feb | 2040-02-29 23:59:59 |
      | PARSE-COMMON-MONTHYEAR-04-LAST-DM6 | current-text | last | 2040/Feb | 2040-02-29 23:59:59 |

  Scenario Outline: Reject date text for <case>
    Given date-parsing profile "<profile>"
    And the month-year interpretation setting is "<month-year mode>"
    When I interpret the complete text "<text>" as a date
    Then parsing rejects the text and returns no date value

    Examples:
      | case | profile | month-year mode | text |
      | PARSE-ISO-DATE-COMPLETE-03-DEFAULT-DM5 | legacy-text | default | 400229 |
      | PARSE-ISO-DATE-COMPLETE-05-DEFAULT-DM5 | legacy-text | default | -400229 |
      | PARSE-ISO-DATE-COMPLETE-06-DEFAULT-DM5 | legacy-text | default | -40-02-29 |
      | PARSE-ISO-DATE-COMPLETE-07-DEFAULT-DM5 | legacy-text | default | --0229 |
      | PARSE-ISO-DATE-COMPLETE-08-DEFAULT-DM5 | legacy-text | default | --02-29 |
      | PARSE-ISO-DATE-COMPLETE-09-DEFAULT-DM5 | legacy-text | default | ---29 |
      | PARSE-ISO-DATE-COMPLETE-14-DEFAULT-DM5 | legacy-text | default | -40060 |
      | PARSE-ISO-DATE-COMPLETE-15-DEFAULT-DM5 | legacy-text | default | -40-060 |
      | PARSE-ISO-DATE-COMPLETE-16-DEFAULT-DM5 | legacy-text | default | -060 |
      | PARSE-ISO-DATE-COMPLETE-21-DEFAULT-DM5 | legacy-text | default | -40W093 |
      | PARSE-ISO-DATE-COMPLETE-22-DEFAULT-DM5 | legacy-text | default | -40-W09-3 |
      | PARSE-ISO-DATE-COMPLETE-23-DEFAULT-DM5 | legacy-text | default | -0W093 |
      | PARSE-ISO-DATE-COMPLETE-24-DEFAULT-DM5 | legacy-text | default | -0-W09-3 |
      | PARSE-ISO-DATE-COMPLETE-25-DEFAULT-DM5 | legacy-text | default | -W093 |
      | PARSE-ISO-DATE-COMPLETE-26-DEFAULT-DM5 | legacy-text | default | -W09-3 |
      | PARSE-ISO-DATE-COMPLETE-27-DEFAULT-DM5 | legacy-text | default | -W-3 |
      | PARSE-ISO-DATE-COMPLETE-28-DEFAULT-DM5 | legacy-text | default | ---3 |
      | PARSE-ISO-DATE-TRUNCATED-04-DEFAULT-DM5 | legacy-text | default | -4002 |
      | PARSE-ISO-DATE-TRUNCATED-05-DEFAULT-DM5 | legacy-text | default | -40-02 |
      | PARSE-ISO-DATE-TRUNCATED-06-DEFAULT-DM5 | legacy-text | default | -40 |
      | PARSE-ISO-DATE-TRUNCATED-07-DEFAULT-DM5 | legacy-text | default | --02 |
      | PARSE-ISO-DATE-TRUNCATED-12-DEFAULT-DM5 | legacy-text | default | -40W09 |
      | PARSE-ISO-DATE-TRUNCATED-13-DEFAULT-DM5 | legacy-text | default | -40-W09 |
      | PARSE-ISO-DATE-TRUNCATED-14-DEFAULT-DM5 | legacy-text | default | -W09 |
      | PARSE-COMMON-NUMERIC-05-DEFAULT-DM5 | legacy-text | default | 2040:02:29 |
      | PARSE-COMMON-NAMED-SEPARATED-12-DEFAULT-DM5 | legacy-text | default | 40 Feb/29 |
      | PARSE-COMMON-NAMED-SEPARATED-14-DEFAULT-DM5 | legacy-text | default | 40 29/Feb |
      | PARSE-COMMON-NAMED-JOINED-14-DEFAULT-DM5 | legacy-text | default | 40 29Feb |
      | PARSE-COMMON-MONTHYEAR-02-DISABLED-OO | current-value | default | 2040Feb |
      | PARSE-COMMON-MONTHYEAR-02-DISABLED-DM6 | current-text | default | 2040Feb |
      | PARSE-COMMON-MONTHYEAR-03-DISABLED-OO | current-value | default | Feb/2040 |
      | PARSE-COMMON-MONTHYEAR-03-DISABLED-DM6 | current-text | default | Feb/2040 |
      | PARSE-COMMON-MONTHYEAR-04-DISABLED-OO | current-value | default | 2040/Feb |
      | PARSE-COMMON-MONTHYEAR-04-DISABLED-DM6 | current-text | default | 2040/Feb |
      | PARSE-INVALID-EMPTY-OO | current-value | default |  |
      | PARSE-INVALID-EMPTY-DM6 | current-text | default |  |
      | PARSE-INVALID-EMPTY-DM5 | legacy-text | default |  |
      | PARSE-INVALID-INVALID-LEAP-OO | current-value | default | 2039-02-29 |
      | PARSE-INVALID-INVALID-LEAP-DM6 | current-text | default | 2039-02-29 |
      | PARSE-INVALID-INVALID-LEAP-DM5 | legacy-text | default | 2039-02-29 |
      | PARSE-INVALID-MONTH-ZERO-OO | current-value | default | 2040-00-17 |
      | PARSE-INVALID-MONTH-ZERO-DM6 | current-text | default | 2040-00-17 |
      | PARSE-INVALID-MONTH-ZERO-DM5 | legacy-text | default | 2040-00-17 |
      | PARSE-INVALID-MONTH-HIGH-OO | current-value | default | 2040-13-17 |
      | PARSE-INVALID-MONTH-HIGH-DM6 | current-text | default | 2040-13-17 |
      | PARSE-INVALID-MONTH-HIGH-DM5 | legacy-text | default | 2040-13-17 |
      | PARSE-INVALID-DAY-ZERO-OO | current-value | default | 2040-02-00 |
      | PARSE-INVALID-DAY-ZERO-DM6 | current-text | default | 2040-02-00 |
      | PARSE-INVALID-DAY-ZERO-DM5 | legacy-text | default | 2040-02-00 |
      | PARSE-INVALID-DAY-HIGH-OO | current-value | default | 2040-02-30 |
      | PARSE-INVALID-DAY-HIGH-DM6 | current-text | default | 2040-02-30 |
      | PARSE-INVALID-DAY-HIGH-DM5 | legacy-text | default | 2040-02-30 |
      | PARSE-INVALID-LEFTOVER-OO | current-value | default | 2040-02-29 rubbish |
      | PARSE-INVALID-LEFTOVER-DM6 | current-text | default | 2040-02-29 rubbish |
      | PARSE-INVALID-LEFTOVER-DM5 | legacy-text | default | 2040-02-29 rubbish |
      | PARSE-INVALID-MIXED-DASHES-OO | current-value | default | 2040-0229 |
      | PARSE-INVALID-MIXED-DASHES-DM6 | current-text | default | 2040-0229 |

