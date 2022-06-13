import pandas as pd
from data_prep_scripts import auto_sanity_check_function

good_data = pd.DataFrame([
        {"A": "A1", "B": "B1", "F1": 1, "F2": 0},
        {"A": "A2", "B": "B2", "F1": 0, "F2": 1},
        {"A": "A1", "B": "B1", "F1": "NA", "F2": "NA"}
    ])

bad_data = pd.DataFrame([
        {"A": "A1", "B": "B1", "F1": 1, "F2": 0},
        {"A": "A1", "B": "B1", "F1": 1, "F2": 1},
        {"A": "A1", "B": "B1", "F1": "NA", "F2": "NA"}
    ])

flag_columns = ["F1", "F2"]

categories = {}
categories["A"] = ["A1", "A2"]
categories["B"] = ["B1", "B2"]

def test_check_has_all_categorical_values_success():
    assert auto_sanity_check_function.check_has_all_categorical_values(good_data, "A", categories["A"]) is True

def test_check_has_all_categorical_values_failure():
    assert auto_sanity_check_function.check_has_all_categorical_values(bad_data, "A", categories["A"]) is False

def test_check_flag_columns_have_0s_and_1s_success():
    assert auto_sanity_check_function.check_flag_columns_have_0s_and_1s(good_data, flag_columns) is True

def test_check_flag_columns_have_0s_and_1s_failure():
    assert auto_sanity_check_function.check_flag_columns_have_0s_and_1s(bad_data, flag_columns) is False

def test_sanity_check_success():
    assert auto_sanity_check_function.sanity_check(good_data, flag_columns, categories) is True

def test_sanity_check_failure():
    assert auto_sanity_check_function.sanity_check(bad_data, flag_columns, categories) is False
