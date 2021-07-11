#test_id_duplicates.py
#author: wspk, Max Chis

import sys
import pytest
import pandas as pd

from data_prep_scripts import id_duplicates_functions as idf

################################################################
# Helpers
################################################################

def create_test_dataframe(n_list, a_list, lat_list, long_list):
    d = {
        'name': n_list,
        'address': a_list,
        'latitude': lat_list,
        'longitude': long_list
    }
    df = pd.DataFrame(data=d)
    return df

def run_test(entries, match_diff_str):
    n_list, a_list, lat_list, long_list = ([] for i in range(4))
    for lst in entries:
        n_list.append(lst[0])
        a_list.append(lst[1])
        lat_list.append(lst[2])
        long_list.append(lst[3])
    td = create_test_dataframe(n_list, a_list, lat_list, long_list)
    result = idf.id_duplicates(td)
    if match_diff_str == 'match':
        #Check if all results have same group id
        assert(len(set(result['group_id'])) == 1)
    elif match_diff_str == 'diff':
        #Check if all results have different group id
        assert(len(set(result['group_id'])) != len(result['group_id']))

#################################################################
# Tests
#################################################################

def test_bloomfield_match():
    entries = [
        ['Bloomfield Saturday Market', '5050 Liberty Avenue', 40.459114, -79.944321],
        ['Bloomfield Farmers Market', '5050 Liberty Avenue', 40.459095, -79.944289],         
        ['Bloomfield Saturday Market', '5050 Liberty Avenue', 40.458813, -79.943713]
    ]
    run_test(entries, 'match')

def test_bloomfield_diff():
    entries = [
        ['Bloomfield Groceria', '237 Cedarville Street', 40.461876, -79.948547],         
        ['Bloomfield Bp', '4006 Liberty Avenue', 40.462864, -79.956894],         
        ['Bloomfield Saturday Market', '5050 Liberty Avenue', 40.459114, -79.944321],
        ['Community Market Bloomfield 96', '4401 Liberty Avenue', 40.464138, -79.952065]        
    ]
    run_test(entries, 'diff')

def test_dylamatos():
    entries = [
        ['Dylamato\'s Market', '5414 Second Avenue', 40.402326, -79.941685],
        ['Dylamatos', '5414 Second Avenue', 40.402326, -79.941685],
        ['Dylamato\'s Market  LLC', '5414 2nd Avenue', 40.402439, -79.941544]
    ]
    run_test(entries, 'match')

def test_green_grocer():
    entries = [
        ['Green Grocer - Greater Pittsburgh Comm Food Bank', '1 N Linden Street',  40.375511, -79.843300],         
        ['Green Grocer/Three Rivers Manor', '125 Rhine Place',  40.466898, -79.993992],
        ['Green Grocer/5 Generaltion Bakers', '1100 Chartiers Avenue',  40.465582, -80.068218],         
        ['Green Grocer/Woods Run Library', '1201 Woods Run Avenue',  40.476240, -80.030200],         
        ['Green Grocer/GAP park', '518 Grant Avenue',  40.480910, -79.974494],         
        ['Green Grocer/Family Dollar', '533 Miller Avenue',  40.294019, -79.883286],         
        ['Green Grocer/Glassport Honor Roll Park', '440 Monogahela Avenue',  40.328938, -79.892710],         
        ['Green Grocer/Clock Tower', '306 Brownsville Road',  40.414165, -79.988410],         
        ['Green Grocer/A Childs World Daycare', '300 Rankin Boulevard',  40.412370, -79.881352],         
        ['Green Grocer/Alma Illery Medical Center', '7227 Hamilton Avenue',  40.454544, -79.896267],         
        ['Green Grocer/East Hills Community Center', '2291 Wilner Drive',   0.000000,   0.000000],         
        ['Green Grocer/Arthur J Edmunds Family Support C...', '101 Hazlett Street',  40.477073, -80.002191],         
        ['Green Grocer/Sharpsburg Community Library', '1212 Main Street',  40.494332, -79.930202],         
        ['Green Grocer/Old Shop n\' Save Building', '1850 Centre Avenue',  40.442741, -79.981917],         
        ['Green Grocer/Pavillion', 'Hillsboro Street & Sheaden Boulevard',  40.452187, -80.058417],         
        ['Green Grocer/Monview Heights', '48 Midway Drive',  40.398001, -79.880712],         
        ['Green Grocer/Wilmerding Apt', '314 Commerce Street',  40.392748, -79.807620],         
        ['Green Grocer/UPMC Matilda Theiss Health Center', '373 Burrows Street',  40.442058, -79.970400] 
    ]
    run_test(entries, 'diff')

def test_manor_match():
    entries = [
        ['Green Grocer/Three Rivers Manor',  '125 Rhine Place', 40.466898, -79.993992],
        ['Three Rivers Manor',  '125 Rhine Place', 40.467282, -79.993399] 
    ]
    run_test(entries, 'match')

def test_manor_diff():
    entries = [
        ['Green Grocer/Three Rivers Manor', '125 Rhine Place', 40.466898, -79.993992],
        ['Jefferson Manor Food Pantry', '201 Jefferson Road', 40.465286, -79.822761],
        ['Bjwl Hays Manor', '205 Locust Street', 40.466739, -80.056224]        
    ]
    run_test(entries, 'diff')

#Test that two entries, one for "Bailie Food Mart", and one for "Bailey Food Mart" are grouped together
def test_id_duplicates_Bailey_Bailie_group():
    entries = [
        ['Bailey Food Mart', '2316 Bailie Avenue', 40.341113, -79.848597],
        ['Bailie Food Mart', '2316 Bailey Avenue', 40.341465, -79.849228]
    ]
    run_test(entries,'match')

#Test that three entries for "Bellevue Farmers Market", "Belllevue Farmers Market", and "BELLEVUE" are grouped together
#BELLEVUE may be a challenging one to merge. Let us know if passing it is especially difficult
def test_id_duplicates_Bellevue_group():
    entries = [
        ['BELLEVUE', '34 North Balph Avenue', 40.4962663, -80.0569321],
        ['Bellevue Farmers Market', '34 N Balph Avenue', 40.4967, -80.054756],
        ['Belllevue Farmers Market', '34 N Balph Avenue', 40.496526, -80.054299]
    ]
    run_test(entries, 'match')
	   