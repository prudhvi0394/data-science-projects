# loading packages
library(dplyr)
library(ggplot2)
library(pROC)
library(glmnet)
library(rpart)

#                             /**** Data preperation ****/
# reading data and creating dataframe
df = os

# dataframe dimensions and features
glimpse(df)

# dataframe summary
summary(df)

# missing value analysis
sapply(df, function(col) sum(is.na(col)))

# creating list of numerical and categorical variables
features_numerical = c('Administrative','Administrative_Duration','Informational','Informational_Duration','ProductRelated','ProductRelated_Duration','BounceRates','ExitRates','PageValues','SpecialDay')
features_categorical = c('OperatingSystems','Browser','Month','Region','TrafficType','VisitorType','Weekend','Revenue')

# creating dataframes with numerical and categorical features
df_numerical = df[features_numerical]
df_categorical = df[features_categorical]

# modifying the datatypes
#df_categorical$Revenue = ifelse(df_categorical$Revenue == TRUE,1,0)
df_categorical$Weekend = ifelse(df_categorical$Weekend == TRUE,1,0)
df_categorical$TrafficType = as.factor(df_categorical$TrafficType)
df_categorical$Region = as.factor(df_categorical$Region)
df_categorical$OperatingSystems = as.factor(df_categorical$OperatingSystems)
df_categorical$Browser = as.factor(df_categorical$Browser)
glimpse(df_categorical)

# feature engineering to reduce classes in categorical variables
df_categorical$OperatingSystems =  ifelse(df_categorical$OperatingSystems %in% c('1','2','3'), df_categorical$OperatingSystems, 'Other')
df_categorical$Browser =  ifelse(df_categorical$Browser %in% c('1','2'), df_categorical$Browser, 'Other')
df_categorical$Region =  ifelse(df_categorical$Region %in% c('1','3'), df_categorical$Browser, 'Other')
df_categorical$TrafficType =  ifelse(df_categorical$TrafficType %in% c('12','17','18'), df_categorical$Browser, 'Other')

# creating dummy variables
df_dummy = fastDummies::dummy_cols(df_categorical[c(-7,-8)], remove_first_dummy = TRUE)

# replacing the factor variables with dummies
df_categorical_dummy = cbind(df_dummy[,c(-1:-6)], df_categorical[,c(7,8)])

# checking for multicollinearity
corrplot::corrplot(cor(df_numerical))

# feature engineering to remove multicollinearity
df_numerical$Mean_Administrative_Duration = df_numerical$Administrative_Duration / df_numerical$Administrative
df_numerical$Mean_Informational_Duration = df_numerical$Informational_Duration / df_numerical$Informational
df_numerical$Mean_ProductRelated_Duration = df_numerical$ProductRelated_Duration / df_numerical$ProductRelated
df_numerical[is.na(df_numerical)] = 0
df_numerical_fe = df_numerical[,c(-1:-7)]

# checking for multicollinearity
corrplot::corrplot(cor(df_numerical_fe))

# combining numerical and categorical dataframes
df_cleaned = cbind(df_numerical_fe, df_categorical_dummy)


#                             /**** Modelling ****/
set.seed(1)
# train test split - 80:20
train_index = sample(1:dim(df_cleaned)[1], dim(df_cleaned)[1]*0.8, replace = FALSE)
df_train = df_cleaned[train_index, ]
df_test = df_cleaned[-train_index, ]

# base logit model
model = glm(Revenue~., data=df_train, family='binomial')
summary(model)
y_pred_prob = predict(model, df_test, type='response')
y_pred = ifelse(y_pred_prob>0.5, 1, 0)
mean(df_test$Revenue == y_pred)
ROC = roc(df_test$Revenue, y_pred)
auc(ROC)

# lasso regression
X = as.matrix(df_train[,c(-28)])
y = as.matrix(df_train['Revenue'])
cv_lasso <- cv.glmnet(X, y, family='binomial', alpha=1, standardize=TRUE, nfolds=5,  type.measure='auc')
plot(cv_lasso)
model_lasso = glmnet(X, y, alpha=1, standardize=TRUE, lambda=cv_lasso$lambda.min)
coef(model_lasso)

# logit model with feature selection
model_fe = glm(Revenue~ExitRates+PageValues+Month_Nov, data=df_train, family='binomial')
summary(model_fe)
y_pred_prob = predict(model_fe, df_test, type='response')
y_pred = ifelse(y_pred_prob>0.5, 1, 0)
mean(df_test$Revenue == y_pred)
ROC = roc(df_test$Revenue, y_pred)
auc(ROC)

# finding the best threshold
threshold = seq(0.2, 0.5, by=0.05)
accuracy = c()
auc = c()

for (i in 1:7){
  y_pred = ifelse(y_pred_prob>threshold[i], 1, 0)
  accuracy[i] = mean(df_test$Revenue == y_pred)
  auc[i] = auc(roc(df_test$Revenue, y_pred))
}

df_threshold_results = data.frame(threshold, accuracy, auc)
plot(threshold, accuracy, type='b', main='Threshold vs Accuracy')

# optimized logit model
model_final = glm(Revenue~ExitRates+PageValues+Month_Nov, data=df_train, family='binomial')
summary(model_final)
y_pred_prob = predict(model_final, df_test, type='response')
y_pred = ifelse(y_pred_prob>0.5, 1, 0)
mean(df_test$Revenue == y_pred)
ROC = roc(df_test$Revenue, y_pred)
auc(ROC)

# results matrix
models = c('Base logit model', 'Logit model with Lasso regression', 'Optimized logit model')
features = c(27, 3, 3)
accuracy = c(0.89, 0.89, 0.90)
auc = c(0.68, 0.68, 0.77)
df_results = data.frame(models, features, accuracy, auc)

# decision tree
credit_model <- rpart(formula = Revenue ~ ., 
                      data = df_train, 
                      method = "class")
y_pred_prob = predict(credit_model, df_test, type='class')
y_pred = ifelse(y_pred_prob == "1", 1, 0)
mean(df_test$Revenue == y_pred)
ROC = roc(df_test$Revenue, y_pred)
auc(ROC)
