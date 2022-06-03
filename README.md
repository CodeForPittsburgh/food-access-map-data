# What is the Food Access Map?
This project's goal is to create an internal and public-facing resource (e.g. an interactive map) for people looking to find healthy, affordable food. [Pittsburgh Food Policy Council](https://www.pittsburghfoodpolicy.org), an umbrella organization for food-related nonprofits, is the project sponsor. More information about the need for this project can be found [here](https://docs.google.com/presentation/d/1hk3n8cwbKtqxZjHni3JJlvjSSUeCv4dbVIdjq3FiTp8/edit#slide=id.g58c466d72b_0_179).

There are many food-related nonprofits in the Pittsburgh area, and each maintains datasets about different food access programs and where they are offered (for example, Greater Pittsburgh Food Bank maintains a list of food pantries). The data processing part of this project gathers data from various sources and merges the datasets into a common format.

# Where is the Map located?

The map is located at the following address:
http://codeforpittsburgh.github.io/FoodAccessMap/
Code for the map is located at a different repo:
https://github.com/CodeForPittsburgh/CodeForPittsburgh.github.io/tree/master/FoodAccessMap

# How does the map work?

The map relies on the following steps to provide results

1. Raw data is manually gathered from various providers at the federal and local level and saved in the [Github repository](https://github.com/CodeForPittsburgh/food-access-map-data).
2. A [Github Action](https://github.com/CodeForPittsburgh/food-access-map-data/actions) is used to kick off a virtual machine containing the [various scripts](https://github.com/CodeForPittsburgh/food-access-map-data/tree/master/data_prep_scripts) which then clean, transform, deduplicate, and collate the multiple  data sources into a single file for use by the map.
3. The map is hosted on another [Code for Pittsburgh Github repo](https://github.com/CodeForPittsburgh/CodeForPittsburgh.github.io/tree/master/FoodAccessMap).

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

* `merged_datasets.csv` is the most current version of compiled PFPC data 

* To regenerate merged_datasets.csv with new data, run the "[Generate Merged Dataset](https://github.com/CodeForPittsburgh/food-access-map-data/actions/workflows/generate_merged_dataset.yml)" Github Action. This calls "data_prep_scripts/run.sh", which runs the following scripts in order.
	+ **auto_agg_clean_data.R**   --		Reads in previously prepared data sources and aggregates them to a single data frame.
	+ **auto_text_process_name.R**  --		Assigns types (like Chain Grocery Store, Farmer's Market, etc) to different addresses
	+ **auto_geocode_wrapper.R**  --		Uses geocoding to obtain latitude and longitude coordinates for addresses without them
	+ **auto_clean_addresses_wrapper.py**  --	Cleans up addresses to a standardized format
	+ **auto_id_duplicates_wrapper.py**  --		Identifies duplicate rows
	+ **auto_merge_duplicates_wrapper.py**  --	Merges duplicate rows, resolving conflicts on critical information by prioritizing some data sources

The end result of all of these steps is a new merged_datasets.csv, which the map points to for its data! 

# Data Sources for Food Access Map

* Farmers Market Nutritional Program - Established by Congress in 1992, to provide fresh, unprepared, locally grown fruits and vegetables to WIC participants, and to expand the awareness, use of, and sales at farmers’ markets
* Greater Pittsburgh Community Food Bank - Food bank for the Greater Pittsburgh Area
* Just Harvest - "Nonprofit organization that reduces hunger through sustainable, long-term approaches that lift up those in need"
* Pittsburgh Food Policy Council - "The mission of the Pittsburgh Food Policy Council is to build a food system that benefits our communities, economy, and environment in ways that are just, equitable and sustainable"
* USDA Food and Nutrition Service - Agency of US Department of Agriculture responsible for administering the nation’s domestic nutrition assistance programs

Sources are obtained and prepared for additional processing via our data prep scripts. The source rules for utilizing those scripts can be found [here](https://github.com/CodeForPittsburgh/food-access-map-data/blob/master/data_prep_scripts/source_rules.md).

# Data Labels
These labels are listed in merged_datasets.csv and are used to denote particular unique traits of the food source.

* SNAP - Whether the site accepts SNAP
* WIC - Whether the site accepts WIC
* FMNP - Whether the site accepts farmers market nutrition program
* fresh_produce - Whether the site offers fresh produce
* food_bucks - Whether the site accepts food bucks
* free_distribution - Whether the site offers free food assistance
* open_to_spec_group - Whether the site is only open to special groups

# Adding new datasets
New datasets can be added as they are discovered. A prep script can be added to this [directory](https://github.com/CodeForPittsburgh/food-access-map-data/tree/master/data_prep_scripts/prep_source_scripts). 

New datasets need to correspond to the project-wide schema set in [schema.xlsx](https://github.com/CodeForPittsburgh/food-access-map-data/blob/master/schema.xlsx). Cleaned data should be saved in .csv format [here](https://github.com/CodeForPittsburgh/food-access-map-data/tree/master/food-data/Cleaned_data_files).

Any new prep script also needs to be added to the source_r_scripts.R or source_python_scripts.py files in the same prep_source_scripts directory. The source scripts control what prep scripts are run to update the full dataset.

# Training the Deduplication Data Sets
Because we are combining multiple data sets, we utilize a deduplication process to identify and resolve possible duplicates.

The "training set", which is used to train the deduplication program in what is and is not likely to be a duplicate, is located [here](https://github.com/CodeForPittsburgh/food-access-map-data/tree/master/data_prep_scripts/deduper_training_data). Adding to the training data primarily consists of added cases of address strings that are duplicates, as well as cases of address strings that aren't. To train new data, you can utilize the IPython Notebook located [here](https://github.com/CodeForPittsburgh/food-access-map-data/blob/master/data_prep_scripts/Train_new_deduplication_data.ipynb). 

# Extra Resources

## For An Introduction to R and RStudio
[https://education.rstudio.com/learn/beginner/](https://education.rstudio.com/learn/beginner/)
## Introduction To Github
[https://guides.github.com/](https://guides.github.com/)
