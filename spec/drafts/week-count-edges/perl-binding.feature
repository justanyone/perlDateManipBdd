@source-binding @perl-binding @excluded-from-portable-handoff
Feature: Native week-count edge traces
  These rows preserve every Perl return carrier, warning sequence, and public error snapshot.
  Repeated scalar and list calls are separate because cache hits can change warning counts.

  Background:
    Given Perl loads Date-Manip 7.00 from the pinned local installation
    And each case uses a fresh Base service, process, and temporary working directory
    And the requested Base configuration is the full object profile except ForceDate

  Scenario Outline: Preserve every executed step and diagnostic channel
    Given native step <binding step> belongs to case <case>
    When Perl invokes <operation> with arguments <arguments>
    Then its scalar outcome is <scalar outcome>
    And its repeated scalar outcome is <repeated outcome>
    And its list outcome is <list outcome>
    And its scalar diagnostic is <scalar diagnostic>
    And its repeated diagnostic is <repeated diagnostic>
    And its list diagnostic is <list diagnostic>
    And public error text is <error before> before and <error after> after the step

    Examples:
      | binding step | case | operation | arguments | scalar outcome | repeated outcome | list outcome | scalar diagnostic | repeated diagnostic | list diagnostic | error before | error after |
      | WCE-YEAR1-S01 | WCE-YEAR1 | weeks_in_year | [1] | scalar 52 | scalar 52 | list [52] | none | none | none | "" | "" |
      | WCE-YEAR9999-S01 | WCE-YEAR9999 | weeks_in_year | [9999] | scalar 52 | scalar 52 | list [52] | none | none | none | "" | "" |
      | WCE-ZERO-S01 | WCE-ZERO | weeks_in_year | [0] | scalar 52 | scalar 52 | list [52] | none | none | none | "" | "" |
      | WCE-NEGATIVE-S01 | WCE-NEGATIVE | weeks_in_year | [-1] | scalar 52 | scalar 52 | list [52] | none | none | none | "" | "" |
      | WCE-HIGH-S01 | WCE-HIGH | weeks_in_year | [10000] | scalar 52 | scalar 52 | list [52] | none | none | none | "" | "" |
      | WCE-FRACTION-S01 | WCE-FRACTION | weeks_in_year | [2000.5] | scalar 52 | scalar 52 | list [52] | none | none | none | "" | "" |
      | WCE-OMITTED-S01 | WCE-OMITTED | weeks_in_year | [] | scalar 52 | scalar 52 | list [52] | warnings ["Use of uninitialized value $y in exists","Use of uninitialized value $year in exists","Use of uninitialized value $y in integer subtraction (-)","Use of uninitialized value $year in hash element","Use of uninitialized value $y in integer addition (+)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer lt (<)","Use of uninitialized value $y1 in integer lt (<)","Use of uninitialized value $y in integer addition (+)","Use of uninitialized value $y in hash element"] | warnings ["Use of uninitialized value $y in exists","Use of uninitialized value $y in hash element"] | warnings ["Use of uninitialized value $y in exists","Use of uninitialized value $y in hash element"] | "" | "" |
      | WCE-ABSENT-S01 | WCE-ABSENT | weeks_in_year | [null] | scalar 52 | scalar 52 | list [52] | warnings ["Use of uninitialized value $y in exists","Use of uninitialized value $year in exists","Use of uninitialized value $y in integer subtraction (-)","Use of uninitialized value $year in hash element","Use of uninitialized value $y in integer addition (+)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer modulus (%)","Use of uninitialized value $y in integer lt (<)","Use of uninitialized value $y1 in integer lt (<)","Use of uninitialized value $y in integer addition (+)","Use of uninitialized value $y in hash element"] | warnings ["Use of uninitialized value $y in exists","Use of uninitialized value $y in hash element"] | warnings ["Use of uninitialized value $y in exists","Use of uninitialized value $y in hash element"] | "" | "" |
      | WCE-EMPTY-S01 | WCE-EMPTY | weeks_in_year | [""] | scalar 52 | scalar 52 | list [52] | warnings ["Argument \"\" isn't numeric in integer subtraction (-)","Argument \"\" isn't numeric in integer addition (+)","Argument \"\" isn't numeric in integer lt (<)"] | none | none | "" | "" |
      | WCE-TEXT-S01 | WCE-TEXT | weeks_in_year | ["year"] | scalar 52 | scalar 52 | list [52] | warnings ["Argument \"year\" isn't numeric in integer subtraction (-)","Argument \"year\" isn't numeric in integer addition (+)","Argument \"year\" isn't numeric in integer lt (<)"] | none | none | "" | "" |
      | WCE-SHORT-S01 | WCE-SHORT | weeks_in_year | ["00"] | scalar 52 | scalar 52 | list [52] | none | none | none | "" | "" |
      | WCE-CONFIG-ABA-S01 | WCE-CONFIG-ABA | weeks_in_year | [2000] | scalar 52 | scalar 52 | list [52] | none | none | none | "" | "" |
      | WCE-CONFIG-ABA-S02 | WCE-CONFIG-ABA | config | ["Week1ofYear","jan1"] | completed with undefined scalar | not called | not called | none | not called | not called | "" | "" |
      | WCE-CONFIG-ABA-S03 | WCE-CONFIG-ABA | weeks_in_year | [2000] | scalar 53 | scalar 53 | list [53] | none | none | none | "" | "" |
      | WCE-CONFIG-ABA-S04 | WCE-CONFIG-ABA | config | ["Week1ofYear","jan4"] | completed with undefined scalar | not called | not called | none | not called | not called | "" | "" |
      | WCE-CONFIG-ABA-S05 | WCE-CONFIG-ABA | weeks_in_year | [2000] | scalar 52 | scalar 52 | list [52] | none | none | none | "" | "" |
      | WCE-BAD-FIRSTDAY-S01 | WCE-BAD-FIRSTDAY | weeks_in_year | [2000] | scalar 52 | scalar 52 | list [52] | none | none | none | "" | "" |
      | WCE-BAD-FIRSTDAY-S02 | WCE-BAD-FIRSTDAY | config | ["FirstDay",8] | completed with undefined scalar | not called | not called | warnings ["ERROR: [config_var] invalid: FirstDay: 8"] | not called | not called | "" | "" |
      | WCE-BAD-FIRSTDAY-S03 | WCE-BAD-FIRSTDAY | weeks_in_year | [2000] | scalar 52 | scalar 52 | list [52] | none | none | none | "" | "" |
      | WCE-BAD-WEEKRULE-S01 | WCE-BAD-WEEKRULE | weeks_in_year | [2000] | scalar 52 | scalar 52 | list [52] | none | none | none | "" | "" |
      | WCE-BAD-WEEKRULE-S02 | WCE-BAD-WEEKRULE | config | ["Week1ofYear","jan8"] | completed with undefined scalar | not called | not called | warnings ["ERROR: [config_var] invalid: Week1ofYear: jan8"] | not called | not called | "" | "" |
      | WCE-BAD-WEEKRULE-S03 | WCE-BAD-WEEKRULE | weeks_in_year | [2000] | scalar 52 | scalar 52 | list [52] | none | none | none | "" | "" |
