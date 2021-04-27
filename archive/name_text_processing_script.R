## text-processing for super market and convenience stores
## 05/31/2020

supermarket <- c("ALDI", 
                 "TARGET", 
                 "KUHN",
                 "SAMS CLUB", 
                 "GIANT EAGLE", 
                 "GORDON FOOD SERVICE", 
                 "WALMART","WAL MART", 
                 "KMART", 
                 "COSTCO", 
                 "WHOLE FOODS", 
                 "TRADER JOES", 
                 "SAVALOT", "SAVEALOT")

convenience_store <- c("COGO",
                       "CVS", 
                       "WALGREEN",
                       "GETGO","GET GO", 
                       "DOLLAR GENERAL",
                       "FAMILY DOLLAR", 
                       "DOLLAR TREE", 
                       "SHEETZ", 
                       "SUNOCO", 
                       "SPEEDWAY", 
                       "7-ELEVEN", "ELEVEN",
                       "RITE AID", 
                       "APLUS",
                       "PAR MAR STORE", 
                       "UNI MART", "UNIMART",
                       "CIRCLE K")


assign_type <- function(name, type) {
  x <- str_to_upper(name)
  if(str_detect(name, "Green Grocer")) {
    res <- type
    }
  else if(any(str_detect(x, convenience_store))) {
    res <- "convenience store"
  }
  else if(any(str_detect(x, supermarket))) {
    res <- "supermarket"
  }
  else {
    res <- type
  }
  return(res)
}


