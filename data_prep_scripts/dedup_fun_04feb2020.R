## Catalina Moreno 02/04/2020
## function to handle max info across multiple entries

## create working example
ex_dup <- dat %>% filter(str_detect(name, "Bloomfield")) %>% 
  filter(str_detect(name, "Market"))

select_info <- function(var_entries = c("a", "b")){
  # browser()
 if(sum(is.na(var_entries)) == length(var_entries)) {
      res <- NA
  }
  else {
    ## find if all same or not
    unique_entries <- unique(var_entries)
    if(length(unique_entries) == 1) {
        res <- unique_entries
      }
    else{
        res <- tibble(var_name = var_entries) %>% 
          count(var_name) %>% arrange(desc(n)) %>% slice(1) %>% pull(var_name) ## could do count, take max value (this way selecting max info)
      }
    }
  return(res)
}

## test function
select_info(ex_dup %>% pull(name))

ex_dup %>% purrr::map_df(function(x) {select_info(var_entries = x)}) %>% 
  mutate(source = "mixed") ## better way to track this?

## try another example, these two entries have different GEIOID and hence mrfei
ex_dup2 <- dat %>% filter(str_detect(name, "Curry Hollow"))

ex_dup2 %>% purrr::map_df(function(x) {select_info(var_entries = x)})

