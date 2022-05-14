#! /usr/bin/env Rscript

# Auto_Merge_Duplicates.R
# A modular version of original "Merge_Duplicates.R", script. 
# Accepts stdin dataframe input, and takes address of Source File Prioritization File as argument
# This script merges duplicate rows -- identified by their duplicate group id's -- together
#  and reconciles disparities in key fields by prioritizing fields based on their source data sets
# Outputs a merged dataset 

library("readr")

args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("Source Field Prioritization csv must be called as first argument", call.=FALSE)
} else if (length(args)==1) {
  sfp_filepath <- args[1]
}

#Clear Merge Log
merge_log <- file.path(here::here('merge.log'))
close( file( merge_log, open="w" ) )

input_file <- file('stdin', 'r')

sfp <- read.csv(sfp_filepath)
md <- read.csv(input_file)
md$merged_record = '0'
md$timestamp = as.character(Sys.time())

source("data_prep_scripts/merge_duplicates_functions.R")
md <- merge_all_duplicates_in_dataframe(md, sfp)

write.csv(md, stdout(), row.names = FALSE)