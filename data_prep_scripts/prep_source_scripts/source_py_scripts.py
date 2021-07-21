#one main script to exec() all the python scripts in /prep_data_sources
#for https://github.com/CodeForPittsburgh/food-access-map-data/issues/116

#I can use python
#To do the same thing as well
#Haikus are easy
from tqdm import tqdm

files = ["prep_FMNP.py", "prep_Greater_Pittsburgh_Community_Food_Bank.py",
        "prep_Just_Harvest.py", "prep_Pittsburgh_Food_Policy_Council.py", "prep_The_Food_Trust.py",
        "prep_USDA_Food_And_Nutrition.py"]
for filename in tqdm(files):
    with open('data_prep_scripts/prep_source_scripts/' + filename, "rb") as source_file:
        code = compile(source_file.read(), filename, "exec")
    exec(code)

# with open("prep_Greater_Pittsburgh_Community_Food_Bank.py", "rb") as source_file:
#     code = compile(source_file.read(), "prep_Greater_Pittsburgh_Community_Food_Bank.py", "exec")
# exec(code)
#
# with open("prep_Just_Harvest.py", "rb") as source_file:
#     code = compile(source_file.read(), "prep_Just_Harvest.py", "exec")
# exec(code)
#
# with open("prep_Pittsburgh_Food_Policy_Council.py", "rb") as source_file:
#     code = compile(source_file.read(), "prep_Pittsburgh_Food_Policy_Council.py", "exec")
# exec(code)
#
# with open("prep_The_Food_Trust.py", "rb") as source_file:
#     code = compile(source_file.read(), "prep_The_Food_Trust.py", "exec")
# exec(code)
#
# with open("prep_USDA_Food_And_Nutrition.py", "rb") as source_file:
#     code = compile(source_file.read(), "prep_USDA_Food_And_Nutrition.py", "exec")
# exec(code)
