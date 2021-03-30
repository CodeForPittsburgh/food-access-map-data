#!/usr/bin/Rscript

library(jsonlite)

## read in stdin() from previous step
input <- file('stdin', 'r')

## read.table() bc stdin input
d <- read.table(input)

## run function with datatable input
j <- serializeJSON(d)

## write out as stdout json
stream_out(d, con = stdout(), verbose = FALSE)
