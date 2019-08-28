library(tidyverse)
library(sf)
library(ggmap)
library(tigris)
library(rgeos)
library(rstudioapi)

# Google API key needed - paste only string without quotes
password <- askForPassword()
register_google(key=password)

## Geocoding locations without latitude and longitude
food <- all_datasets

# create small dataset with items without geography
food_small <- food[is.na(food$longitude), ]
food_small <- food_small %>% mutate(location=paste0(address, ", ", city, ", ", state, " ", zip_code))

# add lat/lon for locations without geography (need google api)
food_small <- mutate_geocode(food_small, location)

# replace empty lat/long in original data
food$lon <- food_small[match(food$id, food_small$id), "lon"]
food$lat <- food_small[match(food$id, food_small$id), "lat"]
food$longitude[is.na(food$longitude)] <- food$lon[is.na(food$longitude)]
food$latitude[is.na(food$latitude)] <- food$lat[is.na(food$latitude)]
food <- select(food, -c(lat, lon))

## Point in polygon - census tract
# Get Allegheny County census tracts from Tigris package
pa_tracts <- tracts(42)

# Convert data to sf and set the same crs
pa_tracts <- st_as_sf(pa_tracts)
food_coord <- st_as_sf(food, coords = c("longitude", "latitude"))
st_crs(food_coord) <- st_crs(pa_tracts)

# PGH wards
wards <- st_read("food-data/Wards.shp") 
## All of the "Wards" files have to be downloaded. 
## I don't know if you can link to the raw github content.
st_crs(wards) <- st_crs(pa_tracts)

# PGH neighborhoods
hoods <- st_read("food-data/Neighborhoods_.shp")
st_crs(hoods) <- st_crs(pa_tracts)

# PGH council districts
districts <- st_read("food-data/City_Council_Districts.shp")
st_crs(districts) <- st_crs(pa_tracts)

# Join geographies to data
food_geo <-
  cbind(food, 
        st_join(food_coord, pa_tracts, join = st_intersects)["GEOID"] %>% st_drop_geometry(),
        st_join(food_coord, wards, join = st_intersects)["ward"] %>% st_drop_geometry(),
        st_join(food_coord, hoods, join = st_intersects)["hood"] %>% st_drop_geometry(),
        st_join(food_coord, districts, join = st_intersects)["council"] %>% st_drop_geometry()
  )

## Add MRFEI score to each row
mrfei_list <- readxl::read_excel("food-data/PFPC_data_files/2_16_mrfei_data_table.xls")
mrfei_list <- mrfei_list %>% filter(state %in% "PA")

food_geo$MRFEI_score <- mrfei_list[match(food_geo$GEOID, mrfei_list$fips), "mrfei"]

food_geo <- food_geo %>% left_join(mrfei_list %>% select(GEOID = fips, mrfei), by = "GEOID") %>% 
  mutate(MRFEI_score = mrfei) %>% select(-mrfei) 

readr::write_csv(food_geo, "merged_datasets.csv")