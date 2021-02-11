
# clear workspace and load necessary packages
rm(list=ls())
library(tidyverse)

########################
#### Data Reshaping ####
########################

# This script introduces functions for data reshaping


## Load some data --------------------------------------------------------------

load("data/nhds/nhds_adult.RData")


#####################################
#### pivoting from long to wide #####
#####################################

# Start by subsetting to diagnosis codes

dx_codes <- nhds_adult %>% 
  mutate(id=row_number()) %>% 
  select(id,dx01:dx15)  



# often we want to store things in long rather than wide format
nhds_long <- dx_codes %>% 
  pivot_longer(dx01:dx15,
               names_to = "dx",
               values_to = "icd")

# notice the NA's are still included
nhds_long %>% 
  filter(is.na(icd))

nhds_long2 <- dx_codes %>% 
  pivot_longer(dx01:dx15,
               names_to = "dx",
               values_to = "icd",
               values_drop_na = TRUE)


## Why is this useful?
# size
object.size(nhds_long)
object.size(nhds_long2)

# easier to filter
nhds_long %>% 
  filter(icd=="00845") %>% 
  count(dx)

###################################
### Pivoting from long to wide ####
###################################

# use the function pivot_wider()
nhds_long  %>% 
  pivot_wider(names_from = dx,
              values_from = icd)

# also works when missing values are absent
nhds_long2  %>% 
  pivot_wider(names_from = dx,
              values_from = icd)




####################################
#### Pivoting data for plotting ####
####################################

# load in the injury counts data
injuries <- read_csv("R/SimEpi/example_data/injury_counts.csv")

# look at data structure
injuries

## Now suppose we want to plot the trends across months for each injury type

# we could do this manually using an aesthetic in multiple geom_line() layers
# note this would take a long time to include everything
injuries %>% 
  ggplot(aes(x=dc_month)) +
  geom_line(aes(y=dislocations)) +
  geom_line(aes(y=hip_fracture), color ="red") +
  geom_line(aes(y=spinal_injury), color ="blue")

# a better way is to reshape the data
injuries_long <- injuries %>% 
  pivot_longer(cols = dislocations:burns, 
               names_to = "injury",
               values_to = "count")
  
injuries_long

# then plot using the long data
injuries_long %>% 
  ggplot(aes(x=dc_month,y=count,color =injury)) +
  geom_line()



##################################
#### Old Reshaping Functions #####
##################################


## Gather ----------------------------------------------------------------------

# using gather, specify key name (name of category) and value name (name of corresponding
# value) to create
dx_codes %>% 
  gather(key = "dx", value = "icd_code", -id)

dx_codes %>% 
  gather(key = "dx", value = "icd_code", -id, na.rm = TRUE)

## Spread ----------------------------------------------------------------------
nhds_long %>% 
  spread(key = dx, value = icd)

