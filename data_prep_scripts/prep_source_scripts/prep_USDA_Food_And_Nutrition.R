## script to clean up original data sources (by fitting to schema); data provided by PFPC
## specific sources include 1) PA SNAP 2) Grow PGH

## load libs
library(tidyverse)

## data sources for new scheme
read_loc1 <- "food-data/PFPC_data_files/" ## original file source
write_loc <- "food-data/Cleaned_data_files/" ## check if this is how we want to do it

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

# object$features %>% str()

SNAP <- object$features$attributes %>% 
  as_tibble() #%>% mutate_all(as.character)

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
rm(dat1, SNAP)


##  ----------------- growgardenpgh
dat2 <- "growpghgardens201712_readin.xlsx"
growpgh <- readxl::read_excel(paste0(read_loc1, dat2)) 

growpgh <- dat0 %>%
  bind_rows(growpgh %>%
              mutate(state = ifelse(state %in% "Pennsylvania", "PA", state),
                     original_id = as.character(grower_id),
                     zip_code = as.character(zip_code)) %>%
              select(name = urban_grower,
                     address = street_address,
                     city,
                     state,
                     zip_code,
                     latitude,
                     longitude,
                     original_id,
                     url = url)) %>%
  rowwise() %>%
  mutate(source_org = "Western Pennsylvania Regional Data Center",
         source_file = dat2,
         type = "Grow PGH Garden",
         latlng_source = "Western Pennsylvania Regional Data Center",
         food_bucks = 0, 
         SNAP = 1, 
         WIC = 0,
         FMNP = 1, 
         fresh_produce = 1, 
         free_distribution = 0, 
         open_to_spec_group = 0,
         data_issues = "no date/time;no county info") %>%
  ungroup()

write_csv(growpgh, paste0(write_loc, "cleaned_growpgh.csv"))
rm(dat2, growpgh)

###--- clean up
rm(dat0, data_mod, read_loc1, write_loc)
