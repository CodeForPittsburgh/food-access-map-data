#!/usr/bin/python3.6

import sys
import id_duplicates_functions
import pandas as pd

dat = pd.read_json(StringIO(sys.stdin.read()), lines=True)

print("Running...")
#auto_id_duplicates_wrapper
sys.stdout.write(id_duplicates_functions.id_duplicates(dat))