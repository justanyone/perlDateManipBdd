@draft @configuration-files @reference-dm700
Feature: Load configuration files through public configuration requests
  File bodies below are original UTF-8 text represented as JSON strings so
  spaces and line endings are unambiguous. Civil date-times use the portable
  readable representation. Native return and diagnostic channels are mapped
  separately in the research binding record.

  Background:
    Given a fresh English context with local zone "Etc/UTC"
    And numeric date order starts as "US" with omitted clock fields at midnight
    And the fixed reference date-time is "2040-02-28 10:20:30 Etc/UTC"
    And configuration files are resolved from an isolated working directory

  Scenario Outline: An empty file leaves the date order unchanged for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      ""
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-EMPTY-OO | object | requested | US |
      | CF-EMPTY-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: Blank lines and whole-line comments are ignored for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "\n  # Original fixture comment\n\t\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-COMMENTS-OO | object | requested | US |
      | CF-COMMENTS-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: A file changes numeric date order for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "DateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-ORDER-OO | object | requested | non-US |
      | CF-ORDER-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: Names and surrounding whitespace accept mixed case and CRLF for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "  dAtEfOrMaT  =  non-US \r\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-SPACE-CASE-OO | object | requested | non-US |
      | CF-SPACE-CASE-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: The last assignment in a file wins for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "DateFormat=non-US\nDateFormat=US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-LAST-WINS-OO | object | requested | US |
      | CF-LAST-WINS-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: A later direct setting overrides the file for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "DateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
      | DateFormat | US |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-CALL-OVERRIDE-OO | object | requested | US |
      | CF-CALL-OVERRIDE-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: A later file overrides a direct setting for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "DateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | DateFormat | US |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-FILE-OVERRIDE-OO | object | requested | non-US |
      | CF-FILE-OVERRIDE-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: An included file takes effect immediately for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "DateFormat=US\nConfigFile=child.cnf\n"
      """
    And file "child.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "DateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-NESTED-OO | object | requested | non-US |
      | CF-NESTED-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: The including file resumes after an included file for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "DateFormat=US\nConfigFile=child.cnf\nDateFormat=US\n"
      """
    And file "child.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "DateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-NESTED-RESUME-OO | object | requested | US |
      | CF-NESTED-RESUME-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: Later files override earlier files for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "DateFormat=non-US\n"
      """
    And file "child.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "DateFormat=US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
      | ConfigFile | child.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-TWO-FILES-OO | object | requested | US |
      | CF-TWO-FILES-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: A missing file warns and leaves parsing available for <case>
    Given the "<profile>" public configuration profile
    And file "missing.cnf" does not exist
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | missing.cnf |
    Then configuration returns without an exception
    And one missing configuration file warning is reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-MISSING-OO | object | requested | US |
      | CF-MISSING-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: An empty file path leaves settings unchanged for <case>
    Given the "<profile>" public configuration profile
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | [empty text] |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-04-05 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-EMPTY-PATH-OO | object | requested | US |
      | CF-EMPTY-PATH-DM6 | functional-current | not requested | not applicable |

  @observed-compatibility @disputed
  Scenario Outline: An invalid line stops loading after earlier settings took effect for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "DateFormat=non-US\nnot an assignment\nDateFormat=US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration raises an invalid-configuration-line error for "not an assignment"
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-MALFORMED-OO | object | requested | non-US |
      | CF-MALFORMED-DM6 | functional-current | not requested | not applicable |

  @observed-compatibility @disputed
  Scenario Outline: Trailing hash text is retained as part of a setting value for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "DateFormat=non-US # fixture comment\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-INLINE-COMMENT-OO | object | requested | non-US # fixture comment |
      | CF-INLINE-COMMENT-DM6 | functional-current | not requested | not applicable |

  @observed-compatibility @disputed
  Scenario Outline: Quotation marks are retained in a setting value for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "DateFormat=\"non-US\"\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-QUOTED-VALUE-OO | object | requested | "non-US" |
      | CF-QUOTED-VALUE-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: An unknown setting warns while later settings are read for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "NotASetting=example\nDateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And one unknown configuration variable warning is reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-UNKNOWN-KEY-OO | object | requested | non-US |
      | CF-UNKNOWN-KEY-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: An unknown section warns and a later configuration section is read for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "*FixtureNotes\nNote=original text\n*Conf\nDateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And one unknown configuration section warning is reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-UNKNOWN-SECTION-OO | object | requested | non-US |
      | CF-UNKNOWN-SECTION-DM6 | functional-current | not requested | not applicable |

  Scenario Outline: Configuration section names accept mixed case for <case>
    Given the "<profile>" public configuration profile
    And file "main.cnf" contains the UTF-8 text decoded from this JSON string:
      """json
      "*cOnF\nDateFormat=non-US\n"
      """
    When I apply these settings in the stated order:
      | setting | value |
      | ConfigFile | main.cnf |
    Then configuration returns without an exception
    And no configuration warnings are reported
    And the date-order query is <query> with expected text <setting>
    When I parse "04/05/2040" after that configuration attempt
    Then the parsed civil date-time is "2040-05-04 00:00:00"
    And no later warnings or standard output are reported

    Examples:
      | case | profile | query | setting |
      | CF-SECTION-CASE-OO | object | requested | non-US |
      | CF-SECTION-CASE-DM6 | functional-current | not requested | not applicable |

