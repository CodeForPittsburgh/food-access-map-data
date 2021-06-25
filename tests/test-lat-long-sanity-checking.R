#Tests for merge-duplicates
library("readr")

test_that("Geocode returns expected coordinates for single row",  {
  source('../data_prep_scripts/auto_geocode_functions.R')
  input <- read_csv("test-data/test_geocode_one_row_input.csv")
  exp_output <- read_csv("test-data/test_geocode_one_row_exp_output.csv")  
  output <- run_geocode(input)
  expect_equal(round(output$longitude, digits=2), round(exp_output$longitude, digits=2))
  expect_equal(round(output$latitude, digits=2), round(exp_output$latitude, digits=2))
})

test_that("Geocode returns expected coordinates for multiple rows", {
  input <- read_csv("test-data/test_geocode_three_rows_input.csv")
  exp_output <- read_csv("test-data/test_geocode_three_rows_exp_output.csv")
  source('../data_prep_scripts/auto_geocode_functions.R')
  output <- run_geocode(input)
  expect_equal(round(output$longitude, digits=2), round(exp_output$longitude, digits=2))
  expect_equal(round(output$latitude, digits=2), round(exp_output$latitude, digits=2))
})