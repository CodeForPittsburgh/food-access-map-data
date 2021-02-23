#!/usr/bin/Rscript

# --------------------------- info
# name: auto_text_process_name.R
# authors: Max Chis | Catalina Moreno | Connor Tompkins
# last update: 2021-01-05
# info: This script reads in output from auto_agg_clean_data.R and works to
#       text process the name field in an effort to assign type (e.g. for large chain grocery stores etc)
#       this is a mintor step in workflow, but populating the type fields helps the map
#       results are written out as stdout() for next step in data prep


# -------------------------- script
## load pkg
# if (!require("tidyverse", character.only = TRUE)) {
#   suppressWarnings(install.packages("tidyverse", dependencies = TRUE))
# }
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(stringr))

## hardcode look up tables
supermarket <- c("ALDI", 
                 "TARGET", 
                 "KUHN",
                 "SAMS CLUB", 
                 "GIANT EAGLE", 
                 "GORDON FOOD SERVICE", 
                 "WALMART","WAL MART", 
                 "KMART", 
                 "COSTCO", 
                 "WHOLE FOODS", 
                 "TRADER JOES", 
                 "SAVALOT", "SAVEALOT")

convenience_store <- c("COGO",
                       "CVS", 
                       "WALGREEN",
                       "GETGO","GET GO", 
                       "DOLLAR GENERAL",
                       "FAMILY DOLLAR", 
                       "DOLLAR TREE", 
                       "SHEETZ", 
                       "SUNOCO", 
                       "SPEEDWAY", 
                       "7-ELEVEN", "ELEVEN",
                       "RITE AID", 
                       "APLUS",
                       "PAR MAR STORE", 
                       "UNI MART", "UNIMART",
                       "CIRCLE K")


## function to assign type
assign_type <- function(name, type) {
  x <- str_to_upper(name)
  if(str_detect(name, "Green Grocer")) {
    res <- type
  }
  else if(any(str_detect(x, convenience_store))) {
    res <- "convenience store"
  }
  else if(any(str_detect(x, supermarket))) {
    res <- "supermarket"
  }
  else {
    res <- type
  }
  return(res)
}

## apply function to dataset
fix_type_info <- function(input_dat) {
  ## read.table() bc stdin input
  all_datasets <- read.table(input_dat) 
  
  all_datasets <- all_datasets %>% 
    rowwise() %>%
    mutate(type = assign_type(name = name, type = type)) %>% 
    ungroup() 
    
    ## write out as stdout
    write.table(all_datasets, stdout())
}

## read in stdin() from previous step
input <- file('stdin', 'r')

## run function with CLI input
fix_type_info(input_dat = input) 