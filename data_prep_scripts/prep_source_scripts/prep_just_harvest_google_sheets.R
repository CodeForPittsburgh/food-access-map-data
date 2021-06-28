library(tidyverse)
library(googlesheets4)
library(janitor)

df_schema <- data_mod <- readxl::read_excel("schema.xlsx", sheet = "master_table") %>% 
  filter(!str_detect(STATUS, "remove|REMOVE|eliminate")) 

dat0 <- data_mod %>% 
  select(field, type) %>% 
  mutate(value = case_when(type %in% c("string", "date") ~ list("a"), 
                           type %in% c("int", "float") ~ list(1),
                           type %in% "bool" ~ list(NA))) %>%
  select(-type) %>% 
  tidyr::pivot_wider(names_from = "field", values_from = "value") %>% 
  purrr::map_dfr(unlist) %>% 
  slice(-1)

#for ellie to set up authentication for codeforpittsburgh@gmail.com account
#run this line
googlesheets4::gs4_auth()
#enter "0" to set up new account authentication
#follow in-browser instructions

schema_cols <- c('id', 'source_org', 'source_file', 'original_id', 'type', 'name', 'address', 'city', 
                 'state', 'zip_code', 'county', 'location_description', 'phone', 'url', 'latitude', 
                 'longitude', 'latlng_source', 'date_from', 'date_to', 'SNAP', 'WIC', 'FMNP', 
                 'fresh_produce', 'food_bucks', 'free_distribution', 'open_to_spec_group', 'data_issues')

gs_path <- "https://docs.google.com/spreadsheets/d/1DuzaXafd-2eH5oBlL8JVGZLi_f7Ccj2npqyPoGiusQM/edit?ts=60d28fc9#gid=820493315"  

jh_sheet_names <- sheet_names(gs_path)

#fresh corners
fresh_corners <- read_sheet(gs_path, sheet = jh_sheet_names[1]) %>% 
  rename(name = `Corner Store`,
         address = Address,
         city = City,
         zip_code = Zip,
         SNAP = `Participates in Food Bucks SNAP Incentive Program`) %>% 
  mutate(zip_code = as.character(zip_code)) %>% 
  select(-c(Area, Notes)) %>% 
  mutate(SNAP = case_when(SNAP == "yes" ~ 1,
                          TRUE ~ 0)) %>% 
  select(any_of(schema_cols))

glimpse(fresh_corners)

#fresh access market
fresh_access_market <- read_sheet(gs_path, sheet = jh_sheet_names[2]) %>% 
  rename(name = Market,
         SNAP = `Participates in Food Bucks SNAP Incentive program`) %>%
  mutate(zip_code = as.character(zip_code)) %>% 
  separate(Season, into = c("date_from", "date_to"), sep = "-") %>% 
  mutate(SNAP = case_when(SNAP == "yes" ~ 1,
                          TRUE ~ 0)) %>% 
  mutate(location_description = str_c("Date Time: ", `Date/Time`,
                                      "|",
                                      "Weekday: ", weekday,
                                      "|",
                                      "Open Time: ", open_time1,
                                      "|",
                                      "Close Time: ", close_time1,
                                      "|",
                                      "Description: ", description,
                                      sep = "")) %>% 
  select(any_of(schema_cols))

#combine
just_harvest_data <- list(fresh_corners, fresh_access_market) %>% 
  bind_rows()

just_harvest_data

glimpse(food_data)

# test_file %>% 
#   write_csv("food-data/Cleaned_data_files/just_harvest.csv")
