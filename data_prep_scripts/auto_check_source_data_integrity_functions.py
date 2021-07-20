import pandas as pd

def run_checks_for_all_dfs(df_list):
	all_checks_passed = True
	for df in df_list:
		all_checks_passed = all_checks_passed and run_checks(df)
	return all_checks_passed

def run_checks(df):
	return(
		check_more_than_zero_rows(df)
	)

def check_more_than_zero_rows(df):
	return(len(df.index) > 0)	