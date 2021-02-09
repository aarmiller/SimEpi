

rm(list=ls())

##############################
#### Plotting with ggplot ####
##############################

## Load some data --------------------------------------------------------------

load("data/nhds/nhds_adult.RData")

nhds_adult



##############################
#### Univariate summaries ####
##############################

## histogram -------------------------------------------------------------------

nhds_adult %>% 
  ggplot(aes()) +
  geom_histogram()

## density plot ----------------------------------------------------------------

nhds_adult %>% 
  ggplot(aes()) +
  geom_density()



# frequency plot
nhds_adult %>% 
  ggplot(aes()) +
  geom_freqpoly()



## box plot --------------------------------------------------------------------

nhds_adult %>% 
  ggplot(aes()) +
  geom_boxplot()



# violin
nhds_adult %>% 
  ggplot(aes(x= ,y = )) +
  geom_violin()



## bar plot --------------------------------------------------------------------

nhds_adult %>% 
  ggplot(aes()) +
  geom_bar()



# custom bar plot
nhds_adult %>% 
  count() %>% 
  ggplot(aes(x= , y= )) +
  geom_bar(stat = "identity")



# custom labels
nhds_adult %>% 
  ggplot(aes(x=)) +
  geom_bar() +
  theme(axis.text.x = element_text())


###################################
#### adding a second dimension ####
###################################


## Using color -----------------------------------------------------------------

# boxplot
nhds_adult %>% 
  ggplot(aes(x = , color = )) +
  geom_boxplot()



# bar chart
nhds_adult %>% 
  ggplot(aes(x= , color= )) +
  geom_bar()



## Scatter plot ----------------------------------------------------------------

nhds_adult %>% 
  group_by() %>% 
  summarise() %>% 
  ggplot(aes(x = , y =)) +
  geom_point()


# add trend - geom_smooth
nhds_adult %>% 
  group_by() %>% 
  summarise() %>% 
  ggplot(aes(x = , y =)) +
  geom_point() +
  geom_smooth()


# linear trend



## Line plot -------------------------------------------------------------------

nhds_adult %>% 
  group_by() %>% 
  summarise() %>% 
  ggplot(aes(x = , y = )) +
  geom_line() 



# multiple lines
nhds_adult %>% 
  mutate(age_group = )
  group_by() %>% 
  summarise() %>% 
  ggplot(aes(x = , y = )) +
  geom_line() 


## facets ----------------------------------------------------------------------

nhds_adult %>% 
  group_by() %>% 
  summarise() %>% 
  ggplot(aes(x = , y = , color = )) +
  geom_line() +
  facet_wrap(~region)



##################
#### Editing #####
##################

## Titles / labels -------------------------------------------------------------

# ggtitle

# ylab

# xlab

## Changing sizes --------------------------------------------------------------


## Themes ----------------------------------------------------------------------


##################
### Exporting ####
##################

pdf()

dev.off()



######################################
#### Problems to work on in group ####
######################################


# 1) Look at LOS by age and sex - make a scatter plot of LOS by age then color 
#    the dots by sex. What trend emerges? Is there a different pattern by age 
#    and sex, why might that be?





# 2) Plot the percent of admissions by age group that are among women compared to 
#    men (e.g., X% of visits among 25 year olds are female). Plot the trend using
#    a scatter plot with age on x axis and % female on y-axis, then add a smooth
#    trend line




# 3) Now plot the number number of admissions by age for each sex. Draw a scatter
#    plot with age on the x-axis and the number of observations on the y-axis. 
#    Then color the dots by sex. Look for outliers.




# 4) Now plot the number number of admissions by age (y-axis) for each sex 
#    (color), just like the previous graph but add separate plots (facets) for 
#    each admission type. What differences do you observe by admission type?




# 5) Now looking at the above plot...see if you can validate your hypothesis (for
#    any observed differences between men and women) in some way by looking at 
#    the primary admission reason (dx_adm) for the group/admission type that 
#    appears unusual.



