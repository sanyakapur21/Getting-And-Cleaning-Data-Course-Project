
#Prepare the libraries
library(reshape2)

#Obtain datset from web
rDtDir <- "./rawData"
DataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rDataFilename <- "rawData.zip"
rDataFunction <- paste(rDtDir, "/", "rawData.zip", sep = "")
Dirdata <- "./data"

if (!file.exists(rDtDir)) {
  dir.create(rDtDir)
  download.file(url = DataUrl, destfile = rDataFunction)
}
if (!file.exists(Dirdata)) {
  dir.create(Dirdata)
  unzip(zipfile = rDataFunction, exdir = Dirdata)
}


#Combine{train, test} dataset
#train data
x_tr<- read.table(paste(sep = "", Dirdata, "/UCI HAR Dataset/train/X_train.txt"))
y_tr<- read.table(paste(sep = "", Dirdata, "/UCI HAR Dataset/train/Y_train.txt"))
s_tr<- read.table(paste(sep = "", Dirdata, "/UCI HAR Dataset/train/subject_train.txt"))

#test data
x_test <- read.table(paste(sep = "", Dirdata, "/UCI HAR Dataset/test/X_test.txt"))
y_test <- read.table(paste(sep = "", Dirdata, "/UCI HAR Dataset/test/Y_test.txt"))
s_test <- read.table(paste(sep = "", Dirdata, "/UCI HAR Dataset/test/subject_test.txt"))

#combine {train, test} data
x_data <- rbind(x_tr, x_test)
y_data <- rbind(y_tr, y_test)
s_data <- rbind(s_tr, s_test)


#load feature and activity informations
#feature information
feature <- read.table(paste(sep = "", Dirdata, "/UCI HAR Dataset/features.txt"))

#activity labels
a_lbl <- read.table(paste(sep = "", Dirdata, "/UCI HAR Dataset/activity_labels.txt"))
a_lbl[,2] <- as.character(a_lbl[,2])

#extract feature columns and names named 'mean, std'
selectedCols <- grep("-(mean|std).*", as.character(feature[,2]))
selectedColNames <- feature[selectedCols, 2]
selectedColNames <- gsub("-mean", "Mean", selectedColNames)
selectedColNames <- gsub("-std", "Std", selectedColNames)
selectedColNames <- gsub("[-()]", "", selectedColNames)


#extract data by columns and use descriptive name
x_data <- x_data[selectedCols]
TotalData <- cbind(s_data, y_data, x_data)
colnames(TotalData) <- c("Subject", "Activity", selectedColNames)

TotalData$Activity <- factor(TotalData$Activity, levels = a_lbl[,1], labels = a_lbl[,2])
TotalData$Subject <- as.factor(TotalData$Subject)


#Produce tidy dataset
meltData <- melt(TotalData, id = c("Subject", "Activity"))
tidyData <- dcast(meltData, Subject + Activity ~ variable, mean)

write.table(tidyData, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)