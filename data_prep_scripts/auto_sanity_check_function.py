import pandas as pd
import numpy as np

def check_has_all_categorical_values(data, column_name, category_array):
    """
    This is for columns that contain a limited set of categories, such as source_file and source_orgs
    :param data: The dataframe to be examined
    :param column_name: Name of the column in the dataset to be examined
    :param category_array: The valid values in the column.
    :return: True if all valid values exist in dataset, False otherwise.
    """
    unique_vals_in_column = data[column_name].unique()
    for val in category_array:
        if val not in unique_vals_in_column:
            print(column_name + " does not contain value " + val)
            return False
    return True

def check_flag_columns_have_0s_and_1s(data, flag_columns):
    """
    Returns True if all flag columns contain both 0s and 1s. False if they contain only one or neither.
    :param data:
    :param flag_columns: Array of flag columns that will be examined to confirm is they contain 0s and 1s
    :return: True if all flag columns contain 0s and 1s, false otherwise.
    """
    for flag_column in flag_columns:
        if 0 not in data[flag_column].unique() or 1 not in data[flag_column].unique():
            print(flag_column + " does not contain both 0s and 1s")
            return False
    return True



def sanity_check(data, flag_columns, categories):
    """
    Runs all given sanity check functions
    :param data: The dataframe to run the sanity checks on
    :param flag_columns: Flag columns to check for in check_flag_columns_have_0s_and_1s
    :param categories: A dictionary of categories and the expected values in each category
    :return:
    """
    #If not all flag columns have 0s and 1s, sanity check fails
    if not check_flag_columns_have_0s_and_1s(data, flag_columns):
        return False
    #If not all category values exist in the data, sanity check fails
    #Iterate through each category and check the data contains all values for that category
    for category in categories:
        if not check_has_all_categorical_values(data, category, categories[category]):
            return False
    return True
