# What is the Food Access Map?
This project's goal is to create an internal and public-facing resource (e.g. an interactive map) for people looking to find healthy, affordable food. [Pittsburgh Food Policy Council](https://www.pittsburghfoodpolicy.org), an umbrella organization for food-related nonprofits, is the project sponsor. More information about the need for this project can be found [here](https://docs.google.com/presentation/d/1hk3n8cwbKtqxZjHni3JJlvjSSUeCv4dbVIdjq3FiTp8/edit#slide=id.g58c466d72b_0_179). 

There are many food-related nonprofits in the Pittsburgh area, and each maintains datasets about different food access programs and where they are offered (for example, Greater Pittsburgh Food Bank maintains a list of food pantries). The data processing part of this project gathers data from various sources and merges the datasets into a common format.

# Where is the Map located?

The map is located at the following address: 
https://www.arcgis.com/apps/instant/nearby/index.html?appid=6315c774b49540689eac60bce9e0c8bd

# How You Can Help
Volunteers can help in a number of ways, including developing code, fixing bugs, and improving project documentation. A list of outstanding issues can be found on the [issues page](https://github.com/CodeForPittsburgh/food-access-map-data/issues), but if you can't find an issue you think you can work on, don't hesitate to ask one of us for help figuring out how you can contribute!

## What Programs You Need Installed

Python: Some of the data processing scripts are written in Python.
R: Some of the data processing scripts are written in R.


There are multiple ways to access and manipulate the data, but for simplicity’s sake, this README will recommend a Python or R. 
# Get the Data
## Python
This project uses [Python3](https://www.python.org/), [pipenv](https://pypi.org/project/pipenv/) and [pytest](https://docs.pytest.org/en/6.2.x/).

Required packages are listed in `Pipfile` and can be installed using

```$ pipenv install```

This installs the packages in a virtual environment, a python convention which allows different projects to have different dependencies, with different versions.

You can run a single command inside the virtual environment using `pipenv run`, or open a shell using

```$ pipenv shell```

Tests are stored in the `tests/` directory, and include any file in the form `test_*.py`, you can run them using

```$ pytest```

When you're done with the virtual environment, you can leave it using

```$ exit```

## R
It is recommended to use the RStudio IDE to interact with the data. 

1. Download/Install R
2. Download RStudio
3. Start an RStudio Project (recommended)
4. Install the `tidyverse` package with the following line of code (one-time action):

`install.packages(“tidyverse”)`

5. Start a new R Script or RMarkdown and read in the data with the following line of code:  
`library(tidyverse)`  
`my_data <- read_csv(“https://raw.githubusercontent.com/CodeForPittsburgh/food-access-map-data/master/merged_datasets.csv”)`  

6. Once you’ve entered this line of code, you now have access to the data. You can use the various functions in base R or the `tidyverse` to explore the data
7. For example, you can use the command `names(my_data)` to see the attributes of the data table.

# food-access-map-data

Data for the food access map:

* `merged_datasets.csv` is the most current version of compiled PFPC data (last update 04/01/2020 w/ de-dup by fuzzystring turned off for now)

* To regenerate merged_datasets.csv with new data, run the "[Generate Merged Dataset](https://github.com/CodeForPittsburgh/food-access-map-data/actions/workflows/generate_merged_dataset.yml)" Github Action. This calls "data_prep_scripts/run.sh", which runs the following scripts in order.
	+ **auto_agg_clean_data.R**   --		Reads in previously prepared data sources and aggregates them to a single data frame.
	+ **auto_text_process_name.R**  --		Assigns types (like Chain Grocery Store, Farmer's Market, etc) to different addresses
	+ **auto_geocode_wrapper.R**  --		Uses geocoding to obtain latitude and longitude coordinates for addresses without them
	+ **auto_clean_addresses_wrapper.py**  --	Cleans up addresses to a standardized format
	+ **auto_id_duplicates_wrapper.py**  --		Identifies duplicate rows
	+ **auto_merge_duplicates_wrapper.py**  --	Merges duplicate rows, resolving conflicts on critical information by prioritizing some data sources

# Data Sources for Food Access Map

* Farmers Market Nutritional Program
* Greater Pittsburgh Community Food Bank
* Just Harvest
* Pittsburgh Food Policy Council
* USDA Food and Nutrition Service

# Data Labels
These labels are listed in merged_datasets.csv and are used to denote particular unique traits of the food source.

* SNAP - Whether the site accepts SNAP
* WIC - Whether the site accepts WIC
* FMNP - [**TO BE DETERMINED**]
* fresh_produce - Whether the site offers fresh produce
* food_bucks - Whether the site accepts food bucks
* free_distribution - [**TO BE DETERMINED**]
* open_to_spec_group - [**TO BE DETERMINED**]

Sources are obtained and prepared for additional processing via our data prep scripts. The source rules for utilizing those scripts can be found [here](https://github.com/CodeForPittsburgh/food-access-map-data/blob/master/data_prep_scripts/source_rules.md).

# Extra Resources

## For An Introduction to R and RStudio
[https://education.rstudio.com/learn/beginner/](https://education.rstudio.com/learn/beginner/)
## Introduction To Github
[https://guides.github.com/](https://guides.github.com/)

