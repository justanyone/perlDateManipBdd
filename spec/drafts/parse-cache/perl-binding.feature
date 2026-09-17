@draft @reference-dm700 @parse-cache @source-binding @perl-binding @excluded-from-portable-handoff
Feature: Preserve Perl diagnostics for converted reads after a failed complete parse
  These scenarios retain native calling-context and diagnostic observations that
  support the generic public outcomes. They are not requirements for another language.

  Background:
    Given the pinned Date-Manip 7.00 Perl binding with tzdata "tzdata2026c"
    And the English ASCII US-order reference profile with default time midnight
    And the fixed clock and local zone "2040-02-28 10:20:30 Etc/UTC"
    And a fresh receiver parsed as "2039-12-31 07:08:09 America/New_York"

  @PC-BIND-EXCEPTIONS @observed-compatibility @disputed
  Scenario: Perl raises the captured array-reference exception for a converted scalar read
    Given complete parsing of "2040-02-30 16:05:09 America/New_York" returned numeric 1
    And its error "[parse] Invalid date" was cleared
    When each native value request is evaluated in scalar context
    Then the caught call is interrupted with no returned value and empty error before and after
    And its exception begins "Can't use an undefined value as an ARRAY reference"
    And a later successful complete parse and converted scalar read both succeed
    And the exact binding outcomes are:
      | binding case | source case | native value request | exception prefix | recovery result |
      | PC-BIND-EXCEPTION-LOCAL | PC-PARSE-FAIL-LOCAL-OBSERVER | value("local") in scalar context | Can't use an undefined value as an ARRAY reference | 2040030214:10:11 |
      | PC-BIND-EXCEPTION-GMT | PC-PARSE-FAIL-GMT-OBSERVER | value("gmt") in scalar context | Can't use an undefined value as an ARRAY reference | 2040030214:10:11 |

  @PC-BIND-WARNINGS @observed-compatibility @disputed
  Scenario: Perl emits the captured warning sequence before each array-reference exception
    When each mapped native value request is evaluated after the failed parse error is cleared
    Then exactly eight warnings are emitted in the stated order
    And the exact warning outcomes are:
      | binding case | source case | warning count | ordered warning prefixes |
      | PC-BIND-WARNINGS-LOCAL | PC-PARSE-FAIL-LOCAL-OBSERVER | 8 | Use of uninitialized value $year in numeric lt (<); Use of uninitialized value $year in numeric gt (>); Use of uninitialized value $beg in string comparison (cmp); Use of uninitialized value $end in string comparison (cmp); Use of uninitialized value $year in addition (+); Use of uninitialized value $y in integer multiplication (*); Use of uninitialized value $m in integer multiplication (*); Use of uninitialized value $d in integer multiplication (*) |
      | PC-BIND-WARNINGS-GMT | PC-PARSE-FAIL-GMT-OBSERVER | 8 | Use of uninitialized value $year in numeric lt (<); Use of uninitialized value $year in numeric gt (>); Use of uninitialized value $beg in string comparison (cmp); Use of uninitialized value $end in string comparison (cmp); Use of uninitialized value $year in addition (+); Use of uninitialized value $y in integer multiplication (*); Use of uninitialized value $m in integer multiplication (*); Use of uninitialized value $d in integer multiplication (*) |
    And the other 28 mapped source sequences emit zero warnings
