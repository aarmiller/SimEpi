
rm(list = ls())
load("R/SimEpi/example_data/nhds_adult.RData")

nhds_adult %>% count(dx01)

#####################################################
#### Ways to create reduced set of dx indicators ####
#####################################################

# just for top most populated codes
nhds_adult %>% count(dx01) %>% filter(n>100)

# DRG codes
nhds_adult %>% count(DRG) 
nhds_adult %>% count(DRG) %>% filter(n>100)


# first 3 icd digits
nhds_adult %>% 
  mutate(dx01 = str_sub(dx01,1,3)) %>% 
  count(dx01)

# other categories (e.g., CCS codes)
ccs_codes <- read_csv("R/SimEpi/example_data/ccs_dx_codes.csv") %>% 
  select(dx01=icd_9_code,ccs_code)

nhds_adult %>% 
  mutate(dx01 = as.character(dx01)) %>% 
  inner_join(ccs_codes) %>% 
  count(ccs_code)


