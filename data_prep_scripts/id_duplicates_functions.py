import pandas as pd, dedupe, json

def id_duplicates(data):
    return

def get_relevant_data(df):
    #This takes all empty strings and replaces them with a single space -- this is a workaround because the deduper cannot compare empty strings.
    df = df.replace(r'^\s*$', " ", regex=True)

    rd = df[['name', 'address']].astype(str)
    rd['LatLong'] = list(zip(df.latitude, df.longitude))
    rd['type'] = df['type'].astype(str)
    data = rd.to_dict(orient='index')
    return data

#Load fake data for the purposes of testing. 
def load_fake_data():
    data = pd.read_csv("../tests/test-data/test_id_duplicates_fake_datasets.csv")
    return data

def assign_group_ids(data, duplicate_list):
    #Maintain group_id counter. Increment for each set of duplicates id'd
    gid = 1
    #Go through duplicate_list
    for duplicate_set in duplicate_list:
        #Assign corresponding records in dataset the gid
        #Increment gid
        gid+=1
    return data

def initialize_deduper(data):
    # initialize from a defined set of fields
    variables = [{'field' : 'name', 'type': 'String'},
                 {'field' : 'address', 'type': 'String'},
                 {'field' : 'LatLong', 'type': 'LatLong'},
                 {'field' : 'type', 'type': 'String'}
                ]
    deduper = dedupe.Dedupe(variables)
    
    path = r'data_prep_scripts/deduper_training_data/training.json'
    with open(path) as training_file:
        deduper.prepare_training(data, training_file=training_file, sample_size=15000, blocked_proportion=0.9)
    deduper.train(index_predicates=False)
    return deduper

def assign_group_ids(data, duplicate_list):
#Maintain group_id counter. Increment for each set of duplicates id'd
    data['group_id'] = ''
    gid = 1
    #Go through duplicate_list
    for duplicate_set in duplicate_list:
        if len(duplicate_set[0]) > 1:
            #Assign corresponding records in dataset the gid
            for record_id in duplicate_set[0]:
                data.loc[data.index == record_id, 'group_id'] = int(gid)
        #Increment gid
        gid+=1
    return data

def id_duplicates(data):
    rd = get_relevant_data(data)
    deduper = initialize_deduper(rd)
    duplicates = deduper.partition(rd, threshold=0.5)
    return(assign_group_ids(data, duplicates))
