#!/usr/bin/env python3
"""Create the original branch-focused calendar validation manifest."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / "docs/research/calendar-check-family/cases.json"
cases = []


def fields(case_id, operation, values, partition, category, disposition, note):
    cases.append({
        "case_id": case_id,
        "operation_id": operation,
        "profile": "oo",
        "input": {"carrier": "ordered-fields", "fields": values},
        "partition_id": partition,
        "category": category,
        "disposition": disposition,
        "note": note,
    })


def scalar(case_id, operation, value, partition, category, note):
    cases.append({
        "case_id": case_id,
        "operation_id": operation,
        "profile": "oo",
        "input": {"carrier": "text scalar", "value": value},
        "partition_id": partition,
        "category": category,
        "disposition": "binding-only malformed carrier",
        "note": note,
    })


time = "calendar.validate-time"
fields("CC-T-MIDNIGHT-NUMERIC", time, [0, 0, 0], time+".p1", "valid", "documented", "numeric midnight")
fields("CC-T-MIDNIGHT-ONE-DIGIT", time, ["0", "0", "0"], time+".p4", "representation", "observed-compatibility", "one-digit text fields")
fields("CC-T-MIDNIGHT-PADDED", time, ["00", "00", "00"], time+".p1", "valid", "documented", "padded midnight text")
fields("CC-T-LAST-SECOND", time, [23, 59, 59], time+".p1", "valid", "documented", "last second before 24:00")
fields("CC-T-24-EXACT", time, [24, 0, 0], time+".p2", "valid", "documented", "documented upper endpoint")
fields("CC-T-24-MINUTE", time, [24, 1, 0], time+".p3", "invalid-value", "documented", "hour 24 with nonzero minute")
fields("CC-T-HOUR-25", time, [25, 0, 0], time+".p3", "invalid-value", "documented", "hour above maximum")
fields("CC-T-MINUTE-60", time, [12, 60, 0], time+".p3", "invalid-value", "documented", "minute above maximum")
fields("CC-T-SECOND-60", time, [12, 0, 60], time+".p3", "invalid-value", "documented", "second above maximum")
fields("CC-T-NEGATIVE", time, [-1, 0, 0], time+".p4", "representation", "observed-compatibility", "signed field")
fields("CC-T-FRACTION", time, [1.5, 0, 0], time+".p4", "representation", "observed-compatibility", "fractional field")
fields("CC-T-WHITESPACE", time, [" 1", 0, 0], time+".p4", "representation", "observed-compatibility", "leading whitespace")
fields("CC-T-NONNUMERIC", time, ["x", 0, 0], time+".p4", "representation", "observed-compatibility", "nonnumeric text")
fields("CC-T-MISSING-FIELD", time, [12, 30], time+".p4", "shape", "observed-compatibility", "second field omitted")
fields("CC-T-UNDEFINED-FIELD", time, [12, None, 0], time+".p4", "shape", "observed-compatibility", "minute explicitly absent")
fields("CC-T-EXTRA-FIELD", time, [12, 30, 15, 99], time+".p4", "shape", "observed-compatibility", "one extra field")

date = "calendar.validate-date"
fields("CC-D-ORDINARY", date, [2039, 5, 17, 9, 7, 5], date+".p1", "valid", "documented", "ordinary date and time")
fields("CC-D-LEAP-DAY", date, [2040, 2, 29, 0, 0, 0], date+".p1", "valid", "documented", "leap day")
fields("CC-D-LOWER-ENDPOINT", date, [1, 1, 1, 0, 0, 0], date+".p2", "valid", "documented", "lower supported year endpoint")
fields("CC-D-UPPER-ENDPOINT", date, [9999, 12, 31, 24, 0, 0], date+".p2", "valid", "documented", "upper supported year endpoint at 24:00")
fields("CC-D-APRIL-END", date, [2040, 4, 30, 23, 59, 59], date+".p2", "valid", "documented", "last day of a 30-day month")
fields("CC-D-YEAR-ZERO", date, [0, 1, 1, 0, 0, 0], date+".p3", "invalid-value", "documented", "year below supported range")
fields("CC-D-YEAR-10000", date, [10000, 1, 1, 0, 0, 0], date+".p3", "invalid-value", "documented", "year above supported range")
fields("CC-D-MONTH-ZERO", date, [2040, 0, 1, 0, 0, 0], date+".p3", "invalid-value", "documented", "month below range")
fields("CC-D-MONTH-13", date, [2040, 13, 1, 0, 0, 0], date+".p3", "invalid-value", "documented", "month above range")
fields("CC-D-DAY-ZERO", date, [2040, 1, 0, 0, 0, 0], date+".p3", "invalid-value", "documented", "day below range")
fields("CC-D-COMMON-FEB29", date, [2039, 2, 29, 0, 0, 0], date+".p3", "invalid-value", "documented", "February 29 in a common year")
fields("CC-D-APRIL31", date, [2040, 4, 31, 0, 0, 0], date+".p3", "invalid-value", "documented", "day above month end")
fields("CC-D-24-SECOND", date, [2040, 1, 1, 24, 0, 1], date+".p3", "invalid-value", "documented", "hour 24 with nonzero second")
fields("CC-D-FRACTIONAL-YEAR", date, [2040.5, 1, 1, 0, 0, 0], date+".p4", "representation", "observed-compatibility", "fractional year")
fields("CC-D-WHITESPACE-YEAR", date, [" 2040", 1, 1, 0, 0, 0], date+".p4", "representation", "observed-compatibility", "year text with leading whitespace")
fields("CC-D-NONNUMERIC-YEAR", date, ["x", 1, 1, 0, 0, 0], date+".p4", "representation", "observed-compatibility", "nonnumeric year")
fields("CC-D-MISSING-TIME", date, [2040, 1, 1], date+".p4", "shape", "observed-compatibility", "time fields omitted")
fields("CC-D-EXTRA-FIELD", date, [2040, 1, 1, 0, 0, 0, 99], date+".p4", "shape", "observed-compatibility", "one extra field")
fields("CC-D-UNDEFINED-DAY", date, [2040, 1, None, 0, 0, 0], date+".p4", "shape", "observed-compatibility", "day explicitly absent")
scalar("CC-D-SCALAR-CARRIER", date, "2040-01-01", date+".p4", "carrier", "text supplied instead of an ordered field collection")

assert len(cases) == 36
OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(json.dumps({
    "schema_version": 1,
    "purpose": "Original branch-focused public Base calendar validation requests.",
    "canonical_operations": [time, date],
    "cases": cases,
}, indent=2, ensure_ascii=False) + "\n")
print(f"wrote {len(cases)} cases")
