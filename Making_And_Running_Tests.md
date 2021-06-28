__NOTE__: Because this is new functionality in the project, errors, issues, or unclear instructions are not only possible, but expected! Please let us know if you encounter any issues. 

Tests are important for maintaining code -- it's easier to find out if a code change breaks some functionality if a test for that functionality fails immediately after making the change -- and they also serve as a "living documentation" that outlines how the program is expected to run under different circumstances.

Because we have two different languages used in this project, we have two different testing libraries--Pytest, for testing Python scripts, and Testthat, for testing R scripts.

Tests are run automatically when code is checked in, via Github Actions. You can see how the automated tests work by looking in the ".github/workflows" directory. Tests can also be run manually on a local machine--for more information on that, consult the "Running Tests" section of this document. 

# Creating Tests

## Creating Pytest Scripts

1. If you are creating a new testfile, name the file "test_TESTNAME.py" and add to the "tests" folder. If you are adding a test to an existing file, skip this step.
2. Add code in the testfile in the following format:
```python
def test_TESTNAME:
	# Code to run script 
	# Assert statement to confirm functionality tested
```
3. Test new test by following steps in "Running Pytest on Local Machine" section

## Creating Testthat Script

1. Name file "test-TESTNAME.R" and add to the "tests" folder. 
2. Add code in the testfile in the following format:
```R
test_that("Whatever test verifies", {
	# Code to run script
	expect_equal(result, expected_result)
	})
```
3. Test new test by following steps in "Running Testthat on Local Machine" section.

# Running Tests

## Running Pytest on Local Machine

0. Make sure you have python installed on your local machine
1. Open Git Bash, CMD Prompt, or your preferred command line interface in the root of the local food-access-map-data directory (should look something like ".../food-access-map-data/").
2. Run "pip install -r requirements.txt" This should install all required modules from the "requirements.txt" file in the root folder.
4. Run "pytest". This should automatically run all python tests indicated with "test_TESTNAME.py" in all subdirectories, but realistically, such tests should only be located in the "test" subdirectory.

## Running Testthat on Local Machine

0. Make sure you have RStudio installed on your local machine.
1. Open script "run_tests.R" using R studio. You may need to install some packages before tests run successfully.
2. Press Ctrl + Alt + R to run the entire script. This should automatically run all R tests labeled "test-TESTNAME.R" in the "tests" subdirectory.

# Advice when making tests

* Tests generally boil down to two components: What is the input I'm giving it, and what output do I expect for that input? The former is determined by the code given to it, and the latter by the assert statement at the end of the test.
* Test coverage -- how much code is tested by a set of tests -- is important! If a test doesn't cover additional functionality, it probably doesn't need to be made. 
* Try to isolate functionality as best as you can when you test -- if a test runs too much code, it becomes harder to determine the cause if it fails.
* Remember that every test added is a test that may need to be maintained or modified in the future, either because the functionality it is testing changes, or because a bug exists in the test itself. Be judicious when determining what tests to make!
* Generally, we should test for at least two kinds of cases:
  * "Happy path" testing, which tests the code when it receives expected inputs
  * "Edge case" testing, which tests the code when it receives unusual (but still probable) inputs
* For example, if you were testing a program that adds two numbers, possible tests include:
  * Giving it inputs of two positive integers (i.e., the happy path)
  * Giving it inputs of one positive and one negative integer
  * Giving it inputs of really large integers
  * Giving it inputs of strings or letters
* Generally, tests should be developed with emphasis on what you think is most likely to occur first, like the happy path and possible edge cases, and, if you're willing, moving on towards less likely inputs.
