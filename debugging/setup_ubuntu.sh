#This script is meant to assist with setting up an ubuntu system closely approximating the Github VM.


#===INSTALL R ON UBUNTU===#

#Install dependencies necessary to add new repository over HTTPS
sudo apt install dirmngr gnupg apt-transport-https ca-certificates software-properties-common

#Add the CRAN repository to your system sources’ list:
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'

#Install R
sudo apt install r-base

#Install requisite R packages
sudo Rscript -e 'install.packages(c("dplyr", "readr", "remotes","purrr", "stringr", "httr", "jsonlite", "janitor", "tidyr", "readxl", "googlesheets4"), Ncpus = 2, repos = "https://demo.rstudiopm.com/cran/__linux__/centos7/latest", dependencies = TRUE)'



#===INSTALL PYTHON ON UBUNTU===#

#Update and refresh repository list
sudo apt update

#Update software  repository
sudo apt install software-properties-common

#Add Deadsnakes PPA
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update

#Install Python 3.6
sudo apt install python3.6

#Update/Upgrade Pip and install requirements
python3 -m pip install --upgrade pip
pip install -r requirements.txt


#===INSTALL ENCHANT C LIBRARY ON UBUNTU===#

#Update and refresh repository list
sudo apt-get update -y

#Install Enchant
sudo apt-get install -y enchant