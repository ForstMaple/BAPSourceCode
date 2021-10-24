

library(ggplot2)
library(randomForest)

train <- read.csv('train1020.csv')
test <- read.csv('test1020.csv')
hist(train$log_subscribers) # Check the distribution of response variable

# Compare variables rankings and provider category by building random forest
# model with them seperately with 800 number of trees.
rf_f_rank=randomForest(log_subscribers~ provider_category+
                    num_subtitles+subcategory+level+hours_to_complete,
                  data=train, mtry=2, ntree=800, importance=TRUE)
rf_f_pro=randomForest(log_subscribers~ ranking+
                    num_subtitles+subcategory+level+hours_to_complete,
                  data=train, mtry=2, ntree=800, importance=TRUE)
rf_f_rank
rf_f_pro

# Build random forest models with 800 trees and 1000 trees respectively
rf_f=randomForest(log_subscribers~ ranking+
                    num_subtitles+subcategory+level+hours_to_complete,
                  data=train, mtry=2, ntree=800, importance=TRUE)
rf_f # Check the summray
rf_f1=randomForest(log_subscribers~ ranking+
                    num_subtitles+subcategory+level+hours_to_complete,
                  data=train, mtry=2, ntree=1000, importance=TRUE)
rf_f1 # Check the summray


# Make prediction by using testing set and plot the graph with out log transformation
predict = predict(rf_f, newdata=test) # Utilize the model on testing set for prediction
subscribers <- exp(test$log_subscribers)
pre <- exp(predict)
plot(subscribers, pre, col='dodgerblue4', main='Actual VS. Predict (without transformation)')
abline(0,1, col='red')


# Plot the graph of actual value and predicted value with log transformation and calculate
# RMSE
log_subscribers <- test$log_subscribers
plot(log_subscribers, predict, col='dodgerblue4', main='Actual VS. Predict')
abline(0,1, col='red')
RMSE <- mean((test$log_subscribers-predict)^2)^0.5
knitr::kable(RMSE, "simple")

# Check the importance level for each variable that is used in model and plot the importance
rn <- round(randomForest::importance(rf_f), 2)
rn[order(rn[,1], decreasing=TRUE),]
rn <- data.frame(rn)
rn$category <- c('ranking',
                   'num_subtitles','subcategory','level','hours_to_complete')
colnames(rn) <- c('%IncMSE', 'IncNodePurity', 'Variables')
ggplot(data = rn, aes(y = reorder(Variables, `%IncMSE`), x = `%IncMSE`))+
  geom_bar(stat='identity', fill='lightskyblue1')+
  geom_text(aes(label=`%IncMSE`), col='dodgerblue4')+
  ggtitle('Importance')

