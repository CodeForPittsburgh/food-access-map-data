#!/usr/bin/python3.6

import sys
import id_duplicates_functions
import pandas as pd
from io import StringIO

dat = pd.read_csv(StringIO(sys.stdin.read()))

#auto_id_duplicates_wrapper
sys.stdout.write(id_duplicates_functions.id_duplicates(dat).to_csv(line_terminator='\n'))