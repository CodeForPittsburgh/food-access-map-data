import pandas as pd
import numpy as np
import abbreviate
import usaddress
import nltk
import fuzzywuzzy
import string
from num2words import num2words
import re
import sys
from io import StringIO

dat = pd.read_json(StringIO(sys.stdin.read()), lines=True)

# dat = pd.read_csv('../../food-access-map-data/merged_datasets.csv')

# preprocess addresses
	# strip punctuation from name
	# remove periods from street name

dat['address'] = dat['address'].fillna('')

#from https://gis.stackexchange.com/questions/336221/converting-abbreviation-street-type-names-to-full-names-using-dictionary-for-pyt
d = { 
    'aly' : 'Alley',
    'ave' : 'Avenue',
    'blv' : 'Boulevard',
    'blvd' : 'Boulevard',
    'cir' : 'Circle',
    'ct' : 'Court',
    'cv' : 'Cove',
    'cyn' : 'Canyon',
    'dr' : 'Drive',
    'expy' : 'Expressway',
    'hwy' : 'Highway',
    'ln' : 'Lane',
    'pkwy' : 'Parkway',
     'plz': 'Plaza',
    'pl' : 'Place',
    'pk' : 'Park',
    'pt' : 'Point',
    'rd' : 'Road',
    'sq' : 'Square',
    'st' : 'Street',
    'ter' : 'Terrace',
    'tr' : 'Trail',
    'trl' : 'Trail',
    'wy' : 'Way'
    }


#looks up the longer form 
def abbreviate(x):
    no_punc = x.strip('.')
    if no_punc.lower() in d.keys(): #rematch
        return d[no_punc.lower()]
    else:
        return x

dat_cleaned = dat.copy(deep = True)

dat_cleaned['address'] = dat_cleaned['address'].apply(lambda x: ' '.join([abbreviate(w) for w in x.split()]))

def convert_number_street_names(street):
    if re.match(r'.*(\d+)(rd|th|st).*', street) is None:
        return street
    return num2words(re.match(r'.*(\d+)(rd|th|st).*', street)[1], lang="en", to="ordinal")

#convert street numbers from number to letters
dat_cleaned['address'] = dat_cleaned['address'].apply((lambda x: ' '.join([convert_number_street_names(w).capitalize() for w in x.split()])))

output = dat_cleaned.to_json(orient="records", lines=True)

sys.stdout.write(output)

# Close the file

sys.stdout.close()