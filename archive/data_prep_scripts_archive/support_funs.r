## functions for extracting date/time info

## make function to extract multi-day indication, accounting for Daily entry, bridging all values in between
weekday_calc <- function(entry_val) {
  # browser()
  weekday_lookup <- data.frame(weekday = c("Monday", "Tuesday", "Wednesday", "Thursday", 
                                           "Friday", "Saturday", "Sunday"),
                               abbrev = c("Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun")) %>%
    mutate(ord = 1:n(), abbrev = as.character(abbrev)) ## abbrev doesn't need to be factor, only weekday for seq below
  
  ## check for /
  check_special <- str_detect(entry_val, "/")

  res <- str_extract_all(entry_val, "[:alpha:]*")[[1]] %>% 
    tbl_df() %>% 
    dplyr::rename(weekday = value) %>% 
    filter(str_detect(weekday, "Daily|Mon*|Tues*|Wed*|Thurs*|Fri*|Sat*|Sun*")) ## define character class, will require testing
  
  ## trim s at end
  res$weekday <- str_remove(res$weekday, "s$")
  
  ## handle Daily
  if(str_detect(res$weekday, "Daily") %>% any) {
    res <- weekday_lookup %>% mutate(weekday = as.character(weekday))
  }
  
  ## handle day abbreviations
  else if(!str_detect(res$weekday, "day") %>% any) {
    res <- res %>% select(abbrev = weekday) %>% left_join(weekday_lookup, by = "abbrev") %>% select(-abbrev)
  }
  
  ## handle multi-days, fill in
  if(length(res$weekday) > 1) {
    
   if(!check_special) {
      ## fill in the gap of remaining days
      res <- seq(weekday_lookup$ord[weekday_lookup$weekday == res$weekday[1]], 
                 weekday_lookup$ord[weekday_lookup$weekday == res$weekday[length(res$weekday)]], by = 1)
      res <- data.frame(ord = res) %>% left_join(weekday_lookup %>% select(-abbrev), by = "ord")
      res <- res %>% mutate(weekday = as.character(weekday))
    }
    
  }
  
  return(res)
}


## function to extract open time
time_calc <- function(entry_val) { ## add robustness to confirm time 1 is min, time 2 is max
  open_time <- str_extract_all(entry_val, "[:digit:]{1,2}:[:digit:]{2} [:alpha:]{2}")[[1]][1]
  close_time <- str_extract_all(entry_val, "[:digit:]{1,2}:[:digit:]{2} [:alpha:]{2}")[[1]][2]
  
  return(list(open_time = open_time, close_time = close_time))
}

## function to extract months, and add day of month** verify this method, example had specific day
season_calc <- function(entry_val) {
  # browser()
  date_from = str_split(entry_val, "[:punct:]")[[1]][1]
  # date_from = lubridate::make_date(year = lubridate::year(Sys.time()), month = date_from, day = 1)
  
  date_to = str_split(entry_val, "[:punct:]")[[1]][2]
  # date_to = lubridate::make_date(year = lubridate::year(Sys.time()), month = date_to, day = 1)
  
  return(list(date_from = date_from, date_to = date_to))
}


# season_calc(agh_farm_markets$Season[1])