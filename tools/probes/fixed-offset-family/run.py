#!/usr/bin/env python3
"""Create an external fixed-offset reachability manifest and observations."""
from __future__ import annotations

import concurrent.futures
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[3]
DATE_LIB = ROOT / "local/date-manip-7.00/lib/perl5"
COVER_LIB = ROOT / "local/devel-cover-1.52/lib/perl5"
PERL = "/usr/bin/perl"
PATH = "/usr/bin:/bin"
SELECTED = {
    "+00:00:00": "FO-SUPPORTED-ZERO",
    "+05:30:00": "FO-SUPPORTED-MINUTES",
    "+05:45:00": "FO-SUPPORTED-45-MIN",
    "+14:00:00": "FO-SUPPORTED-PLUS14",
    "-03:30:00": "FO-SUPPORTED-MINUS30",
    "-14:00:00": "FO-SUPPORTED-MINUS14",
    "+00:06:04": "FO-REJECT-SECONDS",
}


def clean_env(perl5lib: str) -> dict[str, str]:
    return {"PATH": PATH, "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8",
            "TZ": "Etc/UTC", "PERL5LIB": perl5lib}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tree_sha256(directory: Path) -> str:
    digest = hashlib.sha256()
    for path in sorted(item for item in directory.rglob("*") if item.is_file()):
        relative = path.relative_to(directory).as_posix().encode()
        digest.update(len(relative).to_bytes(8, "big"))
        digest.update(relative)
        content = path.read_bytes()
        digest.update(len(content).to_bytes(8, "big"))
        digest.update(content)
    return digest.hexdigest()


def utc_text(offset: str) -> str:
    sign = 1 if offset[0] == "+" else -1
    hour, minute, second = (int(part) for part in offset[1:].split(":"))
    zone = dt.timezone(sign * dt.timedelta(hours=hour, minutes=minute, seconds=second))
    value = dt.datetime(2040, 2, 29, 12, 34, 56, tzinfo=zone).astimezone(dt.timezone.utc)
    return value.strftime("%Y%m%d%H:%M:%S")


def run_case(entry: dict, label: str, output: Path, instrumented: bool, arch: str) -> dict:
    cwd = output / label / "work" / entry["case_id"]
    cwd.mkdir(parents=True, exist_ok=False)
    command = [PERL]
    if instrumented:
        cover_db = output / "cover_db"
        command.append(
            f"-MDevel::Cover=-db,{cover_db},-coverage,statement,branch,-silent,1,-select,{DATE_LIB}/Date/Manip"
        )
        lib = f"{COVER_LIB / arch}:{COVER_LIB}:{DATE_LIB}"
    else:
        lib = str(DATE_LIB)
    command += [str(ROOT / "tools/probes/fixed-offset-family/probe.pl"),
                entry["case_id"], entry["offset"], entry["offset_module"]]
    process = subprocess.run(command, cwd=cwd, env=clean_env(lib), text=True,
                             capture_output=True, timeout=30, check=False)
    if process.returncode or process.stderr:
        raise RuntimeError(f"{label} {entry['case_id']} failed: {process.returncode} {process.stderr!r}")
    record = json.loads(process.stdout)
    validate_record(record, entry, label)
    return record


def run_group(entries: list[dict], label: str, output: Path, instrumented: bool, arch: str) -> list[dict]:
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        futures = [pool.submit(run_case, entry, label, output, instrumented, arch) for entry in entries]
        records = [future.result() for future in futures]
    return sorted(records, key=lambda record: record["case_id"])


def canonical_records(records: list[dict], behavioral_only: bool = False) -> str:
    if behavioral_only:
        records = json.loads(json.dumps(records))
        for record in records:
            result = record["result"]
            for key in ("target_offset_module_loaded_before", "target_offset_module_loaded",
                        "new_offset_modules", "new_offset_module_count", "new_zone_module_count"):
                result.pop(key, None)
    return json.dumps(records, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def validate_record(record: dict, entry: dict, label: str) -> None:
    if (record["case_id"], record["input_offset"], record["target_offset_module"]) != (
            entry["case_id"], entry["offset"], entry["offset_module"]):
        raise RuntimeError(f"{label} request echo differs for {entry['case_id']}")
    if record["exception"] or record["warnings"] or record["call_stdout"]:
        raise RuntimeError(f"{label} {entry['case_id']} emitted {record['exception']!r} {record['warnings']!r}")
    result = record["result"]
    if not result or result["configuration_status"] is not None or result["configuration_error"] != "":
        raise RuntimeError(f"{label} {entry['case_id']} configuration differed")
    if result["target_offset_module_loaded_before"] or not result["target_offset_module_loaded"]:
        raise RuntimeError(f"{label} {entry['case_id']} did not load {entry['offset_module']}")
    if result["new_offset_modules"] != [entry["offset_module"]] or result["new_offset_module_count"] != 1:
        raise RuntimeError(f"{label} {entry['case_id']} new modules were {result['new_offset_modules']!r}")
    if result["error_after_parse"] == "":
        if not result["value_observers_called"] or result["error_after_reads"] != "":
            raise RuntimeError(f"{label} {entry['case_id']} success observer sequence differed")
        expected_utc = utc_text(entry["offset"])
        if result["gmt_scalar"] != expected_utc:
            raise RuntimeError(f"{label} {entry['case_id']} UTC {result['gmt_scalar']} != {expected_utc}")
        record["independent_expected_gmt"] = expected_utc
    else:
        if result["value_observers_called"]:
            raise RuntimeError(f"{label} {entry['case_id']} read a failed date")
        forbidden = {"parsed_scalar", "parsed_list", "gmt_scalar", "gmt_list", "formatted", "error_after_reads"}
        if forbidden.intersection(result):
            raise RuntimeError(f"{label} {entry['case_id']} fabricated skipped observer fields")
        record["independent_expected_gmt"] = None


def load_manifest(output: Path) -> dict:
    manifest_path = output / "offset-manifest.json"
    if not manifest_path.is_file():
        raise SystemExit(f"missing manifest: initialize {output} first")
    manifest = json.loads(manifest_path.read_text())
    if manifest["entry_count"] != 408:
        raise SystemExit("unexpected fixed-offset manifest count")
    return manifest


def check_dependencies() -> str:
    arch = subprocess.check_output([PERL, "-MConfig", "-e", "print $Config::Config{archname}"], text=True).strip()
    cover_arch = COVER_LIB / arch / "Devel/Cover.pm"
    if not (DATE_LIB / "Date/Manip.pm").is_file() or not cover_arch.is_file():
        raise SystemExit("separately installed Date-Manip 7.00 and Devel-Cover 1.52 are required")
    if not re.search(r"\$VERSION\s*=\s*['\"]1\.52['\"]", cover_arch.read_text()):
        raise SystemExit("installed Devel::Cover release is not 1.52")
    return arch


def initialize(output: Path) -> None:
    if output.exists():
        raise SystemExit(f"refusing to merge into existing output directory: {output}")
    output.mkdir(parents=True)
    manifest_process = subprocess.run([PERL, str(ROOT / "tools/probes/fixed-offset-family/manifest.pl")],
                                      env=clean_env(str(DATE_LIB)), cwd=output, text=True,
                                      capture_output=True, check=True)
    if manifest_process.stderr:
        raise SystemExit(manifest_process.stderr)
    manifest = json.loads(manifest_process.stdout)
    if manifest["entry_count"] != 408:
        raise SystemExit("unexpected fixed-offset manifest count")
    (output / "offset-manifest.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")


def observe(output: Path, label: str, arch: str) -> None:
    manifest = load_manifest(output)
    destination = output / f"{label}.json"
    if destination.exists():
        raise SystemExit(f"refusing to replace existing observation: {destination}")
    records = run_group(manifest["entries"], label, output, False, arch)
    destination.write_text(json.dumps(records, indent=2, sort_keys=True) + "\n")


def cover(output: Path, arch: str) -> None:
    manifest = load_manifest(output)
    destination = output / "coverage-observations.json"
    if destination.exists():
        raise SystemExit(f"refusing to replace existing coverage observations: {destination}")
    coverage_work = output / "coverage-run/work"
    coverage_work.mkdir(parents=True, exist_ok=False)
    coverage_command = [PERL, f"-MDevel::Cover=-db,{output / 'cover_db'},-coverage,statement,branch,-silent,1,-select,{DATE_LIB}/Date/Manip",
                        str(ROOT / "tools/probes/fixed-offset-family/coverage_batch.pl"), str(output / "offset-manifest.json")]
    coverage_process = subprocess.run(coverage_command, cwd=coverage_work,
                                      env=clean_env(f"{COVER_LIB / arch}:{COVER_LIB}:{DATE_LIB}"),
                                      text=True, capture_output=True, check=True)
    if coverage_process.stderr:
        raise SystemExit(coverage_process.stderr)
    covered = json.loads(coverage_process.stdout)
    entries = manifest["entries"]
    if len(covered) != len(entries):
        raise SystemExit("coverage batch record count differs")
    entry_by_case = {entry["case_id"]: entry for entry in entries}
    for record in covered:
        entry = entry_by_case.get(record["case_id"])
        if entry is None:
            raise SystemExit(f"coverage batch has unknown case {record['case_id']}")
        validate_record(record, entry, "coverage-run")
    destination.write_text(json.dumps(sorted(covered, key=lambda r: r["case_id"]), indent=2, sort_keys=True) + "\n")
    cover_bin = ROOT / "local/devel-cover-1.52/bin/cover"
    report = subprocess.run([str(cover_bin), "-report", "json", "-outputdir", str(output / "report"),
                             "-coverage", "statement", "-coverage", "branch", str(output / "cover_db")],
                            env=clean_env(f"{COVER_LIB / arch}:{COVER_LIB}"), cwd=ROOT,
                            text=True, capture_output=True, check=True)
    if report.stderr:
        raise SystemExit(report.stderr)


def finalize(output: Path) -> None:
    manifest = load_manifest(output)
    try:
        first = json.loads((output / "run-one.json").read_text())
        second = json.loads((output / "run-two.json").read_text())
        covered = json.loads((output / "coverage-observations.json").read_text())
        coverage = json.loads((output / "report/cover.json").read_text())
    except FileNotFoundError as error:
        raise SystemExit(f"missing required phase output: {error.filename}") from error
    entries = manifest["entries"]
    arch = subprocess.check_output([PERL, "-MConfig", "-e", "print $Config::Config{archname}"], text=True).strip()
    if canonical_records(first) != canonical_records(second):
        raise SystemExit("isolated repeat runs differ")
    if canonical_records(first, behavioral_only=True) != canonical_records(covered, behavioral_only=True):
        raise SystemExit("instrumentation changed fixed-offset records")
    (output / "observations.json").write_text(json.dumps(first, indent=2, sort_keys=True) + "\n")
    selected = []
    by_offset = {record["input_offset"]: record for record in first}
    for offset, example_id in SELECTED.items():
        record = by_offset[offset]
        result = record["result"]
        public_result = {
            "error_after_parse": result["error_after_parse"],
            "value_observers_called": result["value_observers_called"],
        }
        if result["value_observers_called"]:
            for key in ("parsed_scalar", "parsed_list", "gmt_scalar", "gmt_list",
                        "formatted", "error_after_reads"):
                public_result[key] = result[key]
        selected.append({
            "example_id": example_id,
            "input_text": f"2040-02-29 12:34:56 {offset}",
            "public_result": public_result,
            "independent_expected_gmt": record["independent_expected_gmt"],
        })
    selected_record = {
        "schema_version": 1,
        "status": "seven reviewed public observations; excludes the source-derived 408-row module manifest",
        "reference": {"distribution": "Date-Manip", "version": "7.00"},
        "fixture": {
            "constructor": "Date::Manip::Date->new_date(text)",
            "configuration": [["Defaults", 1], ["ForceDate", "2040-02-28-10:20:30,Etc/UTC"],
                              ["Language", "English"], ["Encoding", "ASCII"], ["DateFormat", "non-US"]],
            "format_pattern": "%Y-%m-%d %H:%M:%S %z %Z",
        },
        "full_external_observation_sha256": sha256(output / "observations.json"),
        "observations": selected,
    }
    (output / "selected-observations.json").write_text(json.dumps(selected_record, indent=2) + "\n")

    summary_paths = coverage["summary"]
    missing = []
    target_statement_covered = 0
    target_statement_total = 0
    for entry in entries:
        matches = [(path, values) for path, values in summary_paths.items()
                   if path.endswith(entry["offset_module"])]
        if len(matches) != 1:
            missing.append(entry["offset_module"])
            continue
        statement = matches[0][1].get("statement", {})
        if statement.get("covered") != 9 or statement.get("total") != 9 or statement.get("percentage") != 100:
            raise SystemExit(f"coverage is not 9/9 for {entry['offset_module']}: {statement}")
        target_statement_covered += statement["covered"]
        target_statement_total += statement["total"]
    summary = {
        "schema_version": 1,
        "status": "all fixed-offset entries reached through public parsing; not complete timezone behavior coverage",
        "runtime": {
            "date_manip_version": "7.00",
            "devel_cover_version": "1.52",
            "perl_archname": arch,
            "environment": {"PATH": PATH, "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8", "TZ": "Etc/UTC", "PERL5LIB": "profile-specific only"},
        },
        "entry_count": len(entries),
        "repeatable_runs": 2,
        "coverage_run_records_identical": True,
        "target_offset_module_rows": len(entries) - len(missing),
        "missing_target_offset_module_rows": missing,
        "target_offset_statement_coverage": {
            "covered": target_statement_covered,
            "total": target_statement_total,
            "per_module_covered": 9,
            "per_module_total": 9,
        },
        "successful_parse_count": sum(record["result"]["error_after_parse"] == "" for record in first),
        "rejected_parse_count": sum(record["result"]["error_after_parse"] != "" for record in first),
        "rejected_parse_errors": sorted({record["result"]["error_after_parse"] for record in first if record["result"]["error_after_parse"]}),
        "artifact_sha256": {
            "offset-manifest.json": sha256(output / "offset-manifest.json"),
            "run-one.json": sha256(output / "run-one.json"),
            "run-two.json": sha256(output / "run-two.json"),
            "observations.json": sha256(output / "observations.json"),
            "coverage-observations.json": sha256(output / "coverage-observations.json"),
            "report/cover.json": sha256(output / "report/cover.json"),
            "selected-observations.json": sha256(output / "selected-observations.json"),
            "cover_db_tree": tree_sha256(output / "cover_db"),
        },
        "source_hashes": {
            "Date/Manip.pm": sha256(DATE_LIB / "Date/Manip.pm"),
            "Date/Manip/Zones.pm": sha256(DATE_LIB / "Date/Manip/Zones.pm"),
            "Date/Manip/Date.pm": sha256(DATE_LIB / "Date/Manip/Date.pm"),
            "Devel/Cover.pm": sha256(COVER_LIB / arch / "Devel/Cover.pm"),
            "manifest.pl": sha256(ROOT / "tools/probes/fixed-offset-family/manifest.pl"),
            "probe.pl": sha256(ROOT / "tools/probes/fixed-offset-family/probe.pl"),
            "coverage_batch.pl": sha256(ROOT / "tools/probes/fixed-offset-family/coverage_batch.pl"),
            "run.py": sha256(Path(__file__)),
        },
    }
    if missing:
        raise SystemExit(f"coverage lacks {len(missing)} target offset rows")
    (output / "summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")


def main() -> int:
    if len(sys.argv) != 3:
        raise SystemExit(f"usage: {sys.argv[0]} OUTPUT_DIRECTORY initialize|run-one|run-two|coverage|finalize")
    output = Path(sys.argv[1]).resolve()
    phase = sys.argv[2]
    if phase == "initialize":
        check_dependencies()
        initialize(output)
    elif phase in {"run-one", "run-two"}:
        observe(output, phase, check_dependencies())
    elif phase == "coverage":
        cover(output, check_dependencies())
    elif phase == "finalize":
        finalize(output)
    else:
        raise SystemExit(f"unknown phase: {phase}")
    print(f"fixed-offset {phase} completed in {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
