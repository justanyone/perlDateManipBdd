@draft @pattern-parsing @reference-dm700
Feature: Parse date and time text with an explicit pattern
  These cases use Date-Manip 7.00 as the reference and the explicit-pattern syntax
  identified as DATE.PATTERN.DIRECTIVES. A pattern is a regular expression in which
  percent directives recognize date or time fields. In the tables, {TAB} denotes
  one tab character and {LF} denotes one line-feed character.

  Background:
    Given the explicit-pattern profile uses English names and ASCII text
    And its local zone is "Etc/UTC"
    And its numeric date order is "US month/day/year"
    And its fixed current date-time is "2040-02-28 10:20:30 Etc/UTC"
    And omitted clock fields default to midnight
    And weeks start on Monday and the week containing January 4 is week one

  @PTN-DIRECTIVE-SUCCESS
  Scenario Outline: Parse one accepted directive through both public routes for <case>
    When I parse text "<text>" with explicit pattern "<pattern>"
    Then the object request succeeds
    And the object result is local date-time "<result>"
    And the functional request returns local date-time "<result>"

    Examples:
      | case   | directive | pattern                  | text                              | result                  |
      | PTN-01 | %Y        | %Y-%m-%d %H:%M           | 2040-02-29 16:05                  | 2040-02-29 16:05:00 UTC |
      | PTN-02 | %y        | %y-%m-%d %H:%M           | 40-02-29 16:05                    | 2040-02-29 16:05:00 UTC |
      | PTN-03 | %m        | %Y-%m-%d %H:%M           | 2040-02-29 16:05                  | 2040-02-29 16:05:00 UTC |
      | PTN-04 | %f        | %Y-%f-%d %H:%M           | 2040- 2-29 16:05                  | 2040-02-29 16:05:00 UTC |
      | PTN-05 | %b        | %Y-%b-%d %H:%M           | 2040-Feb-29 16:05                 | 2040-02-29 16:05:00 UTC |
      | PTN-06 | %h        | %Y-%h-%d %H:%M           | 2040-Feb-29 16:05                 | 2040-02-29 16:05:00 UTC |
      | PTN-07 | %B        | %Y-%B-%d %H:%M           | 2040-February-29 16:05            | 2040-02-29 16:05:00 UTC |
      | PTN-08 | %j        | %Y-%j %H:%M              | 2040-060 16:05                    | 2040-02-29 16:05:00 UTC |
      | PTN-09 | %d        | %Y-%m-%d %H:%M           | 2040-02-29 16:05                  | 2040-02-29 16:05:00 UTC |
      | PTN-10 | %e        | %Y-%m-%e %H:%M           | 2040-02-29 16:05                  | 2040-02-29 16:05:00 UTC |
      | PTN-11 | %v        | %Y-%m-%d %v %H:%M        | 2040-02-29 W 16:05                | 2040-02-29 16:05:00 UTC |
      | PTN-12 | %a        | %Y-%m-%d %a %H:%M        | 2040-02-29 Wed 16:05              | 2040-02-29 16:05:00 UTC |
      | PTN-13 | %A        | %Y-%m-%d %A %H:%M        | 2040-02-29 Wednesday 16:05        | 2040-02-29 16:05:00 UTC |
      | PTN-14 | %w        | %Y-%m-%d %w %H:%M        | 2040-02-29 3 16:05                | 2040-02-29 16:05:00 UTC |
      | PTN-15 | %E        | %Y-%m-%E %H:%M           | 2040-02-29th 16:05                | 2040-02-29 16:05:00 UTC |
      | PTN-16 | %H        | %Y-%m-%d %H:%M           | 2040-02-29 16:05                  | 2040-02-29 16:05:00 UTC |
      | PTN-17 | %k        | %Y-%m-%d %k:%M           | 2040-02-29 16:05                  | 2040-02-29 16:05:00 UTC |
      | PTN-18 | %i        | %Y-%m-%d %i:%M %p        | 2040-02-29  4:05 PM               | 2040-02-29 16:05:00 UTC |
      | PTN-19 | %I        | %Y-%m-%d %I:%M %p        | 2040-02-29 04:05 PM               | 2040-02-29 16:05:00 UTC |
      | PTN-20 | %p        | %Y-%m-%d %I:%M %p        | 2040-02-29 04:05 PM               | 2040-02-29 16:05:00 UTC |
      | PTN-21 | %M        | %Y-%m-%d %H:%M           | 2040-02-29 16:05                  | 2040-02-29 16:05:00 UTC |
      | PTN-22 | %S        | %Y-%m-%d %H:%M:%S        | 2040-02-29 16:05:09               | 2040-02-29 16:05:09 UTC |
      | PTN-23 | %Z        | %Y-%m-%d %H:%M %Z        | 2040-02-29 16:05 UTC              | 2040-02-29 16:05:00 UTC |
      | PTN-24 | %z        | %Y-%m-%d %H:%M %z        | 2040-02-29 16:05 +0000            | 2040-02-29 16:05:00 UTC |
      | PTN-25 | %N        | %Y-%m-%d %H:%M %N        | 2040-02-29 16:05 +00:00:00        | 2040-02-29 16:05:00 UTC |
      | PTN-26 | %s        | %s                       | 2214144309                        | 2040-02-29 16:05:09 UTC |
      | PTN-27 | %o        | %o                       | 2214144309                        | 2040-02-29 16:05:09 UTC |
      | PTN-28 | %G        | %G-W%W-%w                | 2040-W09-1                        | 2040-02-27 00:00:00 UTC |
      | PTN-29 | %W        | %G-W%W-%w                | 2040-W09-1                        | 2040-02-27 00:00:00 UTC |
      | PTN-32 | %c        | %c                       | Wed Feb 29 16:05:09 2040          | 2040-02-29 16:05:09 UTC |
      | PTN-33 | %C        | %C                       | Wed Feb 29 16:05:09 UTC 2040      | 2040-02-29 16:05:09 UTC |
      | PTN-34 | %u        | %u                       | Wed Feb 29 16:05:09 UTC 2040      | 2040-02-29 16:05:09 UTC |
      | PTN-35 | %g        | %g                       | Wed, 29 Feb 2040 16:05:09 UTC     | 2040-02-29 16:05:09 UTC |
      | PTN-36 | %D        | %D                       | 02/29/40                          | 2040-02-29 00:00:00 UTC |
      | PTN-37 | %x        | %x                       | 02/29/40                          | 2040-02-29 00:00:00 UTC |
      | PTN-38 | %r        | %r                       | 04:05:09 PM                       | 2040-02-28 16:05:09 UTC |
      | PTN-39 | %R        | %R                       | 16:05                             | 2040-02-28 16:05:00 UTC |
      | PTN-40 | %T        | %T                       | 16:05:09                          | 2040-02-28 16:05:09 UTC |
      | PTN-41 | %X        | %X                       | 16:05:09                          | 2040-02-28 16:05:09 UTC |
      | PTN-42 | %V        | %V                       | 0229160540                        | 2040-02-29 16:05:00 UTC |
      | PTN-43 | %Q        | %Q                       | 20400229                          | 2040-02-29 00:00:00 UTC |
      | PTN-44 | %q        | %q                       | 20400229160509                    | 2040-02-29 16:05:09 UTC |
      | PTN-45 | %P        | %P                       | 2040022916:05:09                  | 2040-02-29 16:05:09 UTC |
      | PTN-46 | %O        | %O                       | 2040-02-29T16:05:09               | 2040-02-29 16:05:09 UTC |
      | PTN-47 | %F        | %F                       | Wednesday, February 29, 2040      | 2040-02-29 00:00:00 UTC |
      | PTN-48 | %K        | %K                       | 2040-060                          | 2040-02-29 00:00:00 UTC |
      | PTN-49 | %J        | %J                       | 2040-W09-1                        | 2040-02-27 00:00:00 UTC |
      | PTN-50 | %t        | %Y%t%m%t%d %H:%M        | 2040{TAB}02{TAB}29 16:05        | 2040-02-29 16:05:00 UTC |
      | PTN-51 | %%        | %Y%%%m%%%d %H:%M        | 2040%02%29 16:05                  | 2040-02-29 16:05:00 UTC |
      | PTN-52 | %+        | %Y%+%m%+%d %H:%M        | 2040+02+29 16:05                  | 2040-02-29 16:05:00 UTC |

  @PTN-30 @PTN-31 @observed-compatibility @disputed
  Scenario Outline: Keep the rejected Sunday-week composition visible for <case>
    When I parse text "2040-09-1" with explicit pattern "%L-%U-%w"
    Then the object status is the no-result status 1
    And the object error is "[parse_format] Day of week invalid"
    And no object date-time is read after the failed request
    And the functional result is empty text

    Examples:
      | case   | directive |
      | PTN-30 | %L        |
      | PTN-31 | %U        |

  @PTN-53 @PTN-54 @captures @reference-binding
  Scenario Outline: Return the complete reference named-capture record for <case>
    When I parse text "id=2040-02-29" in list-result form with explicit pattern "<pattern>"
    Then the object request succeeds with local date-time "2040-02-29 00:00:00 UTC"
    And the complete named-capture record is <captures>
    And the functional request returns local date-time "2040-02-29 00:00:00 UTC"

    Examples:
      | case   | pattern                    | captures                                      |
      | PTN-53 | (?<Label>id=)%Y-%m-%d      | {Label: "id=", d: "29", m: "02", y: "2040"} |
      | PTN-54 | (id=)%Y-%m-%d              | {d: "29", m: "02", y: "2040"}               |

  @PTN-PATTERN-FAILURES
  Scenario Outline: Distinguish rejected patterns from a valid pattern that does not match for <case>
    When I parse text "<text>" with explicit pattern "<pattern>"
    Then the object outcome is "<object-outcome>"
    And no object date-time is read after the failed request
    And the functional result is empty text

    Examples:
      | case   | pattern       | text                 | object-outcome                                      |
      | PTN-55 | %Y-%m-%d %l:%M | 2040-02-29 4:05     | pattern error "Time not fully specified"           |
      | PTN-56 | %Y-%n%m-%d    | 2040-{LF}02-29      | valid pattern with no match, status 1               |
      | PTN-57 | %Y-%y-%m-%d   | 2040-40-02-29       | pattern error "Year specified multiple times"      |
      | PTN-58 | %Y-%m         | 2040-02             | pattern error "Date not fully specified"           |
      | PTN-60 | %Y-%m-%d      | 2040/02/29          | valid pattern with no match, status 1               |
      | PTN-63 | %<A=3>        | Wednesday           | valid pattern with no match, status 1               |

  @PTN-59 @invalid-regex @observed-compatibility @disputed
  Scenario: An invalid regular expression raises before either route can return a status
    When I parse text "2040-02-29" with explicit pattern "(%Y-%m-%d"
    Then the object request raises an unmatched-opening-group regular expression error
    And no object status is returned and no object date-time is read
    And the functional request raises the same class of regular expression error
    And the functional request does not return a value

  @PTN-61 @cache @observed-compatibility @disputed
  Scenario: Preserve the observed DateFormat change after the percent-x pattern is used
    Given explicit pattern "%x" has parsed "02/29/40" as local date-time "2040-02-29 00:00:00 UTC"
    When I change numeric date order to "non-US day/month/year"
    And I parse "02/29/40" again with the same explicit pattern "%x"
    Then the object status is the no-result status 1
    And the object error is "[parse_format] Invalid date"
    And no object date-time is read after the failed request
    And the functional result is empty text

  @PTN-62 @posix-setting
  Scenario: The POSIX rendering setting does not change percent-x pattern parsing
    Given I enable the POSIX rendering setting
    When I parse text "02/29/40" with explicit pattern "%x"
    Then the object request succeeds with local date-time "2040-02-29 00:00:00 UTC"
    And the functional request returns local date-time "2040-02-29 00:00:00 UTC"

  @PTN-64 @PTN-65 @observed-compatibility @disputed
  Scenario Outline: Preserve numeric-prefix acceptance for malformed epoch text in <case>
    When I parse text "221?" with explicit pattern "<pattern>"
    Then the object request succeeds with local date-time "1970-01-01 00:03:41 UTC"
    And the functional request returns local date-time "1970-01-01 00:03:41 UTC"

    Examples:
      | case   | pattern |
      | PTN-64 | %s      |
      | PTN-65 | %o      |
