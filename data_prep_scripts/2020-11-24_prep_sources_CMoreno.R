## script to clean up original data sources (fit to schema) provided by PFPC
## specific sources include 1) PA SNAP 2) Green Grocer 3) PA WIC 4) Grow PGH

## load libs
library(tidyverse)

## data sources for new scheme
read_loc1 <- "food-data/PFPC_data_files/" ## original file source
read_loc2 <- "food-data/new-datasets/" ## file loc 2020 new data
write_loc <- "food-data/Cleaned_data_files/" ## check if this is how we want to do it

## ----------------------- read in data_model
data_mod <- readxl::read_excel("schema.xlsx", sheet = "master_table")

dat_mod_col_names <- data_mod %>% 
  filter(!str_detect(STATUS, "remove|REMOVE|eliminate")) %>% 
  pull(field)

## create empty dataframe according to data model
dat0 <- data.frame(matrix(ncol = length(dat_mod_col_names), nrow = 0), stringsAsFactors = FALSE)
colnames(dat0) <- dat_mod_col_names


#  ---------------------------------SNAP
dat1 <- "SNAP_Store_Locations.csv"
SNAP <- read_csv(paste0(read_loc2, dat1))

SNAP <- dat0 %>% 
  bind_rows(SNAP %>% filter(State %in% "PA", 
                            County %in% "ALLEGHENY") %>% 
              mutate(address = ifelse(is.na(Address_Line__2), Address, paste(Address, Address_Line__2)),
                     zip_code = as.character(Zip5)) %>%
              select(name = Store_Name, 
                     longitude = Longitude,
                     latitude = Latitude, 
                     address, # check linking together is correct
                     city = City,
                     state = State, 
                     zip_code,
                     county = County,
                     original_id = ObjectId)) %>% 
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

##  ----------------------- pfpc green grocer
dat2 <- "GPCFB - Green Grocer.xlsx"

pfpc_green_grocer <- readxl::read_excel(paste0(read_loc1, dat2))

pfpc_green_grocer <- dat0 %>% 
  bind_rows(pfpc_green_grocer %>% 
              rowwise() %>% 
              mutate(food_bucks = ifelse(`Participates in Food Bucks SNAP Incentive Program` %in% "yes", 1, 0),
                     start_loc = str_locate(name, "\\(")[1,1],
                     end_loc = str_locate(name, "\\)")[1,1],
                     location_description = str_sub(name, (start_loc + 1), (end_loc -1)),
                     start_loc = ifelse(is.na(start_loc), str_length(name), start_loc -1),
                     name = str_trim(str_sub(name, 1, start_loc)),
                     name = paste0("Green Grocer at ", "", name, ""),
                     address = ifelse(is.na(address), paste(street_one, street_two), address)) %>% 
              ungroup() %>% 
              select(name, 
                     address, 
                     city, 
                     state, 
                     zip_code, 
                     location_description, #= Description,
                     food_bucks) %>% 
              rowwise() %>% 
              mutate(type = "farmer's market",
                     source_org = "Greater Pittsburgh Community Food Bank",
                     source_file = dat2,
                     latlng_source = "Google",
                     food_bucks = 1,
                     SNAP = 1, 
                     WIC = 0,
                     FMNP = 1,
                     fresh_produce = ifelse(type %in% c("farmer's market", "supermarket"), 1, NA),
                     free_distribution = 0, 
                     open_to_spec_group = 0, 
                     data_issues = "no lat/long")) %>% 
  ungroup()

write_csv(pfpc_green_grocer, paste0(write_loc, "cleaned_pfpc_green_grocer.csv"))
rm(dat2, pfpc_green_grocer)

##  ----------------------- Allegheny County WIC Vendor Locations
dat3 <- "Allegheny_County_WIC_Vendor_Locations.csv"

WIC <- read_csv(paste0(read_loc2, dat3))

WIC <-  dat0 %>% 
  bind_rows(WIC %>% 
              filter(Ref_ID != -1) %>% 
              select(original_id = Ref_ID,
                     name = Name,
                     address = Address,
                     city = ARC_City,
                     zip_code = ARC_ZIP) %>% 
              rowwise() %>% 
              mutate(state = "PA",
                     source_file = dat3,
                     source_org = "Western Pennsylvania Regional Data Center",
                     latlng_source = "Google",
                     type = NA,
                     food_bucks = NA,
                     SNAP = NA, 
                     WIC = 1,
                     FMNP = NA,
                     fresh_produce = ifelse(type %in% c("farmer's market", "supermarket"), 1, NA),
                     free_distribution = 0,
                     open_to_spec_group = 0,
                     data_issues = "lat/long invalid;no date/time info;state assumed PA;missing type")) %>% 
  ungroup()

write_csv(WIC, paste0(write_loc, "cleaned_agh_wic.csv"))
rm(dat3, WIC)

##  ----------------- growgardenpgh
dat4 <- "growpghgardens201712_readin.xlsx"
growpgh <- readxl::read_excel(paste0(read_loc1, dat4))

growpgh <- dat0 %>%
  bind_rows(growpgh %>%
              mutate(state = ifelse(state %in% "Pennsylvania", "PA", state)) %>%
              select(name = urban_grower,
                     address = street_address,
                     city,
                     state,
                     zip_code,
                     latitude,
                     longitude,
                     original_id = grower_id,
                     url = url) %>%
rowwise() %>%
  mutate(source_org = "Western Pennsylvania Regional Data Center",
         source_file = dat4,
         type = "Grow PGH Garden",
         latlng_source = "Western Pennsylvania Regional Data Center",
         food_bucks = 1, 
         SNAP = 1, 
         WIC = 0,
         FMNP = 1, 
         fresh_produce = 1, 
         free_distribution = 0, 
         open_to_spec_group = 0,
         data_issues = "no date/time;no county info")) %>%
  ungroup()

write_csv(growpgh, paste0(write_loc, "cleaned_growpgh.csv"))
rm(dat4, growpgh)

###--- clean up
rm(dat0, data_mod, dat_mod_col_names, read_loc1, read_loc2, write_loc)
