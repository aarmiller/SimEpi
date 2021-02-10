
##############################
#### Plotting with ggplot ####
##############################
# This script contains some preliminary examples for using ggplot


#######################
#### Preliminaries ####
#######################

# clear workspace and load necessary packages
rm(list=ls())
library(tidyverse)

## Load some data --------------------------------------------------------------

load("data/nhds/nhds_adult.RData")

# view dataset
nhds_adult

##############################
#### Univariate summaries ####
##############################

## histogram -------------------------------------------------------------------

# a histogram of patient ages
nhds_adult %>% 
  ggplot(aes(x = age_years)) +
  geom_histogram()

# changing the number of bins in the histogram
nhds_adult %>% 
  ggplot(aes(x = age_years)) +
  geom_histogram(bins = 50)

# or changeing the width of bins
nhds_adult %>% 
  ggplot(aes(x = age_years)) +
  geom_histogram(binwidth = 1)

## density plot ----------------------------------------------------------------

# a density plot of age distribution
nhds_adult %>% 
  ggplot(aes(x = age_years)) +
  geom_density()

# frequency plot
nhds_adult %>% 
  ggplot(aes(x = age_years)) +
  geom_freqpoly()


## box plot --------------------------------------------------------------------

nhds_adult %>% 
  ggplot(aes(x = age_years)) +
  geom_boxplot()

# use help file to see what values are used for the bounds
?geom_boxplot

# violin plot - this requires a y variable for the categories
# distribution of ages by sex
nhds_adult %>% 
  ggplot(aes(x= age_years, y = sex)) +
  geom_violin()

# note that this does not work without a y aesthetic
nhds_adult %>% 
  ggplot(aes(x= age_years)) +
  geom_violin()



## bar plot --------------------------------------------------------------------

# bar plot of count of visits by race
nhds_adult %>% 
  ggplot(aes(x = race)) +
  geom_bar()

# custom bar plot by manually computing a count (note: this produces the same
# plot as above)
nhds_adult %>% 
  count(race) %>% 
  ggplot(aes(x= race, y= n)) +
  geom_bar(stat = "identity")


# custom labels using theme with the x-axis text (note: before this was 
# challenging to read)
nhds_adult %>% 
  ggplot(aes(x=race)) +
  geom_bar() +
  theme(axis.text.x = element_text(angle = 45,hjust = 1))

# or you could just flip the axes to make it easier to read
nhds_adult %>% 
  ggplot(aes(x=race)) +
  geom_bar() +
  coord_flip()


###################################
#### adding a second dimension ####
###################################


## Using color -----------------------------------------------------------------

# boxplot of age distribution colored by sex
nhds_adult %>% 
  ggplot(aes(x = age_years, color = sex)) +
  geom_boxplot()

# use "fill" to fill in the boxplot color
nhds_adult %>% 
  ggplot(aes(x = age_years, fill = adm_type)) +
  geom_boxplot()

# bar charts colored by sex
nhds_adult %>% 
  ggplot(aes(x= race, color= sex)) +
  geom_bar()

nhds_adult %>% 
  ggplot(aes(x= race, color= sex, fill = sex)) +
  geom_bar()


## Scatter plot ----------------------------------------------------------------

# scatter plot of number of visits by month
nhds_adult %>% 
  group_by(dc_month) %>% 
  summarise(tot_visits = n()) %>% 
  ggplot(aes(x = dc_month, y =tot_visits)) +
  geom_point()


# add trend - geom_smooth
# the default is a loess model is used
nhds_adult %>% 
  group_by(dc_month) %>% 
  summarise(tot_visits = n()) %>% 
  ggplot(aes(x = dc_month, y =tot_visits)) +
  geom_point() +
  geom_smooth()

# linear trend by specifying method="lm"
nhds_adult %>% 
  group_by(dc_month) %>% 
  summarise(tot_visits = n()) %>% 
  ggplot(aes(x = dc_month, y =tot_visits)) +
  geom_point() +
  geom_smooth(method = "lm")

# we could also create separate points and smooth lines by color or shape
nhds_adult %>% 
  group_by(dc_month,adm_type) %>% 
  summarise(tot_visits = n()) %>% 
  ggplot(aes(x = dc_month, y =tot_visits, color = adm_type)) +
  geom_point() +
  geom_smooth(method = "lm")

nhds_adult %>% 
  group_by(dc_month,adm_type) %>% 
  summarise(tot_visits = n()) %>% 
  ggplot(aes(x = dc_month, y =tot_visits, shape = adm_type)) +
  geom_point() +
  geom_smooth(method = "lm")


## Line plot -------------------------------------------------------------------

# a line plot of total visits by month
nhds_adult %>% 
  group_by(dc_month) %>% 
  summarise(tot_visits = n()) %>% 
  ggplot(aes(x = dc_month, y =tot_visits)) +
  geom_line() 


# multiple lines - visits by month for each sex
nhds_adult %>% 
  group_by(dc_month, sex) %>% 
  mutate(sex = ifelse(sex=="male",1L,2L)) %>% 
  summarise(tot_visits = n()) %>% 
  ggplot(aes(x = dc_month, y =tot_visits, color = as.factor(sex))) +
  geom_line() 


## facets ----------------------------------------------------------------------

# facets can be used to generate separate plots
# ~race tells it to create separate plots for each race
nhds_adult %>% 
  group_by(dc_month, race) %>% 
  summarise(tot_visits = n()) %>% 
  ggplot(aes(x = dc_month, y =tot_visits)) +
  geom_line() +
  facet_wrap(~race)

# use scales = "free_y" to allow the y-axis scale to vary freely across plots
nhds_adult %>% 
  group_by(dc_month, race) %>% 
  summarise(tot_visits = n()) %>% 
  ggplot(aes(x = dc_month, y =tot_visits)) +
  geom_line() +
  facet_wrap(~race, scales = "free_y")



##################
#### Editing #####
##################

## Titles / labels -------------------------------------------------------------

# first store the plot as an object
p <- nhds_adult %>% 
  group_by(dc_month, race) %>% 
  summarise(tot_visits = n()) %>% 
  ggplot(aes(x = dc_month, y =tot_visits)) +
  geom_line() +
  facet_wrap(~race, scales = "free_y")

# ggtitle
# add a title to our last plot with ggtitle
p <- p + ggtitle("Trend in Total Visits by Month and Race")
p

# ylab - Add y-axis label
p <- p + ylab("Total Visits")
p

# xlab - Add x-axis label
p <- p + xlab("Discharge Month")
p

## Changing sizes --------------------------------------------------------------
p + theme(axis.title = element_text(size = 14, face = "bold", color = "blue"),
          title = element_text(size = 16, face = "bold", color = "red"))

## Themes ----------------------------------------------------------------------
p + theme_minimal()
p + theme_bw()

##################
### Exporting ####
##################

pdf(file = "R/my_scripts/test_plot.pdf")
p
dev.off()

# or change the size
pdf(file = "R/my_scripts/test_plot.pdf", width = 10, height = 8)
p
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



