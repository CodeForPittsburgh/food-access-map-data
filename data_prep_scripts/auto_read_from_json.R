#!/usr/bin/Rscript

library(jsonlite)

## read in stdin() from previous step
input <- file('stdin', 'r')

#convert to data frame
d <- stream_in(input)

## write out as stdout
write.table(d, stdout())