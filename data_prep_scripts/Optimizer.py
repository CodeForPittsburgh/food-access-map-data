import pandas as pd
from skopt.space import Real, Integer, Categorical
from skopt.utils import use_named_args
from skopt import gbrt_minimize
from fuzzywuzzy import fuzz
import numpy as np
from itertools import combinations

# this is an example (and usable demo) of how to use skopt
# as an optimizer for Hyperparameter tuning
# here we take this fuzzy matching levenstein distance matching
# and some ground "truths" and we test out a bunch of options
# for how the fuzzy matching should actually be set up (trying to choose the best options)

# mattsandler 2021
# mishugana@gmail.com

def specialFuzz(x, y, skew=.5, cutoff=75, ratioType="full", tokenType="tpsort"):
# this one takes params for optomization
    skewOne = skew
    skewTwo = 1.0 - skewOne
    if ratioType=="full":
        ratioOne = fuzz.ratio(x, y)
    else:
        ratioOne = fuzz.partial_ratio(x, y)
    if tokenType=="tpsort":
        ratioTwo = fuzz.partial_token_sort_ratio(x, y)
    elif tokenType=="tsort":
        ratioTwo = fuzz.token_sort_ratio(x, y)
    else: 
        ratioTwo = fuzz.token_set_ratio(x, y)
    return ((skewOne * ratioOne) + (skewTwo * ratioTwo)) > cutoff

# if going this route, this really should be weighted equally (what does that mean?)
def fromTests():
    tests = [["St. Catherine of Siena Food Pantry","St. Catherine of Siena Fresh Market"],
    ["Windber Area Community Kitchen", "Windber Area Community Kitchen - Wackpack Program"],
    ["Green Grocer at East Hills Community Center", "Green Grocer/East Hills Community Center"],
    ["Giant Eagle 78", "Giant Eagle"]]

    answers = [False, False, True, True]
    return (tests, answers)

# copy pasted from google docs with:
# (.*)\t(.*)  to  ["$1", "$2", "$3", "$4"],
# random sampling might ensure good weighting

# btw, i flagged these with a complete dataset, so they are not perfect for testing lev distance, but is an example

def fromGoogleDoc():
    testDf = pd.DataFrame([["0", "", "A", "Shop 'n Save"],
    ["0", "", "B", "YMCA New Kensington"],
    ["1", "1", "A", "Dylamato's Market"],
    ["1", "1", "A", "Dylamato's Market LLC"],
    ["1", "", "B", "Rebos House"],
    ["9", "9", "A", "Las Palmas IGA"],
    ["9", "9", "A", "Las Palmas Iga 2"],
    ["9", "", "B", "Beechview Fresh Access"],
    ["9", "", "C", "Beechview United Presbyterian"],
    ["10", "10", "A", "Bellevue Farmer's Market"],
    ["10", "10", "A", "Bellevue Farmers Market"],
    ["10", "10", "A", "Belllevue Farmers Market"],
    ["13", "13", "A", "Bloomfield Saturday Market"],
    ["13", "13", "A", "Bloomfield Saturday Market"],
    ["13", "", "A", "Bloomfield Farmer's Market"],
    ["14", "", "A", "Braddock Farm Stand"],
    ["14", "", "B", "Family Dollar 6347"],
    ["14", "", "A", "Grow Pittsburgh Farm Stands"],
    ["14", "", "C", "BELL'S MARKET"],
    ["16", "16", "A", "Carrick Farmer's Market"],
    ["16", "16", "A", "Carrick Farmers Market"],
    ["16", "16", "B", "Concord El Sch"],
    ["16", "16", "B", "Concord El Sch"],
    ["17", "", "A", "Clairton Green Grocer"],
    ["17", "", "B", "Family Dollar 4774"],
    ["17", "", "A", "Green Grocer at Family Dollar Parking Lot"],
    ["17", "", "C", "Steel Valley LifeSpan"],
    ["18", "", "A", "Coraopolis Farmer's Market"],
    ["18", "", "B", "Coraopolis Community Garden"],
    ["18", "", "C", "RITE AID 1448"],
    ["19", "", "A", "DeCarlo's Market"],
    ["19", "", "B", "ELIZABETH TOWNSHIP GIANT EAGLE"],
    ["24", "", "A", "Duquesne Green Grocer"],
    ["24", "", "A", "Green Grocer - Greater Pittsburgh Comm Food Bank"],
    ["24", "", "B", "Produce to People - Duquesne"],
    ["25", "25", "A", "East Hills Green Grocer"],
    ["25", "25", "A", "Green Grocer at East Hills Community Center"],
    ["25", "", "B", "Second East Hills Apartments"],
    ["25", "", "B", "Yp East Hills"],
    ["29", "", "A", "Etna Farmer's Market"],
    ["29", "", "B", "Etna Express"],
    ["30", "", "A", "Farmer's Co-Op of East Liberty"],
    ["30", "", "B", "J L Kennedy Meat Stand"],
    ["34", "34", "A", "Glassport Green Grocer"],
    ["34", "34", "A", "Green Grocer at Glassport Honor Roll Park"],
    ["34", "", "B", "Glassport Community Outreach Food Pantry"],
    ["35", "", "A", "Green Tree Farmer's Market"],
    ["35", "", "B", "Green Tree Wilson Park"],
    ["38", "", "A", "Homewood Fresh Access"],
    ["38", "", "B", "Homewood Backyard Market"],
    ["38", "", "C", "Homewood House"],
    ["38", "", "D", "Homewood - Brushton Ymca"],
    ["39", "", "A", "Homewood Green Grocer"],
    ["39", "", "B", "BAKER'S DAIRY"],
    ["39", "", "A", "Green Grocer at Alma Illery Medical Center"],
    ["39", "", "D", "Alma Illery Health Center"],
    ["39", "", "E", "Legacy Arts Project"],
    ["45", "45", "A", "Lawrenceville Farmer's Market"],
    ["45", "45", "A", "Lawrenceville Farmers' Market 0549590"],
    ["47", "47", "A", "Market Square Farmer's Market"],
    ["47", "47", "A", "Market Square Farmers Market"],
    ["47", "", "B", "Kidsplay Pgh"]])

    grouped = testDf.groupby(0)
    tests = []
    answers = []
    for name, group in grouped:
        combos = (list(combinations((zip(group[3].values, group[2].values)),2)))
        tests += [[t[0][0],t[1][0]] for t in combos]
        answers += [t[0][1]==t[1][1] for t in combos]
    return (tests,answers)

# Best score=0.0649
# Best parameters:
# - skew=0.371228
# - cutoff=73
def main():
    # you could use "log-uniform", so that it is less likely 
    # to choose values on the extreme ends (i think)
    space  = [Real(.1, .9,  name='skew'),
         Integer(10, 95, name='cutoff'),
         Categorical(["tpsort","tsort","tset"], name="tokenType"),
         Categorical(["full","partial"], name="ratioType")]

    tests, answers = fromTests()
    testsGD, answersGD = fromGoogleDoc()

    tests += testsGD
    answers += answersGD

    @use_named_args(space)
    def objective(**params):
        # passing reference to x and y as 2 length array, and pass reference params as dict 
        guesses = np.array([specialFuzz(*t, **params) for t in tests])
        # here id the scoring metric, lower is better (maybe to be more advanced)
        # this is simply percentage wrong
        return 1 - np.sum(np.array(answers) == guesses) / len(guesses)

    # lots of different minimize functions availble (like gp, or dummy)
    res_gp = gbrt_minimize(objective, space, n_calls=100)

    print("Best score=%.4f" % res_gp.fun)

    print("""Best parameters:
    - skew=%f
    - cutoff=%d
    - ratio type=%s
    - token type=%s
    """ % (res_gp.x[0], res_gp.x[1], res_gp.x[2], res_gp.x[3]))

if __name__ == "__main__":
    main()
