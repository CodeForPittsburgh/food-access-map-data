import pandas as pd
import numpy as np

def check_has_source_orgs(data):
    """
    Returns true if all source orgs are in data's "source_org" column
    :param data:
    """
    source_orgs = ["Grow Pittsburgh",
                   "USDA Food and Nutrition Service",
                   "PA WIC",
                   "Allegheny County",
                   "FMNP Markets",
                   "Greater Pittsburgh Community Food Bank",
                   "Just Harvest"]
    for source_org in source_orgs:
        if not data["source_org"].contains(source_org):
            return False
    return True




def check_has_source_files(data):
    """
    Returns true if all listed source files are in data's "source_file" column
    :param data:
    """
    source_files = ["GP_garden_directory_listing-20210322.csv",
                    "https://services1.arcgis.com/RLQu0rK7h4kbsBq5/arcgis/rest/services/Store_Locations/FeatureServer",
                    "wicresults.json",
                    "https://services1.arcgis.com/vdNDkVykv9vEWFX4/arcgis/rest/services/Child_Nutrition/FeatureServer",
                    "https://services5.arcgis.com/n3KaqXoFYDuIhfyz/ArcGIS/rest/services/FMNPMarkets/FeatureServer",
                    "https://services1.arcgis.com/vdNDkVykv9vEWFX4/arcgis/rest/services/COVID19_Food_Access_(PUBLIC)/FeatureServer",
                    "Just Harvest Google Sheets"]
    for source_file in source_files:
        if not data["source_file"].contains(source_file):
            return False
    return True

def check_flag_columns_have_0s_and_1s(data):
    """
    Returns True if all flag columns contain both 0s and 1s. False if they contain only one or neither.
    :param data:
    """
    flag_columns = ["food_bucks","SNAP","WIC","FMNP","fresh_produce","free_distribution"]
    for flag_column in flag_columns:
        if not (data[flag_column].contains(0) and data[flag_column].contains(1)):
            return False
    return True



def sanity_check(data):
    return(
            check_flag_columns_have_0s_and_1s(data) and
            check_has_source_orgs(data) and
            check_has_source_files(data)
           )
