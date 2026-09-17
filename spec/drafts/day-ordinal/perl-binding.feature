@source-binding @perl-binding @excluded-from-portable-handoff
Feature: Perl argument and return carriers for day ordinals
  These cases describe the Perl facade and are not requirements for another language.

  Background:
    Given the current facade uses ASCII encoding and the legacy facade uses its built-in text mode
    And its zone is "Etc/UTC" and its reference clock is "2040-02-28 10:20:30"
    And its date order is US

  Scenario Outline: Perl-specific argument shapes preserve their native result
    Given the <profile> ordinal facade is configured in English
    When Perl calls it with arguments <arguments> in separate scalar and list contexts
    Then its scalar-context result is <literal result>
    And list context contains exactly one item with the same native value
    And the scalar and list calls each produce <diagnostic>

    Examples:
      | request | profile | arguments | literal result | diagnostic |
      | DO-DM6-OMITTED | dm6 | [] | text "31st" | one uninitialized-value warning |
      | DO-DM6-UNDEFINED | dm6 | [null] | text "31st" | one uninitialized-value warning |
      | DO-DM6-NUMERIC-TEXT | dm6 | ["02"] | text "2nd" | no warning |
      | DO-DM6-EMPTY | dm6 | [""] | text "31st" | one nonnumeric-value warning |
      | DO-DM6-NONNUMERIC | dm6 | ["x"] | text "31st" | one nonnumeric-value warning |
      | DO-DM6-ARRAY | dm6 | [[1]] | an absent value | no warning |
      | DO-DM6-HASH | dm6 | [{}] | an absent value | no warning |
      | DO-DM6-EXTRA | dm6 | [1,99] | text "1st" | no warning |
      | DO-DM5-OMITTED | dm5 | [] | text "31st" | one uninitialized-value warning |
      | DO-DM5-UNDEFINED | dm5 | [null] | text "31st" | one uninitialized-value warning |
      | DO-DM5-NUMERIC-TEXT | dm5 | ["02"] | text "2nd" | no warning |
      | DO-DM5-EMPTY | dm5 | [""] | text "31st" | one nonnumeric-value warning |
      | DO-DM5-NONNUMERIC | dm5 | ["x"] | text "31st" | one nonnumeric-value warning |
      | DO-DM5-ARRAY | dm5 | [[1]] | an absent value | no warning |
      | DO-DM5-HASH | dm5 | [{}] | an absent value | no warning |
      | DO-DM5-EXTRA | dm5 | [1,99] | text "1st" | no warning |

  Scenario Outline: Native failure carriers distinguish undefined from empty text
    Given the <profile> ordinal facade is configured in English
    When binding case <binding case> requests ordinal text with arguments <arguments> in separate scalar and list contexts
    Then the scalar result is undefined
    And the list result is exactly one undefined item
    And neither call raises an exception or emits a warning
    And no documented facade error observer is available

    Examples:
      | binding case | profile | arguments |
      | DOB-DM6-OUT32 | dm6 | [32] |
      | DOB-DM6-LARGE | dm6 | [100] |
      | DOB-DM5-OUT32 | dm5 | [32] |
      | DOB-DM5-LARGE | dm5 | [100] |
