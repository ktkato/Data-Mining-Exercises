library(foreach)
library(tidyverse)
require(scales)

options(scipen = 999)
online_news <- read.csv("~/University of Texas/Data Mining & Statistical Inference/Data/online_news.csv")

# Define regressands, "logshares" and "viral"

online_news$logshares = log(online_news$shares)
online_news$viral = ifelse(online_news$shares > 1400, 1, 0)

# Define train/test sizes

n = nrow(online_news)
ntrain = floor(n*0.8)
ntest = n - ntrain

#### Regress first, then threshold: Linear model

calc_accuracy <- function(formula, splitnum, df) {
  
  fitlist <- list()
  
  for(i in 1:splitnum) {
    
    trainind = sample.int(n, ntrain, replace = FALSE)
    trainset = df[trainind,]
    testset = df[-trainind,]
    
    mash_lm = lm(formula, data = trainset)
    predshares_lm = exp(predict(mash_lm, newdata = testset))
    predviral_lm = ifelse(predshares_lm > 1400, 1, 0)
    
    viral = testset[which(testset$viral==1),]$viral
    notviral = testset[which(testset$viral==0),]$viral
    correctpredviral = ifelse(predviral_lm==1 & testset$viral==1, 1, 0)
    correctprednotviral = ifelse(predviral_lm==0 & testset$viral==0, 1, 0)
    wrongpredviral = ifelse(predviral_lm==1 & testset$viral==0, 1, 0)
    
    fitlist[[i]] <- 
      data.frame(accuracy = (sum(correctprednotviral)+sum(correctpredviral))/7929,
                 nullacc = length(notviral)/7929,
                 error = 1-((sum(correctprednotviral)+sum(correctpredviral))/7929),
               truepos = sum(correctpredviral)/length(viral),
               falsepos = sum(wrongpredviral)/length(notviral)) 
  }
  
  data.table::rbindlist(fitlist, idcol = T)
  
}

linreg = calc_accuracy(logshares ~ n_tokens_title + n_tokens_content + num_self_hrefs + num_hrefs + average_token_length +
                         num_imgs + num_videos + num_keywords + is_weekend + global_rate_positive_words + global_rate_negative_words +
                         title_subjectivity + abs_title_sentiment_polarity + self_reference_avg_sharess + data_channel_is_world +
                         data_channel_is_bus + data_channel_is_entertainment + data_channel_is_tech + data_channel_is_socmed +
                         avg_positive_polarity + avg_negative_polarity,
                       splitnum = 100, df = online_news)

mean(linreg$error)
mean(linreg$truepos)
mean(linreg$falsepos)
mean(linreg$nullacc)
mean(linreg$accuracy)



####  Threshold first, then regress: Logit model

logit_accuracy <- function(formula, splitnum, df) {
  
  fitlist <- list()
  
  for(i in 1:splitnum) {
    
    trainind = sample.int(n, ntrain, replace = FALSE)
    trainset = df[trainind,]
    testset = df[-trainind,]
    
    mash_logit = glm(formula, data = trainset, family = binomial)
    probviral_logit = predict(mash_logit, newdata = testset, type = "response")
    predviral_logit = ifelse(probviral_logit > 0.5, 1, 0)
    
    viral = testset[which(testset$viral==1),]$viral
    notviral = testset[which(testset$viral==0),]$viral
    correctpredviral = ifelse(predviral_logit==1 & testset$viral==1, 1, 0)
    correctprednotviral = ifelse(predviral_logit==0 & testset$viral==0, 1, 0)
    wrongpredviral = ifelse(predviral_lm==1 & testset$viral==0, 1, 0)
    
    fitlist[[i]] <- 
      data.frame(accuracy = (sum(correctprednotviral)+sum(correctpredviral))/7929,
                 nullacc = length(notviral)/7929,
                 error = 1-((sum(correctprednotviral)+sum(correctpredviral))/7929),
                 truepos = sum(correctpredviral)/length(viral),
                 falsepos = sum(wrongpredviral)/length(notviral)) 
  }
  
  data.table::rbindlist(fitlist, idcol = T)
  
}

logreg = logit_accuracy(viral ~ n_tokens_title + n_tokens_content + num_self_hrefs + num_hrefs + average_token_length +
                          num_imgs + num_videos + num_keywords + is_weekend + global_rate_positive_words + global_rate_negative_words +
                          title_subjectivity + abs_title_sentiment_polarity + self_reference_avg_sharess + data_channel_is_world +
                          data_channel_is_bus + data_channel_is_entertainment + data_channel_is_tech + data_channel_is_socmed +
                          avg_positive_polarity + avg_negative_polarity, splitnum = 100, df = online_news)

mean(logreg$error)
mean(logreg$truepos)
mean(logreg$falsepos)
mean(logreg$nullacc)
mean(logreg$accuracy)

# Sample confusion matrices

trainind = sample.int(n, ntrain, replace = FALSE)
trainset = online_news[trainind,]
testset = online_news[-trainind,]

  # Regress-then-threshold

mash_lm = lm(logshares ~ n_tokens_title + n_tokens_content + num_self_hrefs + num_hrefs + average_token_length +
               num_imgs + num_videos + num_keywords + is_weekend + global_rate_positive_words + global_rate_negative_words +
               title_subjectivity + abs_title_sentiment_polarity + self_reference_avg_sharess + data_channel_is_world +
               data_channel_is_bus + data_channel_is_entertainment + data_channel_is_tech + data_channel_is_socmed +
               avg_positive_polarity + avg_negative_polarity, data = trainset)
predshares_lm = exp(predict(mash_lm, newdata = testset))
predviral_lm = ifelse(predshares_lm > 1400, 1, 0)
confusion_out_lm = table(viral = testset$viral, viral_pred = predviral_lm)
confusion_out_lm

error_lm = 1-(sum(diag(confusion_out_lm))/sum(confusion_out_lm))
error_lm

  # Threshold-then-regress

mash_logit = glm(viral ~ n_tokens_title + n_tokens_content + num_self_hrefs + num_hrefs + average_token_length +
               num_imgs + num_videos + num_keywords + is_weekend + global_rate_positive_words + global_rate_negative_words +
               title_subjectivity + abs_title_sentiment_polarity + self_reference_avg_sharess + data_channel_is_world +
               data_channel_is_bus + data_channel_is_entertainment + data_channel_is_tech + data_channel_is_socmed +
               avg_positive_polarity + avg_negative_polarity, data = trainset, family = binomial)
probviral_logit = predict(mash_logit, newdata = testset, type = "response")
predviral_logit = ifelse(probviral_logit > 0.5, 1, 0)
confusion_out_logit = table(viral = testset$viral, viral_pred = predviral_logit)
confusion_out_logit

error_logit = 1-(sum(diag(confusion_out_logit))/sum(confusion_out_logit))
error_logit