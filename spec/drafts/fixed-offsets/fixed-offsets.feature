@draft @fixed-offsets @public-api
Feature: Parse selected fixed UTC-offset civil times
  Every request uses a fresh English, ASCII, non-US parser context with a
  forced Etc/UTC reference clock of 2040-02-28 10:20:30. These are observed
  public object-operation results from Date-Manip 7.00. They do not specify
  any generated offset-module layout or named-zone selection policy.
  Serialized date text uses the six-field serialization YYYYMMDDHH:MM:SS.
  Parsed-zone fields retain the input civil time; the configured local zone is UTC.

  @FO-PARSE-SUPPORTED
  Scenario Outline: Preserve the supplied civil fields and expose UTC for a supported offset in <case>
    Given public example "<case>"
    When I parse the civil time "2040-02-29 12:34:56 <offset>" with the fixed-offset parser
    Then the parsed-zone text is "2040022912:34:56"
    And the UTC text is "<utc_text>"
    And formatting as local date, time, numeric offset, and zone text is "<formatted>"
    And the parse error is empty

    Examples:
      | case                 | offset      | utc_text       | formatted                            |
      | FO-SUPPORTED-ZERO    | +00:00:00  | 2040022912:34:56 | 2040-02-29 12:34:56 +0000 GMT       |
      | FO-SUPPORTED-MINUTES | +05:30:00  | 2040022907:04:56 | 2040-02-29 12:34:56 +0530 +0530     |
      | FO-SUPPORTED-45-MIN  | +05:45:00  | 2040022906:49:56 | 2040-02-29 12:34:56 +0545 +0545     |
      | FO-SUPPORTED-PLUS14  | +14:00:00  | 2040022822:34:56 | 2040-02-29 12:34:56 +1400 +14       |
      | FO-SUPPORTED-MINUS30 | -03:30:00  | 2040022916:04:56 | 2040-02-29 12:34:56 -0330 NST       |
      | FO-SUPPORTED-MINUS14 | -14:00:00  | 2040030102:34:56 | 2040-02-29 12:34:56 -1400 GMT-14    |

  @FO-PARSE-OBSERVED-REJECTION
  @FO-REJECT-SECONDS
  Scenario: Report the observed failure for a seconds offset input in FO-REJECT-SECONDS
    Given public example "FO-REJECT-SECONDS"
    When I parse the civil time "2040-02-29 12:34:56 +00:06:04" with the fixed-offset parser
    Then the parse error is "[parse] Unable to determine timezone"
    And no date value is read after the failed request
