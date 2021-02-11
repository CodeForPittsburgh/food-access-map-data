library(stringr)
library(purrr)
library(dplyr)
library(tidygeocoder)

run_geocode <- function(df) {
  Sys.setenv(GEOCODIO_API_KEY="64735d54370c29c4458c32d44306323007a0d60")
  
  # STEP 1 
  df_filter <- df %>% 
    filter(is.na(latitude) | is.na(longitude) | latitude==0 | longitude==0) 
  
  # STEP 2
  df_transmute <- df_filter %>% transmute(id = id, address = str_c(address, city, state, zip_code, sep = ", "))
  
  # STEP 3
  df_geocode <- geocode(df_transmute, address, geo="osm", cascade_order=c("osm", "geocodio"))
  
  # STEP 4
  df <- df %>% left_join(df_geocode %>% select(id, long, lat), by = "id")
  df <- df %>% mutate(longitude = ifelse(is.na(longitude), long, longitude),
                      latitude = ifelse(is.na(latitude), lat, latitude),
                      latlng_source = ifelse(is.na(latlng_source), "Mapbox Geocode", latlng_source))
  df <- df %>% select(-lat, -long) 
  
  return(df)
}