#!/usr/bin/env python3
"""Choose all Gregorian Jan-1 weekday/leap types and enumerate valid rules."""
from __future__ import annotations

import calendar
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / "docs/research/week-rules-family/matrix-manifest.json"

def is_leap(year: int) -> bool:
    return calendar.isleap(year)

def main() -> None:
    years = []
    for leap in (False, True):
        for jan1_weekday in range(7):  # calendar: Monday=0 through Sunday=6
            year = next(y for y in range(2000, 2400)
                        if is_leap(y) == leap and calendar.weekday(y, 1, 1) == jan1_weekday)
            years.append({"year":year, "leap":leap, "jan1_weekday_monday0":jan1_weekday,
                          "jan1_weekday_monday1":jan1_weekday + 1})
    years.sort(key=lambda value: (value["leap"], value["jan1_weekday_monday1"]))
    date_days = [{"month":1, "day":day, "label":f"01-{day:02d}"} for day in range(1, 8)]
    date_days += [{"month":12, "day":day, "label":f"12-{day:02d}"} for day in range(25, 32)]
    rules = [f"jan{day}" for day in range(1, 8)]
    rules += [f"dow{day}" for day in range(1, 8)] + ["firstday"]
    configs = [{"case_id":f"WR-F{firstday}-{rule.upper()}", "first_day":firstday,
                "week1_of_year":rule} for firstday in range(1, 8) for rule in rules]
    OUT.write_text(json.dumps({
        "schema_version":1, "operation_id":"calendar.week-number",
        "selection_method":"Python calendar.isleap and calendar.weekday chose the earliest year from 2000..2399 for each leap/nonleap × Jan-1 Monday-based weekday type.",
        "years":years, "date_order":date_days, "configurations":configs,
        "selected_inverse_configurations":["WR-F1-JAN1","WR-F1-JAN4","WR-F1-JAN7","WR-F1-DOW1","WR-F1-DOW7","WR-F1-FIRSTDAY","WR-F7-FIRSTDAY"],
        "inverse_weeks":[1,2],
    }, indent=2, sort_keys=True) + "\n")

if __name__ == "__main__": main()
