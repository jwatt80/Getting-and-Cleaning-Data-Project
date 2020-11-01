install.packages("plyr")
install.packages("dplyr")
install.packages("reshape2")

library(plyr)
library(dplyr)
library(reshape2)

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

### merges test and training data sets (Objective 1) ###
full <- rbind(train_full, test_full)

### selects only columns of measurement mean and standard deviations (Obj. 2) ###

subset <- full[,grepl("mean()", names(full))|grepl("std()", names(full))]
subj_activity <- rbind(train_merge, test_merge)
subset2 <- cbind(subj_activity, subset)

### adds a column of descriptive names to the activity code (Obj. 3) ###

colnames(activity_labels) <- c("activities", "activity")
subset3 <- left_join(subset2, activity_labels, by = "activities")
subset3 <- relocate(subset3, activity, .after = activities)

### calculates means of each measurement by subject and activity (Obj. 5) ###

subset6m <- melt(subset3, id.vars = c("subject", "activities", "activity"))
subset6m <- group_by(subset6m, subject, activity, variable)

mean_subset <- summarize(subset6m, mean(value)) #Long data set

mean_subsetw <- dcast(mean_subset, subject + activity ~ variable, #Wide data set
                      value.var = "mean(value)")



