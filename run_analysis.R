## This is the inscription list to the Week 4's Project

## 1. Open RStudio with R version 4.2.0

## 2. Get the files after copy-pasting the URL
if(!file.exists("./data")){dir.create("./data")}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "./data/Galaxy.zip", method = "curl")
unzip("Galaxy.zip", exdir = "./Galaxy")
setwd(dir = "./data/Galaxy/UCI HAR Dataset")

## 3. Using packages
library(data.table)
library(dplyr)

## 4. Get and read data
features <- read.table("./features.txt")
actlabels <- read.table("./activity_labels.txt")

IDtest <- read.table("./test/subject_test.txt")
acttest <- read.table("./test/y_test.txt")
feattest <- read.table("./test/X_test.txt")

IDtrain <- read.table("./train/subject_train.txt")
acttrain <- read.table("./train/y_train.txt")
feattrain <- read.table("./train/X_train.txt")

## 5. Merge the training and the test sets to create one data set = STEP 1
### 5.a. Bind rows of the different data sets

ID <- rbind(IDtest, IDtrain)
act <- rbind(acttest, acttrain)
feat <- rbind(feattest, feattrain)

### 5.b. Name the columns

colnames(feat) <- t(features[2])
colnames(act) <- "Activity"
colnames(ID) <- "Patient"

### 5.c. Bind columns

Data_in_1 <- cbind(ID, act, feat)

## 6. Extract only the measurements on the mean and standard deviation 
## for each measurement = STEP 2 

### 6.a. Search column which have *mean* or *std* in name

Col_with_mean_std <- grep(".*[Mm]ean.*|.*[Ss]td.*", names(Data_in_1), ignore.case = TRUE)

### 6.b. Extract the final table

Data_with_mean_std <- Data_in_1[, c(1, 2, Col_with_mean_std)]

## 7. Use descriptive activity names to name the activities in the data set = STEP 3

for(i in 1:6){
  Data_with_mean_std$Activity[Data_with_mean_std$Activity == i] <- as.character(actlabels[i, 2])
}

## 8. Appropriately label the data set with descriptive variable names. = STEP 4
### 8.a. Look at the names 
names(Data_with_mean_std)

### 8.b. Change them

names(Data_with_mean_std) <- gsub("Acc", "Accelerometer", names(Data_with_mean_std))
names(Data_with_mean_std) <- gsub("Gyro", "Gyroscope", names(Data_with_mean_std))
names(Data_with_mean_std) <- gsub("BodyBody", "Body", names(Data_with_mean_std))
names(Data_with_mean_std) <- gsub("Mag", "Magnitude", names(Data_with_mean_std))
names(Data_with_mean_std) <- gsub("^t", "Time", names(Data_with_mean_std))
names(Data_with_mean_std) <- gsub("^f", "Frequency", names(Data_with_mean_std))
names(Data_with_mean_std) <- gsub("tBody", "TimeBody", names(Data_with_mean_std))
names(Data_with_mean_std) <- gsub("-mean()", "Mean", names(Data_with_mean_std), ignore.case = TRUE)
names(Data_with_mean_std) <- gsub("-std()", "StandardDeviation", names(Data_with_mean_std), ignore.case = TRUE)
names(Data_with_mean_std) <- gsub("-freq()", "Frequency", names(Data_with_mean_std), ignore.case = TRUE)

## 9. From the data set in step 4, creates a second, independent tidy data set 
## with the average of each variable for each activity and each subject.= STEP 5

### 9.a. Transform in data.table before using dplyr

Data_in_Table <- data.table(Data_with_mean_std)

### 9.b. Create a new data set 

tidy <- aggregate(. ~Patient + Activity, Data_in_Table, mean)
tidy <- tidy[order(tidy$Patient,tidy$Activity),]
write.table(tidy, file = "Finished_Work.txt", row.names = FALSE)

## It was hard...