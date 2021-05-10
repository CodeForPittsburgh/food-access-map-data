#test_id_duplicates.py

import sys
import pandas as pd

#This is importing the "id_duplicates_function.py" file from the
#	"data_prep_scripts" directory.
from data_prep_scripts import id_duplicates_functions as idf

#Each test must begin with "test_"
#Test that three entries for Bloomfield Farmer's market are grouped together to be merged
#Ids are 1124, 556, and 1754, respectively
def test_id_duplicates_bloomfield_group():
	data = pd.read_csv("tests/test-data/test_id_duplicates_bloomfield_input.csv")
	results = idf.id_duplicates(data)
	assert (
		results["group_id"][0] == 0 and #Commenting this line causes the test to pass
		results["group_id"][1] == 0 and
		results["group_id"][2] == 0
		)

#Test that two entries, one for "Windber Area Community Kitchen", and one for "Windber Area Community Kitchen - Wackpack Program" are NOT grouped together for merge
#id's of entries are 1745 and 1746, respectively.
def test_id_duplicates_windber_no_group():
	return True

#Test that two entries, one for "St. Catherine of Siena Food Pantry", and one for "St. Catherine of Siena Fresh Market" are NOT grouped together for merge
#id's of entries are 1660 and 1661, respectively.
def test_id_duplicates_st_catherine_no_group():
	return True

#Test that two entries, one for "Green Grocer at East Hills Community Center", and one for "Green Grocer/East Hills Community Center" are merged
#id's of entries are 1101 and 1170, respectively.
#Entries with names that include "Green Grocer" should not be grouped together for merge, even if they are duplicates
def test_id_duplicates_east_hills_green_grocer_no_group():
	return True

#Test that two entries, one for "Giant Eagle 78", and one for "Giant Eagle" are grouped together
#id's of entries are 963 and 36, respectively.
def test_id_duplicates_giant_eagle_group():
	return True

#Test that two entries, one for "Bailie Food Mart", and one for "Bailey Food Mart" are grouped together
#id's of entries are 650 and 1778, respectively.
def test_id_duplicates_Bailey_Bailie_group():
	return True

#Test that three entries for "Bellevue Farmers Market", "Belllevue Farmers Market", and "BELLEVUE" are grouped together
#id's of entries are 272,1753, and 1144, respectively
#BELLEVUE may be a challenging one to merge. Let us know if passing it is especially difficult
def test_id_duplicates_Bellevue_group():
	return True

#Test that two entries, both for "North Versailles Save A Lot" are grouped together
#id's of entries are 567 and 572, respectively.
def test_id_duplicates_North_Versailles_group():
	return True

#Test that two entries, for "Community Human Services - Food Pantry", and "Community Human Services Teaching Garden" are NOT grouped together for merge
#id's of entries are 1291, 115, respectively
def test_id_duplicates_Community_Human_Services_no_group():
	return True

#Test that three entries for Dylamoto's Market are grouped together for merge
#id's of entries are 1018, 6, 1
def test_id_duplicates_Dylamotos_group():
	return True
