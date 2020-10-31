packages <- c("dplyr", "plyr")
install.packages(packages)
library(plyr)
library(dplyr)

#Merges subject_test.txt and y_test.txt

X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

test_merge <- data.frame("subject" = subject_test[,1],
                         "ytest" = y_test[,1])
