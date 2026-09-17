@draft @configuration-files @reference-dm700
Feature: Load configuration files through a functional configuration request
  File bodies below are original UTF-8 text represented as JSON strings so
  spaces and line endings are unambiguous. Civil date-times use the portable
  readable representation. Native return and diagnostic channels are mapped
  separately in the research binding record.

  Background:
    Given the "functional-current" public configuration profile
    And a fresh English context with local zone "Etc/UTC"
    And numeric date order starts as "US" with omitted clock fields at midnight
    And the fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"
    And configuration files are resolved from an isolated working directory

  Scenario: An empty file leaves the date order unchanged [CF-EMPTY-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      ""
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

  Scenario: Blank lines and whole-line comments are ignored [CF-COMMENTS-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "\n  # Original fixture comment\n\t\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

  Scenario: A file changes numeric date order [CF-ORDER-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "DateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

  Scenario: Names and surrounding whitespace accept mixed case and CRLF [CF-SPACE-CASE-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "  dAtEfOrMaT  =  non-US \r\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

  Scenario: The last assignment in a file wins [CF-LAST-WINS-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "DateFormat=non-US\nDateFormat=US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

  Scenario: A later direct setting overrides the file [CF-CALL-OVERRIDE-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "DateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
      | DateFormat | US |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

  Scenario: A later file overrides a direct setting [CF-FILE-OVERRIDE-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "DateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | DateFormat | US |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

  Scenario: An included file takes effect immediately [CF-NESTED-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "DateFormat=US\nConfigFile=child.cnf\n"
      """
    And file "child.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "DateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

  Scenario: The including file resumes after an included file [CF-NESTED-RESUME-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "DateFormat=US\nConfigFile=child.cnf\nDateFormat=US\n"
      """
    And file "child.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "DateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

  Scenario: Later files override earlier files [CF-TWO-FILES-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "DateFormat=non-US\n"
      """
    And file "child.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "DateFormat=US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
      | ConfigFile | child.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

  Scenario: A missing file warns and leaves parsing available [CF-MISSING-DM6]
    Given file "missing.cnf" does not exist
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | missing.cnf |
    Then configuration returns without an exception
    And one missing configuration file warning is reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

  Scenario: An empty file path leaves settings unchanged [CF-EMPTY-PATH-DM6]
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | [empty text] |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

  @observed-compatibility @disputed
  Scenario: An invalid line stops loading after earlier settings took effect [CF-MALFORMED-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "DateFormat=non-US\nnot an assignment\nDateFormat=US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration raises an invalid-configuration-line error for "not an assignment"
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

  @observed-compatibility @disputed
  Scenario: Trailing hash text is retained as part of a setting value [CF-INLINE-COMMENT-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "DateFormat=non-US # fixture comment\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

  @observed-compatibility @disputed
  Scenario: Quotation marks are retained in a setting value [CF-QUOTED-VALUE-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "DateFormat=\"non-US\"\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

  Scenario: An unknown setting warns while later settings are read [CF-UNKNOWN-KEY-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "NotASetting=example\nDateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And one unknown configuration variable warning is reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

  Scenario: An unknown section warns and a later configuration section is read [CF-UNKNOWN-SECTION-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "*FixtureNotes\nNote=original text\n*Conf\nDateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And one unknown configuration section warning is reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

  Scenario: Configuration section names accept mixed case [CF-SECTION-CASE-DM6]
    Given file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """
      "*cOnF\nDateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported
