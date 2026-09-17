@observed-compatibility @value-serialization
Feature: Observed value serialization compatibility
  These behaviors are frozen separately from the ordinary portable contract.
  These cases are required when claiming the complete reference compatibility profile.

  Background:
    Given the value serialization profile uses English and ASCII text
    And its zone is "Etc/UTC" and its reference clock is "2040-02-28 10:20:30"
    And its date order is US, its default Printable mode is 0, and Monday starts the week
    And business days are Monday through Friday from "09:00" through "17:00"
    And date fields are ordered year, month, day, hour, minute, second
    And hms, offset and time fields are ordered hour, minute, second
    And delta and business fields are ordered year, month, week, day, hour, minute, second

  Scenario Outline: Deprecated and permissive requests retain their observed result
    When I <method> the <kind> value <input> with <options and configuration>
    Then the <operation> compatibility result is <literal result>

    Examples:
      | case | method | operation | kind | input | options and configuration | literal result |
      | VS-DATE-JOIN-UNCHECKED-FIELDS | join | value.join-fields | date | ordered fields [2040,13,40,25,61,"x"] | no options | text "2040134025:61:0x" |
      | VS-HMS-JOIN-SHORT | join | value.join-fields | hms | ordered fields [7] | no options | text "07:00:00" |
      | VS-TIME-SPLIT-LEGACY-NONORM | split | value.split-fields | time | text "1:120:90" | deprecated positional nonorm=true | ordered fields [1,120,90] |
      | VS-TIME-JOIN-SHORT | join | value.join-fields | time | ordered fields [90] | no options | text "0:1:30" |
      | VS-BUSINESS-SPLIT-ALIAS | split | value.split-fields | business | text "0:0:0:0:16:0:0" | no options | ordered fields [0,0,0,2,0,0,0] |
      | VS-DELTA-JOIN-SHORT | join | value.join-fields | delta | ordered fields [4,5,6,7] | no options | text "0:0:0:4:5:6:7" |
      | VS-BUSINESS-JOIN-ALIAS | join | value.join-fields | business | ordered fields [0,0,0,0,16,0,0] | no options | text "0:0:0:2:0:0:0" |

  @suspected-bug
  Scenario Outline: Documentation-sensitive requests retain their observed discrepancy
    When I <method> the <kind> value <input> with <options and configuration>
    Then the <operation> observed result is <literal result>
    But that result remains disputed rather than becoming the portable contract

    Examples:
      | case | method | operation | kind | input | options and configuration | literal result |
      | VS-DELTA-SPLIT-OMITTED-FIELDS | split | value.split-fields | delta | text "4:::7" | no options | an absent value |
      | VS-DELTA-SPLIT-BUSINESS | split | value.split-fields | delta | text "0:0:0:0:16:0:0" | options {"mode":"business"} | ordered fields [0,0,0,0,16,0,0] |
      | VS-DELTA-JOIN-BUSINESS | join | value.join-fields | delta | ordered fields [0,0,0,0,16,0,0] | options {"mode":"business"} | text "0:0:0:0:16:0:0" |
      | VS-SPLIT-INVALID-KIND | split | value.split-fields | fortnight | text "1:2:3" | no options | empty text |
      | VS-JOIN-INVALID-KIND | join | value.join-fields | fortnight | ordered fields [1,2,3] | no options | empty text |
