from data_prep_scripts import auto_check_source_data_integrity_functions as csd
import pandas as pd

def test_get_schema():
	schema = csd.get_schema('schema.xlsx')
	columns = schema.columns
	assert('field' in columns)
	assert('type' in columns)
	assert('description/reasoning' in columns)
	assert('STATUS' in columns)
	#Verify that schema has same columns "field", "type", "description/reasoning", "STATUS"

def test_check_more_than_zero_rows_true():
	#Create df with two rows
	df = pd.DataFrame({'a':[10, 20], 'b':[100,200]}, index='1 2'.split())
	assert(csd.check_more_than_zero_rows(df))

def test_check_more_than_zero_rows_false():
	#Create df with zero rows
	df = pd.DataFrame(columns=['User_ID', 'UserName', 'Action'])
	assert(not csd.check_more_than_zero_rows(df)) 

def test_check_match_with_schema_true():
	#Create df with all columns in schema
	schema = csd.get_schema('schema.xlsx')
	df = pd.DataFrame(columns=['id', 'source_org', 'source_file', 'original_id', 'type', 'name', 'address', 'city', 'state', 'zip_code', 'county', 'location_description', 'phone', 'url', 'latitude', 'longitude', 'latlng_source', 'date_from', 'date_to', 'SNAP', 'WIC', 'FMNP', 'fresh_produce', 'food_bucks', 'free_distribution', 'open_to_spec_group', 'data_issues'])
	assert(csd.check_match_with_schema(df, schema))

def check_match_with_schema_false():
	schema = csd.get_schema('schema.xlsx')
	df = pd.DataFrame(columns=['id', 'source_org', 'source_file', 'original_id', 'type', 'name', 'address', 'city', 'state', 'zip_code', 'county', 'location_description', 'phone', 'url', 'latitude', 'longitude', 'latlng_source', 'date_to', 'SNAP', 'WIC', 'FMNP', 'fresh_produce', 'food_bucks', 'free_distribution', 'open_to_spec_group', 'data_issues'])
	#Create df with one column in schema missing
	assert(not csd.check_match_with_schema(df, schema))