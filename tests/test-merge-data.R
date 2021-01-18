library("here")

test_that("Merge_data.R runs", {
  source(here::here('data_prep_scripts', 'merge_duplicates.R'))
  expect_true(TRUE)
})
