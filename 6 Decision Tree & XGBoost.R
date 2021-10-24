train = read.csv("C:/Users/Jennie/Desktop/EBAC课件/EB5002/data1018/train1020.csv")
test = read.csv("C:/Users/Jennie/Desktop/EBAC课件/EB5002/data1018/test1020.csv")
train = na.omit(train)
test = na.omit(test)
train = train[,-c(1,2,3,4,6,7,12)]
coly <- 6
colnames(train)[6] = "y"
test = test[,-c(1,2,3,4,6,7,12)]
test$hours_to_complete = as.numeric(test$hours_to_complete)
colnames(test)[6] = "y"
combined <- rbind(train, test)

trainx = train[,-6]
trainy = train$y
testx = test[,-6]
testy = test$y

library(caret)

## Decision Tree ##
#Build Regression Tree
library(rpart) 
library(rpart.plot) 

rp_rpart <- rpart(y~.,train,method="anova") 

summary(rp_rpart)
rp_rpart$variable.importance
print(rp_rpart)
rpart.plot(rp_rpart,type=4,fallen.leaves=TRUE) # Draw Tree Plot
cpmatrix <- printcp(rp_rpart)

#Determine the cp value for pruning the tree
plotcp(rp_rpart) 
mincpindex <- which.min(cpmatrix[,4])
cponeSE <- cpmatrix[mincpindex,4]+cpmatrix[mincpindex,5]
cpindex <- min(which(cpmatrix[,4]<=cponeSE))
cpmatrix[cpindex,1]

#Pruning
rp_rpart2 <- prune(rp_rpart,cp=cpmatrix[cpindex,1]) 
summary(rp_rpart2)
print(rp_rpart2)

#Draw the model
rpart.plot(rp_rpart2,type=4) 
post(rp_rpart2,file="",title.="post: Regression Tree") 

#Model Effect on the Test Set
pre <- data.frame(predict(rp_rpart,test[,-coly])) #Original Model Predicted Results
measure.rpart <- postResample(pre,test[,coly]) 
measure.rpart
rp_rpart$variable.importance
pre2 <- data.frame(predict(rp_rpart2,test[,-coly])) # Pruned Tree Predicted Results
measure.rpart2 <- postResample(pre2,test[,coly]) 
measure.rpart2
rp_rpart2$variable.importance

pre2 <- as.numeric(unlist(pre2))

plot(pre2,testy,main="Predicted VS. True (CART)",col="dodgerblue4")
abline(0,1,col="red")

#One-hot encoding for XGBoost model
combind_model <- model.matrix(~.,data = combined[,-coly])[,-1]
trainx <- combind_model[1:2080,]
testx<- combind_model[-(1:2080),]
trainy <- train[,coly]

#########################################################
#Modeling
if (!require(xgboost)) {
  install.packages("xgboost")
  library(xgboost)
}
param <- list(seed=1,objective="reg:linear",max_depth=8,min_child_weight=0.1)

model.xgb <- xgboost(data=trainx,label=trainy,params=param,nrounds=20)

# Cross-validation method
modelcv.xgb <- xgb.cv(data=trainx,label=trainy,params=param,nrounds=10,nfold=2)
modelcv.xgb 
# Checking each sub learning methods
submodel <- xgb.dump(model.xgb, with_stats = T)
submodel[1:20]

## Relative Variable Importance Plot
names <- dimnames(data.matrix(trainx))[[2]]
importance_matrix <- xgb.importance(names, model = model.xgb)
xgb.plot.importance(importance_matrix[1:10,])

#Prediction
pred.xgb <- predict(model.xgb, testx)
measure.xgb <- postResample(pred.xgb,test$y) # Prediction Results
measure.xgb
plot(pred.xgb,testy,main = "Predicted VS. True (XGBoost)",col="dodgerblue4")
abline(0,1,col="red")

