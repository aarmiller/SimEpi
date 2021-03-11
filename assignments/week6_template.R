
############################################################
### Assignment 6 - Simulation In Epidemiology Spring 2021
### Due Date: 2/4/2021
############################################################

### Your Name: 

library(tidyverse)
library(lubridate)


###################
#### Load Data ####
###################

## Load NHDS Dataset  ----------------------------------------------------------



## Subset the data -------------------------------------------------------------



##########################
#### Write Simulation ####
##########################

## Set parameter values --------------------------------------------------------
start_date <- ymd("2019-01-01") # date for the start of the simulation
end_date <- ymd("2019-12-31") # date for the end of the simulation
hospital_size <- 300 # number of beds


##  Draw patients  -------------------------------------------------------------

draw_patients <- function(n){
  
}

## test by drawing initial hospital


## Discharge and Admit Patients ------------------------------------------------

discharge_admit_patients <- function(hospital,date){
  
  # find patients who are discharged
  
  
  # subset hospital to patients who are not discharged
  
  
  # compute the number discharged
  
  
  # draw new admissions and add admdate and disdate
  
  
  # rebuild hospital
  
  # return updated hospital and discharged patients
  return(list())
  
}



## Simulate Hospital -----------------------------------------------------------


discharge_admit_patients <- function(hospital,date){
  
  # find patients who are discharged
  
  
  # subset hospital to patients who are not discharged
  
  
  # compute the number discharged
  
  
  # draw new admissions and add admdate and disdate
  
  
  # rebuild hospital
  
  # return updated hospital and discharged patients
  return(list())
  
}

#########################
#### Run Simulations ####
#########################

## Describe trends in average daily age of patients ----------------------------




## Describe trends in the average daily LOS of patients ------------------------




########################
#### Extra Problems ####
########################

## Specify the type of hospital setting ----------------------------------------




## Draw patients according to the admission/discharge month --------------------




## Pick a non-uniform start date -----------------------------------------------




## Allow hospital over/under capacity ------------------------------------------


