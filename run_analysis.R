packages <- c("dplyr", "plyr")
install.packages(packages)
library(plyr)
library(dplyr)

#imports activity labels and features .txt files
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
features <- read.table("./UCI HAR Dataset/features.txt")
feat_list <- features[,2]

#Merges subject_test.txt and y_test.txt

X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

test_merge <- data.frame("subject" = subject_test[,1],
                         "activities" = y_test[,1])

#adds labels to X_test for features
colnames(X_test) <- feat_list

#merges test results to test_merge
test_full <- cbind(test_merge, X_test)

#Does the same for train data sets
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

train_merge <- data.frame("subject" = subject_train[,1],
                         "activities" = y_train[,1])

colnames(X_train) <- feat_list
train_full <- cbind(train_merge, X_train)

#merges test and training data sets
full <- rbind(train_full, test_full)
