---
title: "README"
author: "James Watt"
date: "11/1/2020"
output:
  pdf_document: default
  html_document: default
---
This is an R script titled **run_analysis.R** that cleans up the mobile computing dataset from the UCI machine learning repository. It produces two tidy datsets: one LONG dataset, where each row includes subject and activity, and a single measurement value; and a WIDE dataset, where each row contains subject, activity, and each measurement value.

The measurement values included in the final data sets are explained in the codebook, but, in brief, are all mean calculations of repeated measures of that variable within a subject and activity.

To start, the 'test' and 'train' data sets are merged together.

The code below installs the necessary packages.

```{r eval=FALSE}
install.packages("plyr")
install.packages("dplyr")
install.packages("reshape2")
install.packages("magrittr")
```
```{r message=FALSE, warning=FALSE}
library(plyr)
library(dplyr)
library(reshape2)
library(magrittr)
```

This code imports activity labels from 'activity_labels.txt' and the list of features (variables) from 'features.txt'. 'feat_list' is a vector of feature names.

```{r}
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
features <- read.table("./UCI HAR Dataset/features.txt")
feat_list <- features[,2]
```
```{r}
feat_list[1:15]
```

This code merges 'subject_test.txt' and 'y_test.txt', which assigns each activity to each subject. It also reads in the 'X_test.txt' file, which is a list of values of feature results.

```{r}
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

test_merge <- data.frame("subject" = subject_test[,1],
                         "activities" = y_test[,1])
```

Then, I add the 'feat_list' vector to 'X_test' to label the columns of 'X_test' with their variable names.

```{r}
colnames(X_test) <- feat_list
```

Finally, I merge the subjects, activity codes, and X_test results together by columns using **cbind**.

```{r}
test_full <- cbind(test_merge, X_test)
```

This process is repeated for the 'train' data sets.

```{r}
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

train_merge <- data.frame("subject" = subject_train[,1],
                         "activities" = y_train[,1])

colnames(X_train) <- feat_list
train_full <- cbind(train_merge, X_train)
```

To complete Objective #1, the 'test' and 'train' datasets are joined using **rbind** to produce a full data set with subject, activity code, and feature values.

```{r}
full <- rbind(train_full, test_full)
```

To simplify future analyses, only the features which are means or standard deviations (std) are extracted from the 'full' dataset into a data frame called 'subset'. This is accomplished using the **grepl** function. The resulting extracted data are re-merged with datasets containing subject and activity into a new dataframe called 'subset2'. This completes Objective #2.

```{r}
subset <- full[,grepl("mean()", names(full))|grepl("std()", names(full))]
subj_activity <- rbind(train_merge, test_merge)
subset2 <- cbind(subj_activity, subset)
```

The activity codes are listed as numerals 1-6. To replace these with corresponding descriptive activities, the column names of 'activity_labels' (see above) are replaced with "activities" and "activity": the number and description, respectively. This facilitates merging using **left_join** by the "activities" value, which exists in both data sets. For clarity, the new column, "activity", is moved adjacent to the exisiting "activities" column in the new data frame, 'subset3'. This completes Objective #3.

```{r}
colnames(activity_labels) <- c("activities", "activity")
subset3 <- left_join(subset2, activity_labels, by = "activities")
subset3 <- relocate(subset3, activity, .after = activities)
```

Next, each of the feature names is replaced with a more descriptive feature name, using information from the 'features_info.txt' file, provided by the data source. A vector is created of the column names from 'subset3', named 'features'. The first three column names ("subject", "activities", and "activity") are already descriptive, so they are separated out into a vector 'featurestop'. The remaining features are separated into a vector named 'featuresbot'. 'featuresbot' uses piping to replace specific text strings with descriptive strings using **gsub()**. Each element of the vector is made lowercase by **tolower()**. Because each of the final values will be calculated mean values (below), the phrase "mean of" is appended to the front of each variable name in 'featuresbot'. 'features' is then updated by pasting 'featurestop' and 'featuresbot' together using **paste()**. Last, the column names of 'subset3' are updated to those created in 'features' using **colnames()**. This completes Objective #4. 

```{r}
features <- names(subset3)
featurestop <- features[1:3]
featuresbot <- features[4:length(features)]
featuresbot %<>%
        gsub("Acc", "accelerometer ", .) %>%
        gsub("Gyro", "gyroscope ", .) %>%
        gsub("Jerk", "jerksignal ", .) %>% 
        gsub("Mag", "magnitude ", .) %>%
        gsub("^tBody", "time domain body ", .) %>%
        gsub("^fBody", "frequency domain body ", .) %>%
        gsub("Body", "", .) %>%
        gsub("^tGravity", "time domain gravity ", .) %>%
        gsub("-mean", "mean", .) %>%
        gsub("-std", "std", .) %>%
        gsub("\\()", "", .) %>%
        gsub("\\-", " ", .) %>%
        gsub("meanFreq", "mean frequency", .) %>%
        tolower() %>%
        paste("mean of", ., sep = " ")

features <- c(featurestop, featuresbot)
colnames(subset3) <- features
```
```{r}
features
```

Objective #5 is to calculate the mean of each variable (feature) for each subject at each activity. The first step is to **melt()** the data into a *long* data set. The dataframe 'subset6m' is created ('subsets 4 and 5' were temporary and discarded).

```{r}
subset6m <- melt(subset3, id.vars = c("subject", "activities", "activity"))
```

This allows **dplyr** to use the **summarize()** function. First, the data needs to be grouped, using **group_by()**, creating individual groups of "subject" x "activity" x "variable". "variable" was created by default by **melt()** and consists of the feature names. 

```{r}
subset6m <- group_by(subset6m, subject, activity, variable)
```

I then create a data frame of the mean values by the above groups, named 'mean_subset'.

```{r message=FALSE, warning=FALSE}
mean_subset <- summarize(subset6m, mean(value)) 
```

This is a *long* data set. Each line shows the subject, activity, and variable, and the mean value of the repeated measurements of that variable calculated above by **summarize()**. 

```{r}
head(mean_subset)
tail(mean_subset)
```


To make it a little more easy to interpret, a *wide* data set is created using **dcast**.

```{r}
mean_subsetw <- dcast(mean_subset, subject + activity ~ variable,
                      value.var = "mean(value)")
```

Each row of 'mean_subsetw' consists of the subject, activity, and the mean value of the repeated measurements of each variable, with variables as columns. 

```{r}
mean_subsetw[1:10,1:6]
```





