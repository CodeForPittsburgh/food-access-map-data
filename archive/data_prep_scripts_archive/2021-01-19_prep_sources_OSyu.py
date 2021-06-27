"""
Data Prep Script by Oscar Syu
Adapted from 2020-06-07_prep_sources_DLevitt.py
"""
import pandas as pd
import numpy as np
import os
import re
import urllib.request, json

#for reading in with csv
# in_dir = '../food-data/PFPC_data_files'
out_dir = '../food-data/Cleaned_data_files'

# in_path = os.path.join(in_dir,'%5BPUBLIC%5D_COVID19_Food_Access.csv')
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

#for reading in with csv
# df = pd.read_csv(in_path)

#read in data from the api
api = "https://services1.arcgis.com/vdNDkVykv9vEWFX4/arcgis/rest/services/COVID19_Food_Access_(PUBLIC)/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=true&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token="

with urllib.request.urlopen(api) as url:
    data = json.loads(url.read().decode())

df = pd.json_normalize(data['features'])
df.columns = [x.replace('attributes.', '').replace('geometry.', '') for x in df.columns]
df = df.rename(columns={'x':'X', 'y':'Y'})
# Keep only active sites
df = df[df['STATUS'] == 'active']

df['source_org'] = 'Greater Pittsburgh Community Food Bank'
df['source_file'] = 'https://services1.arcgis.com/vdNDkVykv9vEWFX4/arcgis/rest/services/COVID19_Food_Access_(PUBLIC)/FeatureServer' #%5BPUBLIC%5D_COVID19_Food_Access.csv'
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
