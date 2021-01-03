# Running Tests

(Note that this is going to start off as a very basic how-to for setting up tests initially, and can easily have more added to it. If anyone runs into issues with these instructions (and I think it's highly likely there might be), please let me know - Max)

0. Make sure you have Python installed to your computer and properly accessible from the command line.
1. If pipenv is not yet installed, run "pip install pipenv"
2. Download latest version from Github
3. Navigate to downloaded directory in file explorer
4. Open "Git BASH", "Powershell", or whatever command line interface you prefer.
5. In the command line, type "git status". You should see a message saying "Your branch is up to date with origin/master"
6. Run "pipenv sync --dev --three". You may need to run "pipenv lock" beforehand.
7. Run "pipenv shell". This will open up a virtual environment complete with the required packages.
8. Run "pytest"
