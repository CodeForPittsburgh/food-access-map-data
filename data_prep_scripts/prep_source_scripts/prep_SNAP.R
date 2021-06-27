## script to clean up original PA SNAP source (by fitting to schema); data pulled from USDA website

## load libs / set up
library(tidyverse)
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

#  ---------------------------------SNAP
# point to USDA API
library(httr)
library(jsonlite)
dat1 <- "https://services1.arcgis.com/RLQu0rK7h4kbsBq5/arcgis/rest/services/Store_Locations/FeatureServer/0/query?where=State%20%3D%20'PA'%20AND%20County%20%3D%20'ALLEGHENY'&outFields=*&outSR=4326&f=json"
request <- httr::GET(dat1)
object <- httr::content(request, as = "text", encoding = "UTF-8") %>% 
  jsonlite::fromJSON()


SNAP <- object$features$attributes %>% 
  as_tibble() 

SNAP <- dat0 %>% 
  bind_rows(SNAP %>% filter(State %in% "PA", 
                            County %in% "ALLEGHENY") %>% 
              mutate(address = ifelse(is.na(Address_Line__2), Address, paste(Address, Address_Line__2)),
                     zip_code = as.character(Zip5),
                     original_id = as.character(ObjectId)) %>%
              select(name = Store_Name, 
                     longitude = Longitude,
                     latitude = Latitude, 
                     address, 
                     city = City,
                     state = State, 
                     zip_code,
                     county = County,
                     original_id)) %>% 
  rowwise() %>%
  mutate(source_org = "USDA Food and Nutrition Service",
         source_file = dat1,
         latlng_source = "USDA Food and Nutrition Service",
         food_bucks = NA,
         SNAP = 1,
         WIC = NA,
         FMNP = NA,
         fresh_produce = ifelse(type %in% c("farmer's market", "supermarket"), 1, NA),
         free_distribution = 0, 
         open_to_spec_group = 0,
         data_issues = "no type;no phone;no date/time info") %>% 
  ungroup()

write_csv(SNAP, paste0(write_loc, "cleaned_PA_SNAP.csv"))

###--- clean up
rm(dat0, data_mod, write_loc, dat1, SNAP)
