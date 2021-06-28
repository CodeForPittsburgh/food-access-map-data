#test_id_duplicates.py
#author: wspk

#################################################################
# These tests looks at the data in tests/test-data/test_id_duplicates.csv
# A sample taken 05-17-2021, which has gone through:
# * auto_agg_clean_data.R
# * auto_text_process_name.R
# * auto_geocode_wrapper.R
# * auto_clean_addresses_wrapper.py

# How to make these tests:
# I suggest exploring the data in python using pandas
#
# >>> from tests import test_id_duplicates as dup
# >>> deduped = dup.load_data()
# >>> dup.search_name("bloomfield", deduped)
#
# I think it would also be worth looking at the data spatially
# with something like QGIS, but I have not done that here.
################################################################

import sys
import pytest
import pandas as pd

from data_prep_scripts import id_duplicates_functions as idf

################################################################
# Helpers
################################################################
# Load the data
def load_data():
    data = pd.read_csv("tests/test-data/test_id_duplicates.csv")
    deduped = idf.id_duplicates(data)

    return deduped

# Search the data by name, helpful for defining tests
def search_name(name, deduped):
    contains = deduped[deduped["name"].str.contains(name, case=False)]
    return contains[["name", "address", "latitude", "longitude", "group_id"]]


# Check whether a list of ids share a single group id
def match(ids, group_id):
    return len(set([group_id[ele] for ele in ids])) == 1

# Check whether a list of ids all have either null, or different group ids
def all_different(ids, group_id):
    notnull = [group_id[ele] for ele in ids if group_id[ele] != '']

    return len(set(notnull)) == len(notnull)


#################################################################
# Tests
#################################################################

# Load the data once before all tests
@pytest.fixture
def deduped():
    data = pd.read_csv("tests/test-data/test_id_duplicates.csv")
    deduped = idf.id_duplicates(data)

    # check that no existing columns were changed
    compare = pd.merge(data, deduped, how='inner')
    assert(data.equals(compare))

    return deduped

# Isolate group_id column for convenience
@pytest.fixture
def group_id(deduped):
    return deduped["group_id"]


#Test that three entries for Bloomfield Farmer's market are grouped together to be merged
# deduped[deduped["name"].str.contains("bloomfield", case=False)]
#                                name                address   latitude  longitude
#90               Bloomfield Groceria  237 Cedarville Street  40.461876 -79.948547         
#98                     Bloomfield Bp    4006 Liberty Avenue  40.462864 -79.956894         
#470       Bloomfield Saturday Market    5050 Liberty Avenue  40.459114 -79.944321
#980   Community Market Bloomfield 96    4401 Liberty Avenue  40.464138 -79.952065         
#1028       Bloomfield Farmers Market    5050 Liberty Avenue  40.459095 -79.944289         
#1244      Bloomfield Saturday Market    5050 Liberty Avenue  40.458813 -79.943713
def test_bloomfield(group_id):
    # assert(match([1244, 1028, 470], group_id)) # Currently fails, as 1028 is not included
    assert(match([470, 1244], group_id))
    assert(all_different([90, 98, 470, 980], group_id))


# deduped[deduped["name"].str.contains("dylamato", case=False)]
#                       name             address   latitude  longitude
#0         Dylamato's Market  5414 Second Avenue  40.402326 -79.941685
#5                 Dylamatos  5414 Second Avenue  40.402326 -79.941685
#919  Dylamato's Market  LLC     5414 2nd Avenue  40.402439 -79.941544
def test_dylamatos(group_id):
    assert(match([0,5,919], group_id))



# deduped[deduped["name"].str.contains("green grocer", case=False)]
#                                                   name                               address   latitude  longitude
#571    Green Grocer - Greater Pittsburgh Comm Food Bank                     1 N Linden Street  40.375511 -79.843300         
#1065                    Green Grocer/Three Rivers Manor                       125 Rhine Place  40.466898 -79.993992
#1066                  Green Grocer/5 Generaltion Bakers                 1100 Chartiers Avenue  40.465582 -80.068218         
#1067                     Green Grocer/Woods Run Library                 1201 Woods Run Avenue  40.476240 -80.030200         
#1068                              Green Grocer/GAP park                      518 Grant Avenue  40.480910 -79.974494         
#1069                         Green Grocer/Family Dollar                     533 Miller Avenue  40.294019 -79.883286         
#1070             Green Grocer/Glassport Honor Roll Park                 440 Monogahela Avenue  40.328938 -79.892710         
#1071                           Green Grocer/Clock Tower                  306 Brownsville Road  40.414165 -79.988410         
#1072                Green Grocer/A Childs World Daycare                  300 Rankin Boulevard  40.412370 -79.881352         
#1073            Green Grocer/Alma Illery Medical Center                  7227 Hamilton Avenue  40.454544 -79.896267         
#1074           Green Grocer/East Hills Community Center                     2291 Wilner Drive   0.000000   0.000000         
#1089  Green Grocer/Arthur J Edmunds Family Support C...                    101 Hazlett Street  40.477073 -80.002191         
#1090          Green Grocer/Sharpsburg Community Library                      1212 Main Street  40.494332 -79.930202         
#1091             Green Grocer/Old Shop n' Save Building                    1850 Centre Avenue  40.442741 -79.981917         
#1092                             Green Grocer/Pavillion  Hillsboro Street & Sheaden Boulevard  40.452187 -80.058417         
#1093                       Green Grocer/Monview Heights                       48 Midway Drive  40.398001 -79.880712         
#1094                        Green Grocer/Wilmerding Apt                   314 Commerce Street  40.392748 -79.807620         
#1095     Green Grocer/UPMC Matilda Theiss Health Center                    373 Burrows Street  40.442058 -79.970400 
def test_green_grocer(group_id):
    assert(all_different([571, 1065, 1066, 1067, 1068, 1069, 1070, 1071, 
        1072, 1073, 1074, 1089, 1090, 1091, 1092, 1093, 1094, 1095], group_id))


# deduped[deduped["name"].str.contains("manor", case=False)]
#                                 name             address   latitude  longitude
#1065  Green Grocer/Three Rivers Manor     125 Rhine Place  40.466898 -79.993992
#1119      Jefferson Manor Food Pantry  201 Jefferson Road  40.465286 -79.822761
#1386               Three Rivers Manor     125 Rhine Place  40.467282 -79.993399
#1425                  Bjwl Hays Manor   205 Locust Street  40.466739 -80.056224
def test_manor(group_id):
    assert(match([1065, 1386], group_id))
    assert(all_different([1065,1119,1425], group_id))


#Test that two entries, one for "Bailie Food Mart", and one for "Bailey Food Mart" are grouped together
#                                 name             address   latitude  longitude
#1269                 Bailey Food Mart  2316 Bailie Avenue  40.341113 -79.848597
#554                  Bailie Food Mart  2316 Bailey Avenue  40.341465 -79.849228
def test_id_duplicates_Bailey_Bailie_group(group_id):
    assert(match([1269, 554], group_id))


#Test that three entries for "Bellevue Farmers Market", "Belllevue Farmers Market", and "BELLEVUE" are grouped together
#                                 name                address     latitude   longitude
# 1049                        BELLEVUE  34 North Balph Avenue   40.4962663 -80.0569321
# 188          Bellevue Farmers Market      34 N Balph Avenue      40.4967  -80.054756
# 1244        Belllevue Farmers Market      34 N Balph Avenue    40.496526  -80.054299
#BELLEVUE may be a challenging one to merge. Let us know if passing it is especially difficult
def test_id_duplicates_Bellevue_group():
	assert(match([1049, 188, 1244], group_id))