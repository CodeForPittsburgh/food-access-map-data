library(tidyverse)
library(sf)
library(ggmap)
library(tigris)
library(rgeos)
library(rstudioapi)

# Google API key needed - paste only string without quotes
password <- askForPassword(prompt = "Enter Google API Key")
register_google(key=password)

## Geocoding locations without latitude and longitude
food <- all_datasets ## link to dataframe from clean data aggregation step

# create small dataset with items without geography
food_small <- food %>% filter(is.na(longitude) | is.na(latitude))
food_small <- food_small %>% mutate(location=paste0(address, ", ", city, ", ", state, " ", zip_code))

# add lat/lon for locations without geography (need google api)
food_small <- mutate_geocode(food_small, location)

# replace empty lat/long in original data
food <- food %>% left_join(food_small %>% select(id, lon, lat), by = "id")

food <- food %>% mutate(longitude = ifelse(is.na(longitude), lon, longitude),
                        latitude = ifelse(is.na(latitude), lat, latitude))

food <- food %>% select(-lat, -lon)

## March 2020 - turning below steps off for now, as MRFEI is no longer part of the data schema 

# ## Point in polygon - census tract
# # Get Allegheny County census tracts from Tigris package
# pa_tracts <- tracts(42, cb = TRUE)
# 
# # Convert data to sf and set the same crs
# pa_tracts <- st_as_sf(pa_tracts)
# food_coord <- st_as_sf(food, coords = c("longitude", "latitude"))
# st_crs(food_coord) <- st_crs(pa_tracts)
# 
# # PGH wards
# wards <- st_read("food-data/Wards.shp") 
# ## All of the "Wards" files have to be downloaded. 
# ## I don't know if you can link to the raw github content.
# st_crs(wards) <- st_crs(pa_tracts)
# 
# # PGH neighborhoods
# hoods <- st_read("food-data/Neighborhoods_.shp")
# st_crs(hoods) <- st_crs(pa_tracts)
# 
# # PGH council districts
# districts <- st_read("food-data/City_Council_Districts.shp")
# st_crs(districts) <- st_crs(pa_tracts)
# 
# # Join geographies to data
# food_geo <-
#   cbind(food, 
#         st_join(food_coord, pa_tracts, join = st_intersects)["GEOID"] %>% st_drop_geometry(),
#         st_join(food_coord, wards, join = st_intersects)["ward"] %>% st_drop_geometry(),
#         st_join(food_coord, hoods, join = st_intersects)["hood"] %>% st_drop_geometry(),
#         st_join(food_coord, districts, join = st_intersects)["council"] %>% st_drop_geometry()
#   )
# 
# ## Add MRFEI score to each row
# mrfei_list <- readxl::read_excel("food-data/PFPC_data_files/2_16_mrfei_data_table.xls")
# mrfei_list <- mrfei_list %>% filter(state %in% "PA")
# 
# # food_geo$MRFEI_score <- mrfei_list[match(food_geo$GEOID, mrfei_list$fips), "mrfei"]
# 
# food_geo <- food_geo %>% left_join(mrfei_list %>% select(GEOID = fips, mrfei), by = "GEOID") %>% 
#   mutate(MRFEI_score = mrfei) %>% select(-mrfei) 
# 
# # readr::write_csv(food_geo, "merged_datasets.csv")