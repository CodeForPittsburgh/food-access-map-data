#!/bin/bash

file_name=merged_datasets
 
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
echo "Current Time : $current_time"
 
new_fileName=$file_name.$current_time.csv
echo "New FileName: " "$new_fileName"

Rscript data_prep_scripts/auto_agg_clean_data.R food-data/Cleaned_data_files/ | \
	Rscript data_prep_scripts/auto_text_process_name.R | \
	Rscript data_prep_scripts/auto_geocode_wrapper.R $mapbox_key | \
	python data_prep_scripts/auto_clean_addresses_wrapper.py | \
	python data_prep_scripts/auto_id_duplicates_wrapper.py | \
	Rscript data_prep_scripts/auto_merge_duplicates_wrapper.R "data_prep_scripts/source_field_prioritization_sample_data.csv" > food-data/processed-datasets/merged_datasets.csv
	cp merged_datasets.csv $new_fileName

CURRENTDATE=`date +"%Y-%m-%d %T"`
echo Updated at: ${CURRENTDATE} > date.txt

