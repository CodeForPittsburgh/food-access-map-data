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

## get input for file location passed from the command line
args <- commandArgs(trailingOnly=TRUE)

read_clean_data_sources <- function(read_loc) {
  ## read in cleaned data sources
  all_datasets <- list.files(read_loc, full.names = TRUE) %>%
    set_names() %>%
    map_dfr(read_csv, col_types = cols(.default = "c"), .id = "file_name")

  ## assign uid
  all_datasets <- all_datasets %>% mutate(id = 1:n())

  ## write out as stdout
  write.table(all_datasets, stdout())
}

## run function with CLI input
read_clean_data_sources(args)

