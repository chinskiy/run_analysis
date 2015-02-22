library(dplyr)

# 0. download, unzip, read data
if(!file.exists("./data/data.zip")) 
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

if(!file.exists("./data/data.zip")) 
  download.file(url, destfile = "./data/data.zip")

if(!file.exists("./data/README.txt"))
  unzip("./data/data.zip", exdir = paste(getwd(), "/data", sep = ""))

test_x  <- read.table("./data/UCI HAR Dataset/test/X_test.txt",
                      strip.white = TRUE, stringsAsFactors = FALSE)
train_x <- read.table("./data/UCI HAR Dataset/train/X_train.txt",
                      strip.white = TRUE, stringsAsFactors = FALSE)
test_y  <- read.table("./data/UCI HAR Dataset/test/y_test.txt",
                      strip.white = TRUE, stringsAsFactors = FALSE)
train_y <- read.table("./data/UCI HAR Dataset/train/y_train.txt",
                      strip.white = TRUE, stringsAsFactors = FALSE)
features <- read.table("./data/UCI HAR Dataset/features.txt",
                      strip.white = TRUE, stringsAsFactors = FALSE)[,2]
subjecttrain <- tbl_df(read.table("./data/UCI HAR Dataset/train/subject_train.txt", 
                      stringsAsFactors = FALSE))
subjecttest <- tbl_df(read.table("./data/UCI HAR Dataset/test/subject_test.txt", 
                      stringsAsFactors = FALSE))


# 1. merge the training and the test sets to create one data set
all_x <- tbl_df(rbind (test_x, train_x))
names(all_x) <- features

# 2. Mean and standard deviation
data <- tbl_df(all_x[,grepl("std|mean",colnames(all_x))])

# 3. Use descriptive activity names

activity <- tbl_df(rbind (train_y, test_y))
colnames(activity)<- "Activity"

activity$Activity <- gsub ("1", "WALKING",activity$Activity)
activity$Activity <- gsub ("2", "WALKING_UPSTAIRS", activity$Activity)
activity$Activity <- gsub ("3", "WALKING_DOWNSTAIRS", activity$Activity)
activity$Activity <- gsub ("4", "SITTING", activity$Activity)
activity$Activity <- gsub ("5", "STANDING", activity$Activity)
activity$Activity <- gsub ("6", "LAYING", activity$Activity)

#4. Appropriately label the data set with descriptive variable names.
names(data) <- gsub("BodyBody", "Body",names(data))
names(data) <- gsub("\\()","",names(data))
names(data) <- gsub("-", "",names(data))

#5. Create a second, independent tidy data set with the average of each variable for each activity and each subject.
data <- mutate(data, average = rowMeans(data))
subject <- tbl_df(rbind (subjecttrain, subjecttest))
colnames(subject) <- "Subject"
data <- tbl_df(cbind(cbind(subject,activity),data))

write.table(data,"tidydata.txt", row.name = FALSE)
