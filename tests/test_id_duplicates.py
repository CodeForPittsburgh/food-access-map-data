#test_id_duplicates.py

import sys
import pandas as pd

#This is importing the "id_duplicates_function.py" file from the
#	"data_prep_scripts" directory.
from data_prep_scripts import id_duplicates_functions as idf

#Each test must begin with "test_"
def test_id_duplicates_bloomfield():
	data = pd.read_csv("tests/test-data/test_id_duplicates_bloomfield_input.csv")
	results = idf.id_duplicates(data)
	assert (
		results["group_id"][0] == 0 and #Commenting this line causes the test to pass
		results["group_id"][1] == 0 and
		results["group_id"][2] == 0
		)
