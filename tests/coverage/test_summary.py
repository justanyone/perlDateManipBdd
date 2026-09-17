"""Regression tests for coverage denominator and instrumentation-fidelity safeguards."""
import copy
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
SUMMARIZER = ROOT / 'tools/coverage/summarize_public_call_coverage.pl'

class CoverageSummaryTests(unittest.TestCase):
    def summarize(self, criterion=None, mutation=None, empty=False):
        with tempfile.TemporaryDirectory() as work:
            work = Path(work)
            source = work / 'Date'
            source.mkdir()
            module = source / 'Manip.pm'
            module.write_text('1;\n')
            tool = work / 'Cover.pm'
            tool.write_text('1;\n')
            row = criterion or {'covered': 9, 'error': 0, 'uncoverable': 1, 'total': 10}
            report = {'summary': {} if empty else {str(module): {'statement': row, 'branch': row}}}
            (work / 'cover.json').write_text(json.dumps(report))
            payload = {'result': {'value': 'a literal'}, 'exception': None,
                       'warnings': [], 'call_stdout': ''}
            for profile in ('oo', 'dm6', 'dm5'):
                plain = copy.deepcopy(payload)
                covered = copy.deepcopy(payload)
                if mutation == 'exception' and profile == 'oo':
                    plain['exception'] = covered['exception'] = 'parse failed'
                if mutation == 'value' and profile == 'oo':
                    covered['result']['value'] = 'changed'
                (work / f'plain-{profile}.json').write_text(json.dumps(plain))
                (work / f'covered-{profile}.json').write_text(json.dumps(covered))
                (work / f'plain-{profile}.stderr').write_text('')
                (work / f'covered-{profile}.stderr').write_text('warning' if mutation == 'stderr' and profile == 'oo' else '')
            args = {'module-root': source, 'cover-json': work/'cover.json',
                    'plain-directory': work, 'covered-directory': work,
                    'reference-version': '7.00', 'cover-version': '1.52',
                    'perl-archname': 'test-fixture', 'execution-path': '/usr/bin:/bin',
                    'cover-module': tool, 'pilot-script': tool, 'runner-script': tool,
                    'summary-script': SUMMARIZER, 'output': work/'summary.json'}
            result = subprocess.run(['perl', str(SUMMARIZER),
                                     *[item for key,value in args.items() for item in ('--'+key,str(value))]],
                                    capture_output=True, text=True)
            summary = json.loads((work/'summary.json').read_text()) if result.returncode == 0 else None
            return result, summary

    def test_unapproved_annotations_do_not_raise_raw_percentage(self):
        result, summary = self.summarize()
        self.assertEqual(result.returncode, 0, result.stderr)
        row = summary['totals']['statement']
        self.assertEqual(row['raw_percentage'], 90)
        self.assertEqual(row['tool_reported_percentage'], 100)
        self.assertEqual(row['total'], 10)
        self.assertEqual(row['uncoverable'], 1)

    def test_executed_annotations_are_retained_as_conflicts(self):
        result, summary = self.summarize({'covered': 125, 'error': 44, 'uncoverable': 2, 'total': 167})
        self.assertEqual(result.returncode, 0, result.stderr)
        row = summary['totals']['statement']
        self.assertEqual(row['execution_annotation_cells'], {
            'executed_annotated': 2, 'executed_unannotated': 123,
            'unexecuted_annotated': 0, 'unexecuted_unannotated': 42})
        self.assertAlmostEqual(row['raw_percentage'], 100 * 125 / 167)
        self.assertAlmostEqual(row['tool_reported_percentage'], 100 * 123 / 167)

    def test_inconsistent_denominator_is_rejected(self):
        result, _ = self.summarize({'covered': 9, 'error': 0, 'uncoverable': 1, 'total': 9})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('inconsistent coverage denominator', result.stderr)

    def test_negative_count_is_rejected(self):
        result, _ = self.summarize({'covered': 9, 'error': -1, 'uncoverable': 1, 'total': 9})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('invalid coverage count', result.stderr)

    def test_no_instrumented_library_files_is_rejected(self):
        result, _ = self.summarize(empty=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('no target library files', result.stderr)

    def test_matching_exceptions_are_not_successful_pilot_runs(self):
        result, _ = self.summarize(mutation='exception')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('did not complete', result.stderr)

    def test_changed_value_is_rejected(self):
        result, _ = self.summarize(mutation='value')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('changed the pilot result', result.stderr)

    def test_changed_stderr_is_rejected(self):
        result, _ = self.summarize(mutation='stderr')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('changed process stderr', result.stderr)

if __name__ == '__main__':
    unittest.main()
