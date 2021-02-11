#Tests for merge-duplicates
library("readr")

test_that("Merge_duplicates creates hybrid id's for merged rows",  {
  df <- read_csv("test-data/test_geocode_one_row_input.csv")
  source('../data_prep_scripts/auto_geocode_functions.R')
  result <- run_geocode(df)
})

test_that("Merge_duplicates marks merge_rows with a '1' in 'merged_record' column", {
  df <- read_csv("test-data/test_merge_two_rows_no_conflicts_input.csv")
  sfp <- read_csv("../data_prep_scripts/source_field_prioritization_sample_data.csv")
  source('../data_prep_scripts/merge_duplicates_functions.R')
  result <- merge_all_duplicates_in_dataframe(df, sfp)
  final_merged_record <- result$merged_record
  expect_equal(final_merged_record, "1")
})