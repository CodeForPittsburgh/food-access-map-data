## data sources for new scheme
read_loc <- "food-data/PFPC_data_files/"
write_loc <- "food-data/Cleaned_data_files/" ## check if this is how we want to do it

## ----------------------- read in data_model
data_mod <- readxl::read_excel("schema.xlsx", sheet = "master_table")

dat_mod_col_names <- data_mod %>% 
  filter(!str_detect(STATUS, "remove|REMOVE|eliminate")) %>% 
  pull(field)

## create empty dataframe according to data model
dat1 <- data.frame(matrix(ncol = length(dat_mod_col_names), nrow = 0), stringsAsFactors = FALSE)
colnames(dat1) <- dat_mod_col_names



## ----------------------- 1 Allegheny county farmers markets 
dat3 <- "2019_farmers-markets.csv"

agh_farm_markets <- read_csv(paste0(read_loc, dat3))

agh_farm_markets <- dat1 %>% 
  bind_rows(agh_farm_markets %>% 
              mutate(flag = str_detect(Season, "\\-"),
                     date_from = ifelse(flag, str_extract(Season, "^[:alpha:]{1,}[:space:]*[:digit:]*"), "January"),
                     date_to = ifelse(flag, str_extract(Season, "[:alpha:]{1,}[:space:]*[:digit:]*$"), "December"),
                     Name = ifelse(str_detect(Name, "Green Grocer"), paste0("Green Grocer at ", "", Name, ""), Name)) %>% ## fix green grocer entries to be of format Green Grocer (name of establishment)
              select(name = Name,
                     address = Street_Address,
                     city = City,
                     state = State,
                     zip_code = Zip,
                     location_description = Additional_Directions,
                     latitude = Latitude, 
                     longitude = Longitude,
                     date_from,
                     date_to) %>% 
              mutate(source_org = "PFPC",
                     source_file = dat3,
                     county = "Allegheny",
                     latlng_source = "agency",
                     type = "farmer's market",
                     food_bucks = ifelse((type %in% "farmer's market") && (city %in% "Pittsburgh"), 1, 0),
                     SNAP = ifelse((food_bucks %in% 1) | (type %in% "farmer's market"), 1, 0), 
                     WIC = 0,
                     FMNP = ifelse((type %in% "farmer's market") && (city %in% "Pittsburgh") | (WIC %in% 1), 1, 0),
                     fresh_produce = ifelse(type %in% c("farmer's market", "supermarket"), 1, 0),
                     free_distribution = 0, 
                     open_to_spec_group = 0, 
                     data_issues = "timestamps in season column;no phone; no url; county assumed; source assumed"))

write_csv(agh_farm_markets, paste0(write_loc, "cleaned_agh_farm_markets.csv"))
rm(dat3, agh_farm_markets)

# 2 ---------------------------------PA.xlsx (SNAP)
dat5 <- "PA.xlsx"
# PA <- gs_read(gs_title(dat5))
PA <- readxl::read_excel(paste0(read_loc, dat5))

PA <- dat1 %>% 
  bind_rows(PA %>% filter(County %in% "ALLEGHENY") %>% 
              mutate(address = ifelse(is.na(ADDRESS2), ADDRESS, paste(ADDRESS, ADDRESS2)),
                     ZIP5 = as.character(ZIP5)) %>%
              select(name = STORE_NAME, 
                     longitude,
                     latitude, 
                     address, # check linking together is correct
                     city = CITY,
                     state = STATE, 
                     zip_code = ZIP5,
                     county = County)) %>% 
  mutate(source_org = "USDA",
         source_file = dat5,
         latlng_source = "agency",
         food_bucks = ifelse((type %in% "farmer's market") && (city %in% "Pittsburgh"), 1, 0),
         SNAP = 1,
         WIC = 0,
         FMNP = ifelse((type %in% "farmer's market") && (city %in% "Pittsburgh") | (WIC %in% 1), 1, 0),
         fresh_produce = ifelse(type %in% c("farmer's market", "supermarket"), 1, 0),
         free_distribution = 0, 
         open_to_spec_group = 0,
         data_issues = "no type;no phone;no date/time info")

write_csv(PA, paste0(write_loc, "cleaned_PA_SNAP.csv"))
rm(dat5, PA)

## 3 ----------------------- pfpc green grocer
dat8b <- "GPCFB - Green Grocer.xlsx"

pfpc_green_grocer <- readxl::read_excel(paste0(read_loc, dat8b))

pfpc_green_grocer <- dat1 %>% 
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
              mutate(type = "farmer's market",
                     source_org = "PFPC",
                     source_file = dat8b,
                     latlng_source = "Google",
                     food_bucks = ifelse((type %in% "farmer's market") && (city %in% "Pittsburgh"), 1, 0),
                     SNAP = ifelse((food_bucks %in% 1) | (type %in% "farmer's market"), 1, 0), 
                     WIC = 0,
                     FMNP = ifelse((type %in% "farmer's market") && (city %in% "Pittsburgh") | (WIC %in% 1), 1, 0),
                     fresh_produce = ifelse(type %in% c("farmer's market", "supermarket"), 1, 0),
                     free_distribution = 0, 
                     open_to_spec_group = 0, 
                     data_isses = "no lat/long"))

write_csv(pfpc_green_grocer, paste0(write_loc, "cleaned_pfpc_green_grocer.csv"))
rm(dat8b, pfpc_green_grocer)

## 4 ----------------------- Allegheny County WIC Vendor Locations
dat11 <- "Allegheny_County_WIC_Vendor_Locations.xlsx"

algh_vendor_loc <- readxl::read_excel(paste0(read_loc, dat11))

algh_vendor_loc <-  dat1 %>% 
  bind_rows(algh_vendor_loc %>% 
              filter(Ref_ID != -1) %>% 
              select(original_id = Ref_ID,
                     name = Name,
                     address = Address,
                     city = ARC_City,
                     zip_code = ARC_ZIP) %>% 
              mutate(state = "PA",
                     source_file = dat11,
                     source_org = "WPRDC",
                     latlng_source = "Google",
                     type = NA,
                     food_bucks = ifelse((type %in% "farmer's market") && (city %in% "Pittsburgh"), 1, 0),
                     SNAP = ifelse((food_bucks %in% 1) | (type %in% "farmer's market"), 1, 0), 
                     WIC = 1,
                     FMNP = ifelse(((type %in% "farmer's market") && (city %in% "Pittsburgh")) | (WIC %in% 1), 1, 0),
                     fresh_produce = ifelse(type %in% c("farmer's market", "supermarket"), 1, 0),
                     free_distribution = 0,
                     open_to_spec_group = 0,
                     data_issues = "lat/long invalid;no date/time info;state assumed PA"))

write_csv(algh_vendor_loc, paste0(write_loc, "cleaned_agh_wic.csv"))
rm(dat11, algh_vendor_loc)

###--- clean up
rm(dat1, data_mod, dat_mod_col_names, read_loc, write_loc)
