"""
Data Prep Script by Mary Kohl
Adapted from 2020-06-07_prep_sources_DLevitt.py
Last updated 2021-06-25 by CMoreno to link directly to web API
"""

import pandas as pd
# import numpy as np
import os
# import re
import requests


source = 'https://services5.arcgis.com/n3KaqXoFYDuIhfyz/ArcGIS/rest/services/FMNPMarkets/FeatureServer'
## api end point for Allegheny county, see source for more info
in_path = source + '/0/query?where=FarmMarketCounty+%3D+%27Allegheny%27&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=true&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token='

out_dir = 'food-data/Cleaned_data_files'
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

## get Market data
raw_dat = requests.get(in_path).json()
get_entries = []
for i in range(len(raw_dat['features'])):
    get_entries.append(pd.json_normalize(raw_dat['features'][i]['attributes']))

df = pd.concat(get_entries).reset_index(drop = True)

## get Vendor schedule
get_vendor_info = []
for v in range(len(df)):
    this_market = df['FarmMarketID'][v]
    vend_api_call = requests.get('https://services5.arcgis.com/n3KaqXoFYDuIhfyz/ArcGIS/rest/services/FMNPMarkets/FeatureServer/1/query?where=FarmMarketID+%3D+%27' + str(this_market) + '%27&objectIds=&time=&resultType=none&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token=')
    j = vend_api_call.json()
    if len(j['features']) > 0:
        track_vendors = []
        for i in range(len(j['features'])):
            track_vendors.append(pd.json_normalize(j['features'][i]['attributes']))

        track_vendors = pd.concat(track_vendors).reset_index(drop = True)
        get_vendor_info.append(track_vendors)

vendor_df = pd.concat(get_vendor_info).reset_index(drop = True)
vendor_df = vendor_df[['FarmMarketID', 'VendorSchedule']].drop_duplicates()
vendor_df = vendor_df[~(vendor_df['VendorSchedule']== '')]
## get Vendor schedule for different days of week (if same day will only take first value, assume operating hours among vendors are similar enough within a market day)
vendor_df['day'] = vendor_df['VendorSchedule'].str.extract(r'(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)')
vendor_df = vendor_df.groupby(['FarmMarketID', 'day']).first().groupby('FarmMarketID')['VendorSchedule'].apply(lambda x: "%s" % '; '.join(x)).reset_index()

## join vendor info to market info
df = df.merge(vendor_df, how = 'left', on = 'FarmMarketID')

## set up df to be aligned with schema
df['name'] = df['MarketName'].str.strip()
df['address'] = df['Address1']
df['city'] = df['City']
df['state'] = df['StateCode']
df['zip_code'] = df['Zip']
df['latitude'] = df['Latitude']
df['longitude'] = df['Longitude']
df['location_description'] = df['VendorSchedule']
df['type'] = "farmer's market" # to match schema, this type applies to farmers markets and green grocer
df['county'] = df['FarmMarketCounty']
df['phone'] = df['MarketPhone']
df['data_issues'] = ''
df['original_id'] = df['FarmMarketID']

df['source_org'] = 'FMNP Markets'
df['source_file'] = source #os.path.basename(in_path)
df['latlng_source'] = df['source_org']

## apply rules that apply to both farmers market and green grocer
df['FMNP'] = 1
df['fresh_produce'] = 1
df['free_distribution'] = 0
df['open_to_spec_group'] = 0


# apply rules specific to green grocer (per 05/19/2020 communication with Sarah B.)
df.loc[df['name'].str.lower().str.contains('green grocer'),'SNAP'] = 1
df.loc[df['name'].str.lower().str.contains('green grocer'),'WIC'] = 0
df.loc[df['name'].str.lower().str.contains('green grocer'),'food_bucks'] = 1

schedule = df['VendorSchedule']#.str.strip(' ')

# Get Date Range - There is probably an 'nicer' way to do this... Note, this is using months from first entry of Vendor Schedule
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


# Identify which columns we have handled
handled_cols = df.columns[~df.isna().all()] # i.e. columns that aren't all NA

# Detect and document missingness in handled columns
for col in handled_cols:
    df.loc[df[col].isna(), 'data_issues'] += '{} missing;'.format(col)

# Write out to CSV
df.to_csv(out_path, index = False)
