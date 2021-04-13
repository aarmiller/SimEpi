
rm(list=ls())

library(tidyverse)
library(modelr)
library(broom)
library(tidyr)

############################
#### Data Preprocessing ####
############################

## Data Pre-processing ---------------------------------------------------------

# Start by loading the NHDS adult dataset and processing it a bit

load("R/SimEpi/example_data/nhds_adult.RData")

# add visit ID (or row number)
nhds_adult <- nhds_adult %>% 
  mutate(id = row_number()) %>% 
  select(id,everything()) %>% 
  rename(los = care_days, age=age_years)

nhds_adult

## Select outcome and predictor variables --------------------------------------

# Regression (numerical outcome) - predict LOS
reg_data <- nhds_adult %>% 
  select(los, age, sex, race, region)

# Classification (categorical/binary outcome) - predict hospital mortality
class_data <- nhds_adult %>% 
  mutate(died = dc_status=="dead") %>% 
  select(died, age, sex, race, region,adm_type)


## Build some example models on entire data ------------------------------------

# NOTE: This is not a predictive modeling step...this is to provide an example 
#       of the methods we might use in these problems

# REGRESSION PROBLEM
# fit linear model with the terms selected
reg_fit <- lm(los ~ ., data = reg_data)
reg_fit

# adding predictions and residuals to the data
reg_pred <- reg_data %>% 
  mutate(pred = predict(reg_fit,newdata = reg_data),
         resid = los - pred)

# another approach using broom package
broom::augment(reg_fit,reg_data)

# compute performance metrics (note: here these are on the training data)
reg_pred %>% 
  summarise(mse = mean(resid^2),
            rmse = sqrt(mean(resid^2)),
            mae = mean(abs(resid)),
            mape = mean(abs(resid/los)))

# CLASSIFICATION PROBLEM

# fit logistic regression model
class_fit <- glm(died ~ ., data = class_data, family = "binomial")

class_fit

# predict outcome
predict(class_fit,type = "link")
predict(class_fit,type = "response")

# add predictions to the dataset
class_pred <- class_data %>% 
  mutate(pred_link = predict(class_fit,type = "link"),
         pred_resp = predict(class_fit,type = "response"))

# notice what is being calculated
class_pred %>% 
  #mutate(pred2 = 1/(1+exp(-pred_link))) %>% 
  mutate(pred_died = pred_resp>0.5) %>% 
  count(pred_died)

# plot ROC curve
library(pROC) # the pROC package makes this easier

roc(pred_class$died,pred_class$pred_resp) # return AUC value

plot.roc(pred_class$died,pred_class$pred_resp) # plot ROC curve


###################################################
#### Resampling using core tidyverse functions ####
###################################################

## Simple test and training partitions -----------------------------------------

# First using sample_frac and joins (this requires some type of row ID)
tmp <- reg_data %>% 
  mutate(id=row_number())

# Test (1/3) and Train (2/3)
set.seed(123)
test <- sample_frac(tmp,size = 1/3) 
train <- anti_join(tmp,select(test,id))

# Second, sampling row numbers 
set.seed(123)
test_ids <- sample(nrow(reg_data),size = nrow(reg_data)/3)

test <- reg_data[test_ids,]
train <- reg_data[-test_ids,]

## Fit Models
reg_fit <- lm(los ~ ., data = train)
reg_fit 

## Evaluate Models:

# Performance on test data
augment(reg_fit,newdata = test) %>% 
  summarise(rmse = sqrt(mean(.resid^2)))

# "Fit" on training data
augment(reg_fit,newdata = train) %>% 
  summarise(rmse = sqrt(mean(.resid^2)))



## Bootstrap Crossvalidation ---------------------------------------------------

# create the bootstrapping index
boot_index <- sample(nrow(reg_data),replace = TRUE)

# boot training set
train <- reg_data[boot_index,]

# boot test test set
test <- reg_data[boot_index,]

reg_fit <- lm(los ~ ., data = train)

augment(reg_fit, newdata = test) %>% 
  summarise(mse = mean(.resid^2),
            rmse = sqrt(mse))

# we typically repeat bootstrap CV. To do this we can use a function.

boot_predictions <- function(){
  boot_index <- sample(nrow(reg_data),replace = TRUE)
  
  # boot training set
  train <- reg_data[boot_index,]
  
  # boot test test set
  test <- reg_data[boot_index,]
  
  reg_fit <- lm(los ~ ., data = train)
  
  augment(reg_fit, newdata = test) %>% 
    summarise(mse = mean(.resid^2),
              rmse = sqrt(mse))
}

boot_predictions()

# now run multiple repititions
tibble(rep = 1:10) %>% 
  mutate(res = map(rep,~boot_predictions())) %>% 
  unnest(res)

## K-fold cross_validation -----------------------------------------------------

# Create folds
k <- 5
fold_index <- sample(rep(1:5, length = nrow(reg_data)))

# see which rows belong to a particulat index
which(fold_index==1)

# test set for fold 1
reg_data[which(fold_index==1),]

# train set for fold 1
reg_data[which(fold_index!=1),]
reg_data[-which(fold_index==1),]

# create folds
folds <- tibble(fold = 1:k) %>% 
  mutate(index = map(fold,~which(fold_index==.))) %>% 
  mutate(test = map(index,~reg_data[.,])) %>% 
  mutate(train = map(index,~reg_data[-.,]))

# train model
folds <- folds %>% 
  mutate(fit = map(train, ~lm(los~. , data = .))) 

folds$fit[[1]]

# add predictions
folds <- folds %>% 
  mutate(test = map2(fit,test,~augment(.x,newdata = .y)))

# look at test results
folds$test[[1]]

# add performance metric
folds


###########################################
#### Resampling using resample objects ####
###########################################

## resample objects

tmp <- resample_partition(reg_data,
                          p = c(test = 0.2,train = 0.8))

# look at what this creates
tmp

# can convert index values to useful data objects
tmp$train

as.integer(tmp$train)
as.data.frame(tmp$train)

# some functions will recognize this as a dataset
lm(los ~ ., tmp$train)   

# simple two sample evaluation all together
tmp <- resample_partition(reg_data,
                          p = c(test = 0.2,train = 0.8))

reg_fit <- lm(los ~ ., tmp$train)

augment(reg_fit, new_data = tmp$test) %>% 
  summarise(rmse = sqrt(mean(.resid^2)))

## k-fold CV -------------------------------------------------------------------

set.seed(123)
folds <- crossv_kfold(reg_data, k=5)

folds

# look at what the resample partions contain
folds$train[[1]]
folds$test[[1]]

# add model 
folds <- folds %>% 
  mutate(model = map(train, ~lm(los ~ ., data = .)))

folds

# add predictions and summarize RMSE
folds %>% 
  mutate(test_predictions = map2(model, test, ~augment(.x, newdata = .y))) %>% 
  select(.id,test_predictions) %>% 
  unnest(test_predictions) %>% 
  group_by(.id) %>% 
  summarise(rmse = sqrt(mean(.resid^2)))

# add in nested object
folds %>% 
  mutate(test_predictions = map2(model, test, ~augment(.x, newdata = .y))) %>% 
  mutate(test_rmse = map(test_predictions, ~summarise(., rmse = sqrt(mean(.resid^2))))) %>% 
  unnest(test_rmse)

# add in both test and train RMSE nested object
folds %>% 
  mutate(test_predictions = map2(model, test, ~augment(.x, newdata = .y))) %>% 
  mutate(train_predictions = map2(model, train, ~augment(.x, newdata = .y))) %>% 
  mutate(test_rmse = map(test_predictions, ~summarise(., test_rmse = sqrt(mean(.resid^2))))) %>% 
  mutate(train_rmse = map(train_predictions, ~summarise(., train_rmse = sqrt(mean(.resid^2))))) %>% 
  unnest(c(test_rmse,train_rmse))

# Note this gets unwieldy fast...but you can do this all together
crossv_kfold(reg_data, k=5) %>% 
  mutate(model = map(train, ~lm(los ~ ., data = .))) %>% 
  mutate(test_predictions = map2(model, test, ~augment(.x, newdata = .y))) %>% 
  mutate(train_predictions = map2(model, train, ~augment(.x, newdata = .y))) %>% 
  mutate(test_rmse = map(test_predictions, ~summarise(., test_rmse = sqrt(mean(.resid^2))))) %>% 
  mutate(train_rmse = map(train_predictions, ~summarise(., train_rmse = sqrt(mean(.resid^2))))) %>% 
  unnest(c(test_rmse,train_rmse))

## Other CV approaches ---------------------------------------------------------

## Monte carlo CV repeated 10 times with 20% of sample used as test set
crossv_mc(reg_data, n = 10, test = 0.2)

## Bootstrapping
modelr::bootstrap(reg_data, n = 10)

tmp <- modelr::bootstrap(reg_data, n = 10)

# pull out test and train data
reg_data[as.integer(tmp$strap[[1]]),]
reg_data[-as.integer(tmp$strap[[1]]),]


## Leave One Out CV (note here we are demonstrating with the mtcars dataset for
# speed, since our dataset is so large)
crossv_loo(mtcars)


#############################
#### Using Caret Package ####
#############################

library(caret)

## Setup Evaluation Criteria ---------------------------------------------------

eval_ctrl <- trainControl(method = "repeatedcv",    # select evaluation method
                          number = 5,               # number of folds
                          repeats = 10,             # number of repetitions
                          savePredictions = TRUE)   # store predictions in output

set.seed(5678)
model_lm <- train(los ~ .,                          # specify your model
                  data = reg_data,                  # data to use
                  method = "lm",                    # specify method to use
                  #preProc = c("center", "scale"),  # pre process data (usually normalize -center/scale)
                  #tuneGrid = data.frame(.k=15),    # tuning grid if there is a tuning parameter
                  trControl = eval_ctrl)            # the training control to use


## Model Output ----------------------------------------------------------------

model_lm

model_lm$results

# results across folds & repetitions
model_lm$resample

model_lm$pred

# RMSE across all predictions in all holdout folds
RMSE(pred = model_lm$pred$pred,
     obs = model_lm$pred$obs)

# manually compute for each fold
model_lm$pred %>% 
  as_data_frame() %>% 
  group_by(Resample) %>% 
  summarise(rmse = RMSE(pred,obs))

# for the in sample fits

summary(model_lm$finalModel)



