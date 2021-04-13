"""
Data Prep Script by Oscar Syu
Adapted from 2020-06-07_prep_sources_DLevitt.py
"""
import pandas as pd
import numpy as np
import os
import re

in_dir = '../food-data/PFPC_data_files'
out_dir = '../food-data/Cleaned_data_files'

in_path = os.path.join(in_dir,'%5BPUBLIC%5D_COVID19_Food_Access.csv')
out_path = os.path.join(out_dir,'greater_pittsburgh_community_food_bank.csv')

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

df = pd.read_csv(in_path)

# Keep only active sites
df = df[df['STATUS'] == 'active']

df['source_org'] = 'Greater Pittsburgh Community Food Bank'
df['source_file'] = os.path.basename(in_path)
df['original_id'] = df['globalid'].str.strip('{}')
df['type'] = 'food bank site'
df['name'] = df['SITE_name']
#concatenate extra details, including suite number and more descriptions
df['city'] = df['SITE_city']
df['state'] = df['SITE_state']
df['zip_code'] = df['SITE_zip']
df['county'] = '' #no county given in this dataset

df['phone'] = df['POC_phone']
df['url'] = df['SITE_website']
df['latlng_source'] = df['source_org']

df['longitude'] = df['X']
df['latitude'] = df['Y']

schedule = df['Time'].str.strip(' ')
df['date_from'] = ''
df['date_to'] = ''

df['fresh_produce'] = 0
df.loc[df['PublicNotes'].str.lower().str.contains('grocery') | df['PublicNotes'].str.lower().str.contains('groceries') | df['PublicNotes'].str.contains('fresh') | df['PublicNotes'].str.lower().str.contains('fresh produce'), 'fresh_produce'] = 1

df['free_distribution'] = 1
df['open_to_spec_group'] = df['Population_Served_filter']
df['open_to_spec_group'] = df['open_to_spec_group'].apply((lambda x: 0 if ('everyone' in x) else x)) #fill all others with 0
df['data_issues'] = '' # start with blank field, to populate later
# # Per conversation with Justin 2020-03-03, set these booleans to 0 because you don't pay for free food!
for field in ['SNAP', 'WIC', 'FMNP', 'food_bucks']:
    df[field] = 0

df['SITE_address1'] = df['SITE_address1'].str.replace('  ', ' ').str.strip(' ')
df['SITE_address2'] = df['SITE_address2'].str.replace('  ', ' ').str.strip(' ')
df['address'] = df['SITE_address1']
# df.loc[df['SITE_address2'].notna(), 'address'] = df['SITE_address1']
# df.loc[df['SITE_address2'].isna(), 'address'] = df['SITE_address1']

public_notes = df['PublicNotes'].str.replace('\(none\)', '').astype(str).str.replace('nan', '').str.strip(',').str.strip(', ').str.strip('.')
time = df['Time'].str.replace('\(none\)', '').astype(str).str.strip(',').str.replace('nan', '').str.strip(', ').str.strip('.')
SITE_specific_location =  df['SITE_specific_location'].str.replace("\(none\)", '').astype(str).str.replace('nan', '').str.strip(',').str.strip(', ').str.strip('.')
pop_served = df['Population_Served'].astype(str).str.replace('nan', '').str.strip(',').str.strip(', ').str.strip('.')
df['location_description'] = (pop_served + ', ' + SITE_specific_location + ', '
 + public_notes + ', ' + time + ', ' + df['SITE_address2'].astype(str).str.replace('nan', '')).str.strip(',').str.strip(', ').str.replace(', , ,', ',').str.replace(', ,', ',')

# Reorder and add any missing columns
df = df.reindex(columns = final_cols)

# Identify which columns we have handled
handled_cols = df.columns[~df.isna().all()] # i.e. columns that aren't all NA

# Detect and document missingness in handled columns
for col in handled_cols:
    df.loc[df[col].isna(), 'data_issues'] += '{} missing;'.format(col)

# Detect some specific data issues
df.loc[((df['latitude'] == 0) & (df['longitude'] == 0)), 'data_issues'] += 'latlng is (0,0);'


df.to_csv(out_path, index = False)
