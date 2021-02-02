
library(tidyverse)

########################
#### Importing Data ####
######################## 

# Load and .RData or .Rda files -  which may contain multiple R objects

load("data/nhds/nhds_same_day.RData")

# Load in an .RDS file

tmp <- read_rds("data/nhds/nhds_same_day.RDS")
tmp

# Read data from CSV

tmp <- read_csv("data/nhds/nhds_same_day.csv")

# Read from SAS dataset

tmp <- haven::read_sas("data/nhds/nhds_same_day.sas7bdat")

# Read from Stata dataset

tmp <- haven::read_dta("data/nhds/nhds_same_day.dta")

#########################
#### Exporting Data #####
#########################

# To save and RData or .rda file - may contain multiple R objects
save(nhds,var_labels,file = "<path>/<name>.RData")

# To save all the objects in a workspace
save.image("<path>/<name>.RData")

# To csv 
write_csv(nhds,path = "<path>/<name>.csv")

# To .rds
write_rds(nhds,"<path>/<name>.RDS")

