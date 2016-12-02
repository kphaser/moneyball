### Moneyball Assignment ###
# Using decision trees to impute missing values #

# load training dataset and libraries
library(rpart)
setwd("./PREDICT 411/Moneyball")
mb <- as.data.frame(read.csv("moneyball.csv"))
#test <- as.data.frame(read.csv("moneyball_test.csv"))

# examine the dataset
str(mb)
summary(mb)
cor(mb)

# drop unused columns prior to decision tree
mb <- mb[,-c(1,2,11)]
names(mb)

# create a decision tree for each variable with missing values. cross validate to see if we can prune the tree to make simpler
# TEAM_BATTING_SO, TEAM_BASERUN_CS, TEAM_BASERUN_SB, TEAM_PITCHING_SO, TEAM_FIELDING_DP

batting_so_tree <- rpart(TEAM_BATTING_SO~.,data=mb)
plot(batting_so_tree)
text(batting_so_tree)
printcp(batting_so_tree)
plotcp(batting_so_tree) # keep all 8 branches


baserun_cs <- rpart(TEAM_BASERUN_CS~.,data=mb)
plot(baserun_cs)
text(baserun_cs)
printcp(baserun_cs)
plotcp(baserun_cs) # keep all 10 branches


baserun_sb <- rpart(TEAM_BASERUN_SB~.,data=mb)
plot(baserun_sb)
text(baserun_sb)
printcp(baserun_sb)
plotcp(baserun_sb) # keep all 10 branches (maybe 8)


pitching_so <- rpart(TEAM_PITCHING_SO~.,data=mb)
plot(pitching_so)
text(pitching_so)
printcp(pitching_so)
plotcp(pitching_so) # keep all 6 branches (maybe 5)

fielding_dp <- rpart(TEAM_FIELDING_DP~.,data=mb)
plot(fielding_dp)
text(fielding_dp)
printcp(fielding_dp)
plotcp(fielding_dp) # keep all 6 branches

