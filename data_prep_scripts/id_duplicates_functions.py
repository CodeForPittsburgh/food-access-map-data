#id_duplicates_functions
import pandas as pd
from scipy.spatial import cKDTree
from scipy.spatial.distance import pdist, squareform
from fuzzywuzzy import fuzz
import numpy as np
from itertools import combinations



def combineDisjointedSets(pairs):
    pairDict = {}
    for pair in pairs:
        if pair[0] not in pairDict:
            pairDict[pair[0]] = {pair[0], pair[1]}
            pairDict[pair[1]] = {pair[0]}
        else:
            pointer = pair[0]
            while (len(pairDict[pointer]) == 1):
                pointer = next(iter(pairDict[pointer]))
            pairDict[pointer].add(pair[1])
            pairDict[pair[1]] = {pointer}
    return {k: x for k, x in pairDict.items() if len(x) > 1}


def specialFuzz(x,y):
    return (fuzz.ratio(x, y) + fuzz.partial_token_sort_ratio(x, y)) / 2


def id_duplicates(data):
	# data = pd.read_csv("../merged_datasets.csv")
	tree = cKDTree(data[['longitude','latitude']].astype(float))
	pairs = tree.query_pairs(.001, p=2)
	newpairs = combineDisjointedSets(pairs)
	data["group"] = ""
	for k,x in newpairs.items():
	    for xx in x:
	        data["group"][xx] = k
	newpairs2 = {}
	groups = [x for x in data["group"].unique() if x != '']
	for group in groups:
	    names = np.array(data[data["group"]==group]["name"].values).reshape(-1,1)
	    ids = np.array(data[data["group"]==group].index).reshape(-1,1)
	    Y = pdist(names, specialFuzz)
	    pairwise = list(combinations(range(len(names)),2))
	    for i,y in enumerate(Y):
	        if y>75:
	            for ii in pairwise[i]:
	                if group in newpairs2:
	                    newpairs2[group].add(ids[ii][0])
	                else:
	                    newpairs2[group] = set(ids[ii])

	data["group_id"] = ""
	for k,x in newpairs2.items():
	    for xx in x:
	        data["group_id"][xx] = k
	return data