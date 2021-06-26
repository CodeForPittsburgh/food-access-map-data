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

df = pd.read_excel(in_path, engine='openpyxl')

# Drop that last row of non-data
df = df.iloc[:-1, :]

# Assign some columns to schema fields
df['name'] = df['Name']
df['address'] = df['Address']
df['zip_code'] = df['zip_code'].astype(int)

# Set some fields directly
df['source_org'] = 'The Food Trust'
df['source_file'] = os.path.basename(in_path)
# df['type'] = "farmer's market" # no consistent type - how to handle?
df['county'] = 'Allegheny' # no consistent county - how to handle?
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