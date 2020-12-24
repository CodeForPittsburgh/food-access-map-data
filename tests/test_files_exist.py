#test_files_exist.py
import os.path
from os import path

def test_merge_duplicates_exists():
	assert path.isfile("data_prep_scripts/merge_duplicates.R")