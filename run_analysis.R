
#############################################################################
############################### LOAD LIBRARIES ##############################
#############################################################################

if (!require(data.table)) { install.packages("data.table") }
if (!require(reshape2)) { install.packages("reshape2")}

library(data.table)
library(reshape2)


#############################################################################
################################ COLUMN NAMES ###############################
#############################################################################

# Read the activity labels
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")[, 2]


# Read the features
features <- read.table("UCI HAR Dataset/features.txt")[, 2]

# Get the mean and std feature names only
meanAndStdFeatures <- grepl("mean|std", features)


#############################################################################
################################# TRAIN DATA ################################
#############################################################################

# Read the train data

trainLabels <- read.table("UCI HAR Dataset/train/y_train.txt")
trainSet <- read.table("UCI HAR Dataset/train/x_train.txt")
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")

# Get the training set with column names and only mean and std data
names(trainSet) <- features
meanAndStdTrainSet <- trainSet[meanAndStdFeatures]

# Get the activity Label of the training labels
trainLabels[, 2] <- activityLabels[trainLabels[, 1]]
names(trainLabels) <- c("activityId", 'activityName')

# Get the subject id column a title
names(subjectTrain) <- "subjectId"

# Create a source column to know from where does the data comes from
source <- matrix("train", nrow = nrow(subjectTrain), ncol = 1)
names(source) <- "source"

# Get the complete training table
trainData <- cbind(subjectTrain, source, trainLabels, meanAndStdTrainSet)


#############################################################################
################################## TEST DATA ################################
#############################################################################

# Read the test data

testLabels <- read.table("UCI HAR Dataset/test/y_test.txt")
testSet <- read.table("UCI HAR Dataset/test/x_test.txt")
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt")

# Get the training set with column names and only mean and std data
names(testSet) <- features
meanAndStdTestSet <- testSet[meanAndStdFeatures]

# Get the activity Label of the training labels
testLabels[, 2] <- activityLabels[testLabels[, 1]]
names(testLabels) <- c("activityId", 'activityName')

# Get the subject id column a title
names(subjectTest) <- "subjectId"

# Create a source column to know from where does the data comes from
source <- matrix("test", nrow = nrow(subjectTest), ncol = 1)
names(source) <- "source"

# Get the complete training table
testData <- cbind(subjectTest, source, testLabels, meanAndStdTestSet)

#############################################################################
########################## MERGE TRAIN AND TEST DATA ########################
#############################################################################

tidyData <- rbind(trainData, testData)

#############################################################################
##################### VARIABLES AVG PER USER AND ACTIVITY ###################
#############################################################################


columnsToKeep <- c("subjectId", "activityId", "activityName", "source")
dataToGroup <- setdiff(colnames(tidyData), columnsToKeep)
meltData <- melt(tidyData, id = columnsToKeep, measure.vars = dataToGroup)

summmarizedTidyData <- dcast(meltData, subjectId+activityName ~ variable, mean)

#############################################################################
############################# CLEAN UP ENVIRONMENT ##########################
#############################################################################

rm(trainLabels, trainSet, subjectTrain, meanAndStdTrainSet)
rm(testLabels, testSet, subjectTest, meanAndStdTestSet)
rm(source, activityLabels, columnsToKeep, dataToGroup, features, meanAndStdFeatures)
rm(meltData)

