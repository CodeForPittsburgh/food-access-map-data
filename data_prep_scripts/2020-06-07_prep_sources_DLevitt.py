# Dependencies:
# * pandas
# * xlrd
# * numpy
# * os
# * re

import pandas as pd
import numpy as np
import os
import re

in_dir = '../food-data/PFPC_data_files'
out_dir = '../food-data/Cleaned_data_files'

final_cols = ['id', 'source_org', 'source_file', 'original_id', 'type', 'name', 'address', 'city', 
              'state', 'zip_code', 'county', 'location_description', 'phone', 'url', 'latitude', 
              'longitude', 'latlng_source', 'date_from', 'date_to', 'SNAP', 'WIC', 'FMNP', 
              'fresh_produce', 'food_bucks', 'free_distribution', 'open_to_spec_group', 'data_issues']


### Additional Food Bucks Sites ###

in_path = os.path.join(in_dir, 'Additional Food Bucks sites.xlsx')
out_path = os.path.join(out_dir, 'additional_food_bucks_sites.csv')

df = pd.read_excel(in_path)

# Drop that last row of non-data
df = df.iloc[:-1, :]

# Assign some columns to schema fields
df['name'] = df['Name']
df['address'] = df['Address']

# Set some fields directly
df['source_org'] = 'The Food Trust'
df['source_file'] = os.path.basename(in_path)
# df['type'] = "farmer's market" # no consistent type - how to handle?
# df['county'] = 'Allegheny' # no consistent county - how to handle?
df['food_bucks'] = 1
df['SNAP'] = 1 # because of food_bucks, see below
# df['FMNP'] = 1
df['free_distribution'] = 0
df['data_issues'] = '' # start with blank field, to populate later

# Reorder and add any missing columns
df = df.reindex(columns = final_cols)

# Identify which columns we have handled
handled_cols = df.columns[~df.isna().all()] # i.e. columns that aren't all NA

# Detect and document missingness in handled columns
for col in handled_cols:
    df.loc[df[col].isna(), 'data_issues'] += '{} missing;'.format(col)

# Write out to CSV
df.to_csv(out_path, index = False)


### Allegheny County Farmers Markets ###

in_path = os.path.join(in_dir, 'Allegheny_County_Farmers_Markets_Locations_2019.csv')
out_path = os.path.join(out_dir, 'allegheny_county_farmers_markets.csv')

df = pd.read_csv(in_path)

# Some resources to help with date_from and date_to

month_lengths = {'January': 31,
                 'February': 28,
                 'March': 31,
                 'April': 30,
                 'May': 31,
                 'June': 30,
                 'July': 31,
                 'August': 31,
                 'September': 30,
                 'October': 31,
                 'November': 30,
                 'December': 31}

def string_to_start_date(string):
    if string == 'Year Round':
        return 'January 1'
    elif ' ' in string:
        return string
    else:
        return string + ' 1'

def string_to_end_date(string):
    if string == 'Year Round':
        return 'December 31'
    elif ' ' in string:
        return string
    else:
        return string + ' {}'.format(month_lengths[string])
    
def try_except(function, arg, subscript): # solely necessary in case any data are missing
    try:
        return function(arg[subscript])
    except Exception:
        return np.nan

# Assign some columns to schema fields
df['name'] = df['Name']
df['address'] = df['Street_Address']
df['city'] = df['City']
df['state'] = df['State']
df['zip_code'] = df['Zip']
df['latitude'] = df['Latitude']
df['longitude'] = df['Longitude']
df['location_description'] = df['Additional_Directions']

# Set some fields directly
df['source_org'] = 'Allegheny County Health Department'
df['source_file'] = os.path.basename(in_path)
df['type'] = "farmer's market"
df.loc[df['Name'].str.lower().str.contains('fresh access') | df['Affiliations'].str.lower().str.contains('fresh access'),
       'type'] = 'fresh access'
df['county'] = 'Allegheny'
df['latlng_source'] = df['source_org']
df['FMNP'] = 1
df['fresh_produce'] = 1
df.loc[df['type'] == 'fresh access', 'SNAP'] = 1
df.loc[df['type'] == 'fresh access', 'food_bucks'] = 1
df['free_distribution'] = 0
df['data_issues'] = '' # start with blank field, to populate later

# Calculate date_from and date_to from Season field
df['Season'] = df['Season'].str.strip(' ') # clean off leading/trailing spaces
df['Season'] = df['Season'].str.split('-')
df['date_from'] = df['Season'].apply(lambda x: try_except(string_to_start_date, x, 0))
df['date_to'] = df['Season'].apply(lambda x: try_except(string_to_end_date, x, -1))

# Someday we will handle opening days/times robustly. For now I will append them to location_description :P
df.loc[df['location_description'].notna(), 'location_description'] = df['location_description'] + '; ' + df['Day_Time']
df.loc[df['location_description'].isna(), 'location_description'] = df['Day_Time']

# Reorder and add any missing columns
df = df.reindex(columns = final_cols)

# Identify which columns we have handled
handled_cols = df.columns[~df.isna().all()] # i.e. columns that aren't all NA

# Detect and document missingness in handled columns
for col in handled_cols:
    df.loc[df[col].isna(), 'data_issues'] += '{} missing;'.format(col)

# Detect some specific data issues 
df.loc[((df['latitude'] == 0) & (df['longitude'] == 0)), 'data_issues'] += 'latlng is (0,0);'

# Write out to CSV
df.to_csv(out_path, index = False)


### Just Harvest Fresh Access Markets ###

in_path = os.path.join(in_dir, 'Just Harvest - Fresh Access Markets.xlsx')
out_path = os.path.join(out_dir, 'just_harvest_fresh_access_markets.csv')

df = pd.read_excel(in_path)

# Assign some columns to schema fields
df['name'] = df['Market']
df['location_description'] = df['description']

# Set some fields directly
df['source_org'] = 'Just Harvest'
df['source_file'] = os.path.basename(in_path)
df['type'] = "fresh access"
df['county'] = 'Allegheny'
df['SNAP'] = 1 # because of food_bucks, see below
df['WIC'] = 1 # based on inspection of http://www.justharvest.org/fresh-access/local-farmers-markets-and-farm-stands-accepting-food-stamps/
df['FMNP'] = 1 # Sarah Buranskas to confirm this
df['fresh_produce'] = 1
df['food_bucks'] = 1
df['free_distribution'] = 0
df['data_issues'] = '' # start with blank field, to populate later

# Fill missing addresses with intersections
df.loc[df['address'].isna(), 'address'] = df.loc[df['address'].isna(), 'street_one'] \
    + ' & ' + df.loc[df['address'].isna(), 'street_two']

# Calculate date_from and date_to from Season field
df['date_from'] = df['Season'].apply(lambda x: re.search(r'.+\d', x.split('-')[0]).group())
df['date_to'] = df['Season'].apply(lambda x: re.search(r'.+\d', x.split('-')[1]).group())

# Someday we will handle opening days/times robustly. For now I will append them to location_description :P
df.loc[df['location_description'].notna(), 'location_description'] = df['location_description'] + '; ' + df['Date/Time']
df.loc[df['location_description'].isna(), 'location_description'] = df['Date/Time']

# Reorder and add any missing columns
df = df.reindex(columns = final_cols)

# Identify which columns we have handled
handled_cols = df.columns[~df.isna().all()] # i.e. columns that aren't all NA

# Detect and document missingness in handled columns
for col in handled_cols:
    df.loc[df[col].isna(), 'data_issues'] += '{} missing;'.format(col)

# Write out to CSV
df.to_csv(out_path, index = False)


### Fresh Corners ###

in_path = os.path.join(in_dir, 'Just Harvest - Fresh Corners Stores.xlsx')
out_path = os.path.join(out_dir, 'just_harvest_fresh_corners.csv')

df = pd.read_excel(in_path)

# Assign some columns to schema fields
df['name'] = df['Corner Store'].str.strip('\n')
df['address'] = df['Address']
df['city'] = df['City']
df['zip_code'] = df['Zip']

# Set some fields directly
df['source_org'] = 'Just Harvest'
df['source_file'] = os.path.basename(in_path)
df['type'] = "convenience store"
df['state'] = 'PA'
df['county'] = 'Allegheny'
df['FMNP'] = 0 # per Sarah Buranskas conversation
df['fresh_produce'] = 1 # the whole point of the program
df['food_bucks'] = 0 # start with 0 and set relevant sites to 1
df.loc[df['Participates in Food Bucks SNAP Incentive Program'] == 'yes', 'food_bucks'] = 1
df.loc[df['food_bucks'] == 1, 'SNAP'] = 1
df['free_distribution'] = 0
df['data_issues'] = '' # start with blank field, to populate later

# Reorder and add any missing columns
df = df.reindex(columns = final_cols)

# Identify which columns we have handled
handled_cols = df.columns[~df.isna().all()] # i.e. columns that aren't all NA

# Detect and document missingness in handled columns
for col in handled_cols:
    df.loc[df[col].isna(), 'data_issues'] += '{} missing;'.format(col)

# Write out to CSV
df.to_csv(out_path, index = False)


### Greater Pittsburgh Community Food Bank ###

in_path = os.path.join(in_dir, '2019-10-10 PGH Food Bank Site Addresses.xlsx')
out_path = os.path.join(out_dir, 'greater_pittsburgh_community_food_bank.csv')

df = pd.read_excel(in_path)

# Drop that one empty row at the end
df = df[df['AgencyRef'].notna()]

# Keep only active sites
df = df[df['Food Bank - Inactive In Inventory System'] == 0] # what about all the blanks?

# Assign some columns to schema fields
df['original_id'] = df['AgencyRef']
df['name'] = df['AgencyName']
df['city'] = df['City']
df['state'] = df['State']
df['zip_code'] = df['Zip']
df['county'] = df['County']
df['latitude'] = df['Google Lat']
df['longitude'] = df['Google Long']

# Set some fields directly
df['source_org'] = 'Greater Pittsburgh Community Food Bank'
df['source_file'] = os.path.basename(in_path)
df['type'] = 'food bank site'
df['latlng_source'] = df['source_org']
df['free_distribution'] = 1
df['data_issues'] = '' # start with blank field, to populate later
# Per conversation with Justin 2020-03-03, set these booleans to 0 because you don't pay for free food!
for field in ['SNAP', 'WIC', 'FMNP', 'food_bucks']:
    df[field] = 0

# Set the fresh_produce flag
df['GroupTypes'] = df['GroupTypeOne'] + df['GroupTypeTwo'] + df['GroupTypeThree']
df['fresh_produce'] = 0
df.loc[df['GroupTypes'].str.contains('Grocery') | df['GroupTypes'].str.contains('Fresh Market'), 'fresh_produce'] = 1

# Clean up and concatenate address fields
df['Addr1'] = df['Addr1'].str.replace('  ', ' ').str.strip(' ')
df['Addr2'] = df['Addr2'].str.replace('  ', ' ').str.strip(' ')
df.loc[df['Addr2'].notna(), 'address'] = df['Addr1'] + ', ' + df['Addr2']
df.loc[df['Addr2'].isna(), 'address'] = df['Addr1']

# Reorder and add any missing columns
df = df.reindex(columns = final_cols)

# Identify which columns we have handled
handled_cols = df.columns[~df.isna().all()] # i.e. columns that aren't all NA

# Detect and document missingness in handled columns
for col in handled_cols:
    df.loc[df[col].isna(), 'data_issues'] += '{} missing;'.format(col)

# Detect some specific data issues 
df.loc[((df['latitude'] == 0) & (df['longitude'] == 0)), 'data_issues'] += 'latlng is (0,0);'

# Write out to CSV
df.to_csv(out_path, index = False)


### Summer Meal Sites ###

in_path = os.path.join(in_dir, 'Summer_Meal_Sites_2019.csv')
out_path = os.path.join(out_dir, 'summer_meal_sites_2019.csv')

df = pd.read_csv(in_path, encoding = 'ansi')

# Filter down to Allegheny County sites only
df = df.loc[(df['siteState'] == 'PA') & (df['County'] == 'Allegheny')]

# Assign some columns to schema fields
df['original_id'] = df['FNSID']
df['name'] = df['siteName'].str.title() # deal with ALL CAPS
df['city'] = df['siteCity'].str.title()
df['state'] = df['siteState']
df['zip_code'] = df['siteZip'].str.zfill(5)
df['county'] = df['County']
df['latitude'] = df['Y']
df['longitude'] = df['X']

# Handle phone numbers with and without extensions
df.loc[df['ext'].notnull(), 'phone'] = df.loc[df['ext'].notnull(), 'sitePhone'].astype('int64').astype(str) + \
                                       'x' + df.loc[df['ext'].notnull(), 'ext'].astype('int64').astype(str)
df.loc[df['ext'].isnull(), 'phone'] = df.loc[df['ext'].isnull(), 'sitePhone']

# Handle address, fun text processing
df['address'] = df.apply(lambda x: x['siteAddress'].split(' ' + x['siteCity'])[0].title(), axis = 1)

# Set some fields directly
df['source_org'] = 'USDA Food and Nutrition Service'
df['source_file'] = os.path.basename(in_path)
df['type'] = "summer meal site"
df['latlng_source'] = df['source_org']

df['SNAP'] = 0
df['WIC'] = 0
df['FMNP'] = 0
# df['fresh_produce'] = 1
df['food_bucks'] = 0
df['free_distribution'] = 1
df['open_to_spec_group'] = 'children and teens 18 and younger'
df['data_issues'] = '' # start with blank field, to populate later

# Calculate date_from and date_to
df['date_from'] = df['startDate'].str.split('T').str[0]
df['date_to'] = df['endDate'].str.split('T').str[0]

# Reorder and add any missing columns
df = df.reindex(columns = final_cols)

# Identify which columns we have handled
handled_cols = df.columns[~df.isna().all()] # i.e. columns that aren't all NA

# Detect and document missingness in handled columns
for col in handled_cols:
    df.loc[df[col].isna(), 'data_issues'] += '{} missing;'.format(col)

# Detect some specific data issues 
df.loc[((df['latitude'] == 0) & (df['longitude'] == 0)), 'data_issues'] += 'latlng is (0,0);'

# Write out to CSV
df.to_csv(out_path, index = False)