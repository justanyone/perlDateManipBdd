@source-binding @perl-binding @excluded-from-portable-handoff
Feature: Perl carriers and diagnostics for value serialization
  These scenarios describe public Date::Manip::Base calls in Perl.
  They are not requirements for another language.

  Background:
    Given the value serialization profile uses English and ASCII text
    And its zone is "Etc/UTC" and its reference clock is "2040-02-28 10:20:30"
    And its date order is US, its default Printable mode is 0, and Monday starts the week
    And business days are Monday through Friday from "09:00" through "17:00"
    And date fields are ordered year, month, day, hour, minute, second
    And hms, offset and time fields are ordered hour, minute, second
    And delta and business fields are ordered year, month, week, day, hour, minute, second

  Scenario Outline: Undefined and wrong Perl carriers preserve their native call outcome
    When Perl <method> receives the <kind> value <input> with <options and configuration>
    Then its scalar-context outcome is <literal result>
    And its list-context outcome has the same return or exception
    And the binding diagnostic category is <diagnostic>

    Examples:
      | case | method | kind | input | options and configuration | literal result | diagnostic |
      | VS-DATE-SPLIT-UNDEFINED | split | date | an undefined scalar | no options | an absent value | 3 uninitialized-value warnings |
      | VS-JOIN-UNDEFINED-CARRIER | join | time | an undefined scalar | no options | no return because the call raises an exception | exception: expected array-reference carrier |
      | VS-JOIN-SCALAR-CARRIER | join | time | text "1:2:3" | no options | no return because the call raises an exception | exception: expected array-reference carrier |

  Scenario Outline: Explicit scalar and list carriers for <binding case>
    Given separate freshly configured services for the two calling contexts
    When Perl <method> receives the <kind> value <input> with <options and configuration> in each context
    Then the scalar carrier is <scalar carrier> and its value is <scalar value>
    And the list-context return is <list value>
    And both immediate service errors are empty
    And each call emits <warning count> warnings and the exception category is <exception category>

    Examples:
      | binding case | method | kind | input | options and configuration | scalar carrier | scalar value | list value | warning count | exception category |
      | VSB-DATE-SPLIT-COLON | split | date | text "2040022916:05:09" | no options | ARRAY | [2040,2,29,16,5,9] | [[2040,2,29,16,5,9]] | 0 | none |
      | VSB-DATE-SPLIT-COMPACT | split | date | text "20400229160509" | no options | ARRAY | [2040,2,29,16,5,9] | [[2040,2,29,16,5,9]] | 0 | none |
      | VSB-DATE-SPLIT-PRINTABLE | split | date | text "2040-02-29-16:05:09" | no options | ARRAY | [2040,2,29,16,5,9] | [[2040,2,29,16,5,9]] | 0 | none |
      | VSB-DATE-SPLIT-BAD-SEPARATOR | split | date | text "2040/02/29 16:05:09" | no options | undefined | null | [null] | 0 | none |
      | VSB-DATE-SPLIT-TRAILING | split | date | text "2040022916:05:09Z" | no options | undefined | null | [null] | 0 | none |
      | VSB-DATE-SPLIT-EMPTY | split | date | text "" | no options | undefined | null | [null] | 0 | none |
      | VSB-DATE-SPLIT-UNDEFINED | split | date | an undefined scalar | no options | undefined | null | [null] | 3 | none |
      | VSB-DATE-JOIN-PRINTABLE0 | join | date | ordered fields [2040,2,29,16,5,9] | no options; Printable=0 | text | "2040022916:05:09" | ["2040022916:05:09"] | 0 | none |
      | VSB-DATE-JOIN-PRINTABLE1 | join | date | ordered fields [2040,2,29,16,5,9] | no options; Printable=1 | text | "20400229160509" | ["20400229160509"] | 0 | none |
      | VSB-DATE-JOIN-PRINTABLE2 | join | date | ordered fields [2040,2,29,16,5,9] | no options; Printable=2 | text | "2040-02-29-16:05:09" | ["2040-02-29-16:05:09"] | 0 | none |
      | VSB-DATE-JOIN-WRONG-ARITY | join | date | ordered fields [2040,2,29,16,5] | no options | undefined | null | [null] | 0 | none |
      | VSB-DATE-JOIN-UNCHECKED-FIELDS | join | date | ordered fields [2040,13,40,25,61,"x"] | no options | text | "2040134025:61:0x" | ["2040134025:61:0x"] | 0 | none |
      | VSB-HMS-SPLIT-HOUR | split | hms | text "7" | no options | ARRAY | [7,0,0] | [[7,0,0]] | 0 | none |
      | VSB-HMS-SPLIT-COMPACT4 | split | hms | text "0715" | no options | ARRAY | [7,15,0] | [[7,15,0]] | 0 | none |
      | VSB-HMS-SPLIT-COMPACT6 | split | hms | text "071509" | no options | ARRAY | [7,15,9] | [[7,15,9]] | 0 | none |
      | VSB-HMS-SPLIT-COLON2 | split | hms | text "7:15" | no options | ARRAY | [7,15,0] | [[7,15,0]] | 0 | none |
      | VSB-HMS-SPLIT-ENDPOINT | split | hms | text "24:00:00" | no options | ARRAY | [24,0,0] | [[24,0,0]] | 0 | none |
      | VSB-HMS-SPLIT-PAST-END | split | hms | text "24:00:01" | no options | undefined | null | [null] | 0 | none |
      | VSB-HMS-SPLIT-MINUTE60 | split | hms | text "12:60:00" | no options | undefined | null | [null] | 0 | none |
      | VSB-HMS-SPLIT-NONNUMERIC | split | hms | text "noon" | no options | undefined | null | [null] | 0 | none |
      | VSB-HMS-JOIN-ZERO | join | hms | ordered fields [0,0,0] | no options | text | "00:00:00" | ["00:00:00"] | 0 | none |
      | VSB-HMS-JOIN-SHORT | join | hms | ordered fields [7] | no options | text | "07:00:00" | ["07:00:00"] | 0 | none |
      | VSB-HMS-JOIN-ENDPOINT | join | hms | ordered fields [24,0,0] | no options | text | "24:00:00" | ["24:00:00"] | 0 | none |
      | VSB-HMS-JOIN-INVALID | join | hms | ordered fields [-1,0,0] | no options | undefined | null | [null] | 0 | none |
      | VSB-OFFSET-SPLIT-UNSIGNED | split | offset | text "5:30" | no options | ARRAY | [5,30,0] | [[5,30,0]] | 0 | none |
      | VSB-OFFSET-SPLIT-COMPACT | split | offset | text "-053045" | no options | ARRAY | [-5,-30,-45] | [[-5,-30,-45]] | 0 | none |
      | VSB-OFFSET-SPLIT-POS-END | split | offset | text "+23:59:59" | no options | ARRAY | [23,59,59] | [[23,59,59]] | 0 | none |
      | VSB-OFFSET-SPLIT-NEG-END | split | offset | text "-23:59:59" | no options | ARRAY | [-23,-59,-59] | [[-23,-59,-59]] | 0 | none |
      | VSB-OFFSET-SPLIT-OUT-OF-RANGE | split | offset | text "+24:00:00" | no options | undefined | null | [null] | 0 | none |
      | VSB-OFFSET-SPLIT-BAD-MINUTE | split | offset | text "+05:60" | no options | undefined | null | [null] | 0 | none |
      | VSB-OFFSET-JOIN-ZERO | join | offset | ordered fields [0,0,0] | no options | text | "+00:00:00" | ["+00:00:00"] | 0 | none |
      | VSB-OFFSET-JOIN-POSITIVE | join | offset | ordered fields [5,30,45] | no options | text | "+05:30:45" | ["+05:30:45"] | 0 | none |
      | VSB-OFFSET-JOIN-NEGATIVE | join | offset | ordered fields [-5,-30,-45] | no options | text | "-05:30:45" | ["-05:30:45"] | 0 | none |
      | VSB-OFFSET-JOIN-MIXED-SIGN | join | offset | ordered fields [-5,30,0] | no options | undefined | null | [null] | 0 | none |
      | VSB-OFFSET-JOIN-OUT-OF-RANGE | join | offset | ordered fields [24,0,0] | no options | undefined | null | [null] | 0 | none |
      | VSB-TIME-SPLIT-ZERO | split | time | text "0:0:0" | no options | ARRAY | [0,0,0] | [[0,0,0]] | 0 | none |
      | VSB-TIME-SPLIT-ORDINARY | split | time | text "1:02:03" | no options | ARRAY | [1,2,3] | [[1,2,3]] | 0 | none |
      | VSB-TIME-SPLIT-NEGATIVE | split | time | text "-1:-02:-03" | no options | ARRAY | [-1,-2,-3] | [[-1,-2,-3]] | 0 | none |
      | VSB-TIME-SPLIT-MIXED-SIGN | split | time | text "-1:30:00" | no options | ARRAY | [-1,-30,0] | [[-1,-30,0]] | 0 | none |
      | VSB-TIME-SPLIT-OVERFLOW | split | time | text "1:120:90" | no options | ARRAY | [3,1,30] | [[3,1,30]] | 0 | none |
      | VSB-TIME-SPLIT-OVERFLOW-NONORM | split | time | text "1:120:90" | options {"nonorm":1} | ARRAY | [1,120,90] | [[1,120,90]] | 0 | none |
      | VSB-TIME-SPLIT-LEGACY-NONORM | split | time | text "1:120:90" | deprecated positional nonorm=true | ARRAY | [1,120,90] | [[1,120,90]] | 0 | none |
      | VSB-TIME-SPLIT-NONNUMERIC | split | time | text "1:x:3" | no options | undefined | null | [null] | 0 | none |
      | VSB-TIME-JOIN-ORDINARY | join | time | ordered fields [1,2,3] | no options | text | "1:2:3" | ["1:2:3"] | 0 | none |
      | VSB-TIME-JOIN-MIXED-SIGN | join | time | ordered fields [-1,30,0] | no options | text | "0:-30:0" | ["0:-30:0"] | 0 | none |
      | VSB-TIME-JOIN-OVERFLOW | join | time | ordered fields [1,120,90] | no options | text | "3:1:30" | ["3:1:30"] | 0 | none |
      | VSB-TIME-JOIN-OVERFLOW-NONORM | join | time | ordered fields [1,120,90] | options {"nonorm":1} | text | "1:120:90" | ["1:120:90"] | 0 | none |
      | VSB-TIME-JOIN-SHORT | join | time | ordered fields [90] | no options | text | "0:1:30" | ["0:1:30"] | 0 | none |
      | VSB-TIME-JOIN-TOO-MANY | join | time | ordered fields [1,2,3,4] | no options | undefined | null | [null] | 0 | none |
      | VSB-DELTA-SPLIT-ZERO | split | delta | text "0:0:0:0:0:0:0" | no options | ARRAY | [0,0,0,0,0,0,0] | [[0,0,0,0,0,0,0]] | 0 | none |
      | VSB-DELTA-SPLIT-FULL | split | delta | text "1:2:3:4:5:6:7" | no options | ARRAY | [1,2,3,4,5,6,7] | [[1,2,3,4,5,6,7]] | 0 | none |
      | VSB-DELTA-SPLIT-SHORT | split | delta | text "4:5:6:7" | no options | ARRAY | [0,0,0,4,5,6,7] | [[0,0,0,4,5,6,7]] | 0 | none |
      | VSB-DELTA-SPLIT-OMITTED-FIELDS | split | delta | text "4:::7" | no options | undefined | null | [null] | 0 | none |
      | VSB-DELTA-SPLIT-NEGATIVE | split | delta | text "0:0:0:-1:-2:-3:-4" | no options | ARRAY | [0,0,0,-1,-2,-3,-4] | [[0,0,0,-1,-2,-3,-4]] | 0 | none |
      | VSB-DELTA-SPLIT-OVERFLOW | split | delta | text "0:0:0:0:1:120:90" | no options | ARRAY | [0,0,0,0,3,1,30] | [[0,0,0,0,3,1,30]] | 0 | none |
      | VSB-DELTA-SPLIT-OVERFLOW-NONORM | split | delta | text "0:0:0:0:1:120:90" | options {"nonorm":1} | ARRAY | [0,0,0,0,1,120,90] | [[0,0,0,0,1,120,90]] | 0 | none |
      | VSB-DELTA-SPLIT-BUSINESS | split | delta | text "0:0:0:0:16:0:0" | options {"mode":"business"} | ARRAY | [0,0,0,0,16,0,0] | [[0,0,0,0,16,0,0]] | 0 | none |
      | VSB-BUSINESS-SPLIT-ALIAS | split | business | text "0:0:0:0:16:0:0" | no options | ARRAY | [0,0,0,2,0,0,0] | [[0,0,0,2,0,0,0]] | 0 | none |
      | VSB-DELTA-SPLIT-ESTIMATED | split | delta | text "0:1:0:0:0:0:0" | options {"type":"estimated"} | ARRAY | [0,1,0,0,0,0,0] | [[0,1,0,0,0,0,0]] | 0 | none |
      | VSB-DELTA-SPLIT-NONNUMERIC | split | delta | text "0:0:0:0:x:0:0" | no options | undefined | null | [null] | 0 | none |
      | VSB-DELTA-SPLIT-TOO-MANY | split | delta | text "1:2:3:4:5:6:7:8" | no options | undefined | null | [null] | 0 | none |
      | VSB-DELTA-JOIN-FULL | join | delta | ordered fields [1,2,3,4,5,6,7] | no options | text | "1:2:3:4:5:6:7" | ["1:2:3:4:5:6:7"] | 0 | none |
      | VSB-DELTA-JOIN-SHORT | join | delta | ordered fields [4,5,6,7] | no options | text | "0:0:0:4:5:6:7" | ["0:0:0:4:5:6:7"] | 0 | none |
      | VSB-DELTA-JOIN-OVERFLOW | join | delta | ordered fields [0,0,0,0,1,120,90] | no options | text | "0:0:0:0:3:1:30" | ["0:0:0:0:3:1:30"] | 0 | none |
      | VSB-DELTA-JOIN-OVERFLOW-NONORM | join | delta | ordered fields [0,0,0,0,1,120,90] | options {"nonorm":1} | text | "0:0:0:0:1:120:90" | ["0:0:0:0:1:120:90"] | 0 | none |
      | VSB-DELTA-JOIN-BUSINESS | join | delta | ordered fields [0,0,0,0,16,0,0] | options {"mode":"business"} | text | "0:0:0:0:16:0:0" | ["0:0:0:0:16:0:0"] | 0 | none |
      | VSB-BUSINESS-JOIN-ALIAS | join | business | ordered fields [0,0,0,0,16,0,0] | no options | text | "0:0:0:2:0:0:0" | ["0:0:0:2:0:0:0"] | 0 | none |
      | VSB-DELTA-JOIN-FRACTION | join | delta | ordered fields [0,0,0,0,0,0,1.5] | no options | text | "0:0:0:0:0:0:1" | ["0:0:0:0:0:0:1"] | 0 | none |
      | VSB-DELTA-JOIN-NONNUMERIC | join | delta | ordered fields [0,0,0,0,"x",0,0] | no options | undefined | null | [null] | 0 | none |
      | VSB-SPLIT-INVALID-KIND | split | fortnight | text "1:2:3" | no options | text | "" | [""] | 0 | none |
      | VSB-JOIN-INVALID-KIND | join | fortnight | ordered fields [1,2,3] | no options | text | "" | [""] | 0 | none |
      | VSB-JOIN-UNDEFINED-CARRIER | join | time | an undefined scalar | no options | no return | no return | no return | 0 | expected array-reference carrier |
      | VSB-JOIN-SCALAR-CARRIER | join | time | text "1:2:3" | no options | no return | no return | no return | 0 | expected array-reference carrier |
