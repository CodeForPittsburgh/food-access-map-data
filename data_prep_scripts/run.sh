#!/bin/bash

file_name=merged_datasets
 
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
echo "Current Time : $current_time"
 
new_fileName=$file_name.$current_time.csv
echo "New FileName: " "$new_fileName"

python data_prep_scripts/prep_source_scripts/source_py_scripts.py
Rscript data_prep_scripts/prep_source_scripts/source_r_scripts.R

no_error=`python data_prep_scripts/auto_check_source_data_integrity_wrapper.py food-data/Cleaned_data_files/`

if [ "$no_error" == "True" ]; then
	Rscript data_prep_scripts/auto_agg_clean_data.R food-data/Cleaned_data_files/ | \
		Rscript data_prep_scripts/auto_text_process_name.R | \
		Rscript data_prep_scripts/auto_geocode_wrapper.R $mapbox_key | \
		python data_prep_scripts/auto_clean_addresses_wrapper.py | \
		python data_prep_scripts/auto_id_duplicates_wrapper.py | \
		Rscript data_prep_scripts/auto_merge_duplicates_wrapper.R "data_prep_scripts/source_field_prioritization_sample_data.csv" > food-data/processed-datasets/merged_datasets.csv

	cp food-data/processed-datasets/merged_datasets.csv food-data/processed-datasets/$new_fileName
else
	echo 'Data Integrity Checker Failed. Check Output.'
fi
