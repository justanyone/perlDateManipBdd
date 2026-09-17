@draft @leap-year @source-binding @perl-binding @reference-observed @excluded-from-portable-handoff
Feature: Preserve Perl scalar, list, warning, and interruption carriers
  These scenarios are source-binding evidence and are not portable requirements.

  Background:
    Given the leap-year profile "gregorian-2040" has:
      | setting                   | value                              |
      | calendar                  | proleptic Gregorian                |
      | supported year interval   | 0001 through 9999                  |
      | fixed reference clock     | 2040-02-28 10:20:30 in Etc/UTC     |
      | input language            | English                            |
      | default short-year window | reference year minus 89 through plus 10 |

  Scenario Outline: A complete cycle has explicit native carriers for <case>
    Given the Perl "<profile>" binding
    When it classifies integers 2000 through 2399 in scalar and list context
    Then scalar context completes 400 times with 97 numeric ones and 303 numeric zeroes
    And list context completes 400 times with one-element lists containing the same flags

    Examples:
      | case                       | profile |
      | LY-CYCLE-2000-2399-BASE | base    |
      | LY-CYCLE-2000-2399-DM6  | dm6     |
      | LY-CYCLE-2000-2399-DM5  | dm5     |

  Scenario Outline: Preserve both native return contexts for <case>
    Given the Perl "<profile>" binding and request <request>
    When I invoke the public leap-year call in scalar and list context
    Then scalar completion is <scalar completion> with <scalar return>
    And list completion is <list completion> with <list return>

    Examples:
      | case                         | profile | request                        | scalar completion | scalar return | list completion | list return          |
      | LY-BOUNDARY-0001-BASE        | base    | text "0001"                    | completed         | number 0      | completed       | one-element list [0] |
      | LY-BOUNDARY-0001-DM6         | dm6     | text "0001"                    | completed         | number 0      | completed       | one-element list [0] |
      | LY-BOUNDARY-0001-DM5         | dm5     | text "0001"                    | completed         | number 0      | completed       | one-element list [0] |
      | LY-BOUNDARY-0004-BASE        | base    | text "0004"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-BOUNDARY-0004-DM6         | dm6     | text "0004"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-BOUNDARY-0004-DM5         | dm5     | text "0004"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-BOUNDARY-1600-BASE        | base    | text "1600"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-BOUNDARY-1600-DM6         | dm6     | text "1600"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-BOUNDARY-1600-DM5         | dm5     | text "1600"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-BOUNDARY-1900-BASE        | base    | text "1900"                    | completed         | number 0      | completed       | one-element list [0] |
      | LY-BOUNDARY-1900-DM6         | dm6     | text "1900"                    | completed         | number 0      | completed       | one-element list [0] |
      | LY-BOUNDARY-1900-DM5         | dm5     | text "1900"                    | completed         | number 0      | completed       | one-element list [0] |
      | LY-BOUNDARY-2400-BASE        | base    | text "2400"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-BOUNDARY-2400-DM6         | dm6     | text "2400"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-BOUNDARY-2400-DM5         | dm5     | text "2400"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-BOUNDARY-9996-BASE        | base    | text "9996"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-BOUNDARY-9996-DM6         | dm6     | text "9996"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-BOUNDARY-9996-DM5         | dm5     | text "9996"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-BOUNDARY-9999-BASE        | base    | text "9999"                    | completed         | number 0      | completed       | one-element list [0] |
      | LY-BOUNDARY-9999-DM6         | dm6     | text "9999"                    | completed         | number 0      | completed       | one-element list [0] |
      | LY-BOUNDARY-9999-DM5         | dm5     | text "9999"                    | completed         | number 0      | completed       | one-element list [0] |
      | LY-SHORT-DEFAULT-00-BASE     | base    | text "00"                      | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-DEFAULT-00-DM6      | dm6     | text "00"                      | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-DEFAULT-00-DM5      | dm5     | text "00"                      | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-DEFAULT-40-BASE     | base    | text "40"                      | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-DEFAULT-40-DM6      | dm6     | text "40"                      | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-DEFAULT-40-DM5      | dm5     | text "40"                      | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-c-BASE              | base    | text "00" with YYtoYYYY C      | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-c-DM6               | dm6     | text "00" with YYtoYYYY C      | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-c-DM5               | dm5     | text "00" with YYtoYYYY C      | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-c19-BASE            | base    | text "00" with YYtoYYYY C19    | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-c19-DM6             | dm6     | text "00" with YYtoYYYY C19    | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-c19-DM5             | dm5     | text "00" with YYtoYYYY C19    | completed         | number 0      | completed       | one-element list [0] |
      | LY-SHORT-c20-BASE            | base    | text "00" with YYtoYYYY C20    | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-c20-DM6             | dm6     | text "00" with YYtoYYYY C20    | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-c20-DM5             | dm5     | text "00" with YYtoYYYY C20    | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-c2000-BASE          | base    | text "00" with YYtoYYYY C2000  | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-c2000-DM6           | dm6     | text "00" with YYtoYYYY C2000  | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-c2000-DM5           | dm5     | text "00" with YYtoYYYY C2000  | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-0-BASE              | base    | text "00" with YYtoYYYY 0      | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-0-DM6               | dm6     | text "00" with YYtoYYYY 0      | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-0-DM5               | dm5     | text "00" with YYtoYYYY 0      | completed         | number 0      | completed       | one-element list [0] |
      | LY-SHORT-99-BASE             | base    | text "00" with YYtoYYYY 99     | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-99-DM6              | dm6     | text "00" with YYtoYYYY 99     | completed         | number 1      | completed       | one-element list [1] |
      | LY-SHORT-99-DM5              | dm5     | text "00" with YYtoYYYY 99     | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-OMITTED-BASE         | base    | omitted argument               | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-OMITTED-DM6          | dm6     | omitted argument               | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-OMITTED-DM5          | dm5     | omitted argument               | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-UNDEFINED-BASE       | base    | explicit undefined scalar      | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-UNDEFINED-DM6        | dm6     | explicit undefined scalar      | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-UNDEFINED-DM5        | dm5     | explicit undefined scalar      | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-EMPTY-BASE           | base    | text ""                        | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-EMPTY-DM6            | dm6     | text ""                        | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-EMPTY-DM5            | dm5     | text ""                        | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-SPACE-BASE           | base    | text " "                       | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-SPACE-DM6            | dm6     | text " "                       | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-SPACE-DM5            | dm5     | text " "                       | interrupted       | no return     | interrupted     | no return            |
      | LY-EDGE-NONNUMERIC4-BASE     | base    | text "abcd"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-NONNUMERIC4-DM6      | dm6     | text "abcd"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-NONNUMERIC4-DM5      | dm5     | text "abcd"                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-NONNUMERIC3-BASE     | base    | text "abc"                     | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-NONNUMERIC3-DM6      | dm6     | text "abc"                     | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-NONNUMERIC3-DM5      | dm5     | text "abc"                     | interrupted       | no return     | interrupted     | no return            |
      | LY-EDGE-FRACTION-BASE        | base    | number 2000.5                  | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-FRACTION-DM6         | dm6     | number 2000.5                  | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-FRACTION-DM5         | dm5     | number 2000.5                  | interrupted       | no return     | interrupted     | no return            |
      | LY-EDGE-ZERO-BASE            | base    | number 0                       | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-ZERO-DM6             | dm6     | number 0                       | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-ZERO-DM5             | dm5     | number 0                       | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-NEGATIVE4-BASE       | base    | number -4                      | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-NEGATIVE4-DM6        | dm6     | number -4                      | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-NEGATIVE4-DM5        | dm5     | number -4                      | completed         | number 0      | completed       | one-element list [0] |
      | LY-EDGE-NEGATIVE400-BASE     | base    | number -400                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-NEGATIVE400-DM6      | dm6     | number -400                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-NEGATIVE400-DM5      | dm5     | number -400                    | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-NEGATIVE100-BASE     | base    | number -100                    | completed         | number 0      | completed       | one-element list [0] |
      | LY-EDGE-NEGATIVE100-DM6      | dm6     | number -100                    | completed         | number 0      | completed       | one-element list [0] |
      | LY-EDGE-NEGATIVE100-DM5      | dm5     | number -100                    | completed         | number 0      | completed       | one-element list [0] |
      | LY-EDGE-OUTSIDE10000-BASE    | base    | number 10000                   | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-OUTSIDE10000-DM6     | dm6     | number 10000                   | completed         | number 1      | completed       | one-element list [1] |
      | LY-EDGE-OUTSIDE10000-DM5     | dm5     | number 10000                   | interrupted       | no return     | interrupted     | no return            |

  Scenario Outline: Interrupted DM5 calls have an exact first diagnostic line for <case>
    Given the Perl DM5 binding and request <request>
    When I invoke the public leap-year call in <context> context
    Then the call is interrupted before any return carrier exists
    And the first diagnostic line is exactly "<diagnostic>"

    Examples:
      | case                         | request                   | context | diagnostic                    |
      | LY-EDGE-SPACE-DM5            | text " "                  | scalar  | ERROR: Invalid year ( )       |
      | LY-EDGE-SPACE-DM5            | text " "                  | list    | ERROR: Invalid year ( )       |
      | LY-EDGE-NONNUMERIC3-DM5      | text "abc"                | scalar  | ERROR: Invalid year (abc)     |
      | LY-EDGE-NONNUMERIC3-DM5      | text "abc"                | list    | ERROR: Invalid year (abc)     |
      | LY-EDGE-FRACTION-DM5         | number 2000.5             | scalar  | ERROR: Invalid year (2000.5)  |
      | LY-EDGE-FRACTION-DM5         | number 2000.5             | list    | ERROR: Invalid year (2000.5)  |
      | LY-EDGE-OUTSIDE10000-DM5     | number 10000              | scalar  | ERROR: Invalid year (10000)   |
      | LY-EDGE-OUTSIDE10000-DM5     | number 10000              | list    | ERROR: Invalid year (10000)   |

  @LY-BIND-DM5-DEPRECATION
  Scenario: Loading the DM5 binding emits its exact deprecation diagnostic
    When a fresh process loads the DM5 binding for any recorded request
    Then it emits exactly one warning
    And the warning is exactly "Date::Manip::DM5 is deprecated and will be removed from the Date::Manip package starting in version 7.00 at (eval 42) line 1."

  Scenario Outline: Native operation warnings remain binding evidence for <case>
    Given the Perl "<profile>" binding and request <request>
    When I invoke the public leap-year call in <context> context
    Then it emits exactly <count> operation warnings
    And every warning begins with "<warning>"

    Examples:
      | case                         | profile | request                   | context | count | warning                                                  |
      | LY-EDGE-OMITTED-BASE         | base    | omitted argument          | scalar  | 3     | Use of uninitialized value $y in integer modulus (%)     |
      | LY-EDGE-OMITTED-BASE         | base    | omitted argument          | list    | 3     | Use of uninitialized value $y in integer modulus (%)     |
      | LY-EDGE-OMITTED-DM6          | dm6     | omitted argument          | scalar  | 3     | Use of uninitialized value $y in integer modulus (%)     |
      | LY-EDGE-OMITTED-DM6          | dm6     | omitted argument          | list    | 3     | Use of uninitialized value $y in integer modulus (%)     |
      | LY-EDGE-OMITTED-DM5          | dm5     | omitted argument          | scalar  | 1     | Use of uninitialized value length($y) in integer ne (!=) |
      | LY-EDGE-OMITTED-DM5          | dm5     | omitted argument          | list    | 1     | Use of uninitialized value length($y) in integer ne (!=) |
      | LY-EDGE-UNDEFINED-BASE       | base    | explicit undefined scalar | scalar  | 3     | Use of uninitialized value $y in integer modulus (%)     |
      | LY-EDGE-UNDEFINED-BASE       | base    | explicit undefined scalar | list    | 3     | Use of uninitialized value $y in integer modulus (%)     |
      | LY-EDGE-UNDEFINED-DM6        | dm6     | explicit undefined scalar | scalar  | 3     | Use of uninitialized value $y in integer modulus (%)     |
      | LY-EDGE-UNDEFINED-DM6        | dm6     | explicit undefined scalar | list    | 3     | Use of uninitialized value $y in integer modulus (%)     |
      | LY-EDGE-UNDEFINED-DM5        | dm5     | explicit undefined scalar | scalar  | 1     | Use of uninitialized value length($y) in integer ne (!=) |
      | LY-EDGE-UNDEFINED-DM5        | dm5     | explicit undefined scalar | list    | 1     | Use of uninitialized value length($y) in integer ne (!=) |
      | LY-EDGE-EMPTY-BASE           | base    | text ""                   | scalar  | 1     | Argument "" isn't numeric in integer modulus (%)         |
      | LY-EDGE-EMPTY-BASE           | base    | text ""                   | list    | 1     | Argument "" isn't numeric in integer modulus (%)         |
      | LY-EDGE-EMPTY-DM6            | dm6     | text ""                   | scalar  | 1     | Argument "" isn't numeric in integer modulus (%)         |
      | LY-EDGE-EMPTY-DM6            | dm6     | text ""                   | list    | 1     | Argument "" isn't numeric in integer modulus (%)         |
      | LY-EDGE-SPACE-BASE           | base    | text " "                  | scalar  | 1     | Argument " " isn't numeric in integer modulus (%)        |
      | LY-EDGE-SPACE-BASE           | base    | text " "                  | list    | 1     | Argument " " isn't numeric in integer modulus (%)        |
      | LY-EDGE-SPACE-DM6            | dm6     | text " "                  | scalar  | 1     | Argument " " isn't numeric in integer modulus (%)        |
      | LY-EDGE-SPACE-DM6            | dm6     | text " "                  | list    | 1     | Argument " " isn't numeric in integer modulus (%)        |
      | LY-EDGE-NONNUMERIC4-BASE     | base    | text "abcd"               | scalar  | 1     | Argument "abcd" isn't numeric in integer modulus (%)     |
      | LY-EDGE-NONNUMERIC4-BASE     | base    | text "abcd"               | list    | 1     | Argument "abcd" isn't numeric in integer modulus (%)     |
      | LY-EDGE-NONNUMERIC4-DM6      | dm6     | text "abcd"               | scalar  | 1     | Argument "abcd" isn't numeric in integer modulus (%)     |
      | LY-EDGE-NONNUMERIC4-DM6      | dm6     | text "abcd"               | list    | 1     | Argument "abcd" isn't numeric in integer modulus (%)     |
      | LY-EDGE-NONNUMERIC4-DM5      | dm5     | text "abcd"               | scalar  | 1     | Argument "abcd" isn't numeric in integer modulus (%)     |
      | LY-EDGE-NONNUMERIC4-DM5      | dm5     | text "abcd"               | list    | 1     | Argument "abcd" isn't numeric in integer modulus (%)     |
      | LY-EDGE-NONNUMERIC3-BASE     | base    | text "abc"                | scalar  | 1     | Argument "abc" isn't numeric in integer modulus (%)      |
      | LY-EDGE-NONNUMERIC3-BASE     | base    | text "abc"                | list    | 1     | Argument "abc" isn't numeric in integer modulus (%)      |
      | LY-EDGE-NONNUMERIC3-DM6      | dm6     | text "abc"                | scalar  | 1     | Argument "abc" isn't numeric in integer modulus (%)      |
      | LY-EDGE-NONNUMERIC3-DM6      | dm6     | text "abc"                | list    | 1     | Argument "abc" isn't numeric in integer modulus (%)      |
      | LY-EDGE-NEGATIVE4-DM5        | dm5     | number -4                 | scalar  | 1     | Argument "19-4" isn't numeric in integer lt (<)          |
      | LY-EDGE-NEGATIVE4-DM5        | dm5     | number -4                 | list    | 1     | Argument "19-4" isn't numeric in integer lt (<)          |
