import pandas as pd
correct_dataframe = pd.DataFrame([
    {"source_org": "Grow Pittsburgh", "source_file": "GP_garden_directory_listing-20210322.csv", "food_bucks": 1 , "SNAP": 0, "WIC": 0, "FMNP": 1, "fresh_produce": 0, "free_distribution": 1},
    {"source_org": "USDA Food and Nutrition Service", "source_file": "https://services1.arcgis.com/RLQu0rK7h4kbsBq5/arcgis/rest/services/Store_Locations/FeatureServer", "food_bucks": 1 , "SNAP": 0, "WIC": 0, "FMNP": 1, "fresh_produce": 0, "free_distribution": "NA"},
    {"source_org": "PA WIC", "source_file": "wicresults.json", "food_bucks": 1 , "SNAP": "NA", "WIC": 0, "FMNP": 0, "fresh_produce": 0, "free_distribution": 0},
    {"source_org": "Allegheny County", "source_file": "https://services1.arcgis.com/vdNDkVykv9vEWFX4/arcgis/rest/services/Child_Nutrition/FeatureServer", "food_bucks": 0 , "SNAP": 1, "WIC": 0, "FMNP": "NA", "fresh_produce": "NA", "free_distribution": 1},
    {"source_org": "FMNP Markets", "source_file": "https://services5.arcgis.com/n3KaqXoFYDuIhfyz/ArcGIS/rest/services/FMNPMarkets/FeatureServer", "food_bucks": "NA", "SNAP": 0, "WIC": "NA", "FMNP": 1, "fresh_produce": 1, "free_distribution": 1},
    {"source_org": "Greater Pittsburgh Community Food Bank", "source_file": "https://services1.arcgis.com/vdNDkVykv9vEWFX4/arcgis/rest/services/COVID19_Food_Access_(PUBLIC)/FeatureServer", "food_bucks": 1 , "SNAP": 0, "WIC": 1, "FMNP": 1, "fresh_produce": 0, "free_distribution": 1},
    {"source_org": "Just Harvest", "source_file": "Just Harvest Google Sheets", "food_bucks": 1 , "SNAP": 0, "WIC": 0, "FMNP": 1, "fresh_produce": 0, "free_distribution": 1}
])
flag_columns = ["food_bucks", "SNAP", "WIC", "FMNP", "fresh_produce", "free_distribution"]
incorrect_dataframe = pd.DataFrame([
    {"source_org": "USDA Food and Nutrition Service", "source_file": "GP_garden_directory_listing-20210322.csv", "food_bucks": 1 , "SNAP": 0, "WIC": 0, "FMNP": 1, "fresh_produce": 0, "free_distribution": "NA"},
    {"source_org": "USDA Food and Nutrition Service", "source_file": "wicresults.json", "food_bucks": 1 , "SNAP": 0, "WIC": 0, "FMNP": 1, "fresh_produce": 0, "free_distribution": "NA"},
    {"source_org": "PA WIC", "source_file": "wicresults.json", "food_bucks": 1 , "SNAP": 0, "WIC": 0, "FMNP": 0, "fresh_produce": 0, "free_distribution": "NA"},
    {"source_org": "Allegheny County", "source_file": "https://services1.arcgis.com/vdNDkVykv9vEWFX4/arcgis/rest/services/Child_Nutrition/FeatureServer", "food_bucks": 1 , "SNAP": 0, "WIC": 0, "FMNP": "NA", "fresh_produce": "NA", "free_distribution": "NA"},
    {"source_org": "FMNP Markets", "source_file": "https://services5.arcgis.com/n3KaqXoFYDuIhfyz/ArcGIS/rest/services/FMNPMarkets/FeatureServer", "food_bucks": 1, "SNAP": 0, "WIC": "NA", "FMNP": 1, "fresh_produce": 1, "free_distribution": "NA"},
    {"source_org": "Greater Pittsburgh Community Food Bank", "source_file": "https://services1.arcgis.com/vdNDkVykv9vEWFX4/arcgis/rest/services/COVID19_Food_Access_(PUBLIC)/FeatureServer", "food_bucks": 1, "SNAP": 0, "WIC": 1, "FMNP": 1, "fresh_produce": 0, "free_distribution": "NA"},
    {"source_org": "Just Harvest", "source_file": "Just Harvest Google Sheets", "food_bucks": 1 , "SNAP": 0, "WIC": 0, "FMNP": 1, "fresh_produce": 0, "free_distribution": "NA"}
])

def test_check_has_source_orgs():
    assert False


def test_check_has_source_files():
    assert False


def test_check_flag_columns_have_0s_and_1s():
    assert False


def test_sanity_check():
    assert False
