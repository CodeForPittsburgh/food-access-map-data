import os, pandas as pd, math

def get_schema(path):
	return pd.read_excel(io=path, sheet_name="master_table", engine = 'openpyxl')


def run_checks_for_all_dfs(df_list):
	all_checks_passed = True
	for df in df_list:
		all_checks_passed = all_checks_passed and run_checks(df)
	return all_checks_passed

def run_checks(df, schema):
	return(
		check_more_than_zero_rows(df)
	)

def check_more_than_zero_rows(df):
	return(len(df.index) > 0)	

def check_match_with_schema(df, schema):
	df_keys = df.keys()
	for key in schema['field']:
		if str(key) != 'nan' and key not in df_keys:
			print(str(key) + " not in dataframe!")
			return False
	return True
	# Go through each column in the schema, check that each column corresponds to one in the dataframe.