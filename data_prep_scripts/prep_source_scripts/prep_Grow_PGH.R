# script to clean up original Grow PGH (by fitting to schema); data provided by Grow PGH via Rayden Sorock 06-25-2021

## load libs / set up
library(dplyr)
read_loc1 <- "food-data/PFPC_data_files/" ## original file source
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

##  ----------------- growgardenpgh
dat2 <- "GP_garden_directory_listing-20210322.csv" 
growpgh <- read_csv(paste0(read_loc1, dat2)) 

growpgh <- dat0 %>%
  bind_rows(growpgh %>%
              mutate(state = ifelse(directory_location__state %in% "Pennsylvania", "PA", directory_location__state),
                     zip_code = as.character(directory_location__zip)) %>%
              select(name = content_post_title,
                     address = directory_location__street,
                     city = directory_location__city,
                     state,
                     zip_code,
                     latitude = directory_location__lat,
                     longitude = directory_location__lng,
                     phone = directory_contact__phone,
                     url = directory_contact__website,
                     location_description = directory_category)) %>%
  rowwise() %>%
  mutate(source_org = "Grow Pittsburgh",
         source_file = dat2,
         type = "Grow PGH Garden",
         latlng_source = "Grow Pittsburgh",
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

###--- clean up
rm(dat0, data_mod, read_loc1, write_loc, dat2, growpgh)
