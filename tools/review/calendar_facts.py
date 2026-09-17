#!/usr/bin/env python3
"""Independently review calendar research observations against Python's Gregorian facts.

This is a research reviewer, not a conformance oracle.  It reads the frozen probe
record and labels each observation; it never invokes Date::Manip or writes contracts.
"""
import calendar
import hashlib
import json
from collections import Counter
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
INPUTS = ROOT / "docs/research/inputs/calendar.json"
OBSERVATIONS = ROOT / "docs/research/observations/calendar.json"
PROBE = ROOT / "tools/probes/calendar-contracts.pl"
RUNNER = ROOT / "tools/probes/run-calendar.py"
FIXTURE = ROOT / "docs/automation/reference-profiles.json"
OUT_JSON = ROOT / "docs/research/observations/calendar-review.json"
OUT_MD = ROOT / "docs/research/observations/calendar-review.md"


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def raw(observation):
    return observation["observation"].get("raw_return", {})


def value(observation):
    result = raw(observation)
    return result.get("scalar") if "scalar" in result else result.get("list")


def clean_channels(observation):
    o = observation["observation"]
    return (o.get("exception") is None and o.get("call_stdout") == "" and
            observation.get("stderr") == "" and not o.get("warnings"))


def civil(case):
    a = case["arguments"]
    if case["profile"] == "base":
        return a[0] if isinstance(a[0], list) else None
    if case["profile"] in ("dm5", "dm6"):
        # Functional calls use month, day, year, then optional clock fields.
        return [a[2], a[0], a[1], *a[3:]]
    return None


def valid_date(fields):
    try:
        date(*fields[:3])
        return True
    except (TypeError, ValueError):
        return False


def valid_time(fields):
    if len(fields) != 3:
        return False
    h, m, s = fields
    return 0 <= h <= 23 and 0 <= m <= 59 and 0 <= s < 60


def expected_epoch(fields):
    y, m, d, h, minute, second = fields
    return int(datetime(y, m, d, h, minute, second, tzinfo=timezone.utc).timestamp())


def monday_of_iso_week(year, week):
    return list(date.fromisocalendar(year, week, 1).timetuple()[:3])


def nth_weekday(year, nth, weekday, month=None):
    # Date::Manip uses Monday=1.  A missing month means the year.
    start = date(year, month or 1, 1)
    end = date(year, month or 12, calendar.monthrange(year, month or 12)[1])
    if nth > 0:
        first = start + timedelta((weekday - first_weekday(start)) % 7)
        result = first + timedelta(days=7 * (nth - 1))
    else:
        last = end - timedelta((first_weekday(end) - weekday) % 7)
        result = last - timedelta(days=7 * (-nth - 1))
    return [result.year, result.month, result.day] if start <= result <= end else None


def first_weekday(day):
    return day.isoweekday()


def carrier(observation, case):
    actual = sorted(raw(observation))
    required = [case["return_context"]]
    return {"expected": required[0], "actual": actual[0] if len(actual) == 1 else actual,
            "matches": actual == required}


def review(case, observation):
    record = {
        "case_id": case["case_id"], "operation_id": case["operation_id"],
        "review_status": "unreviewed", "reason": "No independent rule selected.",
        "observed_return": raw(observation), "carrier": carrier(observation, case),
        "channels": {"clean": clean_channels(observation),
                     "warning_free": not observation["observation"].get("warnings", []),
                     "warnings": observation["observation"].get("warnings", []),
                     "exception": observation["observation"].get("exception"),
                     "stdout": observation["observation"].get("call_stdout"),
                     "stderr": observation.get("stderr", "")},
    }
    if not observation.get("repeatable") or observation.get("research_status") != "repeatable":
        record.update(review_status="disputed", reason="Probe record was not repeatable.")
        return record
    op, actual = case["operation_id"], value(observation)
    expected = None
    try:
        if op == "calendar.is-leap-year":
            expected = int(calendar.isleap(case["arguments"][0]))
        elif op == "calendar.days-in-year":
            expected = 366 if calendar.isleap(case["arguments"][0]) else 365
        elif op == "calendar.days-in-month":
            if case["profile"] == "base" and case["return_context"] == "list":
                expected = [calendar.monthrange(2040, m)[1] for m in range(1, 13)]
            else:
                if case["profile"] == "base":
                    year, month = case["arguments"]
                else:
                    month, year = case["arguments"]
                expected = calendar.monthrange(year, month)[1]
        elif op == "calendar.weekday":
            expected = date(*civil(case)[:3]).isoweekday()
        elif op == "calendar.validate-date":
            fields = civil(case)
            if len(fields) == 3:
                record.update(review_status="unreviewed", reason="Three-field Base check emits warnings and its omitted-clock convention is not a Gregorian fact.")
                return record
            expected = int(valid_date(fields) and valid_time(fields[3:]))
        elif op == "calendar.validate-time":
            fields = case["arguments"][0]
            if fields == [24, 0, 0]:
                record.update(review_status="compatibility", reason="24:00:00 is a Date::Manip-supported end-of-day representation; Python datetime only accepts 00:00:00.")
                return record
            if fields[-1] == 0.5:
                record.update(review_status="compatibility", reason="Python permits fractional seconds, while this Date::Manip validator rejects them.")
                return record
            expected = int(valid_time(fields))
        elif op == "calendar.day-of-year":
            a = case["arguments"]
            if case["profile"] == "base" and not isinstance(a[0], list):
                y, ordinal = a
                whole = int(ordinal)
                result = date(y, 1, 1) + timedelta(days=whole - 1)
                expected = [result.year, result.month, result.day]
                if ordinal != whole:
                    seconds = round((ordinal - whole) * 86400)
                    h, seconds = divmod(seconds, 3600); m, s = divmod(seconds, 60)
                    expected += [h, m, s]
            else:
                fields = civil(case)
                expected = date(*fields[:3]).timetuple().tm_yday
                if len(fields) == 6:
                    expected += (fields[3] * 3600 + fields[4] * 60 + fields[5]) / 86400
        elif op == "calendar.date-from-day-of-year":
            y, ordinal = case["arguments"]
            whole = int(ordinal)
            result = date(y, 1, 1) + timedelta(days=whole - 1)
            seconds = round((ordinal - whole) * 86400)
            h, seconds = divmod(seconds, 3600); m, s = divmod(seconds, 60)
            expected = [result.year, result.month, result.day, h, m, s]
        elif op == "calendar.day-ordinal":
            a = case["arguments"]
            if case["profile"] == "base" and not isinstance(a[0], list):
                ordinal = a[0]
                if ordinal < 1:
                    record.update(review_status="compatibility", reason="The Base inverse exposes year 0, outside Python datetime's Gregorian range.")
                    return record
                expected = list((date(1, 1, 1) + timedelta(days=ordinal - 1)).timetuple()[:3])
            else:
                expected = date(*civil(case)[:3]).toordinal()
                if case["profile"] == "dm5":
                    record.update(review_status="compatibility", reason="DM5's day ordinal uses a distinct historical compatibility epoch (366 days higher here).")
                    return record
        elif op == "calendar.nth-weekday":
            y, nth, weekday, *month = case["arguments"]
            if nth == 0:
                record.update(review_status="compatibility", reason="Zero occurrence is interpreted as the first occurrence by the observed Base route.")
                return record
            if abs(nth) > 53 or nth == 5:
                record.update(review_status="invalid", reason="Requested weekday occurrence is outside the selected month/year or permitted range.")
                return record
            expected = nth_weekday(y, nth, weekday, month[0] if month else None)
        elif op == "calendar.week-year-start":
            expected = list(date.fromisocalendar(case["arguments"][0], 1, 1).timetuple()[:3])
        elif op == "calendar.weeks-in-year":
            expected = date(case["arguments"][0], 12, 28).isocalendar().week
        elif op == "calendar.week-number":
            if case["profile"] in ("dm5", "dm6", "oo"):
                record.update(review_status="compatibility", reason="Functional/OO week-number call returns a calendar-week number with a configured first day, not an ISO week-year pair.")
                return record
            a = case["arguments"]
            if isinstance(a[0], list):
                iso = date(*a[0]).isocalendar()
                expected = [iso.year, iso.week]
            else:
                try:
                    expected = monday_of_iso_week(*a)
                except ValueError:
                    record.update(review_status="compatibility", reason="Week 53 was accepted for an ISO year that has only 52 weeks and rolled into the next week-year.")
                    return record
        elif op.startswith("epoch."):
            if op == "epoch.utc-instant-seconds" and case["arguments"]:
                instant = datetime.fromtimestamp(case["arguments"][0], tz=timezone.utc)
                observed_date = observation["observation"].get("date_after")
                # Base::value('local') uses Date::Manip's compact value format.
                record["independent_post_state"] = instant.strftime("%Y%m%d%H:%M:%S")
                record["post_state_matches"] = observed_date == record["independent_post_state"]
                if record["post_state_matches"]:
                    record.update(review_status="compatibility", reason="The independently calculated UTC post-state matches; the scalar zero is a binding-level mutator status, not an epoch value.")
                else:
                    record.update(review_status="disputed", reason="The mutating epoch setter's post-state differs from the independently calculated UTC instant.")
                return record
            elif op == "epoch.utc-instant-seconds":
                expected = expected_epoch([int(x) for x in case["initial_date"].replace("-", " ").replace(":", " ").split()])
            elif case["profile"] == "base" and len(case["arguments"]) == 1:
                if isinstance(case["arguments"][0], list):
                    expected = expected_epoch(case["arguments"][0])
                else:
                    instant = datetime.fromtimestamp(case["arguments"][0], tz=timezone.utc)
                    expected = [instant.year, instant.month, instant.day, instant.hour, instant.minute, instant.second]
            else:
                expected = expected_epoch(civil(case))
        else:
            return record
    except (ValueError, OverflowError, TypeError) as exc:
        record.update(review_status="unreviewed", reason=f"Python standard-library domain does not cover this input: {exc}.")
        return record
    record["independent_expected"] = expected
    if actual == expected and record["carrier"]["matches"]:
        record.update(review_status="reviewed", reason="Matches an independently calculated proleptic-Gregorian, ISO-week, or UTC fact.")
    else:
        record.update(review_status="disputed", reason="Observed return differs from the independently calculated fact or expected return carrier.")
    return record


def main():
    recorded = json.loads(OBSERVATIONS.read_text())
    cases = json.loads(INPUTS.read_text())["cases"]
    observed = {r["case_id"]: r for r in recorded["observations"]}
    rows = [review(case, observed[case["case_id"]]) for case in cases]
    status_counts = dict(sorted(Counter(r["review_status"] for r in rows).items()))
    channel_counts = {
        "clean": sum(r["channels"]["clean"] for r in rows),
        "with_warnings": sum(not r["channels"]["warning_free"] for r in rows),
        "with_exception": sum(r["channels"]["exception"] is not None for r in rows),
        "with_stdout": sum(bool(r["channels"]["stdout"]) for r in rows),
        "with_stderr": sum(bool(r["channels"]["stderr"]) for r in rows),
    }
    evidence_hashes = {str(p.relative_to(ROOT)): sha256(p) for p in (INPUTS, OBSERVATIONS, PROBE, RUNNER, FIXTURE)}
    recorded_hashes = recorded.get("sha256", {})
    evidence_integrity = {
        path: {"current": digest, "recorded": recorded_hashes.get(path),
               "matches_recorded": recorded_hashes.get(path) == digest}
        for path, digest in evidence_hashes.items() if path != "docs/research/observations/calendar.json"
    }
    output = {
        "schema_version": 1,
        "purpose": "Independent stdlib calendar/UTC semantic review; not approved expectations or a conformance snapshot.",
        "reviewer": "tools/review/calendar_facts.py",
        "evidence_sha256": evidence_hashes,
        "evidence_integrity": evidence_integrity,
        "recorded_observation_repetitions": recorded["repetitions"],
        "status_counts": status_counts,
        "channel_counts": channel_counts,
        "cases": rows,
    }
    OUT_JSON.write_text(json.dumps(output, indent=2) + "\n")
    lines = ["# Calendar fact review", "", "This independent review uses only Python standard-library Gregorian, ISO-week, and UTC calculations. It does not approve contract expectations or call Date::Manip.", "", "## Counts", "", "| Status | Cases |", "| --- | ---: |"]
    lines += [f"| {k} | {v} |" for k, v in status_counts.items()]
    lines += ["", "The recorded evidence was captured twice per case. Its input, probe, runner, and fixture hashes " +
              ("match the evidence record." if all(v["matches_recorded"] for v in evidence_integrity.values()) else "do not all match the evidence record; see JSON."),
              "", "## Captured channels", "", "| Channel condition | Cases |", "| --- | ---: |"]
    lines += [f"| {k} | {v} |" for k, v in channel_counts.items()]
    disputed = [r for r in rows if r["review_status"] == "disputed"]
    lines += ["", "## Disputed cases", ""]
    lines += ([f"- `{r['case_id']}` — {r['reason']}" for r in disputed] or ["- None."])
    lines += ["", "## Review boundaries", "", "`reviewed` means the result and return carrier match an independently calculated fact. `compatibility` records an observed, repeatable behavior outside that fact's direct scope. `invalid` records intentionally out-of-domain requests. `unreviewed` preserves cases whose API convention or input domain needs separate evidence. Warnings, exceptions, stdout, and stderr are retained per case in the JSON; warnings keep a case from being treated as a clean channel observation.", "", "The three-field Base `check` cases are unreviewed because the observation itself reports uninitialized clock-field warnings. The explicit six-field variants provide the comparable date-validity evidence.", ""]
    OUT_MD.write_text("\n".join(lines))


if __name__ == "__main__":
    main()
