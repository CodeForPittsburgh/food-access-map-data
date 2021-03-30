#! /usr/bin/env Rscript

# Auto_Merge_Duplicates.R
# A modular version of original "Merge_Duplicates.R", script. 
# Accepts stdin dataframe input, and takes address of Source File Prioritization File as argument
# This script merges duplicate rows -- identified by their duplicate group id's -- together
#  and reconciles disparities in key fields by prioritizing fields based on their source data sets
# Outputs a merged dataset 

library("readr")

sfp_filepath <- commandArgs(TRUE)
input_file <- file('stdin', 'r')

sfp <- read_csv(sfp_filepath)
md <- read_csv(input_file)
md$merged_record = '0'

source("merge_duplicates_functions.R")
md <- merge_all_duplicates_in_dataframe(md, sfp)

write.table(md, stdout())