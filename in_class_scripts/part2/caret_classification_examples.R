
# Note: This script provides examples for how to build predictive models for a 
# classification problem (predicting hospital mortality) using some of the 
# methods we have discussed in class

rm(list = ls())

library(tidyverse)
library(caret)
library(pROC)

#############################
#### Data Pre Processing ####
#############################


# Start by loading the NHDS adult dataset and processing it a bit (Note: these
# are the same steps as in the cross evaluation slides)
load("R/SimEpi/example_data/nhds_adult.RData")

# add visit ID (or row number) and change variable name for los and age
nhds_adult <- nhds_adult %>% 
  mutate(id = row_number()) %>% 
  select(id,everything()) %>% 
  rename(los = care_days, age=age_years)

# Classification (categorical/binary outcome) - predict hospital mortality
class_data <- nhds_adult %>% 
  mutate(died = as.factor(ifelse(dc_status=="dead","yes","no"))) %>% 
  select(died, age, sex, region)


## Setup Evaluation Criteria ---------------------------------------------------
eval_ctrl <- trainControl(method = "repeatedcv",    # select evaluation method
                          number = 5,               # number of folds
                          repeats = 1,              # number of repetitions
                          savePredictions = TRUE,   # store predictions in output
                          summaryFunction = twoClassSummary,  # denotes a binary problem
                          classProbs = TRUE)        # store and return class probability values


## Preprocess so we have a smaller and balanced set ----------------------------

# Notice that outcome is very unbalanced, also there are a lot of observations 
# so many of our methods will be very slow
class_data %>% 
  count(died)

# select all yes cases
tmp1 <- filter(class_data, died=="yes")

# randomly select a corresponding number of no cases
tmp2 <- filter(class_data, died=="no") %>% 
  sample_n(nrow(tmp1))

# bind these together to create a new smaller and balanced dataset
class_data_balanced <- bind_rows(tmp1,tmp2)

# confirm that the set is balanced in terms of the outcome
class_data_balanced %>% count(died)

# remove temporary objects
rm(tmp1,tmp2)

#############################
#### Logistic Regression ####
#############################

# here we fit a logistic regression model (Note: make sure to set and use the 
# same seed value for all models so that the same folds in the data are used)

set.seed(5678)
model_logit <- train(died ~ .,                        # specify your model
                     data = class_data_balanced,      # data to use
                     method = "glm",                  # specify method to use
                     metric = "ROC",                  # for models with a tuning parameter use ROC/AUC to tune
                     #preProc = c("center", "scale"),  # pre process data (usually normalize -center/scale)
                     #tuneGrid = data.frame(.k=15),    # tuning grid if there is a tuning parameter
                     #tuneLength = 20,                 # length of tuning grid
                     trControl = eval_ctrl)            # the training control to use

# view CV predictions
model_logit$pred %>% as_tibble()

# plot ROC curve
plot(roc(model_logit$pred$obs,model_logit$pred$yes))


#############
#### KNN ####
#############

## In this example we train a KNN model to the data
set.seed(5678)
model_knn <- train(died ~ .,                          # specify your model
                   data = class_data_balanced,                  # data to use
                   method = "knn",                    # specify method to use
                   metric = "ROC",                  # for models with a tuning parameter use ROC/AUC to tune
                   preProc = c("center", "scale"),  # pre process data (usually normalize -center/scale)
                   #tuneGrid = data.frame(.k=15),    # tuning grid if there is a tuning parameter
                   tuneLength = 30,                  # length of tuning grid (number of values of tuning parameter to evaluate)
                   trControl = eval_ctrl)            # the training control to use

# view model output
model_knn

# extract the optimal k
model_knn$bestTune

# add KNN ROC curve to the plot
plot(roc(model_knn$pred$obs,model_knn$pred$yes), add = TRUE, col = "red")



## Run model for a single k ----------------------------------------------------

# if you want to run a KNN model for a specific value of k, or set of specific,
# values, you can specify this value using the tuneGrid option. Here we evaluate
# the values for k of 65 and 95

train(died ~ .,                            # specify your model
      data = class_data_balanced,          # data to use
      method = "knn",                      # specify method to use
      metric = "ROC",
      preProc = c("center", "scale"),      # pre process data (usually normalize -center/scale)
      tuneGrid = data.frame(.k=c(65,90)),  # tuning grid if there is a tuning parameter
      #tuneLength = 30,
      trControl = eval_ctrl)               # the training control to use

##############
#### CART ####
##############


## Train CART (or recursive partitioning) model --------------------------------

set.seed(5678)
model_rpart <- train(died ~ .,                          # specify your model
                     data = class_data_balanced,        # data to use
                     method = "rpart",                  # specify method to use
                     metric = "ROC",                    # for models with a tuning parameter use ROC/AUC to tune
                     #preProc = c("center", "scale"),   # pre process data (usually normalize -center/scale)
                     #tuneGrid = data.frame(.cp=.0025), # tuning grid if there is a tuning parameter
                     tuneLength = 10,                   # length of tuning grid (number of values of tuning parameter to evaluate)
                     trControl = eval_ctrl)             # the training control to use

# view final model
model_rpart

# text summary of tree
summary(model_rpart$finalModel)

## Train a CART model for a specific cost complexity parameter -----------------

# here we force a specific cost complexity parameter using the tuneGrid option
# Note: this allows us to create a smaller classification tree by placing a greater
# cost on the size of the tree
set.seed(5678)
model_rpart2 <- train(died ~ .,                          # specify your model
                     data = class_data_balanced,        # data to use
                     method = "rpart",                  # specify method to use
                     metric = "ROC",                    # for models with a tuning parameter use ROC/AUC to tune
                     #preProc = c("center", "scale"),   # pre process data (usually normalize -center/scale)
                     tuneGrid = data.frame(.cp=.0025), # tuning grid if there is a tuning parameter
                     #tuneLength = 10,                   # length of tuning grid (number of values of tuning parameter to evaluate)
                     trControl = eval_ctrl)             # the training control to use


## Visualize Tree --------------------------------------------------------------

# Here we plot the smaller tree "model_rpart2"

# plot tree using base plotting commands
plot(model_rpart2$finalModel, uniform=TRUE,
     main="Classification Tree")
text(model_rpart2$finalModel, use.n.=TRUE, all=TRUE, cex=.8)

# using rpart.plot to create a more appealing visual display
# install.packages("rpart.plot")  # uncomment the prior code to install
library("rpart.plot")
rpart.plot(model_rpart2$finalModel)


# Plot ROC curves - Here we need to go back and construct the original curves
plot(roc(model_logit$pred$obs,model_logit$pred$yes))
plot(roc(model_knn$pred$obs,model_knn$pred$yes), add = TRUE, col = "red")
plot(roc(model_rpart$pred$obs,model_rpart$pred$yes), add = TRUE, col = "green")


#######################
#### Random Forest ####
#######################

## Train a random forest model -------------------------------------------------

set.seed(5678)
model_rf <- train(died ~ .,                            # specify your model
                     data = class_data_balanced,       # data to use
                     method = "rf",                    # specify method to use
                     metric = "ROC",                   # for models with a tuning parameter use ROC/AUC to tune
                     #preProc = c("center", "scale"),  # pre process data (usually normalize -center/scale)
                     #tuneGrid = data.frame(.mtry=2),  # tuning grid if there is a tuning parameter
                     tuneLength = 4,                   # length of tuning grid (number of values of tuning parameter to evaluate)
                     trControl = eval_ctrl)            # the training control to use

# view model results
model_rf

# add rf model to the ROC curve
plot(roc(model_rf$pred$obs,model_rf$pred$yes), add = TRUE, col = "blue")


## changing the number of trees ------------------------------------------------

# here we fit RF model using only 2 trees instead of the default 500 trees

set.seed(5678)
model_rf2 <- train(died ~ .,                          # specify your model
                  data = class_data_balanced,                  # data to use
                  method = "rf",                    # specify method to use
                  metric = "ROC",                   # for models with a tuning parameter use ROC/AUC to tune
                  #preProc = c("center", "scale"),  # pre process data (usually normalize -center/scale)
                  #tuneGrid = data.frame(.mtry=2),    # tuning grid if there is a tuning parameter
                  tuneLength = 4,
                  ntree = 2,
                  trControl = eval_ctrl)            # the training control to use


# compare the two RF models - notice the model with fewer trees performs worse
plot(roc(model_rf$pred$obs,model_rf$pred$yes))
plot(roc(model_rf2$pred$obs,model_rf2$pred$yes), add = TRUE, col = "blue")


####################################
#### Running Models in Parallel ####
####################################

# Note: after using doParallel you may need to restart R to return to non-parallel 
# operation using Caret
library(doParallel)
cl <- makePSOCKcluster(5)
registerDoParallel(cl)

set.seed(5678)
model_knn <- train(died ~ .,                          # specify your model
                   data = class_data_balanced,        # data to use
                   method = "knn",                    # specify method to use
                   metric = "ROC",                    # for models with a tuning parameter use ROC/AUC to tune
                   preProc = c("center", "scale"),  # pre process data (usually normalize -center/scale)
                   #tuneGrid = data.frame(.k=15),    # tuning grid if there is a tuning parameter
                   tuneLength = 30,
                   trControl = eval_ctrl)            # the training control to use

model_knn

# shut down and remove cluster
stopCluster(cl)
rm(cl)

# Note: even after stopping the cluster you might run into problems with re-runing
# the training command. If this occurs just restart your R session
