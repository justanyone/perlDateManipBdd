@draft @rendering
Feature: Render extended selectors and POSIX-mode forms

  Background:
    Given the "utc-english-2040" rendering profile

  @RENDER-EXTENDED-ENDPOINTS
  Scenario: Render extended selector endpoints as one ordered request
    Given the "utc-english-2040" rendering profile and date "2040-02-29 16:05:09"
    When I request patterns "%<A=1>", "%<A=7>", "%<a=1>", "%<a=7>", "%<v=1>", "%<v=7>", "%<B=1>", "%<B=12>", "%<b=01>", "%<b=12>", "%<p=1>", "%<p=2>", "%<E=1>", and "%<E=53>"
    Then the ordered text result is "Monday", "Sunday", "Mon", "Sun", "M", "S", "January", "December", "Jan", "Dec", "AM", "PM", "1st", and "53rd"

  @RENDER-EXTENDED-OUTSIDE-DOMAIN
  Scenario: Preserve out-of-domain extended selectors
    Given the "utc-english-2040" rendering profile and date "2040-02-29 16:05:09"
    When I request patterns "%<A=0>", "%<A=8>", "%<B=00>", "%<B=13>", and "%<E=54>"
    Then the ordered text result is "%<A=0>", "%<A=8>", "%<B=00>", "%<B=13>", and "%<E=54>"

  @RENDER-POSIX-DEFAULT @RENDER-POSIX-OVERRIDES
  Scenario: POSIX mode changes the documented ordered request
    Given a complete UTC date-time "2040-01-01 00:05:09"
    When I request the patterns "%C", "%F", "%l", "%P", "%u", "%G", "%g", "%W", "%V", "%L", "%U", and "%J" without POSIX mode
    Then the ordered text result is "Sun Jan  1 00:05:09 UTC 2040", "Sunday, January  1, 2040", "Jan  1 00:05", "2040010100:05:09", "Sun Jan  1 00:05:09 UTC 2040", "2039", "Sun, 01 Jan 2040 00:05:09 UTC", "52", "0101000540", "2040", "01", and "2039-W52-7"
    Given a fresh context with the same profile and date and POSIX rendering enabled
    When I repeat that exact ordered request
    Then the ordered text result is "20", "2040-01-01", "12", "am", "7", "2039", "39", "52", "52", "2040", "01", and "2039-W52-7"

  @RENDER-POSIX-UNSUPPORTED-DEFAULT @RENDER-POSIX-UNSUPPORTED-POSIX
  Scenario: POSIX mode leaves the documented unavailable forms unchanged
    Given a complete UTC date-time "2040-01-01 00:05:09"
    When I request "%c", "%x", "%X", "%E", "%O", and "%+" without and with POSIX mode
    Then both ordered text results are "Sun Jan  1 00:05:09 2040", "01/01/40", "00:05:09", "1st", "2040-01-01T00:05:09", and "+"

  @RENDER-ZONE-OFFSET
  Scenario: A zone-specific profile renders offset and epoch fields
    Given the "new-york-2040" rendering profile and date "2040-06-01 12:00:00 America/New_York"
    When I request patterns "%Z", "%z", "%N", "%s", and "%o"
    Then the ordered text result is "EDT", "-0400", "-04:00:00", "2222179200", and "2222161200"
