## Catalina Moreno 03/30/2020
## Workflow to search for similar name-address observations and reduce to one entry 

## load libs
library(tidyverse)
library(stringdist)

## support function to select observation with max info (from set of similar obs)
select_info2 <- function(var_entries) {
  
  max_info_source <- var_entries %>% select(-new_name) %>% 
    gather(key = "key", value = "value", -id) %>% 
    group_by(id) %>% summarise(non_missing_entries = sum(!is.na(value))) %>% 
    arrange(desc(non_missing_entries)) %>% slice(1) %>% pull(id)
  
  res <- var_entries %>% filter(id %in% max_info_source)
  
  return(res)
}

## function to execute de-dup
de_dup_wrapper <- function(dat) {
  ## create new variable that combines name and address, for next step dist calc 
  dat <- dat %>% mutate(new_name = str_replace_all(paste0(str_to_lower(name), str_to_lower(address))," ", ""))
  all_dist2 <- stringdistmatrix(dat$new_name, dat$new_name, method = "lv")
  
  ## for loop to find similar dist from 0-100% of the string length, current threshold is 25% **
  check_this <- vector("list", length = nrow(dat))
  
  for(i in 1:nrow(dat)) {
    find_me <- which(all_dist2[i,]/str_length(dat$new_name[i]) < 0.25)
    find_me2 <- find_me[which(find_me != i)]
    
    if(length(find_me2) > 0) {
      ## exact address # check
      dist_check2 <- stringdist(str_extract(dat$address[i], "^[:digit:]{1,4}"), str_extract(dat$address[find_me2], "^[:digit:]{1,4}"))
      keep_me <- find_me2[which(dist_check2 == 0)]
      
      check_this[[i]] <- tibble(similar_locs = keep_me, similar_name = dat$new_name[keep_me]) %>% 
        mutate(orig_loc = dat$id[i],
               orig_name = dat$new_name[i])
    }
  }
  check_this <- check_this %>% bind_rows()
  
  ## fill by orig_loc, go tall, group
  group_check <- check_this %>% distinct(orig_loc) %>% mutate(group_id = 1:n())
  
  # check_this %>% left_join(group_check, by = "orig_loc") %>% 
  #   select(similar_locs, orig_loc, group_id) %>% 
  #   gather(key = "key", value = "value", -group_id) %>% filter(group_id %in% 1) %>% 
  #   distinct(value)
  # 
  # dat %>% filter(id %in% c(8, 880, 1743)) # caught bug in my rules (added rowwise), fixed but need to RERUN TODAY!
  
  # dat %>% nrow()
  ## apply de-dup to groups of similar_locs, replacing 1 row of max info, dropping redudant info
  for(i in 1:nrow(group_check)) {
    relevant_uid <- check_this %>% left_join(group_check, by = "orig_loc") %>% 
      select(similar_locs, orig_loc, group_id) %>% 
      gather(key = "key", value = "value", -group_id) %>% filter(group_id %in% group_check$group_id[i]) %>% 
      distinct(value) %>% pull(value)
    
    dtf <- dat %>% filter(id %in% unique(relevant_uid)) 
    
    if(nrow(dtf) > 0) { ## if have not already addressed this group of similar obs
      ## select max info within column
      # new_dtf <- dtf %>% purrr::map_df(function(x) {select_info(var_entries = x)}) %>% mutate(source = "mixed") #id = NA)
      
      ## select by source with max info
      new_dtf2 <- select_info2(dtf)
      
      dat <- dat %>% 
        filter(!id %in% unique(relevant_uid)) %>% ## drop all similar obs
        bind_rows(new_dtf2) ## add back single obs
    }
    
  }
  
  ## check rows after dedup
  # dat %>% nrow()
  
  ## remove new_name column
  dat <- dat %>% select(-new_name)
  
  ## clean workspace
  rm(all_dist2, check_this, dtf, group_check, new_dtf2, dist_check2, keep_me, find_me, find_me2, i, relevant_uid)
  
  return(dat)
}