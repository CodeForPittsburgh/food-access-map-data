library(dplyr)
library(readr)
library(stringr)
library(tidyr)
library(purrr)
library(readxl)
library(googlesheets4)

#read in schema
df_schema <- readxl::read_excel("schema.xlsx", sheet = "master_table") %>% 
  filter(!str_detect(STATUS, "remove|REMOVE|eliminate")) 

empty_schema <- df_schema %>% 
  select(field, type) %>% 
  mutate(value = case_when(type %in% c("string", "date") ~ list("a"), 
                           type %in% c("int", "float") ~ list(1),
                           type %in% "bool" ~ list(NA))) %>%
  select(-type) %>% 
  tidyr::pivot_wider(names_from = "field", values_from = "value") %>% 
  purrr::map_dfr(unlist) %>% 
  slice(-1)

schema_cols <- df_schema %>% 
  pull(field)

#for ellie to set up authentication for codeforpittsburgh@gmail.com account
#run this line
googlesheets4::gs4_auth()
#enter "0" to set up new account authentication
#follow in-browser instructions

gs_path <- "https://docs.google.com/spreadsheets/d/1DuzaXafd-2eH5oBlL8JVGZLi_f7Ccj2npqyPoGiusQM/edit?ts=60d28fc9#gid=820493315"  

#get sheet names from google sheets document
jh_sheet_names <- sheet_names(gs_path)

#jh_sheet_names

#read in fresh corners sheet
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
  select(any_of(schema_cols)) %>% 
  mutate(state = "PA",
         county = "Allegheny")

#glimpse(fresh_corners)

#read in fresh access market sheet
# read_sheet(gs_path, sheet = jh_sheet_names[2]) %>% 
#   View()

fresh_access_market <- read_sheet(gs_path, sheet = jh_sheet_names[2]) %>% 
  rename(name = Market,
         SNAP = `Participates in Food Bucks SNAP Incentive program`) %>%
  mutate(zip_code = as.character(zip_code)) %>% 
  separate(Season, into = c("date_from", "date_to"), sep = "-") %>% 
  mutate(SNAP = case_when(SNAP == "yes" ~ 1,
                          TRUE ~ 0)) %>% 
  #put all other data into "location_description"
  mutate(location_description = str_c("Street 1: ", street_one,
                                      "|",
                                      "Street 2: ", street_two,
                                      "|",
                                      "Date Time: ", `Date/Time`,
                                      "|",
                                      "Weekday: ", weekday,
                                      "|",
                                      "Open Time: ", open_time1,
                                      "|",
                                      "Close Time: ", close_time1,
                                      "|",
                                      "Description: ", description,
                                      sep = "")) %>% 
  mutate(county = "Allegheny") %>% 
  select(any_of(schema_cols))

#identify data issues
fresh_access_market <- fresh_access_market %>% 
  mutate(missing_address = case_when(is.na(address) ~ "missing address",
                                     TRUE ~ NA_character_),
         missing_city = case_when(is.na(city) ~ "missing city",
                                  TRUE ~ NA_character_),
         missing_zip_code = case_when(is.na(zip_code) ~ "missing zip code",
                                      TRUE ~ NA_character_)) %>% 
  unite(col = "data_issues",
        c(missing_address, missing_city, missing_zip_code),
        sep = "; ",
        na.rm = TRUE)

#combine
just_harvest_data <- list(empty_schema, fresh_corners, fresh_access_market) %>% 
  bind_rows() %>% 
  mutate(source_org = "Just Harvest",
         source_file = "Just Harvest Google Sheets")


#just_harvest_data

#glimpse(food_data)

just_harvest_data %>%
   write_csv("food-data/Cleaned_data_files/just_harvest.csv")

