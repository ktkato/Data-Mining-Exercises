library(tidyverse)
library(FNN)

# omit unnecessary columns

keep = c("trim", "price", "mileage")
sclass = sclass[keep]

summary(sclass)

# defining two datasets

sclass350 = subset(sclass, trim == '350')
sclass65amg = subset(sclass, trim == '65 AMG')

#####


# split data into training and testing set

  ## defining set sizes

N350 = nrow(sclass350)
Ntrain350 = floor(0.8*N350)
Ntest350 = N350 - Ntrain350
  
N65 = nrow(sclass65amg)
Ntrain65 = floor(0.8*N65)
Ntest65 = N65 - Ntrain65

  ## random sample for training set

trainind_350 = sample.int(N350, Ntrain350, replace = FALSE)
trainind_65AMG = sample.int(N65, Ntrain65, replace = FALSE)

  ## define training and testing sets
Dtrain_350 = sclass350[trainind_350,]
Dtest_350 = sclass350[-trainind_350,]

Dtrain_65AMG = sclass65amg[trainind_65AMG,]
Dtest_65AMG = sclass65amg[-trainind_65AMG,]

  ## reorder rows by mileage
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


# run KNN starting at K = 2 and going as high as needed
# for each value of K, fit model to training set and make predictions on test set

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
knn20_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=20)
knn30_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=30)
knn40_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=40)
knn50_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=50)
knn75_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=75)
knn100_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=100)
knn125_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=125)
knn150_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=150)
knn175_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=175)
knn200_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=200)
knn233_65 = knn.reg(train = X_train_65AMG, test = X_test_65AMG, y = Y_train_65AMG, k=233)

ypred_knn3_65 = knn3_65$pred
ypred_knn10_65 = knn10_65$pred
ypred_knn20_65 = knn20_65$pred
ypred_knn30_65 = knn30_65$pred
ypred_knn40_65 = knn40_65$pred
ypred_knn50_65 = knn50_65$pred
ypred_knn75_65 = knn75_65$pred
ypred_knn100_65 = knn100_65$pred
ypred_knn125_65 = knn125_65$pred
ypred_knn150_65 = knn150_65$pred
ypred_knn175_65 = knn175_65$pred
ypred_knn200_65 = knn200_65$pred
ypred_knn233_65 = knn233_65$pred


######


# calculate out-of-sample RMSE for each value of K
  
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
rmse(Y_test_65AMG, ypred_knn20_65)
rmse(Y_test_65AMG, ypred_knn30_65)
rmse(Y_test_65AMG, ypred_knn40_65)
rmse(Y_test_65AMG, ypred_knn50_65)
rmse(Y_test_65AMG, ypred_knn75_65)
rmse(Y_test_65AMG, ypred_knn100_65)
rmse(Y_test_65AMG, ypred_knn125_65)
rmse(Y_test_65AMG, ypred_knn150_65)
rmse(Y_test_65AMG, ypred_knn175_65)
rmse(Y_test_65AMG, ypred_knn200_65)
rmse(Y_test_65AMG, ypred_knn233_65)