## load libs
library(tidyverse)
library(googlesheets)
library(janitor)
library(Hmisc)
source("data_prep_scripts/support_funs.R")
# source("functions.R")

## read loc
read_loc <- "food-data/PFPC_data_files/"

## ----------------------- read in data_model
# data_mod <- gs_read(gs_title("fields_and_descriptions"))
data_mod <- readxl::read_excel(paste0(read_loc, "fields_and_descriptions.xlsx"))

dat_mod_col_names <- data_mod %>% pull(field)

## create empty dataframe according to data model
dat1 <- data.frame(matrix(ncol = length(dat_mod_col_names), nrow = 0))
colnames(dat1) <- dat_mod_col_names

## clean up
rm(data_mod, dat_mod_col_names)

## ----------------------- data-conveniencesupermarkets
dat2 <- "data-conveniencesupermarkets.xlsx"
# data_convenience <- gs_read(gs_title(dat2))
data_convenience <- readxl::read_excel(paste0(read_loc, dat2))


## identify all NA entries
empty_entries <- data_convenience %>% tidyr::gather(key = "key", value = "value", -`Client ID`) %>% 
  group_by(`Client ID`) %>% 
  summarise(remove_true = sum(is.na(value)) == n()) %>% 
  filter(remove_true) %>% 
  pull(`Client ID`)

data_convenience <- data_convenience %>% filter(!`Client ID` %in% empty_entries)

## fit to data model
data_convenience <- dat1 %>% 
  bind_rows(data_convenience %>% 
              mutate(address = ifelse(is.na(`Street #`), 
                                      `Street Name`, paste(`Street #`, `Street Name`))) %>% 
              select(name = Name,
                     type = Category,
                     address, 
                     state = State, 
                     zip_code = Zip, 
                     latitude = Lat, 
                     longitude = Lon)) %>% 
  mutate(source = dat2)
## clean up
rm(empty_entries)

## ----------------------- Allegheny_County_Farmers_Markets_Locations_2017
dat3 <- "Allegheny_County_Farmers_Markets_Locations_2017.xlsx"

# agh_farm_markets <- gs_read(gs_title(dat3))
agh_farm_markets <- readxl::read_excel(paste0(read_loc, dat3))

multi_day_info <- vector("list", length = nrow(agh_farm_markets))

for(i in 1:nrow(agh_farm_markets)) {
  multi_day_info[[i]] <- weekday_calc(agh_farm_markets$Day_Time[i]) %>% 
    mutate(FID = agh_farm_markets$FID[i]) ## for join later
}


multi_day_info <- bind_rows(multi_day_info)

## go wide, to match data model:
multi_day_info <- multi_day_info %>% 
  select(weekday, FID) %>% 
  mutate(value = 1) %>% 
  tidyr::spread(key = "weekday", value = "value") %>% 
  mutate_at(vars(contains("day")), ~replace(., is.na(.), 0))

agh_farm_markets <- dat1 %>% 
  bind_rows(agh_farm_markets %>% 
              left_join(multi_day_info, by = "FID") %>% 
              rowwise() %>% 
              mutate(type = "Farmers Market",
                     weekday_val = str_trim(str_extract(Day_Time, "^[:alpha:]* ")),
                     open_time1 = time_calc(Day_Time)$open_time,
                     close_time1 = time_calc(Day_Time)$close_time,
                     date_from = season_calc(Season)$date_from,
                     date_to = season_calc(Season)$date_to) %>% ## this may not be robust
              select(type, open_time1, close_time1, date_from, date_to,
                     Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday,
                     address = Address,
                     name = Name, 
                     city = City,
                     state = State, 
                     zip_code = Zip, 
                     location_description = Location__,
                     latitude = Y, 
                     longitude = X)) %>% 
  rowwise() %>% 
  mutate(open_time1 = format(as.POSIXct(open_time1, format = "%I:%M %p"), "%H:%M:%S"),
         close_time1 = format(as.POSIXct(close_time1, format = "%I:%M %p"), "%H:%M:%S")) %>% 
  ungroup() %>% 
  mutate(source = dat3)

## fix green grocer entries to be of format Green Grocer (name of establishment)
agh_farm_markets <- agh_farm_markets %>% 
  rowwise() %>% 
  mutate(name = ifelse(str_detect(name, "Green Grocer"),
                       paste0("Green Grocer (", str_split(str_replace_all(name, "’", ""), "[:punct:]")[[1]][1], ")"), name))

## clean up
rm(multi_day_info, i)

## ----------------------- growpghgardens201712
dat4 <- "growpghgardens201712_readin.xlsx"
# growpgh <- gs_read(gs_title(dat4))
growpgh <- readxl::read_excel(paste0(read_loc, dat4))

growpgh <- dat1 %>% 
  bind_rows(growpgh %>% 
              mutate(type = "Grow PGH Garden",
                     state = ifelse(state %in% "Pennsylvania", "PA", state)) %>% ## avoid their overly descript category field to simply types for merged dataset
              select(name = urban_grower,
                     type, 
                     address = street_address,
                     city,
                     state,
                     zip_code,
                     latitude, 
                     longitude
              )) %>% 
  mutate(source = dat4)

## ----------------------- PA (SNAP)
dat5 <- "PA.xlsx"
# PA <- gs_read(gs_title(dat5))
PA <- readxl::read_excel(paste0(read_loc, dat5))

PA <- dat1 %>% 
  bind_rows(PA %>% filter(County %in% "ALLEGHENY") %>% 
              mutate(address = ifelse(is.na(ADDRESS2), ADDRESS, paste(ADDRESS, ADDRESS2)), 
                     SNAP = 1) %>% 
              select(name = STORE_NAME, 
                     longitude,
                     latitude, 
                     address, # check linking together is correct
                     city = CITY,
                     state = STATE, 
                     zip_code = ZIP5)) %>% 
  mutate(source = dat5)

## -----------------------  pfpc - fresh corners
# dat6a <- "PFPC Member Datasets.xlsx"
dat6b <- "Just Harvest - Fresh Corners Stores.xlsx"

# pfpc_fresh_corners <- gs_read(gs_title(dat6a), ws = dat6b)

pfpc_fresh_corners <- readxl::read_excel(paste0(read_loc, dat6b))

pfpc_fresh_corners <- dat1 %>% 
  bind_rows(pfpc_fresh_corners %>% 
              mutate(food_bucks = ifelse(`Participates in Food Bucks SNAP Incentive Program` %in% "yes", 
                                         1, 0),
                     type = "Convenience Store", 
                     state = "PA") %>% ## assume state 
              select(name = `Corner Store`,
                     address = Address,
                     city = City,
                     state,
                     zip_code = Zip,
                     food_bucks,
                     type)) %>% 
  mutate(source = dat6b)

## -----------------------   pfpc - fresh access markets
# dat7a <- "PFPC Member Datasets"
dat7b <- "Just Harvest - Fresh Access Markets.xlsx"
# pfpc_fresh_access_markets <- gs_read(gs_title(dat7a), ws = dat7b)
pfpc_fresh_access_markets <- readxl::read_excel(paste0(read_loc, dat7b))

pfpc_fresh_access_markets <- dat1 %>% 
  bind_rows(pfpc_fresh_access_markets %>% 
              mutate(uid = 1:n(),
                     date_from = str_split(Season, "-")[[1]][1],
                     date_to = str_split(Season, "-")[[1]][2],
                     food_bucks = ifelse(`Participates in Food Bucks SNAP Incentive program` %in% "yes", 1, 0),
                     type = "Farmers Market",
                     open_time1 = as.character(open_time1),
                     close_time1 = as.character(close_time1)) %>% 
              select(uid,
                     name = Market,
                     address,
                     street_one,
                     street_two,
                     city,
                     state,
                     zip_code,
                     date_from,
                     date_to,
                     open_time1, 
                     close_time1, 
                     location_description = description,
                     food_bucks) %>% 
              left_join(pfpc_fresh_access_markets %>% 
                          mutate(uid = 1:n(), fill_val = 1) %>% 
                          select(uid, fill_val, weekday) %>% 
                          tidyr::spread(key = "weekday", value = "fill_val"),
                        by = "uid") %>% 
              select(-uid)) %>% 
  mutate(source = dat7b)

## ----------------------- pfpc green grocer
# dat8a <- "PFPC Member Datasets"
dat8b <- "GPCFB - Green Grocer.xlsx"
# pfpc_green_grocer <- gs_read(gs_title(dat8a), ws = dat8b)
pfpc_green_grocer <- readxl::read_excel(paste0(read_loc, dat8b))

pfpc_green_grocer <- dat1 %>% 
  bind_rows(pfpc_green_grocer %>% 
              rowwise() %>% 
              mutate(uid = 1:n(), 
                     open_time1 = str_split(str_split(`Date/Time`, "\n")[[1]][2], "-")[[1]][1],
                     close_time1 = str_split(str_split(`Date/Time`, "\n")[[1]][2], "-")[[1]][2],
                     food_bucks = ifelse(`Participates in Food Bucks SNAP Incentive Program` %in% "yes", 1, 0),
                     name = paste0("Green Grocer ", "(", name, ")")) %>% 
              ungroup() %>% 
              select(name, 
                     address, 
                     city, 
                     state, 
                     zip_code, 
                     street_one, 
                     street_two, 
                     location_description = Description,
                     open_time1, 
                     close_time1, 
                     food_bucks,
                     uid) %>% 
              left_join(pfpc_green_grocer %>% 
                          mutate(uid = 1:n(), fill_val = 1) %>% 
                          rowwise() %>% 
                          mutate(day = str_trim(str_split(`Date/Time`, "\n")[[1]][1])) %>% 
                          ungroup() %>% 
                          select(uid, day, fill_val) %>% tidyr::spread(key = "day", value = "fill_val"),
                        by = "uid") %>% 
              select(-uid)) %>% 
  rowwise() %>% 
  mutate(open_time1 = format(as.POSIXct(open_time1, format = "%I:%M %p"), "%H:%M:%S"),
         close_time1 = format(as.POSIXct(close_time1, format = "%I:%M %p"), "%H:%M:%S")) %>% 
  ungroup() %>% 
  mutate(source = dat8b)


## ----------------------- pfpc - additional food bucks
# dat9a <- "PFPC Member Datasets"
dat9b <- "Additional Food Bucks sites.xlsx"
# pfpc_more_food_bucks <- gs_read(gs_title(dat9a), ws = dat9b)

pfpc_more_food_bucks <- readxl::read_excel(paste0(read_loc, dat9b))

pfpc_more_food_bucks <- pfpc_more_food_bucks %>% slice(1:3)
pfpc_more_food_bucks <- dat1 %>% 
  bind_rows(pfpc_more_food_bucks %>% 
              mutate(food_bucks = 1) %>% 
              select(name = Name, 
                     address = Address, 
                     city, 
                     state,
                     zip_code,
                     food_bucks)) %>% 
  mutate(source = dat9b)

## ----------------------- *Updated 2019 summer food sites
dat10 <- "Summer_Meal_Sites_2019.xlsx"
summer_site_2019 <- readxl::read_excel(paste0(read_loc, dat10))

## filter to PA, Allegeheny, status = Open
summer_site_2019 <- summer_site_2019 %>% filter(siteState %in% "PA", County %in% "Allegheny", siteStatus %in% "Open")
max_NA <- function(x) ifelse( !all(is.na(x)), max(x, na.rm=T), NA)

summer_site_2019 <- dat1 %>% 
  bind_rows(summer_site_2019 %>% 
              rowwise() %>% 
              mutate(type = "Summer Food Site",
                     address = str_split(siteAddress, "[:alpha:]*,")[[1]][1], 
                     open_to_spec_group = 1,
                     date_from = str_split(startDate, "T")[[1]][1],
                     date_to = str_split(endDate,"T")[[1]][2]) %>% 
              ungroup() %>% 
              select(name = siteName,
                     type, 
                     address,
                     city = siteCity,
                     state = siteState,
                     zip_code = siteZip,
                     date_from,
                     date_to,
                     latitude = Y,
                     longitude = X,
                     OBJECTID,
                     open_to_spec_group) %>% 
              left_join(summer_site_2019 %>% select(OBJECTID, daysofOperation) %>%
                          tidyr::separate(daysofOperation, sep = ",", 
                                          into = c("X1", "X2", "X3", "X4", "X5", "X6", "X7")) %>% 
                          tidyr::gather(key = "key", value = "value", -OBJECTID) %>% 
                          filter(!is.na(value)) %>% 
                          mutate(value2 = ifelse(value %in% "M", "Monday", NA),
                                 value2 = ifelse(value %in% "T", "Tuesday", value2),
                                 value2 = ifelse(value %in% "W", "Wednesday", value2),
                                 value2 = ifelse(value %in% "TH", "Thursday", value2),
                                 value2 = ifelse(value %in% "F", "Friday", value2),
                                 value2 = ifelse(value %in% "SA", "Saturday", value2),
                                 value2 = ifelse(value %in% "S", "Sunday", value2)) %>% 
                          mutate(value3 = 1) %>% 
                          tidyr::spread(key = "value2", value = "value3") %>% 
                          select(OBJECTID, Monday, Tuesday, Wednesday, Thursday,
                                 Friday, Saturday, Sunday) %>%
                          group_by(OBJECTID) %>%
                          summarise_all(max_NA),
                        by = "OBJECTID") %>% 
              left_join(summer_site_2019 %>% 
                          select(OBJECTID, contains("Time")) %>% 
                          tidyr::gather(key = "key", value = "value", -OBJECTID) %>% 
                          filter(!is.na(value)) %>% 
                          group_by(OBJECTID) %>% mutate(timing = paste0("time", 1:n())) %>% 
                          select(-key) %>% 
                          tidyr::spread(key = "timing", value = "value") %>% 
                          mutate(open_time1 = str_split(time1, " ")[[1]][1],
                                 close_time1 = str_split(time1, " ")[[1]][3],
                                 open_time2 = str_split(time2, " ")[[1]][1],
                                 close_time2 = str_split(time2, " ")[[1]][3]) %>% 
                          select(-time1, -time2), 
                        by = "OBJECTID") %>% 
              select(-OBJECTID)) %>% 
  rowwise() %>%
  mutate(open_time1 = format(as.POSIXct(paste(str_split(open_time1, "[:alpha:]")[[1]][1],
                                              str_sub(open_time1, -2)), format = "%I:%M %p"), "%H:%M:%S"),
         open_time2 = format(as.POSIXct(paste(str_split(open_time2, "[:alpha:]")[[1]][1],
                                              str_sub(open_time2, -2)), format = "%I:%M %p"), "%H:%M:%S"),
         close_time1 = format(as.POSIXct(paste(str_split(close_time1, "[:alpha:]")[[1]][1],
                                               str_sub(close_time1, -2)), format = "%I:%M %p"), "%H:%M:%S"),
         close_time2 = format(as.POSIXct(paste(str_split(close_time2, "[:alpha:]")[[1]][1],
                                               str_sub(close_time2, -2)), format = "%I:%M %p"), "%H:%M:%S")) %>% 
  ungroup() %>% 
  mutate(source = dat10)

## ----------------------- Allegheny County WIC Vendor Locations
dat11 <- "Allegheny_County_WIC_Vendor_Locations.xlsx"
# algh_vendor_loc <- gs_read(gs_title(dat11))
algh_vendor_loc <- readxl::read_excel(paste0(read_loc, dat11))

##cleaning column names to maintain consistency
algh_vendor_loc <- clean_names(algh_vendor_loc) %>% drop_na(address) 

# dat_mod <- setNames(data.frame(matrix(ncol =length(data_model_fields),nrow=0)),data_model_fields) 
data_alghny_vendor_loc <-  dat1 %>% 
  bind_rows(algh_vendor_loc %>% mutate(state="PA",
                                       WIC = 1) %>%
              select(name,address,city=municipa_1,zip_code=zip_codes,state, WIC)) %>% 
  mutate(source = dat11)

## clean up
rm(algh_vendor_loc)

## ----------------------- Merge all datasets into one

all_datasets <- data_convenience %>% 
  bind_rows(agh_farm_markets) %>% ## fixed?
  bind_rows(growpgh) %>% 
  bind_rows(PA) %>% 
  bind_rows(pfpc_fresh_corners) %>% 
  bind_rows(pfpc_fresh_access_markets) %>% 
  bind_rows(pfpc_green_grocer) %>%  ## fixed
  bind_rows(pfpc_more_food_bucks) %>% 
  bind_rows(summer_site_2019) %>% ## fixed
  bind_rows(data_alghny_vendor_loc) %>% 
  mutate(id = 1:n()) 

## apply rules
all_datasets <- all_datasets %>% 
  mutate(SNAP = ifelse(type %in% "Farmers Market", 1, SNAP),
         SNAP = ifelse(food_bucks %in% 1, 1, SNAP),
         FMNP = ifelse(food_bucks %in% 1, 1, FMNP),
         food_bucks = ifelse(type %in% "Farmers Market", 1, food_bucks))

## fix street one and street two to be address (per 07/03/2019 meeting)
all_datasets <- all_datasets %>% 
  mutate(address = ifelse(is.na(address) & !is.na(street_one), 
                          paste(street_one, "&", street_two), 
                          address)) 


## clean up
rm(dat1,
data_convenience, dat2,
agh_farm_markets, dat3,
growpgh, dat4,
PA, dat5,
pfpc_fresh_corners, dat6b,
pfpc_fresh_access_markets, dat7b,
pfpc_green_grocer, dat8b,
pfpc_more_food_bucks, dat9b,
summer_site_2019, dat10,
data_alghny_vendor_loc, dat11,
max_NA,
season_calc,
time_calc,
weekday_calc,
read_loc)
