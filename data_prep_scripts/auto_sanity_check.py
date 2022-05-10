#A script to check that the final dataset...
    #Contains data from all sources
    #Is not empty
#If these conditions aren't met, the script will return false, signalling the Github action to either not commit or throw a warning

import sys
import pandas as pd
from io import StringIO

dat = pd.read_csv(StringIO(sys.stdin.read()))

def empty_dataframe():
    if dat.empty:
        return False

def has_data_from_all_sources():

