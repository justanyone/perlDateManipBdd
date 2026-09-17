@draft @leap-year @reference-observed
Feature: Classify valid years by the Gregorian leap-year rule
  These cases use public operation "calendar.is-leap-year".

  Background:
    Given the leap-year profile "gregorian-2040" has:
      | setting                   | value                              |
      | calendar                  | proleptic Gregorian                |
      | supported year interval   | 0001 through 9999                  |
      | fixed reference clock     | 2040-02-28 10:20:30 in Etc/UTC     |
      | input language            | English                            |
      | default short-year window | reference year minus 89 through plus 10 |

  Scenario Outline: Classify one complete 400-year cycle for <case>
    Given public leap-year profile "<profile>"
    When it classifies every integer year from 2000 through 2399 inclusive
    Then exactly 97 years are leap years
    And exactly 303 years are common years
    And the leap years are exactly:
      | year |
      | 2000 |
      | 2004 |
      | 2008 |
      | 2012 |
      | 2016 |
      | 2020 |
      | 2024 |
      | 2028 |
      | 2032 |
      | 2036 |
      | 2040 |
      | 2044 |
      | 2048 |
      | 2052 |
      | 2056 |
      | 2060 |
      | 2064 |
      | 2068 |
      | 2072 |
      | 2076 |
      | 2080 |
      | 2084 |
      | 2088 |
      | 2092 |
      | 2096 |
      | 2104 |
      | 2108 |
      | 2112 |
      | 2116 |
      | 2120 |
      | 2124 |
      | 2128 |
      | 2132 |
      | 2136 |
      | 2140 |
      | 2144 |
      | 2148 |
      | 2152 |
      | 2156 |
      | 2160 |
      | 2164 |
      | 2168 |
      | 2172 |
      | 2176 |
      | 2180 |
      | 2184 |
      | 2188 |
      | 2192 |
      | 2196 |
      | 2204 |
      | 2208 |
      | 2212 |
      | 2216 |
      | 2220 |
      | 2224 |
      | 2228 |
      | 2232 |
      | 2236 |
      | 2240 |
      | 2244 |
      | 2248 |
      | 2252 |
      | 2256 |
      | 2260 |
      | 2264 |
      | 2268 |
      | 2272 |
      | 2276 |
      | 2280 |
      | 2284 |
      | 2288 |
      | 2292 |
      | 2296 |
      | 2304 |
      | 2308 |
      | 2312 |
      | 2316 |
      | 2320 |
      | 2324 |
      | 2328 |
      | 2332 |
      | 2336 |
      | 2340 |
      | 2344 |
      | 2348 |
      | 2352 |
      | 2356 |
      | 2360 |
      | 2364 |
      | 2368 |
      | 2372 |
      | 2376 |
      | 2380 |
      | 2384 |
      | 2388 |
      | 2392 |
      | 2396 |

    Examples:
      | case                       | profile |
      | LY-CYCLE-2000-2399-BASE | base    |
      | LY-CYCLE-2000-2399-DM6  | dm6     |
      | LY-CYCLE-2000-2399-DM5  | dm5     |

  Scenario Outline: Classify a supported boundary or century control for <case>
    Given public leap-year profile "<profile>"
    When it classifies year text "<year>"
    Then the year is <classification>

    Examples:
      | case                         | profile | year | classification |
      | LY-BOUNDARY-0001-BASE        | base    | 0001 | common         |
      | LY-BOUNDARY-0001-DM6         | dm6     | 0001 | common         |
      | LY-BOUNDARY-0001-DM5         | dm5     | 0001 | common         |
      | LY-BOUNDARY-0004-BASE        | base    | 0004 | leap           |
      | LY-BOUNDARY-0004-DM6         | dm6     | 0004 | leap           |
      | LY-BOUNDARY-0004-DM5         | dm5     | 0004 | leap           |
      | LY-BOUNDARY-1600-BASE        | base    | 1600 | leap           |
      | LY-BOUNDARY-1600-DM6         | dm6     | 1600 | leap           |
      | LY-BOUNDARY-1600-DM5         | dm5     | 1600 | leap           |
      | LY-BOUNDARY-1900-BASE        | base    | 1900 | common         |
      | LY-BOUNDARY-1900-DM6         | dm6     | 1900 | common         |
      | LY-BOUNDARY-1900-DM5         | dm5     | 1900 | common         |
      | LY-BOUNDARY-2400-BASE        | base    | 2400 | leap           |
      | LY-BOUNDARY-2400-DM6         | dm6     | 2400 | leap           |
      | LY-BOUNDARY-2400-DM5         | dm5     | 2400 | leap           |
      | LY-BOUNDARY-9996-BASE        | base    | 9996 | leap           |
      | LY-BOUNDARY-9996-DM6         | dm6     | 9996 | leap           |
      | LY-BOUNDARY-9996-DM5         | dm5     | 9996 | leap           |
      | LY-BOUNDARY-9999-BASE        | base    | 9999 | common         |
      | LY-BOUNDARY-9999-DM6         | dm6     | 9999 | common         |
      | LY-BOUNDARY-9999-DM5         | dm5     | 9999 | common         |
