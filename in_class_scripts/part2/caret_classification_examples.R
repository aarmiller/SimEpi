
rm(list = ls())

library(tidyverse)
library(caret)
library(pROC)

#############################
#### Data Pre Processing ####
#############################


# Start by loading the NHDS adult dataset and processing it a bit

load("R/SimEpi/example_data/nhds_adult.RData")

# add visit ID (or row number)
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

# Notice that outcome is very unbalanced
class_data %>% 
  count(died)

# select all yes cases
tmp1 <- filter(class_data, died=="yes")

tmp2 <- filter(class_data, died=="no") %>% 
  sample_n(nrow(tmp1))

class_data_balanced <- bind_rows(tmp1,tmp2)

class_data_balanced %>% count(died)

rm(tmp1,tmp2)

#############################
#### Logistic Regression ####
#############################

set.seed(5678)
model_logit <- train(died ~ .,                          # specify your model
                     data = class_data_balanced,                  # data to use
                     method = "glm",                    # specify method to use
                     metric = "ROC",
                     preProc = c("center", "scale"),  # pre process data (usually normalize -center/scale)
                     #tuneGrid = data.frame(.k=15),    # tuning grid if there is a tuning parameter
                     #tuneLength = 20,
                     trControl = eval_ctrl)            # the training control to use

# view CV predictions
model_logit$pred %>% as_tibble()

# plot ROC curve
plot(roc(model_logit$pred$obs,model_logit$pred$yes))


#############
#### KNN ####
#############

## Train Model -----------------------------------------------------------------

set.seed(5678)
model_knn <- train(died ~ .,                          # specify your model
                  data = class_data_balanced,                  # data to use
                  method = "knn",                    # specify method to use
                  metric = "ROC",
                  preProc = c("center", "scale"),  # pre process data (usually normalize -center/scale)
                  #tuneGrid = data.frame(.k=15),    # tuning grid if there is a tuning parameter
                  tuneLength = 30,
                  trControl = eval_ctrl)            # the training control to use

model_knn

plot(roc(model_knn$pred$obs,model_knn$pred$yes), add = TRUE, col = "red")



## Run model for a single k ----------------------------------------------------

train(died ~ .,                          # specify your model
      data = class_data_balanced,                  # data to use
      method = "knn",                    # specify method to use
      metric = "ROC",
      preProc = c("center", "scale"),  # pre process data (usually normalize -center/scale)
      tuneGrid = data.frame(.k=65),    # tuning grid if there is a tuning parameter
      #tuneLength = 30,
      trControl = eval_ctrl)            # the training control to use

##############
#### CART ####
##############


## Train Model -----------------------------------------------------------------

set.seed(5678)
model_rpart <- train(died ~ .,                          # specify your model
                     data = class_data_balanced,                  # data to use
                     method = "rpart",                    # specify method to use
                     metric = "ROC",
                     #preProc = c("center", "scale"),  # pre process data (usually normalize -center/scale)
                     #tuneGrid = data.frame(.cp=.025),    # tuning grid if there is a tuning parameter
                     tuneLength = 10,
                     trControl = eval_ctrl)            # the training control to use

model_rpart

# summary of tree
summary(model_rpart$finalModel)

# plot tree
plot(model_rpart$finalModel, uniform=TRUE,
     main="Classification Tree")
text(model_rpart$finalModel, use.n.=TRUE, all=TRUE, cex=.8)

# using rpart.plot
#install.packages("rpart.plot")
library("rpart.plot")
plot(as.party(model_rpart$finalModel))

# Plot ROC curves
plot(roc(model_logit$pred$obs,model_logit$pred$yes))
plot(roc(model_knn$pred$obs,model_knn$pred$yes), add = TRUE, col = "red")
plot(roc(model_rpart$pred$obs,model_rpart$pred$yes), add = TRUE, col = "green")


#######################
#### Random Forest ####
#######################

set.seed(5678)
model_rf <- train(died ~ .,                          # specify your model
                     data = class_data_balanced,                  # data to use
                     method = "rf",                    # specify method to use
                     metric = "ROC",
                     #preProc = c("center", "scale"),  # pre process data (usually normalize -center/scale)
                     #tuneGrid = data.frame(.mtry=2),    # tuning grid if there is a tuning parameter
                     tuneLength = 4,
                     trControl = eval_ctrl)            # the training control to use

plot(roc(model_rf$pred$obs,model_rf$pred$yes), add = TRUE, col = "blue")


# changing the number of trees

set.seed(5678)
model_rf2 <- train(died ~ .,                          # specify your model
                  data = class_data_balanced,                  # data to use
                  method = "rf",                    # specify method to use
                  metric = "ROC",
                  #preProc = c("center", "scale"),  # pre process data (usually normalize -center/scale)
                  #tuneGrid = data.frame(.mtry=2),    # tuning grid if there is a tuning parameter
                  tuneLength = 4,
                  ntree = 5,
                  trControl = eval_ctrl)            # the training control to use


# compare the two RF models
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
                   data = class_data_balanced,                  # data to use
                   method = "knn",                    # specify method to use
                   metric = "ROC",
                   preProc = c("center", "scale"),  # pre process data (usually normalize -center/scale)
                   #tuneGrid = data.frame(.k=15),    # tuning grid if there is a tuning parameter
                   tuneLength = 30,
                   trControl = eval_ctrl)            # the training control to use

model_knn

# shut down and remove cluster
stopCluster(cl)
rm(cl)
