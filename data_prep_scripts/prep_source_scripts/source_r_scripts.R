#one main script to source() all the R scripts in /prep_data_sources
#for https://github.com/CodeForPittsburgh/food-access-map-data/issues/116

#One R script to rule them all,
#One R script to find them,
#One R script to bring them all
#And in the dark-themed IDE source() them.

source("data_prep_scripts/prep_source_scripts/prep_Grow_PGH.R")
source("data_prep_scripts/prep_source_scripts/prep_SNAP.R")
source("data_prep_scripts/prep_source_scripts/prep_just_harvest_google_sheets.R")
source("data_prep_scripts/prep_source_scripts/prep_wic_sites.R")