#!/usr/bin/env python3
"""Build or verify the public behavior-partition gap ledger.

The ledger deliberately separates a recorded call from proof that a whole
contract partition is fulfilled.  It uses only structured partition links as
partition-level evidence; operation identifiers alone remain operation-level
evidence.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "docs/research/behavior-gap-ledger/ledger.json"
CONTRACT_FILES = (
    ROOT / "docs/research/contracts/arithmetic.json",
    ROOT / "docs/research/contracts/calendar.json",
    ROOT / "docs/research/contracts/recurrence.json",
    ROOT / "docs/research/contracts/values.json",
    ROOT / "docs/research/contracts/zones-business.json",
)
EXCLUDED_PARTS = {
    "docs/research/api",
    "docs/research/contracts",
    "docs/research/inputs",
    "docs/research/syntax",
    "docs/research/behavior-gap-ledger",
}
PRIMARY_OPERATION_KEYS = (
    "operation_id", "primary_operation", "portable_operation_id", "operation",
)
OPERATION_LIST_KEYS = (
    "contract_ids", "contracts", "operations", "operation_ids",
    "public_operation_ids", "also_operation_ids",
)


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def git_provenance(paths: list[Path]) -> dict[str, str]:
    def names(args):
        result = subprocess.run(
            ["git", *args], cwd=ROOT, check=True, capture_output=True, text=True
        )
        return {line for line in result.stdout.splitlines() if line}

    tracked = names(["ls-files"])
    modified = names(["diff", "--name-only"])
    staged = names(["diff", "--cached", "--name-only"])
    states = {}
    for path in paths:
        name = rel(path)
        if name in staged:
            states[name] = "pending-staged"
        elif name in modified:
            states[name] = "pending-modified"
        elif name in tracked:
            states[name] = "committed-clean"
        else:
            states[name] = "pending-untracked"
    return states


def git_head() -> str:
    return subprocess.run(
        ["git", "rev-parse", "HEAD"], cwd=ROOT, check=True,
        capture_output=True, text=True,
    ).stdout.strip()


def git_paths(head: str) -> list[Path]:
    result = subprocess.run(
        ["git", "ls-tree", "-r", "--name-only", head], cwd=ROOT, check=True,
        capture_output=True, text=True,
    )
    return [ROOT / name for name in result.stdout.splitlines() if name]


def git_blob(head: str, path: Path) -> bytes:
    return subprocess.run(
        ["git", "show", f"{head}:{rel(path)}"], cwd=ROOT, check=True,
        capture_output=True,
    ).stdout


def load_text(text: str):
    return json.loads(text)


def is_excluded(path: Path) -> bool:
    value = rel(path)
    return any(value == part or value.startswith(part + "/") for part in EXCLUDED_PARTS)


def line_ref(path: Path, token: str, text: str) -> str:
    lines = text.splitlines()
    for number, line in enumerate(lines, 1):
        if contains_identifier(line, token):
            return f"{rel(path)}:{number}"
    return rel(path)


def contains_identifier(text: str, token: str) -> bool:
    return re.search(
        rf"(?<![A-Za-z0-9_.-]){re.escape(token)}(?![A-Za-z0-9_.-])", text
    ) is not None


def strings(value):
    if isinstance(value, str):
        yield value
    elif isinstance(value, list):
        for item in value:
            yield from strings(item)
    elif isinstance(value, dict):
        for item in value.values():
            yield from strings(item)


def case_ids_in(node: dict) -> set[str]:
    result: set[str] = set()
    for key in ("case_id", "reference_case", "source_case_id", "observation_case"):
        value = node.get(key)
        if isinstance(value, str):
            result.add(value)
    for key in ("case_ids", "reference_case_ids", "cases"):
        value = node.get(key)
        if isinstance(value, list) and all(isinstance(item, str) for item in value):
            result.update(value)
    return result


def primary_operation_ids_in(node: dict, known_ops: set[str]) -> set[str]:
    result: set[str] = set()
    for key in PRIMARY_OPERATION_KEYS:
        value = node.get(key)
        if isinstance(value, str) and value in known_ops:
            result.add(value)
    return result


def operation_ids_in(node: dict, known_ops: set[str]) -> set[str]:
    result = primary_operation_ids_in(node, known_ops)
    for key in OPERATION_LIST_KEYS:
        value = node.get(key)
        if isinstance(value, list):
            result.update(item for item in value if isinstance(item, str) and item in known_ops)
    return result


def partition_ids_in(node: dict, known_parts: set[str]) -> set[str]:
    result: set[str] = set()
    for key in ("partition_id", "partition_ids", "partitions"):
        value = node.get(key)
        if isinstance(value, str) and value in known_parts:
            result.add(value)
        elif isinstance(value, list):
            result.update(item for item in value if isinstance(item, str) and item in known_parts)
    return result


def walk_records(
    value, known_ops: set[str], known_parts: set[str],
    inherited_ops=frozenset(), inherited_primary=frozenset(),
):
    """Yield structured case and partition records with conservative operation scope."""
    if isinstance(value, dict):
        local_ops = operation_ids_in(value, known_ops)
        local_primary = primary_operation_ids_in(value, known_ops)
        # A top-level primary operation is safe context for child case records.
        context_ops = local_ops or set(inherited_ops)
        context_primary = local_primary or set(inherited_primary)
        cases = case_ids_in(value)
        parts = partition_ids_in(value, known_parts)
        if cases or parts:
            yield {
                "operations": sorted(context_ops),
                "primary_operations": sorted(context_primary),
                "case_ids": sorted(cases),
                "partition_ids": sorted(parts),
            }
        for key, child in value.items():
            child_inherited = context_ops if key in {
                "cases", "case_map", "case_mappings", "mappings", "examples",
                "feature_cases", "groups", "features",
            } else set(inherited_ops)
            child_primary = context_primary if key in {
                "cases", "case_map", "case_mappings", "mappings", "examples",
                "feature_cases", "groups", "features",
            } else set(inherited_primary)
            yield from walk_records(
                child, known_ops, known_parts, frozenset(child_inherited),
                frozenset(child_primary),
            )
    elif isinstance(value, list):
        for child in value:
            yield from walk_records(
                child, known_ops, known_parts, inherited_ops, inherited_primary
            )


def evidence_kind(path: Path) -> str:
    name = path.name.lower()
    value = rel(path)
    if "observ" in name or "/observations/" in value or name.endswith("-result.json") or name == "result.json":
        return "observation"
    if "map" in name or "coverage" in name:
        return "feature-map-or-coverage"
    if "case" in name or "fixture" in name:
        return "case-fixture"
    if "binding" in name or "inventory" in name:
        return "binding-map"
    return "research-json"


def priority(evidence_state: str, feature_state: str) -> tuple[int, str]:
    if evidence_state in {
        "no-observed-operation-evidence",
        "supporting-operation-observed-partition-unlinked",
        "direct-partition-link-without-observation",
        "operation-planned-only",
        "pending-workspace-evidence-only",
    }:
        return 0, "P0-establish-committed-primary-evidence"
    if evidence_state != "direct-partition-observation":
        return 1, "P1-link-and-observe-partition"
    if feature_state not in {"direct-feature-case", "direct-feature-map-case"}:
        return 2, "P2-author-feature-for-observed-partition"
    return 3, "P3-review-composite-partition-for-fulfillment"


def build(snapshot_commit: str | None = None) -> dict:
    snapshot_commit = snapshot_commit or git_head()
    committed_paths = git_paths(snapshot_commit)
    committed_blobs = {
        path: git_blob(snapshot_commit, path)
        for path in committed_paths
        if path in CONTRACT_FILES
        or (
            rel(path).startswith(("docs/research/", "spec/drafts/"))
            and path.suffix in {".json", ".md", ".feature"}
        )
    }
    committed_text = {
        path: value.decode("utf-8", errors="replace")
        for path, value in committed_blobs.items()
    }
    contracts = []
    known_ops: set[str] = set()
    obligation_by_pair = {}
    partition_to_ops: dict[str, set[str]] = {}
    for path in CONTRACT_FILES:
        data = load_text(committed_text[path])
        family = data.get("family") or path.stem
        for op_index, operation in enumerate(data.get("operations", [])):
            op_id = operation["operation_id"]
            known_ops.add(op_id)
            for part_index, part in enumerate(operation.get("partitions", [])):
                key = (op_id, part["id"])
                item = {
                    "obligation_id": f"{path.stem}:{op_id}:{part['id']}",
                    "contract_family": family,
                    "contract_file": rel(path),
                    "operation_id": op_id,
                    "partition_id": part["id"],
                    "description": part.get("description", ""),
                    "contract_status": part.get("status"),
                    "completion_evidence": part.get("completion_evidence") or part.get("review_evidence"),
                    "operation_order": op_index,
                    "partition_order": part_index,
                    "binding_count": len(operation.get("bindings", [])),
                }
                contracts.append(item)
                obligation_by_pair[key] = item
                partition_to_ops.setdefault(part["id"], set()).add(op_id)
    known_parts = set(partition_to_ops)

    candidate_json = sorted(
        path for path in committed_paths
        if rel(path).startswith("docs/research/")
        and path.suffix == ".json" and not is_excluded(path)
    )
    candidate_features = sorted(
        path for path in committed_paths
        if rel(path).startswith("spec/drafts/") and path.suffix == ".feature"
    )
    candidate_notes = sorted(
        path for path in committed_paths
        if rel(path).startswith("docs/research/")
        and path.suffix == ".md" and not is_excluded(path)
        and (path.name == "README.md" or "remaining" in path.name.lower())
    )
    workspace_state = git_provenance(
        list(CONTRACT_FILES) + candidate_json + candidate_features + candidate_notes
    )
    # Every included byte comes from one fixed commit. Pending worktree versions
    # and untracked files cannot alter the queue.
    research_json = candidate_json
    feature_files = candidate_features
    note_files = candidate_notes
    json_text = {path: committed_text[path] for path in research_json}
    feature_text = {path: committed_text[path] for path in feature_files}
    note_text = {path: committed_text[path] for path in note_files}
    provenance = {
        rel(path): "committed-head"
        for path in list(CONTRACT_FILES) + research_json + feature_files + note_files
    }

    case_ops: dict[str, set[str]] = {}
    case_primary_ops: dict[str, set[str]] = {}
    case_op_sources: dict[str, dict[str, set[str]]] = {}
    case_primary_sources: dict[str, dict[str, set[str]]] = {}
    direct_records: dict[tuple[str, str], list[dict]] = {}
    for path in research_json:
        try:
            data = load_text(json_text[path])
        except json.JSONDecodeError:
            continue
        for record in walk_records(data, known_ops, known_parts):
            operations = set(record["operations"])
            case_ids = set(record["case_ids"])
            for case_id in case_ids:
                case_ops.setdefault(case_id, set()).update(operations)
                case_primary_ops.setdefault(case_id, set()).update(record["primary_operations"])
                for op_id in operations:
                    case_op_sources.setdefault(case_id, {}).setdefault(op_id, set()).add(
                        provenance[rel(path)]
                    )
                for op_id in record["primary_operations"]:
                    case_primary_sources.setdefault(case_id, {}).setdefault(op_id, set()).add(
                        provenance[rel(path)]
                    )
            for part_id in record["partition_ids"]:
                possible_ops = operations & partition_to_ops.get(part_id, set())
                # Full arithmetic/recurrence IDs also carry their operation prefix.
                if not possible_ops:
                    possible_ops = {
                        op for op in partition_to_ops.get(part_id, set())
                        if part_id.startswith(op + ".")
                    }
                for op_id in possible_ops:
                    direct_records.setdefault((op_id, part_id), []).append({
                        "path": rel(path),
                        "kind": evidence_kind(path),
                        "provenance": provenance[rel(path)],
                        "case_ids": sorted(case_ids),
                        "reference": line_ref(path, part_id, json_text[path]),
                    })

    # A case can learn its operation from another map or fixture with the same ID.
    all_case_ids = sorted(case_ops)
    observed_paths = [path for path in research_json if evidence_kind(path) == "observation"]
    map_paths = [path for path in research_json if evidence_kind(path) == "feature-map-or-coverage"]
    case_observations: dict[str, list[str]] = {}
    case_committed_observations: dict[str, list[str]] = {}
    case_maps: dict[str, list[str]] = {}
    case_committed_maps: dict[str, list[str]] = {}
    case_features: dict[str, list[str]] = {}
    case_committed_features: dict[str, list[str]] = {}
    for case_id in all_case_ids:
        observation_ids = [case_id]
        if ":" in case_id:
            observation_ids.append(case_id.split(":", 1)[0])
        if ";" in case_id:
            observation_ids.extend(part.strip() for part in case_id.split(";") if part.strip())
        quoted_ids = [json.dumps(value) for value in observation_ids]
        case_observations[case_id] = [
            rel(path) for path in observed_paths
            if any(quoted in json_text[path] for quoted in quoted_ids)
        ]
        case_committed_observations[case_id] = [
            path for path in case_observations[case_id]
            if provenance[path] == "committed-head"
        ]
        quoted = json.dumps(case_id)
        case_maps[case_id] = [rel(path) for path in map_paths if quoted in json_text[path]]
        case_committed_maps[case_id] = [
            path for path in case_maps[case_id] if provenance[path] == "committed-head"
        ]
        case_features[case_id] = [rel(path) for path, text in feature_text.items() if case_id in text]
        case_committed_features[case_id] = [
            path for path in case_features[case_id] if provenance[path] == "committed-head"
        ]

    operation_cases: dict[str, set[str]] = {op: set() for op in known_ops}
    operation_primary_cases: dict[str, set[str]] = {op: set() for op in known_ops}
    for case_id, ops in case_ops.items():
        for op_id in ops:
            operation_cases[op_id].add(case_id)
    for case_id, ops in case_primary_ops.items():
        for op_id in ops:
            operation_primary_cases[op_id].add(case_id)

    operation_evidence = {}
    for op_id in sorted(known_ops):
        cases = sorted(operation_cases[op_id])
        primary_cases = sorted(operation_primary_cases[op_id])
        observed_cases = [case for case in cases if case_observations.get(case)]
        observed_primary_cases = [case for case in primary_cases if case_observations.get(case)]
        committed_observed_cases = [
            case for case in cases
            if case_committed_observations.get(case)
            and "committed-head" in case_op_sources.get(case, {}).get(op_id, set())
        ]
        committed_observed_primary_cases = [
            case for case in primary_cases
            if case_committed_observations.get(case)
            and "committed-head" in case_primary_sources.get(case, {}).get(op_id, set())
        ]
        mapped_cases = [case for case in cases if case_maps.get(case) or case_features.get(case)]
        committed_mapped_cases = [
            case for case in cases
            if (case_committed_maps.get(case) or case_committed_features.get(case))
            and "committed-head" in case_op_sources.get(case, {}).get(op_id, set())
        ]
        exact_observation_refs = [
            line_ref(path, op_id, json_text[path])
            for path in observed_paths if json.dumps(op_id) in json_text[path]
        ]
        exact_map_refs = [
            line_ref(path, op_id, json_text[path])
            for path in map_paths if json.dumps(op_id) in json_text[path]
        ]
        operation_evidence[op_id] = {
            "known_case_count": len(cases),
            "known_primary_case_count": len(primary_cases),
            "observed_case_count": len(observed_cases),
            "observed_primary_case_count": len(observed_primary_cases),
            "committed_observed_case_count": len(committed_observed_cases),
            "committed_observed_primary_case_count": len(committed_observed_primary_cases),
            "mapped_or_feature_case_count": len(mapped_cases),
            "committed_mapped_or_feature_case_count": len(committed_mapped_cases),
            "observed_case_ids": observed_cases,
            "observed_primary_case_ids": observed_primary_cases,
            "committed_observed_case_ids": committed_observed_cases,
            "committed_observed_primary_case_ids": committed_observed_primary_cases,
            "mapped_or_feature_case_ids": mapped_cases,
            "committed_mapped_or_feature_case_ids": committed_mapped_cases,
            "observation_references": sorted(set(exact_observation_refs + [
                ref for case in observed_cases for ref in case_observations[case]
            ])),
            "committed_observation_references": sorted(set(
                [ref for ref in exact_observation_refs if provenance[ref.split(":", 1)[0]] == "committed-head"]
                + [ref for case in committed_observed_cases for ref in case_committed_observations[case]]
            )),
            "pending_observation_references": sorted(set(
                [ref for ref in exact_observation_refs if provenance[ref.split(":", 1)[0]] != "committed-head"]
                + [ref for case in observed_cases for ref in case_observations[case]
                   if provenance[ref] != "committed-head"]
            )),
            "feature_map_references": sorted(set(exact_map_refs + [
                ref for case in mapped_cases for ref in case_maps.get(case, [])
            ])),
            "feature_references": sorted(set(
                ref for case in mapped_cases for ref in case_features.get(case, [])
            )),
        }

    obligations = []
    for base in contracts:
        op_id = base["operation_id"]
        part_id = base["partition_id"]
        direct = direct_records.get((op_id, part_id), [])
        direct_cases = sorted({case for record in direct for case in record["case_ids"]})
        committed_direct_cases = sorted({
            case for record in direct if record["provenance"] == "committed-head"
            for case in record["case_ids"]
        })
        workspace_observed_direct = [case for case in direct_cases if case_observations.get(case)]
        observed_direct = [
            case for case in committed_direct_cases if case_committed_observations.get(case)
        ]
        workspace_mapped_direct = [
            case for case in direct_cases if case_maps.get(case) or case_features.get(case)
        ]
        mapped_direct = [
            case for case in committed_direct_cases
            if case_committed_maps.get(case) or case_committed_features.get(case)
        ]
        op_evidence = operation_evidence[op_id]
        if workspace_observed_direct:
            workspace_evidence_state = "direct-partition-observation"
        elif direct_cases:
            workspace_evidence_state = "direct-partition-link-without-observation"
        elif op_evidence["observed_primary_case_count"]:
            workspace_evidence_state = "primary-operation-observed-partition-unlinked"
        elif op_evidence["observed_case_count"] or op_evidence["observation_references"]:
            workspace_evidence_state = "supporting-operation-observed-partition-unlinked"
        elif op_evidence["known_case_count"]:
            workspace_evidence_state = "operation-planned-only"
        else:
            workspace_evidence_state = "no-observed-operation-evidence"
        if observed_direct:
            evidence_state = "direct-partition-observation"
        elif committed_direct_cases:
            evidence_state = "direct-partition-link-without-observation"
        elif op_evidence["committed_observed_primary_case_count"]:
            evidence_state = "primary-operation-observed-partition-unlinked"
        elif op_evidence["committed_observed_case_count"] or op_evidence["committed_observation_references"]:
            evidence_state = "supporting-operation-observed-partition-unlinked"
        elif op_evidence["observed_case_count"] or workspace_observed_direct:
            evidence_state = "pending-workspace-evidence-only"
        else:
            evidence_state = "no-observed-operation-evidence"
        if any(case_committed_features.get(case) for case in mapped_direct):
            feature_state = "direct-feature-case"
        elif mapped_direct:
            feature_state = "direct-feature-map-case"
        elif op_evidence["committed_mapped_or_feature_case_count"]:
            feature_state = "operation-feature-evidence-only"
        elif workspace_mapped_direct or op_evidence["mapped_or_feature_case_count"]:
            feature_state = "pending-workspace-feature-evidence-only"
        else:
            feature_state = "no-feature-case-link"
        rank, label = priority(evidence_state, feature_state)
        explicitly_fulfilled = (
            base["contract_status"] in {"fulfilled", "complete", "reviewed-complete"}
            and bool(base["completion_evidence"])
        )
        if explicitly_fulfilled:
            rank, label = 9, "resolved"
        specific_notes = []
        for path, text in note_text.items():
            part_is_namespaced = part_id.startswith(op_id + ".")
            if part_is_namespaced and contains_identifier(text, part_id):
                token = part_id
                specific_notes.append(line_ref(path, token, text))
            elif contains_identifier(text, op_id):
                token = op_id
                specific_notes.append(line_ref(path, token, text))
        obligations.append({
            **{key: value for key, value in base.items() if not key.endswith("_order")},
            "resolution_status": "fulfilled" if explicitly_fulfilled else "unresolved",
            "evidence_state": evidence_state,
            "feature_state": feature_state,
            "priority": label,
            "priority_rank": rank,
            "direct_case_ids": direct_cases,
            "committed_direct_case_ids": committed_direct_cases,
            "observed_direct_case_ids": observed_direct,
            "mapped_direct_case_ids": mapped_direct,
            "direct_evidence_references": sorted({record["reference"] for record in direct}),
            "direct_evidence_provenance": sorted({
                f"{record['reference']} [{record['provenance']}]" for record in direct
            }),
            "operation_evidence": {
                "observed_case_count": op_evidence["observed_case_count"],
                "observed_primary_case_count": op_evidence["observed_primary_case_count"],
                "committed_observed_case_count": op_evidence["committed_observed_case_count"],
                "committed_observed_primary_case_count": op_evidence["committed_observed_primary_case_count"],
                "mapped_or_feature_case_count": op_evidence["mapped_or_feature_case_count"],
                "committed_mapped_or_feature_case_count": op_evidence["committed_mapped_or_feature_case_count"],
                "observation_references": op_evidence["observation_references"][:12],
                "feature_map_references": op_evidence["feature_map_references"][:12],
                "feature_references": op_evidence["feature_references"][:12],
            },
            "remaining_note_references": sorted(set(specific_notes)),
            "next_action": None if explicitly_fulfilled else (
                "Exercise and map this exact partition through every applicable public binding: "
                + base["description"]
            ),
            "non_completion_reason": None if explicitly_fulfilled else (
                "No reviewed source explicitly discharges the full partition domain. "
                "A case, operation ID, or direct partition link is evidence present, not fulfillment."
            ),
        })

    queue = []
    for op_id in sorted(known_ops):
        all_rows = [row for row in obligations if row["operation_id"] == op_id]
        rows = [row for row in all_rows if row["resolution_status"] == "unresolved"]
        if not rows:
            continue
        worst = min(row["priority_rank"] for row in rows)
        queue.append({
            "operation_id": op_id,
            "contract_family": rows[0]["contract_family"],
            "priority": next(row["priority"] for row in rows if row["priority_rank"] == worst),
            "partition_count": len(all_rows),
            "unresolved_count": len(rows),
            "without_direct_observation_count": sum(
                row["evidence_state"] != "direct-partition-observation" for row in rows
            ),
            "without_direct_feature_link_count": sum(
                row["feature_state"] not in {"direct-feature-case", "direct-feature-map-case"}
                for row in rows
            ),
            "next_partition_ids": [
                row["partition_id"] for row in rows
                if row["priority_rank"] == worst
            ],
        })
    queue.sort(key=lambda row: (
        int(row["priority"].split("-")[0][1:]),
        -row["without_direct_observation_count"],
        row["operation_id"],
    ))

    summary = {
        "obligation_count": len(obligations),
        "operation_count": len(known_ops),
        "resolution_status_counts": {},
        "evidence_state_counts": {},
        "feature_state_counts": {},
        "priority_counts": {},
        "family_counts": {},
    }
    for row in obligations:
        for key, field in (
            ("resolution_status_counts", "resolution_status"),
            ("evidence_state_counts", "evidence_state"),
            ("feature_state_counts", "feature_state"),
            ("priority_counts", "priority"),
            ("family_counts", "contract_family"),
        ):
            value = row[field]
            summary[key][value] = summary[key].get(value, 0) + 1

    evidence_manifest = [
        {
            "path": rel(path),
            "sha256": sha256_bytes(committed_blobs[path]),
            "provenance": provenance[rel(path)],
        }
        for path in research_json + feature_files + note_files
    ]
    manifest_text = "\n".join(
        f"{item['path']} {item['sha256']} {item['provenance']}"
        for item in evidence_manifest
    )
    return {
        "schema_version": 1,
        "status": "committed-evidence snapshot; pending workspace files excluded; no partition promoted to fulfilled",
        "snapshot_commit": snapshot_commit,
        "workspace_provenance": {
            "included": "all matching blobs at snapshot_commit, including HEAD versions of locally modified files",
            "excluded": "staged-only and untracked content absent from snapshot_commit",
            "pending_files_must_be_committed_and regenerated_before_they_reduce_gaps": True,
        },
        "generation_command": "python3 tools/review/behavior-gap-ledger.py --write",
        "method": {
            "resolution_rule": (
                "Fulfillment requires an explicit reviewed full-domain disposition. "
                "The contract partition must use fulfilled/complete/reviewed-complete "
                "and name completion_evidence or review_evidence. No current source does."
            ),
            "direct_evidence_rule": (
                "Only structured partition_ids/partitions joined to the same canonical "
                "operation and an observed case count as direct partition observations."
            ),
            "operation_evidence_rule": (
                "Operation identifiers and cases establish evidence presence only; they "
                "never prove a partition complete."
            ),
            "provenance_rule": (
                "Only blobs from snapshot_commit drive evidence_state and priority. A locally "
                "modified tracked path contributes its committed HEAD bytes; staged-only and "
                "untracked content is excluded until committed and the ledger regenerated."
            ),
            "priority_order": [
                "P0-establish-committed-primary-evidence",
                "P1-link-and-observe-partition",
                "P2-author-feature-for-observed-partition",
                "P3-review-composite-partition-for-fulfillment",
            ],
        },
        "contract_sources": [
            {
                "path": rel(path), "sha256": sha256_bytes(committed_blobs[path]),
                "provenance": provenance[rel(path)],
                }
            for path in CONTRACT_FILES
        ],
        "generator": {
            "path": rel(Path(__file__).resolve()),
            "sha256": sha256_bytes(Path(__file__).resolve().read_bytes()),
            "provenance": "generator bytes hashed independently of evidence snapshot",
        },
        "evidence_manifest_sha256": hashlib.sha256(manifest_text.encode()).hexdigest(),
        "evidence_file_count": len(evidence_manifest),
        "evidence_provenance_counts": {
            state: sum(item["provenance"] == state for item in evidence_manifest)
            for state in sorted(set(provenance.values()))
        },
        "evidence_manifest": evidence_manifest,
        "summary": summary,
        "operation_evidence": operation_evidence,
        "prioritized_work_queue": queue,
        "obligations": obligations,
        "limits": [
            "This ledger audits the 397 coarse partitions in five contract JSON files; configuration-domains.json is a separate 38-key inventory.",
            "The audit does not execute probes or BDD scenarios and does not validate every literal result.",
            "Case-to-operation recovery depends on explicit structured IDs shared across fixture, observation, map, and feature files.",
            "Natural-language scenarios without a mapped case ID remain operation-level evidence at most.",
            "Pending worktree bytes and untracked files are excluded from the committed snapshot and cannot reduce a gap.",
            "Composite words such as every, all, each, and both are not treated as satisfied by a sample.",
            "Private helper execution and statement/branch coverage are outside this partition-status ledger.",
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="replace the checked-in ledger")
    parser.add_argument("--output", type=Path, default=OUT)
    args = parser.parse_args()
    output = args.output if args.output.is_absolute() else ROOT / args.output
    snapshot = None if args.write or not output.exists() else json.loads(output.read_text(encoding='utf-8'))['snapshot_commit']
    generated = build(snapshot)
    encoded = json.dumps(generated, indent=2, sort_keys=False) + "\n"
    output = args.output if args.output.is_absolute() else ROOT / args.output
    if args.write:
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(encoded, encoding="utf-8")
    elif not output.exists():
        print(f"missing ledger: {rel(output)}", file=sys.stderr)
        return 1
    elif output.read_text(encoding="utf-8") != encoded:
        print(f"stale ledger: {rel(output)}; run with --write", file=sys.stderr)
        return 1
    summary = generated["summary"]
    try:
        display_output = rel(output)
    except ValueError:
        display_output = str(output)
    print(json.dumps({
        "ledger": display_output,
        "obligations": summary["obligation_count"],
        "operations": summary["operation_count"],
        "resolution": summary["resolution_status_counts"],
        "evidence": summary["evidence_state_counts"],
        "priorities": summary["priority_counts"],
    }, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
