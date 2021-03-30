#!/bin/bash

#NOTE TO REMOVE LATER: Try adding breaking down into intermediate text files for better debugging.

# Rscript data_prep_scripts/auto_agg_clean_data.R food-data/Cleaned_data_files/ | \
# 	Rscript data_prep_scripts/auto_text_process_name.R | \
# 	Rscript data_prep_scripts/auto_geocode_wrapper.R $mapbox_key > temp.file

# Rscript data_prep_scripts/auto_agg_clean_data.R food-data/Cleaned_data_files/ | \
# 	Rscript data_prep_scripts/auto_text_process_name.R | \
# 	Rscript data_prep_scripts/auto_geocode_wrapper.R $mapbox_key | \
# 	Rscript data_prep_scripts/auto_write_to_json.R | \
	# Py data_prep_scripts/auto_clean_addresses_wrapper.py | \


	# This works
	# cat temp.file | Rscript data_prep_scripts/auto_write_to_json.R | \
	# Py data_prep_scripts/auto_clean_addresses_wrapper.py > clean_addresses.output

	# Does this work?
	cat clean_addresses.output | Py data_prep_scripts/auto_id_duplicates_wrapper.py
	
	# This doesn't
	# cat temp.file | Rscript data_prep_scripts/auto_write_to_json.R | \
	# Py data_prep_scripts/auto_clean_addresses_wrapper.py | \
	# Py data_prep_scripts/auto_id_duplicates_wrapper.py > temp_output.file

	# cat temp_json.file | Py data_prep_scripts/auto_clean_addresses_wrapper.py | \
	# Py data_prep_scripts/auto_id_duplicates_wrapper.py | \
	# Rscript data_prep_scripts/auto_merge_duplicates_wrapper.R | \
	# Rscript data_prep_scripts/auto_write_to_csv.R

# echo temp_json.file | Rscript data_prep_scripts/auto_write_to_json.R > temp_json.file