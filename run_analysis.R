# This script (run_analysis.R) will do the following: 
# 1. Download the data from the weblink: "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
# 2. Merges the training and the test sets to create one data set.
# 3. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 4. Uses descriptive activity names to name the activities in the data set
# 5. Appropriately labels the data set with descriptive variable names. 
# 6. From the data set in step 5, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# ==========
# by Y. Ada Zhan (11/20/2014)

# step 1.
# get the file url
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# create a temporary directory
td = tempdir()
# create the placeholder file
tf = tempfile(tempdir=td, fileext=".zip")
# download the file into the placeholder file 
download.file(fileUrl, tf, method = "curl")
# get all file names inside of the .zip file
file_ls <- as.character(unzip(tf,list = TRUE)$Name)
# read the needed files
## training dataset
train <- read.table(unz(tf,file_ls[31]))
## activity labels for training dataset
ytrain <- read.table(unz(tf,file_ls[32]))
## subjects in training dataset
subjecttrain <- read.table(unz(tf,file_ls[30]))
## test dataset
test <- read.table(unz(tf,file_ls[17]))
## activity labels for test dataset
ytest <- read.table(unz(tf,file_ls[18]))
## subjects in test dataset
subjecttest <- read.table(unz(tf,file_ls[16]))
## feature list / variable names for datasets collected
features <- read.table(unz(tf,file_ls[2]))
## activity labels code book
labels <- read.table(unz(tf,file_ls[1]))
# break the link and delete the temporary file
unlink(tf)

# step 2.
# merge training and test datasets
merged <- rbind(train, test)
# delete "train" and "test"
rm("train")
rm("test")

# step 3.
# get the row numbers that contain "mean()" in "features"
mean <- which(grepl("mean()", features$V2))
# get the row numbers that contain "std()" in "features"
std <- which(grepl("std()", features$V2))
# merge "mean" and "std" to form a index list for features
## make "mean" and "std" one column table
mean = data.frame(mean)
std = data.frame(std)
## write "mean" and "std" the same column name so they can be "rbind"
colnames(mean) = c("colindex")
colnames(std) = c("colindex")
## build the list of features
colindex <- rbind(mean,std)
## make the list ascending
colindex <- sort(colindex$colindex)
# extract the mean and std from the dataset
subset <- merged[,colindex]

# step 4.
# get the descriptive activty list for training and test data
labelstrain <- data.frame(labels[ytrain$V1,2])
labelstest <- data.frame(labels[ytest$V1,2])
colnames(labelstrain) = c("activity_labels")
colnames(labelstest) = c("activity_labels")
# merge "labelstrain" and "labelstest" to form a list of acitivity labels for "subset" dataset
ylabels <- rbind(labelstrain, labelstest)
# label the activity with descritpive labels
subset <- cbind(subset,ylabels)

# step 5.
# note that this script will use the variable names designed by the data creators
# get the variable names from "features"
xlabels <- features[colindex,2]
# assign the colnames to the "subset"
colnames(subset) = c(xlabels, "activity_labels")

# step 6.
# create the subject list to be used later
subject <- rbind(subjecttrain,subjecttest)
colnames(subject) = c("subject")
# integrate subject into subset
subset <- cbind(sbuset,subject)
# make an independent tidy dataset as required
## get the number of columns that will be get averaged
n = data.frame(dim(subset))
num = n[2,] - 2
## calculate the mean values for each activity and each subject
tidyDS <- aggregate(subset[,1:num], by=list(subset=subset$subject,activity=subset$activity_labels), mean)
# write the tidy dataset to .txt
write.table(tidyDS,"~/Desktop/tidyDS.txt",sep = " ",row.names = FALSE)

#===The end===