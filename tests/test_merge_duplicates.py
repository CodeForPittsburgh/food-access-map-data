#test_files_exist.py
from rpy2.robjects.packages import importr
import rpy2.robjects as robjects
import subprocess
import os.path
from os import path

r=robjects.r

# base = importr('base')
# utils = importr('utils')

def test_merge_duplicates_exists():
	assert path.isfile("data_prep_scripts/merge_duplicates.R")
	
#NOTE: I'm not sure why the r['source'] command requires the data_prep_scripts folder 
# while the path.isfile() command doesn't
def test_run_merge_duplicates():
	r['source']('data_prep_scripts/merge_duplicates.R')
	assert path.isfile("intermediate_data/merge_duplicates_output.csv")