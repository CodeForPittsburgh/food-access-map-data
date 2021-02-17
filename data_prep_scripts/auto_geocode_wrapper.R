#!/usr/bin/Rscript

# --------------------------- info
# name: auto_geocode.R
# authors: Max Chis | Catalina Moreno | Connor Tompkins
# last update: 2021-01-05
# info: This script reads in output from auto_text_process_name.R and uses mapboxapi to find 
#       lat / long for observations missing this information; 
#       a mapbox api token needs to be provided in CLI as argument (after script name, replace 'token', include '');
#       results are written out as stdout() for next step in data prep


# -------------------------- script
## load pkg

suppressPackageStartupMessages(library(dplyr))
# suppressPackageStartupMessages(library(tidygeocoder))

source("data_prep_scripts/auto_geocode_functions.R")

args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("Mapbox API Key must be called as first argument", call.=FALSE)
} else if (length(args)==1) {
  API_KEY <- args[1]
}

## read in stdin() from previous step
input <- file('stdin', 'r')

## read.table() bc stdin input
all_datasets <- read.table(input_dat)

## run function with datatable input
all_datasets <- run_geocode(all_datasets)

## write out as stdout
write.table(all_datasets, stdout())