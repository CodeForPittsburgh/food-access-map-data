# What is the Food Access Map?
This project's goal is to create an internal and public-facing resource (e.g. an interactive map) for people looking to find healthy, affordable food. Pittsburgh Food Policy Council, an umbrella organization for food-related nonprofits, is the project sponsor. More information about the need for this project can be found here. 

There are many food-related nonprofits in the Pittsburgh area, and each maintains datasets about different food access programs and where they are offered (for example, Greater Pittsburgh Food Bank maintains a list of food pantries). The data processing part of this project gathers data from various sources and merges the datasets into a common format.

# How You Can Help
Volunteers can help in a number of ways, including developing code, fixing bugs, and improving project documentation. A list of outstanding issues can be found on the issues page, but if you can't find an issue you think you can work on, don't hesitate to ask one of us for help figuring out how you can contribute!

## What Programs You Need Installed (and where to Install them)

Python: Some of the data processing scripts are written in Python.
R: Some of the data processing scripts are written in R.


There are multiple ways to access and manipulate the data, but for simplicity’s sake, this README will recommend a Python or R. 
# Get the Data
## Python
Install Python (3, not 2) however you like. The Anaconda distribution is a popular bundle of Python, a package manager (`conda`) that lets you install and update add-ons, and many common packages including `pandas` and `numpy`, which you will need to run the Python scripts.

If you go with a different Python distribution, just make sure you have the following packages installed in your environment:
pandas
numpy
xlrd
os

You can view and edit Python scripts in any of a wide range of programs, from simple text editors like Notepad++ to full-featured Integrated Development Environments like Visual Studio. If you don’t already have a preference, check out Atom, Notepad++, or VS Code.
## R
It is recommended to use the RStudio IDE to interact with the data. 

Download/Install R
Download RStudio
Start an RStudio Project (recommended)
Install the `tidyverse` package with the following line of code (one-time action):

`install.packages(“tidyverse”)`

Start a new R Script or RMarkdown and read in the data with the following line of code:
`library(tidyverse)`
`my_data <- read_csv(“https://raw.githubusercontent.com/CodeForPittsburgh/food-access-map-data/master/merged_datasets.csv”)`
Once you’ve entered this line of code, you now have access to the data. You can use the various functions in base R or the `tidyverse` to explore the data
For example, you can use the command `names(my_data)` to see the attributes of the data table.

# food-access-map-data

Data for the food access map:

* `merged_datasets.csv` is the most current version of compiled PFPC data (last update 04/01/2020 w/ de-dup by fuzzystring turned off for now)


* Run `run_new_data_merge.R` to generate `merged_datasets.csv`, which calls:

	+ prepared data sources in `food-data/Cleaned_data_files/`

	+ `name_text_processing_script.R`
	
	+ `geocoding.R` 

	
[Map of data in merged_datasets.csv](https://wprdc-maps.carto.com/u/wprdc/builder/64b812f6-45fa-4f27-a239-6e61a870d1de/embed)

# Extra Resources

## For An Introduction to R and RStudio
https://education.rstudio.com/learn/beginner/ 
## Introduction To Github
https://guides.github.com/

