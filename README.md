# food-access-map-data

Data for the food access map:

* `merged_datasets.csv` is the most current version of compiled PFPC data (last update 04/01/2020 w/ de-dup by fuzzystring turned off for now)


* Run `run_new_data_merge.R` to generate `merged_datasets.csv`, which calls:

	+ prepared data sources in `food-data/Cleaned_data_files/`

	+ `name_text_processing_script.R`
	
	+ `geocoding.R` 

	
[Map of data in merged_datasets.csv](https://wprdc-maps.carto.com/u/wprdc/builder/64b812f6-45fa-4f27-a239-6e61a870d1de/embed)
