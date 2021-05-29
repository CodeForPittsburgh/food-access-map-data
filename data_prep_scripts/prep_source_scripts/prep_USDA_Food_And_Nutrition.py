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
