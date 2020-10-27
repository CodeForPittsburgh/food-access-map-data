"""
Data Prep Script by Mary Kohl
Adapted from 2020-06-07_prep_sources_DLevitt.py
"""

import pandas as pd
import numpy as np
import os
import re

in_dir = '../food-data/PFPC_data_files'
out_dir = '../food-data/Cleaned_data_files'

in_path = os.path.join(in_dir,'FMNPMarkets.xlsx')
out_path = os.path.join(out_dir,'FMNPMarkets.csv')

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

final_cols = ['id', 'source_org', 'source_file', 'original_id', 'type', 'name', 'address', 'city',
              'state', 'zip_code', 'county', 'location_description', 'phone', 'url', 'latitude',
              'longitude', 'latlng_source', 'date_from', 'date_to', 'SNAP', 'WIC', 'FMNP',
              'fresh_produce', 'food_bucks', 'free_distribution', 'open_to_spec_group', 'data_issues']

df = pd.read_excel(in_path)

df['name'] = df['Market Name']
df['address'] = df['Address1']
df['city'] = df['City']
df['state'] = df['State Code']
df['zip_code'] = df['Zip']
df['latitude'] = df['Latitude (String)']
df['longitude'] = df['Longitude (String)']
df['location_description'] = df['Vendor Schedule']
df['type'] = df['Market Type']
df['county'] = df['Farm Market County']
df['phone'] = df['Market Phone']
df['data_issues'] = ''

df['source_org'] = 'FMNP Markets'
df['source_file'] = os.path.basename(in_path)
df['latlng_source'] = df['source_org']
df['FMNP'] = 1

schedule = df['Vendor Schedule'].str.strip(' ')

# Get Date Range - There is probably an 'nicer' way to do this....
date_to = []
date_from = []
for date in schedule:
    if str(date) != "nan":
        date = str(date).split()
        if date[1] != '-':
            date_from.append(date[0] + " " + date[1])
            date_to.append(date[3] + " " + date[4])
        else:
            date_from.append(date[0] + " " + "1")
            date_to.append(date[2] + " " + str(month_lengths[date[2]]))
    else:
        date_to.append("")
        date_from.append("")
df['date_to'] = date_to
df['date_from'] = date_from

df = df.reindex(columns = final_cols)
df.dropna(subset = ["name"], inplace=True)

# Identify which columns we have handled
handled_cols = df.columns[~df.isna().all()] # i.e. columns that aren't all NA

# Detect and document missingness in handled columns
for col in handled_cols:
    df.loc[df[col].isna(), 'data_issues'] += '{} missing;'.format(col)
# Write out to CSV
df.to_csv(out_path, index = False)
