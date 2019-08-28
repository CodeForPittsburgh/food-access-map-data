# food-access-map-data

Data for the food access map:

* `merged_datasets.csv` is the most current version of compiled PFPC data

* Run `run_clean_and_geocodio.R` to generate `merged_datasets.csv`, which calls:

	+ `clean_merge_PFPC_data.R`
	
	+ `geocoding.R` 