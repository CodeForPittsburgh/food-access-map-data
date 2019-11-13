Fix Type Field in Merged Dataset
================
Catalina Moreno
November 12, 2019

``` r
library(tidyverse)
```

Background
----------

The purpose of this document is to understand where the current version of the merged data set is missing the `type` field and populate that information when possible. Population could occur thru the WPRDC food inspection data set or using assumptions based on public knowledge regarding store brands.

This is effort important because `type` affects how some rules for key labels are applied downstream (SNAP, WIC, etc.)

Read in data from GitHub
------------------------

The current version of the merged data set:

``` r
dat <- read_csv("https://raw.githubusercontent.com/cgmoreno/food-access-map-data/master/merged_datasets.csv")
```

The WPRDC food inspection data, which contains `description` field analogous to `type` in our data set:

``` r
food_inspec <- read_csv("wprdc_food_inspec_for_type.csv")
food_inspec <- food_inspec %>% filter(description %in% c("Retail/Convenience Store", "Supermarket", "Chain Retail/Convenience Store", "Chain Supermarket"))
```

Address missing `type`
----------------------

Check `type`:

``` r
dat %>% count(type) %>% arrange(desc(n))
```

    # A tibble: 6 x 2
      type                  n
      <chr>             <int>
    1 <NA>               1040
    2 Convenience Store   526
    3 Summer Food Site    285
    4 Supermarket         156
    5 Grow PGH Garden      80
    6 Farmers Market       54

Note the large count of NA values.

What are WPRDC types (`description` field):

``` r
food_inspec %>% distinct(description)
```

    # A tibble: 4 x 1
      description                   
      <chr>                         
    1 Retail/Convenience Store      
    2 Chain Supermarket             
    3 Supermarket                   
    4 Chain Retail/Convenience Store

Bring in WPRDC info to see if can populate type, changing to Convenience Store (remove Retail, collapse with Chain) and Supermarket (collapse Chain).

``` r
food_inspec <- food_inspec %>% mutate(description = str_replace(description, "Retail/", ""),
                       description = str_replace(description, "Chain ", "")) 
```

``` r
food_inspec %>% select(facility_name, description) %>% 
  group_by(facility_name) %>% summarise(description = first(description)) %>% 
  inner_join(dat %>% select(name, type), 
             by = c("facility_name" = "name")) %>% 
  filter(is.na(type)) %>% nrow()
```

    [1] 96

The WPRDC food inspec data populates 96 of the 1040 missing `types`.

As a validation step, check how WPRDC data set compares to those that have `type`, do `type` and description align?

``` r
food_inspec %>% select(facility_name, description) %>% 
  group_by(facility_name) %>% summarise(description = first(description)) %>% 
  inner_join(dat %>% select(name, type), 
             by = c("facility_name" = "name")) %>% 
  filter(!is.na(type), description == type) %>% nrow()
```

    [1] 612

Do any not align?

``` r
food_inspec %>% select(facility_name, description) %>% 
  group_by(facility_name) %>% summarise(description = first(description)) %>% 
  inner_join(dat %>% select(name, type), 
             by = c("facility_name" = "name")) %>% 
  filter(!is.na(type), description != type) %>% nrow()
```

    [1] 8

Yes, print these out:

``` r
food_inspec %>% select(facility_name, description) %>% 
  group_by(facility_name) %>% summarise(description = first(description)) %>% 
  inner_join(dat %>% select(name, type), 
             by = c("facility_name" = "name")) %>% 
  filter(!is.na(type), description != type)
```

    # A tibble: 8 x 3
      facility_name        description       type             
      <chr>                <chr>             <chr>            
    1 Aldi #69             Convenience Store Supermarket      
    2 Aldi #77             Convenience Store Supermarket      
    3 Aldi #79             Convenience Store Supermarket      
    4 Soergel's Orchards   Supermarket       Convenience Store
    5 Wal-Mart #2603       Convenience Store Supermarket      
    6 Wal-Mart #5040       Convenience Store Supermarket      
    7 Wal-Mart #5339       Convenience Store Supermarket      
    8 Zoscak's Food Market Supermarket       Convenience Store

I would classify Aldi and Wal-Mart as Supermarket... check if any other Aldi or Wal-Mart in WPRDC data set:

``` r
food_inspec %>% filter(str_detect(facility_name, "Aldi")) %>% count(description)
```

    # A tibble: 2 x 2
      description           n
      <chr>             <int>
    1 Convenience Store     3
    2 Supermarket           8

``` r
food_inspec %>% filter(str_detect(facility_name, "Wal-Mart")) %>% count(description)
```

    # A tibble: 2 x 2
      description           n
      <chr>             <int>
    1 Convenience Store     3
    2 Supermarket           5

This is a limitation with the WPRDC data set. It has inconsistencies in `description` within the same store brand (though only 2 instances of this). For now, only bring in `description` where `type` is missing, and keep note of this limitation in case a better data set becomes available in the future.

As next step, permanently join in `food_insepc` `description` information to populate those missing `type`.

``` r
dat <- dat %>% left_join(food_inspec %>% select(facility_name, description),
                         by = c("name" = "facility_name")) %>% 
  mutate(type = ifelse(is.na(type), description, type)) %>% select(-description)
dat %>% count(type)
```

    # A tibble: 6 x 2
      type                  n
      <chr>             <int>
    1 <NA>                944
    2 Convenience Store   784
    3 Farmers Market       54
    4 Grow PGH Garden      80
    5 Summer Food Site    285
    6 Supermarket         262

Note the new reduction in NA counts.

For those remaining, next try text processing:

``` r
dat %>% filter(type %in% NA) %>% mutate(name = str_to_upper(name),
                                        name = str_replace_all(name, "[:digit:]|[:punct:]", ""),
                                        name = str_trim(name)) %>% 
  count(name) %>% arrange(desc(n))
```

    # A tibble: 403 x 2
       name               n
       <chr>          <int>
     1 GIANT EAGLE       78
     2 RITE AID          74
     3 DOLLAR GENERAL    41
     4 FAMILY DOLLAR     40
     5 DOLLAR TREE       33
     6 ALDI              24
     7 SHEETZ            23
     8 GETGO             22
     9 COGOS             20
    10 CVS PHARMACY      20
    # … with 393 more rows

Via manual effort, build look up tables to assign `type` at these stores w/ &gt; 1 count based on public domain knowledge:

``` r
supermarket <- c("ALDI", "TARGET", "KUHN","KUHNS","KUHNS MARKET", "SAMS CLUB", "GIANT EAGLE", "GORDON FOOD SERVICE", "WALMART","WAL MART", "KMART", "COSTCO", "WHOLE FOODS", "TRADER JOES", "SAVALOT", "SAVEALOT")
supermarket <- tibble(name2 = supermarket) %>% mutate(type2 = "Supermarket")
# supermarket %>% count(name2) %>% filter(n > 1)
```

``` r
# assume APLUS is sunoco, parmar is gas station too
convenience_store <- c("COGO","COGOS", "CVS", "CVS PHARMACY", "CVS PHARMACY INC", "WALGREEN","WALGREENS", "GETGO","GET GO", "DOLLAR GENERAL","DOLLAR GENERAL STORE", "FAMILY DOLLAR", "DOLLAR TREE", "SHEETZ", "SUNOCO", "SPEEDWAY", "7-ELEVEN", "RITE AID", "APLUS","APLUS H", "APLUS MINI MART", "ELEVEN H","ELEVEN STORE A", "ELEVEN STORE  A", "ELEVEN STORE  B", "ELEVEN STORE A A", "ELEVEN STORE B B", "ELEVEN STORE J J", "PAR MAR STORE", "UNI MART", "UNIMART", "CIRCLE K")
convenience_store <- tibble(name2 = convenience_store) %>% mutate(type2 = "Convenience Store")
# convenience_store %>% count(name2) %>% filter(n > 1)
```

Bring in this information

``` r
dat <- dat %>% mutate(name2 = str_to_upper(name),
               name2 = str_replace_all(name2, "[:digit:]|[:punct:]", ""),
               name2 = str_trim(name2),
               name2 = ifelse(is.na(type), name2, NA)) %>% # to only join to those missing
  left_join(convenience_store %>% bind_rows(supermarket), by = c("name2")) %>% 
  mutate(type = ifelse(is.na(type), type2, type)) %>% 
  select(-type2, -name2)
```

``` r
dat %>% count(type)
```

    # A tibble: 6 x 2
      type                  n
      <chr>             <int>
    1 <NA>                407
    2 Convenience Store  1163
    3 Farmers Market       54
    4 Grow PGH Garden      80
    5 Summer Food Site    285
    6 Supermarket         420

Better. For now, will have to leave as is, as those remaining have 1 value for each name, and processing would require manually sifting through these ~ 400 values. Which data sources do these observations still missing `type` come from?

``` r
dat %>% filter(is.na(type)) %>% count(source) %>% rename(count_missing_after = n) %>% 
  left_join(dat %>% count(source) %>% rename(count_orig = n), by = "source") %>% 
  select(source, count_orig, count_missing_after)
```

    # A tibble: 5 x 3
      source                                     count_orig count_missing_after
      <chr>                                           <int>               <int>
    1 Additional Food Bucks sites.xlsx                    8                   1
    2 Allegheny_County_WIC_Vendor_Locations.xlsx         97                   5
    3 GPCFB - Green Grocer.xlsx                          17                  17
    4 Just Harvest - Fresh Access Markets.xlsx           22                  22
    5 PA.xlsx                                           952                 362

GPCFB Green Grocer and Just Harvest - Fresh Access Markets.

Both of these should all be `type` = "Farmers Market" based on previously discussed rules with PFPC.

``` r
dat %>% filter(str_detect(name, "Green Grocer")) %>% select(name, type, source)
```

    # A tibble: 24 x 3
       name                            type      source                        
       <chr>                           <chr>     <chr>                         
     1 Green Grocer (5 Generation Bak… Farmers … Allegheny_County_Farmers_Mark…
     2 Green Grocer (A Childs World D… Farmers … Allegheny_County_Farmers_Mark…
     3 Green Grocer (Alma Illery Medi… Farmers … Allegheny_County_Farmers_Mark…
     4 Green Grocer (Family Dollar)    Farmers … Allegheny_County_Farmers_Mark…
     5 Green Grocer (GAP Park )        Farmers … Allegheny_County_Farmers_Mark…
     6 Green Grocer (Greater Pittsbur… Farmers … Allegheny_County_Farmers_Mark…
     7 Green Grocer - Greater Pittsbu… <NA>      PA.xlsx                       
     8 Green Grocer (Family Support C… <NA>      GPCFB - Green Grocer.xlsx     
     9 Green Grocer (Three Rivers Man… <NA>      GPCFB - Green Grocer.xlsx     
    10 Green Grocer (GAP Park)         <NA>      GPCFB - Green Grocer.xlsx     
    # … with 14 more rows

``` r
dat %>% filter(str_detect(source, "Fresh Access Market")) %>% select(name, type, source)
```

    # A tibble: 22 x 3
       name                        type  source                                
       <chr>                       <chr> <chr>                                 
     1 Beechview Farmers Market    <NA>  Just Harvest - Fresh Access Markets.x…
     2 Belllevue Farmers Market    <NA>  Just Harvest - Fresh Access Markets.x…
     3 Bloomfield Saturday Market  <NA>  Just Harvest - Fresh Access Markets.x…
     4 Carrick Farmers Market      <NA>  Just Harvest - Fresh Access Markets.x…
     5 East Liberty Farmers Market <NA>  Just Harvest - Fresh Access Markets.x…
     6 Garfield Farm Stand         <NA>  Just Harvest - Fresh Access Markets.x…
     7 Green Tree Farmers Market   <NA>  Just Harvest - Fresh Access Markets.x…
     8 Homewood Farmers Market     <NA>  Just Harvest - Fresh Access Markets.x…
     9 Homewood Farmers Market     <NA>  Just Harvest - Fresh Access Markets.x…
    10 Larimer Farmers Market      <NA>  Just Harvest - Fresh Access Markets.x…
    # … with 12 more rows

These should both me modified during data prep. Apply now to see what remaining count of `type` = NA is:

``` r
dat <- dat %>% mutate(type = ifelse(str_detect(name, "Green Grocer"), "Farmers Market", type),
                      type = ifelse(str_detect(source, "Fresh Access Market"), "Farmers Market", type))
```

``` r
dat %>% count(type)
```

    # A tibble: 6 x 2
      type                  n
      <chr>             <int>
    1 <NA>                367
    2 Convenience Store  1163
    3 Farmers Market       94
    4 Grow PGH Garden      80
    5 Summer Food Site    285
    6 Supermarket         420

Final read out on sources and before vs. after this script the reduction in NA values for `type`:

``` r
dat %>% filter(is.na(type)) %>% count(source) %>% rename(count_missing_after = n) %>% 
  left_join(dat %>% count(source) %>% rename(count_orig = n), by = "source") %>% 
  select(source, count_orig, count_missing_after)
```

    # A tibble: 3 x 3
      source                                     count_orig count_missing_after
      <chr>                                           <int>               <int>
    1 Additional Food Bucks sites.xlsx                    8                   1
    2 Allegheny_County_WIC_Vendor_Locations.xlsx         97                   5
    3 PA.xlsx                                           952                 361

Summary
-------

Through this document the following steps have been developed to handle missing `type` field:

-   leverage WPRDC food inspection data set to bring in `description` field to current data set where `type` is missing

-   manual look up / make assignment based on public domain knowledge to brand name Supermarket and Convenience Stores

-   fix Just Harvest - Fresh Access Markets and Green Grocer sources

This leaves ~ 400 missing `type` observations that can be improved upon.

These steps should be incorporated in the data prep procedure (note, doing so will make new renderings of this document not informative, as it is linked directly to the most current merged data set on GitHub).

Appendix
--------

Check names:

``` r
names(dat)
```

     [1] "id"                    "name"                 
     [3] "type"                  "address"              
     [5] "street_one"            "street_two"           
     [7] "city"                  "state"                
     [9] "zip_code"              "location_description" 
    [11] "date_from"             "date_to"              
    [13] "open_time1"            "close_time1"          
    [15] "open_time2"            "close_time2"          
    [17] "Sunday"                "Monday"               
    [19] "Tuesday"               "Wednesday"            
    [21] "Thursday"              "Friday"               
    [23] "Saturday"              "SNAP"                 
    [25] "WIC"                   "FMNP"                 
    [27] "fresh_produce-healthy" "MRFEI_score"          
    [29] "latitude"              "longitude"            
    [31] "open_to_spec_group"    "food_bucks"           
    [33] "source"                "GEOID"                
    [35] "ward"                  "hood"                 
    [37] "council"
