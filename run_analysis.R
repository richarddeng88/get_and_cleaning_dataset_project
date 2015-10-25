#get data
dir.create("data")
url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, "data/get_and_cleanding_data/dataset.zip")
unzip ("data/get_and_cleanding_data/dataset.zip",exdir="data/get_and_cleanding_data")

list.files("data/get_and_cleanding_data/UCI HAR Dataset", recursive=TRUE)

#read data
x_train<- read.table("data/get_and_cleanding_data/UCI HAR Dataset/train/X_train.txt")
x_test <-read.table("data/get_and_cleanding_data/UCI HAR Dataset/test/X_test.txt")
features <- rbind(x_train,x_test)

sub_train <- read.table("data/get_and_cleanding_data/UCI HAR Dataset/train/subject_train.txt")
sub_test <- read.table("data/get_and_cleanding_data/UCI HAR Dataset/test/subject_test.txt")
subject <- rbind(sub_train,sub_test)

act_train <- read.table("data/get_and_cleanding_data/UCI HAR Dataset/train/y_train.txt")
act_test <- read.table("data/get_and_cleanding_data/UCI HAR Dataset/test/y_test.txt")
activity <- rbind(act_train,act_test)

#set names
names(subject)<- c("subject")
names(activity) <- c("activity")

fnames<- read.table("data/get_and_cleanding_data/UCI HAR Dataset/features.txt")
names(features) <- fnames$V2

#merge columns of all three into one table "df"
tem <- cbind(subject,activity)
df <- cbind (features,tem)

#remove temparay objects
rm("act_test","act_train")
rm("sub_test","sub_train")
rm("tem","x_test","x_train")

##extract only measurement on mean and std
subdataFeaturesNames<-fnames$V2[grep("mean\\(\\)|std\\(\\)", fnames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
df<-subset(df,select=selectedNames)

##use descriptive activity lable to name the activity
act_labels <- read.table("data/get_and_cleanding_data/UCI HAR Dataset/activity_labels.txt")
df$activity <- factor(df$activity, act_labels$V1,labels = act_labels$V2)

##======== Appropriately labels the data set with descriptive variable names. ================
# prefix t is replaced by time
# Acc is replaced by Accelerometer
# Gyro is replaced by Gyroscope
# prefix f is replaced by frequency
# Mag is replaced by Magnitude
# BodyBody is replaced by Body
names(df) <- gsub("^t","time",names(df))
names(df) <- gsub("^f","frequency",names(df))
names(df) <- gsub("Acc","Accelerometer",names(df))
names(df) <- gsub("Gyro","Gyroscope",names(df))
names(df) <- gsub("Mag","Magnitude",names(df))
names(df) <- gsub("BodyBody","Body",names(df))

##From the data set in step 4, creates a second, independent tidy data set with the average 
##of each variable for each activity and each subject.
library(dplyr)
data<- aggregate(.~subject + activity, df, mean)
data<- data[order(data$subject,data$activity),]
write.table(data, file = "3. getting and cleaning data/tidydata.txt",row.name=FALSE)

# Prouduce Codebook
library(knitr)
knit2html("codebook.Rmd");