#!/usr/bin/python

import sys, os, pandas as pd
import auto_check_source_data_integrity_functions as sdi

print ('Number of arguments:' + str(len(sys.argv)) + ' arguments.')

args = sys.argv
if len(args) != 2:
	#Stop and throw error, because you need an argument for this
	sys.stdout.write('False')
	sys.exit("ERROR: Insufficient number of arguments for script")

path = args[1]

df_list = []

schema = sdi.get_schema('schema.xlsx')
#TODO: Change this from a list of dfs to a list of dictionaries, with the path + filename given as one value, and the df given as another value
for filename in os.listdir(path):
	df_list.append(pd.read_csv(path + filename))

sys.stdout.write(str(sdi.run_checks_for_all_dfs(df_list)))



#Go through all of the files and check that ...
	# None of the datasets to be merged have 0 rows
	# They have the columns required as stipulated by the schema

#Send a signal that the next script would read?

# Close the files


