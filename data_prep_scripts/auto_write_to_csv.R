library(dplyr)
library(readr)

final_table <- function(dat) {
  all_datasets <- read.table(dat)
  write_csv(all_datasets, "test_merged_20210119.csv")
}

## read in stdin() from previous step
input <- file('stdin', 'r')

## run function with CLI input
final_table(input)