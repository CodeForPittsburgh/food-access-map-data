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