#this script is to show how to:
##load in geometries from TIGER (or other sources)
##join and filter against the food map dataset

#load libraries
library(tidyverse)
library(sf)
library(tigris)
library(leaflet)

#load food map data
my_data <- read_csv("https://raw.githubusercontent.com/CodeForPittsburgh/food-access-map-data/master/merged_datasets.csv")

my_data

#create simple feature point from lon/lat
my_data <- my_data %>% 
  st_as_sf(coords = c("longitude", "latitude"), crs = "NAD83")

#load pa and county geometries from TIGER
pa_state <- states(cb = TRUE) %>% 
  filter(NAME == "Pennsylvania")

ac_county <- tigris::counties(state = "Pennsylvania", cb = TRUE) %>% 
  filter(NAME == "Allegheny") %>% 
  select(NAME)

#set bounding box for static map
bounding_box <- pa_state %>% 
  st_bbox()

#make static map
my_data %>% 
  st_join(ac_county) %>% 
  ggplot() +
  geom_sf(aes(color = NAME), alpha = .3, size = .5) +
  geom_sf(data = ac_county, fill = NA) +
  geom_sf(data = pa_state, fill = NA) +
  coord_sf(xlim = c(bounding_box[1], bounding_box[3]), 
           ylim = c(bounding_box[2], bounding_box[4])) +
  labs(color = "County") +
  theme_void()

#make interactive leaflet map

## join data
my_data_joined <- my_data %>% 
  st_join(ac_county) %>% 
  replace_na(list(NAME = "Other"))

#create color palette for dots
county_palette <- colorFactor(palette = "Set1", domain = my_data_joined$NAME, reverse = TRUE)

## make map
leaflet(pa_state) %>% 
  addTiles() %>% 
  addPolygons(color = "#444444",
              stroke = TRUE,
              fillOpacity = 0,
              opacity = 1,
              weight = 2) %>% 
  addPolygons(data = ac_county,
              color = "#444444",
              stroke = TRUE,
              fillOpacity = 0,
              opacity = 1,
              weight = 2) %>% 
  addCircles(data = my_data_joined,
             color = ~county_palette(NAME),
             opacity = .1)
           