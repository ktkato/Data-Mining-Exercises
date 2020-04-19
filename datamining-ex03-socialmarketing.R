library(LICORS)
library(mosaic)
library(cluster)

social_marketing <- read.csv("~/University of Texas/Data Mining & Statistical Inference/Data/social_marketing.csv")

# delete the untrustworthy records

social_marketing <- social_marketing[!(social_marketing$adult > 0 & social_marketing$spam > 0),]
social_marketing$total <- rowSums(social_marketing[-1])  # totaling number of tags
social_marketing$pctadult <- (social_marketing$adult/social_marketing$total)  # excessive amount of adult posts
social_marketing <- social_marketing[-(which(social_marketing$pctadult >= .25)),]

# delete irrelevant features

social_marketing <- social_marketing[,-c(36,39)]  # removed spam and pctadult columns

# center and scale

sm_scaled <- scale(social_marketing[,-c(1,37)], center = TRUE, scale = TRUE)
mu = attr(sm_scaled, "scaled:center")
sigma = attr(sm_scaled, "scaled:scale")


# K-means++

kpp = kmeanspp(sm_scaled, 6, nstart = 25)

c1 <- data.frame(social_marketing[(which(kpp$cluster == 1)),])
c2 <- data.frame(social_marketing[(which(kpp$cluster == 2)),])
c3 <- data.frame(social_marketing[(which(kpp$cluster == 3)),])
c4 <- data.frame(social_marketing[(which(kpp$cluster == 4)),])
c5 <- data.frame(social_marketing[(which(kpp$cluster == 5)),])
c6 <- data.frame(social_marketing[(which(kpp$cluster == 6)),])

sum1 <- data.frame(cbind(colSums(c1[,-c(1,37)]),
                         kpp$center[1,]*sigma + mu,
                         colSums(c2[,-c(1,37)]),
                         kpp$center[2,]*sigma + mu,
                         colSums(c3[,-c(1,37)]),
                         kpp$center[3,]*sigma + mu,
                         colSums(c4[,-c(1,37)]),
                         kpp$center[4,]*sigma + mu,
                         colSums(c5[,-c(1,37)]),
                         kpp$center[5,]*sigma + mu,
                         colSums(c6[,-c(1,37)]),
                         kpp$center[6,]*sigma + mu))

colnames(sum1)[c(1,3,5,7,9,11)] <- "Label Count"
colnames(sum1)[c(2,4,6,8,10,12)] <- "Center Value"

t1 <- head(sum1[(order(sum1[,1], decreasing = TRUE)), 1:2, drop = FALSE], n=8)
t2 <- head(sum1[(order(sum1[,3], decreasing = TRUE)), 3:4, drop = FALSE], n=8)
t3 <- head(sum1[(order(sum1[,5], decreasing = TRUE)), 5:6, drop = FALSE], n=8)
t4 <- head(sum1[(order(sum1[,7], decreasing = TRUE)), 7:8, drop = FALSE], n=8)
t5 <- head(sum1[(order(sum1[,9], decreasing = TRUE)), 9:10, drop = FALSE], n=8)
t6 <- head(sum1[(order(sum1[,11], decreasing = TRUE)), 11:12, drop = FALSE], n=8)

t1
t2
t3
t4
t5
t6

# Histogram of Total Tags

ggplot(data = social_marketing) +
  geom_bar(mapping = aes(social_marketing$total)) +
  ggtitle("Label Count") +
  labs(x = "Number of Labels", y = "Number of Users") +
  theme(plot.title = element_text(hjust = 0.5, size = 22))

# PCA

Z <- social_marketing[,-1]

sm_pc = prcomp(Z, scale.=TRUE)
summary(sm_pc)

loadings = sm_pc$rotation
scores = sm_pc$x
loadings[order(loadings[,1]),1]
loadings[order(loadings[,2]),2]
loadings[order(loadings[,3]),3]
loadings[order(loadings[,4]),4]
loadings[order(loadings[,5]),5]

qplot(scores[,1], scores[,2], xlab='Component 1', ylab='Component 2')

########

C <- c5[,-c(1,37)]

c5_pc = prcomp(C, scale.=TRUE)
summary(c5_pc)

load_c5 = c5_pc$rotation
score_c5 = c5_pc$x
load_c5[order(load_c5[,1]),1]
load_c5[order(load_c5[,2]),2]

