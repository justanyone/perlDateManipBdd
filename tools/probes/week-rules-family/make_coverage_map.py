#!/usr/bin/env python3
"""Write the exact canonical-partition mapping for the valid-rule batch."""
from __future__ import annotations
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
MANIFEST=json.loads((ROOT/'docs/research/week-rules-family/matrix-manifest.json').read_text())
OUT=ROOT/'docs/research/week-rules-family/coverage-map.json'
def main()->None:
 configs=[row['case_id'] for row in MANIFEST['configurations']]
 OUT.write_text(json.dumps({'schema_version':1,'operation_id':'calendar.week-number','public_binding':'Date::Manip::Base::week_of_year','partition_resolution':'unresolved outside the stated Base configuration and date domain','source_calls':[{'operation_id':'object.create','binding':'Date::Manip::Base->new()'},{'operation_id':'config.apply-settings','binding':'Date::Manip::Base::config(firstday, value, week1ofyear, value)'},{'operation_id':'calendar.week-number','binding':'Date::Manip::Base::week_of_year','forward_carrier':'two-item list [week-year, week-number]','inverse_carrier':'one array reference [year, month, day]','matrix_inverse_presentation':'requested week is prepended as a request label, not an extra returned field'}],'feature':'spec/drafts/week-rules/week-rules.feature','partition_map':[
 {'partition_id':'calendar.week-number.p1','status':'observed-selected','case_ids':[f'{value}-INVERSE' for value in MANIFEST['selected_inverse_configurations']],'detail':'Public inverse requests for weeks 1 and 2 across all fourteen selected Gregorian year types.'},
 {'partition_id':'calendar.week-number.p2','status':'observed-complete-for-stated-edge-domain','case_ids':configs,'detail':'Jan 1..7 and Dec 25..31 in each of the fourteen types.'},
 {'partition_id':'calendar.week-number.p3','status':'observed-complete-valid-Base-domain','case_ids':configs,'detail':'All 7 × 15 valid FirstDay/Week1ofYear settings.'},
 {'partition_id':'calendar.week-number.p4','status':'remaining','case_ids':[],'detail':'Invalid rule, inverse week, malformed date/list, and missing-field inputs remain.'},
 {'partition_id':'calendar.week-number.p5','status':'remaining','case_ids':[],'detail':'Date, DM6, and DM5 legacy-number comparisons remain.'}
 ]},indent=2,sort_keys=True)+'\n')
if __name__=='__main__': main()
