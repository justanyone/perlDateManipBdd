@draft @leap-year @compatibility @disputed @reference-observed
Feature: Characterize short-year interpretation by public profile
  These profile-specific observations remain disputed portability candidates.

  Background:
    Given the leap-year profile "gregorian-2040" has:
      | setting                   | value                              |
      | calendar                  | proleptic Gregorian                |
      | supported year interval   | 0001 through 9999                  |
      | fixed reference clock     | 2040-02-28 10:20:30 in Etc/UTC     |
      | input language            | English                            |
      | default short-year window | reference year minus 89 through plus 10 |

  Scenario Outline: Use the default short-year rule for <case>
    Given public leap-year profile "<profile>" with its default short-year setting
    When it classifies year text "<year>"
    Then the returned flag is <flag>

    Examples:
      | case                      | profile | year | flag |
      | LY-SHORT-DEFAULT-00-BASE  | base    | 00   | 1    |
      | LY-SHORT-DEFAULT-00-DM6   | dm6     | 00   | 1    |
      | LY-SHORT-DEFAULT-00-DM5   | dm5     | 00   | 1    |
      | LY-SHORT-DEFAULT-40-BASE  | base    | 40   | 1    |
      | LY-SHORT-DEFAULT-40-DM6   | dm6     | 40   | 1    |
      | LY-SHORT-DEFAULT-40-DM5   | dm5     | 40   | 1    |

  Scenario Outline: Apply an explicit short-year setting for <case>
    Given public leap-year profile "<profile>" has short-year setting "<setting>"
    When it classifies year text "00"
    Then the returned flag is <flag>

    Examples:
      | case                | profile | setting | flag |
      | LY-SHORT-c-BASE     | base    | C       | 1    |
      | LY-SHORT-c-DM6      | dm6     | C       | 1    |
      | LY-SHORT-c-DM5      | dm5     | C       | 1    |
      | LY-SHORT-c19-BASE   | base    | C19     | 1    |
      | LY-SHORT-c19-DM6    | dm6     | C19     | 1    |
      | LY-SHORT-c19-DM5    | dm5     | C19     | 0    |
      | LY-SHORT-c20-BASE   | base    | C20     | 1    |
      | LY-SHORT-c20-DM6    | dm6     | C20     | 1    |
      | LY-SHORT-c20-DM5    | dm5     | C20     | 1    |
      | LY-SHORT-c2000-BASE | base    | C2000   | 1    |
      | LY-SHORT-c2000-DM6  | dm6     | C2000   | 1    |
      | LY-SHORT-c2000-DM5  | dm5     | C2000   | 1    |
      | LY-SHORT-0-BASE     | base    | 0       | 1    |
      | LY-SHORT-0-DM6      | dm6     | 0       | 1    |
      | LY-SHORT-0-DM5      | dm5     | 0       | 0    |
      | LY-SHORT-99-BASE    | base    | 99      | 1    |
      | LY-SHORT-99-DM6     | dm6     | 99      | 1    |
      | LY-SHORT-99-DM5     | dm5     | 99      | 1    |
