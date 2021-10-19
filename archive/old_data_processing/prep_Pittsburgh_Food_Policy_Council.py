import pandas as pd
import numpy as np
import os
import re

in_dir = 'food-data/PFPC_data_files'
out_dir = 'food-data/Cleaned_data_files'

final_cols = ['id', 'source_org', 'source_file', 'original_id', 'type', 'name', 'address', 'city',
              'state', 'zip_code', 'county', 'location_description', 'phone', 'url', 'latitude',
              'longitude', 'latlng_source', 'date_from', 'date_to', 'SNAP', 'WIC', 'FMNP',
              'fresh_produce', 'food_bucks', 'free_distribution', 'open_to_spec_group', 'data_issues']

### Bridgeway Capital HFFI Funds ###

in_path = 'food-data/PFPC_data_files/Bridgeway Capital - HFFI Funds.xlsx'
out_path = 'food-data/Cleaned_data_files/bridgeway_capital_hffi.csv'

df = pd.read_excel(in_path, engine='openpyxl')

# Keep only non-empty rows
df = df[df['Store Name'].notnull()]

# Assign some columns to schema fields
df['name'] = df['Store Name']
df['address'] = df['Address']
df['city'] = df['City']
df['zip_code'] = df['Zip'].astype(int)

# Set some fields directly
df['source_org'] = 'Pittsburgh Food Policy Council'
df['source_file'] = os.path.basename(in_path)
df['type'] = 'supermarket'
df['state'] = 'PA'
df['county'] = 'Allegheny'
df['fresh_produce'] = 1
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
