
############################################################
### Assignment 1 - Simulation In Epidemiology Spring 2021
### Due Date: 2/9/2021
############################################################

### Your Name: 

library(tidyverse)
library(icd)
library(lubridate)

#############################
#### Load & Process Data ####
#############################

#### Load Data -----------------------------------------------------------------




#### Process Beneficiary Data --------------------------------------------------

# Stack years in beneficiary data:




# Clean and process (e.g., add category labels) beneficiary data:




#### Process Inpatient Data ----------------------------------------------------




######################
#### Analyze Data ####
######################

#### Describe Medicare Population ----------------------------------------------

# Describe Race and Sex Breakdown:




# Compute Percentage of Beneficiaries that are female by state:




# Find states with highest and lowest percentage (do this 2 different ways):




#### Find Inpatient Visits for AMI ---------------------------------------------

# AMI codes (Note: if the icd package does not work, these codes are on ICON)
ami_codes <- children("410")




#### Compute Monthly Incidence of AMI Admissions -------------------------------

# Compute monthly counts of AMI cases




# Go back to beneficiary data and compute mean number of Part A beneficiaries 
# each month:




# Combine to compute monthly incidence of AMI admissions




#### Describe Age and LOS for patients with AMI --------------------------------

# Describe results for patients with Admission for AMI




# Describe the same results for Admissions not for AMI




#### Build a matched case-control study sample ---------------------------------

# Compute the match strata for patients with AMI




# Identify enrollees that did not have AMI (on admission or principal diagnosis)




# Create strata in non-AMI controls and identify strata-specific row number




# Select the final control population




