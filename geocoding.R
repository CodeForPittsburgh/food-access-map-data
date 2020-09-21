library(tidyverse)
library(rstudioapi)
library(mapboxapi)

#install mapboxapi package from github if not already installed
#remotes::install_github("walkerke/mapboxapi")

# Mapbox API key needed - paste only string without quotes
mb_access_token(askForPassword(prompt = "Enter Mapbox API Key"), install = TRUE, overwrite = TRUE)
readRenviron("~/.Renviron")

df <- list.files("food-data/Cleaned_data_files", full.names = TRUE) %>% 
  set_names() %>% 
  map_dfr(read_csv, col_types = cols(.default = "c"), .id = "file_name") %>% 
  select(file_name, everything())

glimpse(df)

df_geocode <- df %>% 
  filter(is.na(latitude) | is.na(longitude)) %>% 
  transmute(address = str_c(address, city, state, zip_code, sep = ", ")) %>% 
  drop_na(address) %>% 
  mutate(geocode_data = map(address, mb_geocode),
         lon = map_dbl(geocode_data, 1),
         lat = map_dbl(geocode_data, 2))

## Geocoding locations without latitude and longitude
# create small dataset with items without geography

df_geocode <- all_datasets %>% 
  filter(is.na(latitude) | is.na(longitude) | latitude==0 | longitude==0) %>% 
  transmute(address = str_c(address, city, state, zip_code, sep = ", "), id = id) %>% 
  mutate(geocode_data = map(address, mb_geocode),
         lon = map_dbl(geocode_data, 1),
         lat = map_dbl(geocode_data, 2))


# replace empty lat/long in original data
all_datasets <- all_datasets %>% left_join(df_geocode %>% select(id, lon, lat), by = "id")

all_datasets <- all_datasets %>% mutate(longitude = ifelse(is.na(longitude), lon, longitude),
                                        latitude = ifelse(is.na(latitude), lat, latitude),
                                        latlng_source = ifelse(is.na(latlng_source), "Mapbox Geocode", latlng_source))

all_datasets <- all_datasets %>% select(-lat, -lon)

## clean up workspace
rm(df_geocode, df)
