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

sheet_ids <- as_sheets_id(gs_path)

sheet_ids

food_data <- read_sheet(gs_path, sheet = sheet_names(gs_path)[1])

food_data <- food_data %>% 
  rename(name = `Corner Store`,
         address = Address,
         city = City,
         zip_code = Zip) %>% 
  mutate(zip_code = as.character(zip_code))

glimpse(food_data)

test_file <-dat0 %>% 
  bind_rows(food_data)

View(test_file)

# test_file %>% 
#   write_csv("food-data/Cleaned_data_files/just_harvest.csv")
