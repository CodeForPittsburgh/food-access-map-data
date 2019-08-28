## purpose: run cleaning and geo script to create final dataset
## contributors: Catalina Moreno, Mohamad Sahil, Elizabeth Speigle
## last updated: 08/26/2019

suppressWarnings(source("clean_merge_PFPC_data.R"))## loads merged, cleaned dataset into environment

suppressWarnings(source("geocoding.R"))## runs geocoding (requires google api)

