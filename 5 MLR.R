install.packages("pacman")
pacman::p_load(tidyverse, caret, corrplot,knitr,car,caTools, ROCR,IRdisplay, e1071, earth,ROSE,caret,magrittr)

# import data
data =  read.csv("train1020.csv")
data_test = read.csv("test1020.csv")
str(data)
summary(data)

#Check independent variable distribution
hist(data$subscribers)
hist(data$log_subscribers)

# Build initial model
model_1=lm(log_subscribers ~ ranking+category+level+hours_to_complete+num_subtitles, data = data)
summary(model_1)
# Check multi-collinearity
vif(model_1)
# Residual Analysis
plot(model_1)

# Grouping category and level
data$category_reclassified=data$category
data$category_reclassified[data$category_reclassified=="Computer Science"]= "CS, DS, PD, LL, IT, ML"
data$category_reclassified[data$category_reclassified=="Data Science"]= "CS, DS, PD, LL, IT, ML"
data$category_reclassified[data$category_reclassified=="Information Technology"]= "CS, DS, PD, LL, IT, ML"
data$category_reclassified[data$category_reclassified=="Language Learning"]= "CS, DS, PD, LL, IT, ML"
data$category_reclassified[data$category_reclassified=="Math and Logic"]= "CS, DS, PD, LL, IT, ML"
data$category_reclassified[data$category_reclassified=="Personal Development"]= "CS, DS, PD, LL, IT, ML"
data$category_reclassified[data$category_reclassified=="Arts and Humanities"]= "PSE, Bus, AH, Heal, SS"
data$category_reclassified[data$category_reclassified=="Business"]= "PSE, Bus, AH, Heal, SS"
data$category_reclassified[data$category_reclassified=="Health"]= "PSE, Bus, AH, Heal, SS"
data$category_reclassified[data$category_reclassified=="Physical Science and Engineering"]= "PSE, Bus, AH, Heal, SS"
data$category_reclassified[data$category_reclassified=="Social Sciences"]= "PSE, Bus, AH, Heal, SS"
data$level_combined=data$level
data$level_combined[data$level_combined=="Intermediate Level"]="Intermediate Level & Advanced Level"
data$level_combined[data$level_combined=="Advanced Level"]="Intermediate Level & Advanced Level"

# Delete outlier
data=data[c(-672,-712,-1480),]

# Build a new model
model_2=lm(log_subscribers ~ ranking+category_reclassified+level_combined+hours_to_complete+num_subtitles, data = data)
# Model result
summary(model_2)
# Check multi-collinearity
vif(model_2)
# Residual Analysis
plot(model_2,col="dodgerblue4")

# Test set add new column
data_test$category_reclassified=data_test$category
data_test$category_reclassified[data_test$category_reclassified=="Computer Science"]= "CS, DS, PD, LL, IT, ML"
data_test$category_reclassified[data_test$category_reclassified=="Data Science"]= "CS, DS, PD, LL, IT, ML"
data_test$category_reclassified[data_test$category_reclassified=="Information Technology"]= "CS, DS, PD, LL, IT, ML"
data_test$category_reclassified[data_test$category_reclassified=="Language Learning"]= "CS, DS, PD, LL, IT, ML"
data_test$category_reclassified[data_test$category_reclassified=="Math and Logic"]= "CS, DS, PD, LL, IT, ML"
data_test$category_reclassified[data_test$category_reclassified=="Personal Development"]= "CS, DS, PD, LL, IT, ML"
data_test$category_reclassified[data_test$category_reclassified=="Arts and Humanities"]= "PSE, Bus, AH, Heal, SS"
data_test$category_reclassified[data_test$category_reclassified=="Business"]= "PSE, Bus, AH, Heal, SS"
data_test$category_reclassified[data_test$category_reclassified=="Health"]= "PSE, Bus, AH, Heal, SS"
data_test$category_reclassified[data_test$category_reclassified=="Physical Science and Engineering"]= "PSE, Bus, AH, Heal, SS"
data_test$category_reclassified[data_test$category_reclassified=="Social Sciences"]= "PSE, Bus, AH, Heal, SS"
data_test$level_combined=data_test$level
data_test$level_combined[data_test$level_combined=="Intermediate Level"]="Intermediate Level & Advanced Level"
data_test$level_combined[data_test$level_combined=="Advanced Level"]="Intermediate Level & Advanced Level"


# Model evaluation
predictions_train <- predict(model_2,data)
predictions_test <- predict(model_2,data_test)
data_test$predictions=predictions_test
RMSE(predictions_train,data$log_subscribers)
R2(predictions_train, data$log_subscribers)
RMSE(predictions_test, data_test$log_subscribers)
R2(predictions_test, data_test$log_subscribers)

# Plot the prediction vs true value
plot(x=predictions_train,y=data$log_subscribers,main="True vs Predicted (log_subscribers)",xlab="Predicted value",ylab="True value",col="dodgerblue4")
abline(0,1,col="red")

