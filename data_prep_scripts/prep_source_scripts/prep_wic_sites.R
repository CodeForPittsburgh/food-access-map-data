
## script to clean up original PA WIC source (by fitting to schema); data pulled from PA WIC website

## load libs / set up
library(dplyr)
write_loc <- "food-data/Cleaned_data_files/"

## ----------------------- read in data_model
data_mod <- readxl::read_excel("schema.xlsx", sheet = "master_table") %>% 
  filter(!str_detect(STATUS, "remove|REMOVE|eliminate")) 

## create empty dataframe according to data model; (elegant approach suggested by Connor that perserves data types)
dat0 <- data_mod %>% 
  select(field, type) %>% 
  mutate(value = case_when(type %in% c("string", "date") ~ list("a"), 
                           type %in% c("int", "float") ~ list(1),
                           type %in% "bool" ~ list(NA))) %>%
  select(-type) %>% 
  tidyr::pivot_wider(names_from = "field", values_from = "value") %>% 
  purrr::map_dfr(unlist) %>% 
  slice(-1)


#  ---------------------------------WIC
# read in wicresults.json dataset
library(jsonlite)
library(janitor)

WIC <- fromJSON("food-data/new-datasets/wicresults.json")$Result %>%
  clean_names()

WIC <- dat0 %>% 
  bind_rows(WIC %>% 
              mutate(address = ifelse(is.na(street_addr_line2), street_addr_line1, paste(street_addr_line1, street_addr_line2)),
                     original_id = NA) %>%
              select(name = store_name, 
                     address, 
                     city,
                     state, 
                     zip_code,
                     original_id)) %>% 
  rowwise() %>%
  mutate(source_org = "PA WIC",
         source_file = "wicresults.json",
         latlng_source = "na",
         food_bucks = NA,
         SNAP = NA,
         WIC = 1,
         FMNP = NA,
         fresh_produce = NA,
         free_distribution = 0, 
         open_to_spec_group = 0,
         data_issues = "no type;no phone;no date/time info") %>% 
  ungroup()

write_csv(WIC, paste0(write_loc, "cleaned_PA_WIC.csv"))

###--- clean up
rm(dat0, data_mod, write_loc, WIC)
