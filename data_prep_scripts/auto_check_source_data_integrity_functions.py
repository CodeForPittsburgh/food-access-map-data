import os, pandas as pd, math

def get_check_response(Passed, Message):
	return {
		'Passed': Passed,
		'Message': Message
	}

def get_schema(path):
	return pd.read_excel(io=path, sheet_name="master_table", engine = 'openpyxl')


def run_checks_for_all_dfs(df_list):	 
	all_checks_passed = True
	schema = get_schema('schema.xlsx')
	for d in df_list:
		results = run_checks(d['DataFrame'], schema)
		for r in results:
			if (r['Passed'] == False):
				print("ERROR: Check failure in " + d['Path'])
				print(r['Message'])
				all_checks_passed = False
	return all_checks_passed

def run_checks(df, schema):
	all_responses = []
	all_responses.append(check_more_than_zero_rows(df))
	all_responses.append(check_match_with_schema(df, schema))
	return all_responses

def check_more_than_zero_rows(df):
	if len(df.index) > 0: 
		return get_check_response(True, 'Passed')
	return get_check_response(False, 'Has zero rows in file')

def check_match_with_schema(df, schema):
	df_keys = df.keys()
	missing_keys = []
	for key in schema['field']:
		if str(key) != 'nan' and key not in df_keys:
			missing_keys.append(key)
	if len(missing_keys) > 0: 
		msg = "File missing the following keys: " + str(missing_keys)
		return get_check_response(False, msg)
	return get_check_response(True, 'Passed')