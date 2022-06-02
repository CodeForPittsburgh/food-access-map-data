import sys
import auto_sanity_check_function
import pandas as pd
from io import StringIO

dat = pd.read_csv(StringIO(sys.stdin.read()))

# These are the current categories expected in each of the given categorical columns
categories = {}
categories["source_org"] = ["Grow Pittsburgh",
                             "USDA Food and Nutrition Service",
                             "PA WIC",
                             "Allegheny County",
                             "FMNP Markets",
                             "Greater Pittsburgh Community Food Bank",
                             "Just Harvest"]
categories["source_file"] = ["GP_garden_directory_listing-20210322.csv",
                              "https://services1.arcgis.com/RLQu0rK7h4kbsBq5/arcgis/rest/services/Store_Locations/FeatureServer",
                              "wicresults.json",
                              "https://services1.arcgis.com/vdNDkVykv9vEWFX4/arcgis/rest/services/Child_Nutrition/FeatureServer",
                              "https://services5.arcgis.com/n3KaqXoFYDuIhfyz/ArcGIS/rest/services/FMNPMarkets/FeatureServer",
                              "https://services1.arcgis.com/vdNDkVykv9vEWFX4/arcgis/rest/services/COVID19_Food_Access_(PUBLIC)/FeatureServer",
                              "Just Harvest Google Sheets"]

# These are the flag columns that will be examined to confirm they contain 0s and 1s.
flag_columns = ["food_bucks", "SNAP", "WIC", "FMNP", "fresh_produce", "free_distribution"]

# auto_id_duplicates_wrapper
sys.stdout.write(auto_sanity_check_function.sanity_check(dat, flag_columns, categories))
