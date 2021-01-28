
library(tidyverse)

# This script is intended to be a quick test of paths on your machine

# make note of your working directory ------------------------------------------
getwd()

# install course packages
source("R/SimEpi/admin/install_packages.R")

## Test path to function directory ---------------------------------------------
# check that you can source functions from the correct directory
source("R/SimEpi/functions/test_functions.R")

test_function()


## Test loading data -----------------------------------------------------------
# Note: First this data needs to be loaded from ICON
load("data/alzheimer_data.RData")

# Note: source for this data
# Salib, E. and Hillier, V. (1997). A case-control study of smoking and 
# Alzheimer's disease. International Journal of Geriatric Psychiatry 12(3), 
# 295–300. doi: 10.1002/(SICI)1099-1166(199703)12:3<295::AID-GPS476>3.0.CO;2-3


