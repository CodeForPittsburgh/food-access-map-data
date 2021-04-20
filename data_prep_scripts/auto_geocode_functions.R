library(stringr)
library(purrr)
library(dplyr)
library(httr)

#POSSIBLY REMOVE THESE LINES IF WE HAVE TO FOR AUTOMATION
#library(rstudioapi)
#API_KEY <- askForPassword(prompt = "Enter Mapbox API Key")
#--END PROPOSED REMOVES

run_geocode <- function(df) {
  # STEP 1 
  df_filter <- df %>% 
    filter(is.na(latitude) | is.na(longitude) | latitude==0 | longitude==0) 
  
  # STEP 2
  df_transmute <- df_filter %>% transmute(id = id, address = str_c(address, city, state, zip_code, sep = ", "))
  
  # Step 3
  df_geocode <- df_transmute %>% mutate(geometry=map(address, geocode_single))
  
  # Step 4
  df_geocode <- df_geocode %>% mutate(long = unlist(map(geometry, get_longitude)), lat=unlist(map(geometry, get_latitude)))
  df_geocode <- df_geocode %>% select(-geometry)
  
  # STEP 5
  df <- df %>% left_join(df_geocode %>% select(id, long, lat), by = "id")
  df <- df %>% mutate(longitude = ifelse(is.na(longitude), long, longitude),
                      latitude = ifelse(is.na(latitude), lat, latitude),
                      latlng_source = ifelse(is.na(latlng_source), "Mapbox Geocode", latlng_source))
  df <- df %>% select(-lat, -long) 
  
  return(df)
}

geocode_single <- function(search) {
  url <- URLencode(paste("https://api.mapbox.com/geocoding/v5/mapbox.places/", search,".json?access_token=", API_KEY, sep = ""))
  r <- GET(url)
  c <- content(r, as="parsed", type="application/json")
  features <- c[[3]]
  geometry <- paste(features[[1]]$geometry$coordinates, collapse=";")
  return(geometry)
}

get_latitude <- function(geometry) {
  return(as.numeric(unlist(strsplit(geometry, ";")[1][[1]][[2]])))
}

get_longitude <- function(geometry) {
  return(as.numeric(unlist(strsplit(geometry, ";")[1][[1]][[1]])))
}
