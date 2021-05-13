#!/usr/bin/Rscript

# --------------------------- info
# name: auto_text_process_name.R
# authors: Max Chis | Catalina Moreno | Conor Tompkins
# last update: 2021-05-13
# info: This script reads in output from auto_agg_clean_data.R and works to
#       text process the name field in an effort to assign type (e.g. for large chain grocery stores etc)
#       this is a mintor step in workflow, but populating the type fields helps the map
#       results are written out as stdout() for next step in data prep


# -------------------------- script
## load pkg
# if (!require("tidyverse", character.only = TRUE)) {
#   suppressWarnings(install.packages("tidyverse", dependencies = TRUE))
# }

#conor's auto_text_process_name.R script

#load packages
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(stringr))

#read in data from stdin
all_datasets <- file('stdin', 'r') %>% 
  read.csv()

#create series of regex assigned to categories of type
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
                 "SAVALOT", "SAVEALOT", "Sav-A-Lot", "North Versailles Save A Lot",
                 "Shop N Save",
                 "LEONARD LABRIOLA FOODS",
                 "Pittsburgh Commissary",
                 "Stop N Shop", "STOP & SHOP",
                 "COMMUNITY MARKET",
                 "CORAOPOLIS CASH MARKET",
                 "FRESH THYME FARMERS MARKET",
                 "LAS PALMAS",
                 "TRADER JOE'S",
                 "EAST END FOOD CO-OP",
                 "COMMUNITY MARKET",
                 "COMMUNITY SUPER MKT INC",
                 "COMMUNITY SUPERMARKET",
                 "GROCER") %>% 
  str_to_upper() %>% 
  str_c(collapse = "|")

convenience_store <- c("COGO",
                       "CVS", 
                       "WALGREEN",
                       "GETGO","GET GO", 
                       "DOLLAR GENERAL",
                       "FAMILY DOLLAR", 
                       "DOLLAR TREE", "DOLLARTREE",
                       "SHEETZ", 
                       "SUNOCO", 
                       "SPEEDWAY", 
                       "7-ELEVEN", "ELEVEN", "7-Elelven",
                       "RITE AID", 
                       "APLUS",
                       "PAR MAR STORE", 
                       "UNI MART", "UNIMART",
                       "CIRCLE K",
                       "In & Out Corner Market",
                       "Mckees Mart",
                       "Hanini Market",
                       "Uni-Mart",
                       "Smoke Shop",
                       "Convenience Store",
                       "American Natural",
                       "Mini Mart",
                       "CIO Stores",
                       "BP TO GO",
                       "QUICK STOP",
                       "^TSP",
                       "A & M MARKET",
                       "DYLAMATO'S MARKET",
                       "Big Lots",
                       "SAM'S CLUB") %>% 
  str_to_upper() %>% 
  str_c(collapse = "|")

farmers_markets <- c("JUST HARVEST") %>% 
  str_to_upper() %>% 
  str_c(collapse = "|")


#series of case_when statements to determine type
#test whether the type is missing and whether we can detect the avove regex in the name
all_datasets <- all_datasets %>% 
  mutate(name = str_to_upper(name),
         name = str_squish(name),
         type_old = type) %>% 
  mutate(type = case_when(is.na(type_old) & str_detect(name, "GREEN GROCER") ~ type_old,
                          is.na(type_old) & str_detect(name, convenience_store) ~ "convenience store",
                          is.na(type_old) & str_detect(name, supermarket) ~ "supermarket",
                          is.na(type_old) & str_detect(name, farmers_markets) ~ "farmer's market",
                          type_old == "farmer's market" ~ "farmer's market",
                          #for all other cases, keep the existing type
                          TRUE ~ type_old)) %>% 
  select(-type_old)

write.csv(all_datasets, stdout(), row.names = FALSE)
