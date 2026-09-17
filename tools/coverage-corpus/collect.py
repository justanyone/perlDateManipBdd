#!/usr/bin/env python3
"""Public-probe coverage diagnostic with isolated plain and covered processes."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import os
from pathlib import Path
import shutil
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

ROOT = Path(__file__).resolve().parents[2]
DATE_LIB = ROOT / "local/date-manip-7.00/lib/perl5"
COVER_LIB = ROOT / "local/devel-cover-1.52/lib/perl5"
PERL = "/usr/bin/perl"
PATH = "/usr/bin:/bin"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def env(perl5lib: str) -> dict[str, str]:
    return {"PATH": PATH, "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8", "TZ": "Etc/UTC", "PERL5LIB": perl5lib}


def run(command: list[str], cwd: Path, run_env: dict[str, str]) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(command, cwd=cwd, env=run_env, capture_output=True, timeout=30, check=False)


def source_files(module_root: Path) -> list[Path]:
    return sorted(path.resolve() for path in module_root.rglob("*.pm"))


def totals(summary: dict, paths: set[str]) -> tuple[dict, list[str]]:
    loaded = [path for path in summary if path != "Total" and str(Path(path).resolve()) in paths]
    answer = {}
    for kind in ("statement", "branch"):
        row = {field: 0 for field in ("covered", "error", "uncoverable", "total")}
        for path in loaded:
            item = summary[path].get(kind, {})
            for field in row:
                value = item.get(field, 0)
                if not isinstance(value, int) or value < 0:
                    raise RuntimeError(f"invalid {kind} count in {path}")
                row[field] += value
        if row["total"] != row["covered"] + row["error"] + row["uncoverable"]:
            raise RuntimeError(f"inconsistent {kind} denominator")
        effective = row["covered"] + row["error"]
        row["raw_percentage"] = 100 * row["covered"] / row["total"] if row["total"] else None
        row["tool_effective_denominator"] = effective
        row["tool_effective_percentage"] = 100 * row["covered"] / effective if effective else None
        answer[kind] = row
    return answer, loaded


DEPRECATION = "Date::Manip::DM5 is deprecated and will be removed from the Date::Manip package starting in version 7.00"

def normalize_deprecation_sites(value):
    """Only DM5's known module-load warning may lose its dynamic eval location."""
    if isinstance(value, list):
        return [normalize_deprecation_sites(item) for item in value]
    if not isinstance(value, dict):
        return value
    answer = {}
    for key, item in value.items():
        if key in ("warnings", "load_warnings", "configuration_warnings") and isinstance(item, list):
            answer[key] = [re.sub(r"at \(eval \d+\)(?:\[[^\]\n]+\])?(?= line \d+\.\n?$)",
                                 "at (eval LOCATION)", warning)
                           if isinstance(warning, str) and warning.startswith(DEPRECATION + " at ")
                           else warning for warning in item]
        else:
            answer[key] = normalize_deprecation_sites(item)
    return answer


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--normalize-dm5-deprecation-sites", action="store_true",
                        help="report and compare DM5 load warnings without dynamic eval-site attribution")
    args = parser.parse_args()
    manifest_path = args.manifest.resolve()
    output = args.output.resolve()
    if output.exists():
        raise SystemExit(f"refusing existing output: {output}")
    manifest = json.loads(manifest_path.read_text())
    if manifest.get("schema_version") != 1 or not manifest.get("families"):
        raise SystemExit("invalid explicit manifest")
    arch = subprocess.check_output([PERL, "-MConfig", "-e", "print $Config::Config{archname}"], text=True).strip()
    cover_arch = COVER_LIB / arch
    cover_module = cover_arch / "Devel/Cover.pm"
    cover_bin = ROOT / "local/devel-cover-1.52/bin/cover"
    if not (DATE_LIB / "Date/Manip.pm").is_file() or not cover_module.is_file() or not cover_bin.is_file():
        raise SystemExit("missing pinned local Date-Manip 7.00 or Devel-Cover 1.52")
    if not re.search(r"\$VERSION\s*=\s*['\"]1\.52['\"]", cover_module.read_text()):
        raise SystemExit("installed Devel::Cover is not 1.52")
    if not re.search(r"\$VERSION\s*=\s*['\"]7\.00['\"]", (DATE_LIB / "Date/Manip.pm").read_text()):
        raise SystemExit("installed Date-Manip is not 7.00")
    output.mkdir(parents=True)
    cases = []
    for family in manifest["families"]:
        probe = (ROOT / family["probe"]).resolve()
        if not probe.is_file() or not family.get("case_ids"):
            raise SystemExit(f"invalid family entry: {family}")
        cases.extend((family["name"], probe, case_id) for case_id in family["case_ids"])
    if len(cases) != len({(probe, case) for _, probe, case in cases}):
        raise SystemExit("duplicate probe/case pair")
    def collect_one(item: tuple[int, tuple[str, Path, str]]) -> tuple[dict, Path]:
        index, (family, probe, case_id) = item
        label = f"{index:02d}-{family}-{case_id}"
        plain_work = output / "work" / label / "plain"
        covered_work = output / "work" / label / "covered"
        plain_work.mkdir(parents=True)
        covered_work.mkdir(parents=True)
        plain = run([PERL, str(probe), case_id], plain_work, env(str(DATE_LIB)))
        database = output / "db" / label
        database.parent.mkdir(parents=True, exist_ok=True)
        covered = run([PERL, f"-MDevel::Cover=-db,{database},-coverage,statement,branch,-silent,1,-select,{DATE_LIB}/Date/Manip", str(probe), case_id], covered_work, env(f"{cover_arch}:{COVER_LIB}:{DATE_LIB}"))
        for name, process in (("plain", plain), ("covered", covered)):
            (output / "work" / label / (name + ".stdout")).write_bytes(process.stdout)
            (output / "work" / label / (name + ".stderr")).write_bytes(process.stderr)
        raw_equal = plain.stdout == covered.stdout
        normalized_equal = False
        if args.normalize_dm5_deprecation_sites and not raw_equal:
            normalized_equal = normalize_deprecation_sites(json.loads(plain.stdout)) == normalize_deprecation_sites(json.loads(covered.stdout))
        if plain.returncode or covered.returncode or not (raw_equal or normalized_equal) or plain.stderr != covered.stderr:
            raise RuntimeError(f"fidelity failure {label}: plain={plain.returncode}, covered={covered.returncode}")
        json.loads(plain.stdout)
        return {"stdout_byte_identical": raw_equal, "comparison_adjustment": None if raw_equal else "DM5 deprecation dynamic eval site only", "family": family, "case_id": case_id, "probe": str(probe.relative_to(ROOT)), "plain_stdout_sha256": hashlib.sha256(plain.stdout).hexdigest(), "covered_stdout_sha256": hashlib.sha256(covered.stdout).hexdigest(), "stderr_sha256": hashlib.sha256(plain.stderr).hexdigest(), "process_stderr": plain.stderr.decode("utf-8", "surrogateescape")}, database
    with ThreadPoolExecutor(max_workers=4) as pool:
        collected = list(pool.map(collect_one, enumerate(cases)))
    fidelity = [item[0] for item in collected]
    dbs = [item[1] for item in collected]
    merged = output / "merged_db"
    report = output / "report"
    report_process = run([str(cover_bin), "-write", str(merged), "-report", "json", "-outputdir", str(report), "-coverage", "statement", "-coverage", "branch", *map(str, dbs)], output, env(f"{cover_arch}:{COVER_LIB}"))
    if report_process.returncode:
        raise RuntimeError(report_process.stderr.decode("utf-8", "surrogateescape"))
    cover_json = json.loads((report / "cover.json").read_text())
    module_root = DATE_LIB / "Date"
    files = source_files(module_root)
    file_paths = {str(path) for path in files}
    coverage_totals, loaded_paths = totals(cover_json["summary"], file_paths)
    loaded_set = {str(Path(path).resolve()) for path in loaded_paths}
    unloaded = [str(path.relative_to(module_root)) for path in files if str(path) not in loaded_set]
    ranked = []
    for path in loaded_paths:
        data = cover_json["summary"][path]
        branch = data.get("branch", {})
        if branch.get("error", 0):
            ranked.append({"file": str(Path(path).resolve().relative_to(module_root)), "uncovered_branch_criteria": branch["error"], "branch_total": branch.get("total", 0)})
    ranked.sort(key=lambda item: (-item["uncovered_branch_criteria"], item["file"]))
    summary = {
        "schema_version": 1,
        "status": "bounded public-probe coverage diagnostic; not a full suite or completion claim",
        "manifest": str(manifest_path.relative_to(ROOT)), "case_count": len(cases),
        "coverage_tool": {"name": "Devel::Cover", "version": "1.52", "criteria": ["statement", "branch"]},
        "runtime": {"date_manip_version": "7.00", "perl_archname": arch, "environment": {**env("profile-specific only"), "inherited_environment": False}},
        "hashes": {str(path.relative_to(ROOT)): digest(path) for path in [manifest_path, Path(__file__).resolve(), *sorted({probe for _, probe, _ in cases}), DATE_LIB / "Date/Manip.pm", cover_module]},
        "fidelity": fidelity,
        "fidelity_policy": {"normalize_dm5_deprecation_sites": args.normalize_dm5_deprecation_sites, "raw_stdout_different_cases": sum(not row["stdout_byte_identical"] for row in fidelity), "raw_outputs_retained": True},
        "source_inventory": {"file_count": len(files), "loaded_file_count": len(loaded_paths), "loaded_files": [str(Path(path).resolve().relative_to(module_root)) for path in sorted(loaded_paths)], "unloaded_file_count": len(unloaded), "unloaded_files": unloaded, "denominator_note": "Unloaded source files have no Devel::Cover criterion rows and are listed rather than manufactured as zero rows."},
        "date_manip_only_totals": coverage_totals,
        "uncovered_branch_modules": ranked[:20],
        "actionable_uncovered_locations": [
            {"file": "Manip/Date.pm", "line": 97, "public_operation": "parse", "public-domain suggestion": "expand parser option, language, prefix, and invalid-token public cases"},
            {"file": "Manip/Date.pm", "line": 2719, "public_operation": "set", "public-domain suggestion": "expand field-name, value-shape, receiver-state, and DST-selector public cases"},
            {"file": "Manip/TZ.pm", "line": 861, "public_operation": "zone", "public-domain suggestion": "add named zone, alias, abbreviation, fixed-offset, and invalid-resolution public calls"},
            {"file": "Manip/TZ.pm", "line": 1197, "public_operation": "all_periods", "public-domain suggestion": "add public period enumeration across stable, transition, historical, and invalid zone/year inputs"},
            {"file": "Manip/Base.pm", "line": 273, "public_operation": "config", "public-domain suggestion": "add independent configuration profiles and invalid-setting public calls"},
            {"file": "Manip/Obj.pm", "line": 31, "public_operation": "new", "public-domain suggestion": "add constructor, receiver-cloning, and configuration-option public cases"},
        ],
        "upstream_annotations": {kind: coverage_totals[kind]["uncoverable"] for kind in coverage_totals},
        "next_public_domains": ["date field replacement: invalid shapes, receiver states, and DST selectors", "completeness: truncated and invalid receiver states", "partial parsing: parser gates, empty input, and date/time token variants"],
        "external_artifacts": {"merged_database": str(merged), "cover_json": str(report / "cover.json")},
    }
    (output / "summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")
    print(f"coverage corpus diagnostic written to {output}")


if __name__ == "__main__":
    main()
