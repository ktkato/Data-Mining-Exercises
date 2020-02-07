library(tidyverse)
library(FNN)
library(foreach)

sclass <- read.csv("~/sclass.csv")

# Omitting unnecessary columns

keep = c("trim", "price", "mileage")
sclass = sclass[keep]

summary(sclass)

# Defining two datasets

sclass350 = subset(sclass, trim == '350')
sclass65amg = subset(sclass, trim == '65 AMG')

#####


# Splitting data into training and testing set

  ## Defining set sizes

N350 = nrow(sclass350)
Ntrain350 = floor(0.8*N350)
Ntest350 = N350 - Ntrain350
  
N65 = nrow(sclass65amg)
Ntrain65 = floor(0.8*N65)
Ntest65 = N65 - Ntrain65

  ## Random sample for training set

trainind_350 = sample.int(N350, Ntrain350, replace = FALSE)
trainind_65AMG = sample.int(N65, Ntrain65, replace = FALSE)

  ## Defining training and testing sets
Dtrain_350 = sclass350[trainind_350,]
Dtest_350 = sclass350[-trainind_350,]

Dtrain_65AMG = sclass65amg[trainind_65AMG,]
Dtest_65AMG = sclass65amg[-trainind_65AMG,]

  ## Reordering rows by mileage
Dtest_350 = arrange(Dtest_350, mileage)
head(Dtest_350)

Dtest_65AMG = arrange(Dtest_65AMG, mileage)
head(Dtest_65AMG)

  ## Splitting each into features (x, mileage) and outcomes (y, price)
X_train_350 = select(Dtrain_350, mileage)
Y_train_350 = select(Dtrain_350, price)
X_test_350 = select(Dtest_350, mileage)
Y_test_350 = select(Dtest_350, price)

X_train_65AMG = select(Dtrain_65AMG, mileage)
Y_train_65AMG = select(Dtrain_65AMG, price)
X_test_65AMG = select(Dtest_65AMG, mileage)
Y_test_65AMG = select(Dtest_65AMG, price)


######


# Running KNN starting at K = 2 and going as high as needed
# Fitting model to training set and make predictions on test set

  ## Predicting values with KNN, sclass 350

knn3_350 = knn.reg(train = X_train_350, test = X_test_350, y = Y_train_350, k=3)
knn10_350 = knn.reg(train = X_train_350, test = X_test_350, y = Y_train_350, k=10)
knn30_350 = knn.reg(train = X_train_350, test = X_test_350, y = Y_train_350, k=30)
knn75_350 = knn.reg(train = X_train_350, test = X_test_350, y = Y_train_350, k=75)
knn100_350 = knn.reg(train = X_train_350, test = X_test_350, y = Y_train_350, k=100)
knn332_350 = knn.reg(train = X_train_350, test = X_test_350, y = Y_train_350, k=332)

ypred_knn3_350 = knn3_350$pred
ypred_knn10_350 = knn10_350$pred
ypred_knn30_350 = knn30_350$pred
ypred_knn75_350 = knn75_350$pred
ypred_knn100_350 = knn100_350$pred
ypred_knn332_350 = knn332_350$pred

  ## Predicting values with KNN, sclass 65 AMG

knn3_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=3)
knn10_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=10)
knn30_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=30)
knn75_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=75)
knn100_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=100)
knn233_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=233)

ypred_knn3_65 = knn3_65$pred
ypred_knn10_65 = knn10_65$pred
ypred_knn30_65 = knn30_65$pred
ypred_knn75_65 = knn75_65$pred
ypred_knn100_65 = knn100_65$pred
ypred_knn233_65 = knn233_65$pred


######


# Calculating out-of-sample RMSE for each value of K
  
  ## Defining RMSE function

rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}
  
rmse(Y_test_350, ypred_knn3_350)
rmse(Y_test_350, ypred_knn10_350)
rmse(Y_test_350, ypred_knn30_350)
rmse(Y_test_350, ypred_knn75_350)
rmse(Y_test_350, ypred_knn100_350)
rmse(Y_test_350, ypred_knn332_350)

rmse(Y_test_65AMG, ypred_knn3_65)
rmse(Y_test_65AMG, ypred_knn10_65)
rmse(Y_test_65AMG, ypred_knn30_65)
rmse(Y_test_65AMG, ypred_knn75_65)
rmse(Y_test_65AMG, ypred_knn100_65)
rmse(Y_test_65AMG, ypred_knn233_65)


######

# Plotting RMSE vs. K

  ## 350

k_grid350 = seq(from = 3, to = Ntrain350)
rmse_grid350 = foreach(k = k_grid350, .combine='c') %do% {
  knn350 = knn.reg(X_train_350, X_test_350, Y_train_350, k = k)
  rmse(Y_test_350, knn350$pred)
}

rmse_grid350 = data.frame(K = k_grid350, RMSE = rmse_grid350)

ggplot(data = rmse_grid350) +
  geom_path(mapping = aes(x = K, y = RMSE)) +
  ggtitle("RMSE vs. K: S Class 350")

  ## 65 AMG

k_grid65 = seq(from = 3, to = Ntrain65)
rmse_grid65 = foreach(k = k_grid65, .combine='c') %do% {
  knn65 = knn.reg(X_train_65AMG, X_test_65AMG, Y_train_65AMG, k = k)
  rmse(Y_test_65AMG, knn65$pred)
}

rmse_grid65 = data.frame(K = k_grid65, RMSE = rmse_grid65)

ggplot(data = rmse_grid65) +
  geom_path(mapping = aes(x = K, y = RMSE)) +
  ggtitle("RMSE vs. K: S Class 65 AMG")


# Plotting fitted models at optimal K

  ## 350

optimal_k350 = rmse_grid350$K[which.min(rmse_grid350$RMSE)]
knn_optimal350 = knn.reg(X_train_350, X_test_350, Y_train_350, optimal_k350)
optimal_pred350 = knn_optimal350$pred
optimal_rmse350 = rmse(Y_test_350, optimal_pred350)
Dtest_350$pred = optimal_pred350

scatter350 = ggplot(data = sclass350) +
  geom_point(mapping = aes(x = mileage, y = price))
scatter350 + geom_path(data = Dtest_350, mapping = aes(x = mileage, y = pred), color = 'blue') +
  ggtitle("S Class 350 with Fitted Line")

  ## 65 AMG

optimal_k65 = rmse_grid65$K[which.min(rmse_grid65$RMSE)]
knn_optimal65 = knn.reg(X_train_65AMG, X_test_65AMG, Y_train_65AMG, optimal_k65)
optimal_pred65 = knn_optimal65$pred
optimal_rmse65 = rmse(Y_test_65AMG, optimal_pred65)
Dtest_65AMG$pred = optimal_pred65

scatter65 = ggplot(data = sclass65amg) +
  geom_point(mapping = aes(x = mileage, y = price))
scatter65 + geom_path(data = Dtest_65AMG, mapping = aes(x = mileage, y = pred), color = 'red') +
  ggtitle("S Class 65 AMG with Fitted Line")


# From repeated random samples, we find that the S Class 350 data generally yields a larger optimal value of K than the S Class 65 AMG, although occasionally we found the reverse to be true.
# We believe the two subsets yield different optimal values of K largely due to the difference in sample size of each subset.  There are 332 observations in the S Class 350 training set and 233 in the S Class 65 AMG training set.  For example, if two datasets of roughly similar x-ranges and an identical trend, but different sample sizes, are making KNN-predictions with equal K, the smaller dataset will need to "reach further" from the x-value of interest than the larger one to acquire the K number of observations, taking into account a larger range of the x-values and thus, more of the change in that trend, distorting the expected value of the x-value.
# The smaller dataset, then, usually needs a smaller K because at a given x-value, the more local observations will be more reliable in predicting f(x).
