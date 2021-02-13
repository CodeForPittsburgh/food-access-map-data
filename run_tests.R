#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("Mapbox API Key must be called as first argument", call.=FALSE)
} else if (length(args)==1) {
  API_KEY <- args[1]
}

library("testthat")

testthat::test_dir("tests")
