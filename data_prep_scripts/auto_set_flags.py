#A script to set flags for every source script
import sys
import pandas as pd
from io import StringIO


def set_fresh_produce_flag(row):
    if row['type'] in ('supermarket', 'farmer\'s market'):
        return 1
    elif row['source_org'] == "Grow Pittsburgh":
        return 1
    elif int(row['food_bucks']) == 1:
        return 1
    elif int(row['WIC']) == 1:
        return 1
    return 0

dat = pd.read_csv(StringIO(sys.stdin.read()))

dat['fresh_produce'] = dat.apply(lambda row : set_fresh_produce_flag(row), axis = 1)

sys.stdout.write(dat.to_csv(line_terminator='\n', index = False))