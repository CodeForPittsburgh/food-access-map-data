import pandas as pd
import numpy as np
import os
import re
import requests
import time 

source = 'https://services1.arcgis.com/vdNDkVykv9vEWFX4/arcgis/rest/services/Child_Nutrition/FeatureServer'
in_path = source + '/0/query?outFields=*&where=1%3D1&f=geojson'
out_dir = '../food-data/Cleaned_data_files'
out_path = os.path.join(out_dir, 'cleaned_summer_meal_sites_api.csv')

final_cols = ['id', 'source_org', 'source_file', 'original_id', 'type', 'name', 'address', 'city', 
              'state', 'zip_code', 'county', 'location_description', 'phone', 'url', 'latitude', 
              'longitude', 'latlng_source', 'date_from', 'date_to', 'SNAP', 'WIC', 'FMNP', 
              'fresh_produce', 'food_bucks', 'free_distribution', 'open_to_spec_group', 'data_issues']

### Summer Meal Sites ###
raw_dat = requests.get(in_path).json() #pd.read_csv(in_path, encoding = 'ansi')
get_entries = []
for i in range(len(raw_dat['features'])):
    get_entries.append(pd.json_normalize(raw_dat['features'][i]['properties']))

df = pd.concat(get_entries).reset_index(drop = True)

# Filter down to Allegheny County sites only
df = df.loc[(df['Site_State'] == 'PA') & (df['Site_County'] == 'Allegheny')].reset_index()

# Assign some columns to schema fields
df['original_id'] = df['Site_ID_External']
df['name'] = df['Site_Name'].str.title() # deal with ALL CAPS
df['city'] = df['Site_City'].str.title()
df['state'] = df['Site_State']
df['zip_code'] = df['Site_Zip'].str.zfill(5)
df['address'] = df['Site_Street']
df['county'] = df['Site_County']
df['latitude'] = df['Latitude']
df['longitude'] = df['Longitude']
df['date_from'] = df['Start_Date'].apply(lambda x: time.strftime('%B %d %Y', time.localtime(x/1000)) if x != None else None)
df['date_to'] = df['End_Date'].apply(lambda x: time.strftime('%B %d %Y', time.localtime(x/1000)) if x != None else None)
                                           

## add into to location description
df["location_description"] = None 
for row in range(len(df)):
    res = ''
    if df['Site_Street2'][row] != '':
         res = res + 'Site Location Info: ' + df['Site_Street2'][row] +'; '
    if df['Service_Type'][row] != '':
        res = res + ' Service Type: ' + df['Service_Type'][row] +'; '
    if df['Site_Hours'][row] != '':
        res = res + 'Site Hours: ' + df['Site_Hours'][row]  + '; '
    if df['Comments'][row] != '':
        res = res + 'Comments: ' + df['Comments'][row] + '; '
    if df['Site_Instructions'][row] != '':
        res = res + 'Site Instructions: ' + df['Site_Instructions'][row]
    df['location_description'][row] = res
        
        
# Set some fields directly
df['source_org'] = 'Allegheny County'
df['source_file'] = source #os.path.basename(in_path)
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


# Reorder and add any missing columns
df = df.reindex(columns = final_cols)

# Identify which columns we have handled
handled_cols = df.columns[~df.isna().all()] # i.e. columns that aren't all NA

# Detect and document missingness in handled columns
for col in handled_cols:
    df.loc[df[col].isna(), 'data_issues'] += '{} missing;'.format(col)

# Detect some specific data issues 
# df.loc[((df['latitude'] == 0) & (df['longitude'] == 0)), 'data_issues'] += 'latlng is (0,0);'

# Write out to CSV
df.to_csv(out_path, index = False)
