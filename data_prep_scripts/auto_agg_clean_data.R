#!/usr/bin/Rscript

# --------------------------- info
# name: auto_agg_clean_data.R
# authors: Max Chis | Catalina Moreno | Connor Tompkins
# last update: 2021-01-05
# info: This script reads in previously prepared data sources (per defined schema) 
#       from food-data/Cleaned_data_files/ and aggregates them into a single dataframe, 
#       thereafter assigning a uid and writing out as stdout() for the next step in data prep


# -------------------------- script

## load pkg
# require("mapboxapi")
# require("dplyr")
# require("readr")
# if (!require("tidyverse", character.only = TRUE)) {
#   suppressPackageStartupMessages(install.packages("tidyverse", dependencies = TRUE))
# }
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(stringr))

## get input for file location passed from the command line
args <- commandArgs(trailingOnly=TRUE)

read_clean_data_sources <- function(read_loc) {
  ## read in cleaned data sources
  all_datasets <- list.files(read_loc, full.names = TRUE) %>%
    set_names() %>%
    map_dfr(read_csv, col_types = cols(.default = "c"), .id = "file_name")

  ## remove name = NA 04/20/2021 
  all_datasets <- all_datasets %>% filter(!is.na(name))
  
  ## assign uid
  all_datasets <- all_datasets %>% mutate(id = 1:n())
  
  ## clean up open_to_spec_group
  all_datasets <- all_datasets %>% mutate(open_to_spec_group = ifelse(str_detect(open_to_spec_group, "children|students|young"), "youth populations", open_to_spec_group),
                                          open_to_spec_group = ifelse(open_to_spec_group %in% c('0', NA), 'open to all', open_to_spec_group),# assume everything is open unless know otherwise so change NA to open
                                          open_to_spec_group = ifelse(open_to_spec_group == 'none_of_the_above', 'contact for more details', open_to_spec_group),# did not match GPCFB filter group, user should contact to learn more about which population this site it serves
                                          open_to_spec_group = str_replace_all(open_to_spec_group, "_", " ")) 
    
  ## write out as stdout
  write.csv(all_datasets, stdout(), row.names = FALSE)
}

## run function with CLI input
read_clean_data_sources(args)

