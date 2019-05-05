library(dplyr)
library(googlesheets)

## read in data model from google sheets

# gs_auth(new_user = TRUE) #auth account (one time action)
data_mod <- gs_read(gs_title("fields_and_descriptions"))

dat_mod_col_names <- data_mod %>% pull(field)

## create empty dataframe according todatamodel
dat1 <- data.frame(matrix(ncol = length(dat_mod_col_names), nrow = 0))
colnames(dat1) <- dat_mod_col_names

## read in first source -- data-convenienvesupermarkets
data_convenience <- gs_read(gs_title("data-conveniencesupermarkets"))
head(data_convenience)

## map data_convenience to dat1
data_convenience <- dat1 %>% 
  bind_rows(data_convenience %>% 
              mutate(address = paste(`Street #`, `Street Name`)) %>% 
              select(name = Name,
                     type = Category,
                     address, 
                     state = State, 
                     zip_code = Zip, 
                     latitude = Lat, 
                     longitude = Lon)) 

## write out as .csv 
write.csv(data_convenience, "data_convenience_cleaned.csv", row.names = FALSE)
## write out to google sheets
# gs_new(title = "data-convenience-cleaned", input = data_convenience)





### next dataset
## NOTE still TBD on how to handle time. come back to this

