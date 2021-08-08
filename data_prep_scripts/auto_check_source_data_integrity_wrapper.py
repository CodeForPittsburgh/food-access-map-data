#!/usr/bin/python

import sys, os, pandas as pd
import auto_check_source_data_integrity_functions as sdi

path = os.getcwd() + '/food-data/Cleaned_data_files/'

df_list = []

schema = sdi.get_schema('schema.xlsx')
for filename in os.listdir(path):
	d = {
		'Path': (path+filename),
		'DataFrame': pd.read_csv(path+filename)
	}
	df_list.append(d)

sys.stdout.write(str(sdi.run_checks_for_all_dfs(df_list)))


