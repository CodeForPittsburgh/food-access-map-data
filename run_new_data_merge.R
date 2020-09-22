## purpose: aggregate cleaned data sources
## contributors: Catalina Moreno, Drew Levitt, Max Chis, Conor Tompkins
## last updated: 09/19/2020

## load lib
library(tidyverse)

## enforce data schema
data_mod <- readxl::read_excel("schema.xlsx", sheet = "master_table")

string_var <- dat_mod_col_names <- data_mod %>% 
  filter(!str_detect(STATUS, "remove|REMOVE|eliminate")) %>% 
  filter(type %in% "string") %>% pull(field)

## point to raw data sources 
read_loc <- "food-data/Cleaned_data_files/"

all_datasets <- list.files("food-data/Cleaned_data_files", full.names = TRUE) %>% 
  set_names() %>% 
  map_dfr(read_csv, col_types = cols(.default = "c"), .id = "file_name") %>% 
  select(file_name, everything())

all_datasets

## assign uid
all_datasets <- all_datasets %>% mutate(id = 1:n())

## text process names to apply further type-based rules
suppressWarnings(source("name_text_processing_script.R"))
all_datasets <- all_datasets %>% 
  rowwise() %>%
  mutate(type = assign_type(name = name, type = type)) %>% 
  ungroup()

rm(convenience_store, supermarket, assign_type)

## pass thru geocode step
suppressWarnings(source("geocoding.R"))## runs geocoding (requires a mapbox api key)

## pass thru curent de-dup
# source("data_prep_scripts/de_dup_fun.R") ## hold off on de-dup to compare directly to google places
# food <- de_dup_wrapper(food)

## write out
readr::write_csv(all_datasets, "merged_datasets.csv")

## clean up
# rm(de_dup_wrapper, select_info2)
