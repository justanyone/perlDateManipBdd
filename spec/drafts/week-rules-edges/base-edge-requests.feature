@draft @portable @calendar @week-rules-edges
Feature: Generic calendar week-number edge requests
  These rows preserve generic public outcomes for invalid, incomplete, malformed,
  and year-limit requests without prescribing a library implementation.

  Background:
    Given the proleptic Gregorian civil calendar in UTC
    And the language context is English
    And these requests do not depend on the current clock
    And profile generic calendar means the route that returns week pairs and inverse dates
    And weekday numbers 1 through 7 mean Monday through Sunday
    And rule janN makes week one the week containing January N
    And civil date fields are ordered as [year, month, day]
    And an inverse date outcome is ordered as [year, month, day]
    And a forward week outcome is ordered as [week-year, week-number]
    And null in a request or observed compatibility outcome means an absent value

  Scenario Outline: Observe a generic calendar edge request
    Given <profile> uses week rule <rule> and first weekday <configured first>
    When I make <request>
    Then the generic outcome is <outcome>
    And its review classification is <classification>

    Examples:
      | case | profile | rule | configured first | request | outcome | classification |
      | WRE-BASE-INVERSE-WEEK-0 | generic calendar | jan4 | 1 | first date of configured week {"week_year":2040,"week":0} | [2040,1,2] | observed-compatibility |
      | WRE-BASE-INVERSE-WEEK-NEG1 | generic calendar | jan4 | 1 | first date of configured week {"week_year":2040,"week":-1} | [2040,1,2] | observed-compatibility |
      | WRE-BASE-INVERSE-WEEK-52 | generic calendar | jan4 | 1 | first date of configured week {"week_year":2040,"week":52} | [2040,12,24] | documented |
      | WRE-BASE-INVERSE-WEEK-53 | generic calendar | jan4 | 1 | first date of configured week {"week_year":2040,"week":53} | [2040,12,31] | observed-compatibility |
      | WRE-BASE-INVERSE-WEEK-54 | generic calendar | jan4 | 1 | first date of configured week {"week_year":2040,"week":54} | [2041,1,7] | observed-compatibility |
      | WRE-BASE-INVERSE-WEEK-UNDEFINED | generic calendar | jan4 | 1 | first date of configured week {"week_year":2040,"week":null} | [2040,1,2] | observed-compatibility |
      | WRE-BASE-INVERSE-WEEK-TEXT | generic calendar | jan4 | 1 | first date of configured week {"week_year":2040,"week":"two"} | [2040,1,2] | observed-compatibility |
      | WRE-BASE-INVERSE-YEAR-UNDEFINED | generic calendar | jan4 | 1 | first date of configured week {"week_year":null,"week":1} | [null,1,2] | observed-compatibility |
      | WRE-BASE-INVERSE-YEAR-NEG1 | generic calendar | jan4 | 1 | first date of configured week {"week_year":-1,"week":1} | [-1,1,3] | observed-compatibility |
      | WRE-BASE-INVERSE-YEAR-0 | generic calendar | jan4 | 1 | first date of configured week {"week_year":0,"week":1} | [0,1,2] | observed-compatibility |
      | WRE-BASE-INVERSE-YEAR-1 | generic calendar | jan4 | 1 | first date of configured week {"week_year":1,"week":1} | [1,1,1] | documented-boundary |
      | WRE-BASE-INVERSE-YEAR-9999 | generic calendar | jan4 | 1 | first date of configured week {"week_year":9999,"week":1} | [9999,1,4] | documented-boundary |
      | WRE-BASE-INVERSE-YEAR-10000 | generic calendar | jan4 | 1 | first date of configured week {"week_year":10000,"week":1} | [10000,1,3] | observed-compatibility |
      | WRE-BASE-INVERSE-YEAR-TEXT | generic calendar | jan4 | 1 | first date of configured week {"week_year":"year","week":1} | ["year",1,2] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-VALID | generic calendar | jan4 | 1 | week pair for civil fields [2040,1,1] | [2039,52] | documented-control |
      | WRE-BASE-FORWARD-DATE-EMPTY | generic calendar | jan4 | 1 | week pair for civil fields [] | [null,52] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-YEAR | generic calendar | jan4 | 1 | week pair for civil fields [2040] | [2040,52] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-YEAR-MONTH | generic calendar | jan4 | 1 | week pair for civil fields [2040,1] | [2039,52] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-EXTRA | generic calendar | jan4 | 1 | week pair for civil fields [2040,1,1,12] | [2039,52] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-MONTH-0 | generic calendar | jan4 | 1 | week pair for civil fields [2040,0,1] | [2041,1] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-MONTH-13 | generic calendar | jan4 | 1 | week pair for civil fields [2040,13,1] | [2041,1] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-DAY-0 | generic calendar | jan4 | 1 | week pair for civil fields [2040,1,0] | [2039,52] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-DAY-32 | generic calendar | jan4 | 1 | week pair for civil fields [2040,1,32] | [2040,5] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-FEB-30 | generic calendar | jan4 | 1 | week pair for civil fields [2040,2,30] | [2040,9] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-YEAR-NEG1 | generic calendar | jan4 | 1 | week pair for civil fields [-1,1,1] | [-2,52] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-YEAR-0 | generic calendar | jan4 | 1 | week pair for civil fields [0,1,1] | [-1,52] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-YEAR-1 | generic calendar | jan4 | 1 | week pair for civil fields [1,1,1] | [1,1] | documented-boundary |
      | WRE-BASE-FORWARD-DATE-YEAR-9999 | generic calendar | jan4 | 1 | week pair for civil fields [9999,1,1] | [9998,53] | documented-boundary |
      | WRE-BASE-FORWARD-DATE-YEAR-10000 | generic calendar | jan4 | 1 | week pair for civil fields [10000,1,1] | [9999,52] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-TEXT-YEAR | generic calendar | jan4 | 1 | week pair for civil fields ["year",1,1] | [-1,52] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-TEXT-MONTH | generic calendar | jan4 | 1 | week pair for civil fields [2040,"month",1] | [2041,1] | observed-compatibility |
      | WRE-BASE-FORWARD-DATE-TEXT-DAY | generic calendar | jan4 | 1 | week pair for civil fields [2040,1,"day"] | [2039,52] | observed-compatibility |
      | WRE-BASE-FORWARD-ARG-UNDEFINED | generic calendar | jan4 | 1 | week pair for an absent civil date | failure without a result | generic-failure |
      | WRE-BASE-ARITY-NO-ARGUMENTS | generic calendar | jan4 | 1 | week pair with the civil date omitted | failure without a result | generic-failure |
      | WRE-BASE-ARITY-ONE-SCALAR | generic calendar | jan4 | 1 | first date of configured week with the week field omitted | failure without a result | generic-failure |
      | WRE-BASE-CONFIG-FIRSTDAY-0 | generic calendar | jan4 | 1 | set first weekday to 0 | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-FIRSTDAY-8 | generic calendar | jan4 | 1 | set first weekday to 8 | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-FIRSTDAY-NEG1 | generic calendar | jan4 | 1 | set first weekday to -1 | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-FIRSTDAY-EMPTY | generic calendar | jan4 | 1 | set first weekday to "" | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-FIRSTDAY-UNDEFINED | generic calendar | jan4 | 1 | set first weekday to "absent value" | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-FIRSTDAY-MISSING | generic calendar | jan4 | 1 | set first weekday to "omitted value" | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-FIRSTDAY-NAME | generic calendar | jan4 | 1 | set first weekday to "Monday" | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-FIRSTDAY-FRACTION | generic calendar | jan4 | 1 | set first weekday to 1.5 | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-WEEKRULE-JAN0 | generic calendar | jan4 | 1 | set first-week rule to "jan0" | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-WEEKRULE-JAN8 | generic calendar | jan4 | 1 | set first-week rule to "jan8" | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-WEEKRULE-DOW0 | generic calendar | jan4 | 1 | set first-week rule to "dow0" | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-WEEKRULE-DOW8 | generic calendar | jan4 | 1 | set first-week rule to "dow8" | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-WEEKRULE-EMPTY | generic calendar | jan4 | 1 | set first-week rule to "" | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-WEEKRULE-UNDEFINED | generic calendar | jan4 | 1 | set first-week rule to "absent value" | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-WEEKRULE-MISSING | generic calendar | jan4 | 1 | set first-week rule to "omitted value" | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-WEEKRULE-FIRST-DAY | generic calendar | jan4 | 1 | set first-week rule to "first-day" | {"configuration_after":{"first_weekday":1,"first_week_rule":"jan4"},"control_week_pair":[2039,52]} | observed-compatibility |
      | WRE-BASE-CONFIG-WEEKRULE-UPPERCASE | generic calendar | jan4 | 1 | set first-week rule to "JAN4" | {"configuration_after":{"first_weekday":1,"first_week_rule":"JAN4"},"control_week_pair":[2039,52]} | documented |
