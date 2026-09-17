#!/usr/bin/env python3
"""Check draft outline/table consistency; not a Gherkin runner or semantic review."""
from pathlib import Path
import re
import sys

def cells(line):
    # Gherkin escapes include \|; escaped separators are data, not columns.
    result, cell, escaped = [], '', False
    for char in line.strip()[1:-1]:
        if escaped:
            cell += '\\' + char
            escaped = False
        elif char == '\\':
            escaped = True
        elif char == '|':
            result.append(cell.strip())
            cell = ''
        else:
            cell += char
    result.append(cell.strip())
    return result

def check(path):
    errors = []
    placeholders = set()
    outline = False
    in_examples = False
    header = None
    table_width = None
    for number, raw in enumerate(path.read_text().splitlines(), 1):
        line = raw.strip()
        if re.match(r'Scenario(?: Outline)?:', line):
            outline = line.startswith('Scenario Outline:')
            placeholders, in_examples, header, table_width = set(), False, None, None
        if line.startswith('Examples:'):
            in_examples, header, table_width = True, None, None
        if outline and not in_examples:
            placeholders.update(re.findall(r'<([A-Za-z_][A-Za-z0-9_ -]*)>', line))
        if line.startswith('|') and line.endswith('|'):
            row = cells(line)
            if table_width is not None and len(row) != table_width:
                errors.append(f'{path}:{number}: {len(row)} columns; expected {table_width}')
            table_width = len(row) if table_width is None else table_width
            if in_examples and header is None:
                header = row
                missing = placeholders - set(header)
                if missing:
                    errors.append(f'{path}:{number}: missing outline columns {sorted(missing)}')
                if len(header) != len(set(header)):
                    errors.append(f'{path}:{number}: duplicate example column')
        elif line and not line.startswith('#'):
            table_width = None
    return errors

if __name__ == '__main__':
    roots = [Path(arg) for arg in sys.argv[1:]] or [Path('spec/drafts')]
    paths = sorted({p for root in roots for p in ([root] if root.is_file() else root.rglob('*.feature'))})
    errors = [error for path in paths for error in check(path)]
    for error in errors:
        print(error)
    print(f'{len(paths)} feature files checked; {len(errors)} structural errors')
    sys.exit(bool(errors))
