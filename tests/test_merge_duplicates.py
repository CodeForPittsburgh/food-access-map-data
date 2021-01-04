#test_merge_duplicates.py
import rpy2.robjects as robjects
import subprocess
import os.path
from os import path

r=robjects.r

# TODO: Determine if importing and enabling packages is necessary for functionality
# import rpy2's package module
import rpy2.robjects.packages as rpackages

# import R's utility package
utils = rpackages.importr('utils')

# select a mirror for R packages
utils.chooseCRANmirror(ind=1) # select the first mirror in the list

# select a mirror for R packages
utils.chooseCRANmirror(ind=1) # select the first mirror in the list

# R package names (can be more than one)
packnames = ('tidyverse', 'ggplot2')

# R vector of strings
from rpy2.robjects.vectors import StrVector

# Selectively install what needs to be install.
names_to_install = [x for x in packnames if not rpackages.isinstalled(x)]
if len(names_to_install) > 0:
    utils.install_packages(StrVector(names_to_install))

def test_merge_duplicates_exists():
	assert path.isfile("data_prep_scripts/merge_duplicates.R")
	
#NOTE: I'm not sure why the r['source'] command requires the data_prep_scripts folder 
# while the path.isfile() command doesn't
def test_run_merge_duplicates():
	r['source']('data_prep_scripts/merge_duplicates.R')
	assert path.isfile("intermediate_data/merge_duplicates_output.csv")