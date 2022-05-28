import sys
import auto_sanity_check_function
import pandas as pd
from io import StringIO

dat = pd.read_csv(StringIO(sys.stdin.read()))

#auto_id_duplicates_wrapper
sys.stdout.write(auto_sanity_check_function.sanity_check(dat))
