#!/bin/bash

#Get timestamp information and prepare historical merged_dataset filename
file_name=merged_datasets 
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
echo "Current Time : $current_time"
new_fileName=$file_name.$current_time.csv
echo "New FileName: " "$new_fileName"

#Get Wic Results from sort-of-API
wget -q -O - --method POST \
--header 'Accept: application/json, text/javascript, /; q=0.01' \
--header 'Content-Type: application/json; charset=UTF-8' \
--body-data '{"county":"2","zip":"","miles":"5"}' \
'https://www.pawic.com/FindWICStores.aspx/FindStores' | jq -r '.d' | jq > food-data/new-datasets/wicresults.json
cat food-data/new-datasets/wicresults.json  | jq --arg current_time "$current_time" '.timestamp |= $current_time' > food-data/new-datasets/wicresults.json

#Prepare source scripts -- scripts that obtain the requisite data from APIs, Googlesheets, and Repository CSVs.
python data_prep_scripts/prep_source_scripts/source_py_scripts.py
Rscript data_prep_scripts/prep_source_scripts/source_r_scripts.R

#Run Data Integrity Checker -- ensuring that data ingested meets basic integrity requirements, like matching the schema and having more than zero rows
no_error=`python data_prep_scripts/auto_check_source_data_integrity_wrapper.py food-data/Cleaned_data_files/`

#Assuming data integrity checker found no errors, continue running script
if [ "$no_error" == "True" ]; then
#Reads in previously prepared data sources (per defined schema) from food-data/Cleaned_data_files/ and aggregate them into a single dataframe 
	Rscript data_prep_scripts/auto_agg_clean_data.R food-data/Cleaned_data_files/ | \
#Text process the name field in an effort to assign type (e.g. for large chain grocery stores etc)
		Rscript data_prep_scripts/auto_text_process_name.R | \
#For addresses missing latitude and longitude, add these via Mapbox Geocoding API
		Rscript data_prep_scripts/auto_geocode_wrapper.R $mapbox_key | \
#Standardize addresses 
		python data_prep_scripts/auto_clean_addresses_wrapper.py | \
#Identify duplicate entries
		python data_prep_scripts/auto_id_duplicates_wrapper.py | \
#Merge duplicate rows, resolving conflicts on critical information by prioritizing some data sources, outputing final result into "merged_datasets.csv"		
		Rscript data_prep_scripts/auto_merge_duplicates_wrapper.R "data_prep_scripts/source_field_prioritization_sample_data.csv" > food-data/processed-datasets/merged_datasets.csv

#Copy merged_datasets.csv to timestamped historical copy of csv. 
	cp food-data/processed-datasets/merged_datasets.csv food-data/processed-datasets/$new_fileName

#If data integrity checker found errors, stop script and send failure message
else
	echo 'Data Integrity Checker Failed. Check Output.'
fi
