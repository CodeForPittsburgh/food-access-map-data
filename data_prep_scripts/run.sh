#!/bin/bash

Rscript data_prep_scripts/auto_agg_clean_data.R food-data/Cleaned_data_files/ | Rscript data_prep_scripts/auto_text_process_name.R | Rscript data_prep_scripts/auto_geocode_wrapper.R $mapbox_key | Rscript data_prep_scripts/auto_write_to_csv.R

CURRENTDATE=`date +"%Y-%m-%d %T"`
echo Updated at: ${CURRENTDATE} > date.txt

