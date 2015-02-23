library(dplyr)
library(tidyr)

dataMerger <- function() {  
  #Merge x_test, x_training, y_test, y_training, subject_test, and subject_train
  #into one dataframe. Features will serve as lables for x datasets.
  x_test <- read.table('./x_test.txt')
  x_train <- read.table('./x_train.txt')
  mergedXFrame <- rbind(x_test, x_train)
  #Still need to add column names
  features <- read.table('./features.txt')
  colnames(mergedXFrame) <- features[[2]]
  y_test <- read.table('./y_test.txt')
  y_train <- read.table('./y_train.txt')
  mergedYFrame <- rbind(y_test, y_train)
  subject_test <- read.table('./subject_test.txt')
  subject_train <- read.table('./subject_train.txt')
  activityLabels <- read.table('./activity_labels.txt')
  mergedSubject <- rbind(subject_test, subject_train)
  mergedXFrame['ActivityID'] <- mergedYFrame[[1]]
  mergedXFrame['Subject'] <- mergedSubject[[1]]
  # Create new column and prepollated with a placeholder activity which will
  # be replaced subsequently.
  mergedXFrame['Activity'] <- c('someAct')
  for(i in 1:length(activity_labels[,2])) {
    activity <- as.character(activityLabels[i,2])
    rowsToMod <- mergedXFrame['ActivityID'] == activityLabels[i,1]
    if(any(rowsToMod) == TRUE) {
      mergedXFrame[rowsToMod, 'Activity'] <- c(activity)      
    }
  }
  mergedXFrame
}

strcount <- function(inputString, pattern, split){
  # Function counts occurance of a pattern in a string.
  #
  # Args:
  #   inputString (string): String to search.
  #   pattern (string): substring to look for and count.
  #   split(string): substring of charcters that are used to split string up.
  #
  # Returns:
  #   Number of occurences for a given pattern.
  unlist(lapply(
    strsplit(inputString, split),
    function(z) na.omit(length(grep(pattern, z)))
  ))  
}

extractMeansAndStdColumns <- function(inputDataFrame) {
  # Method takes in a dataframe and creates a new dataframe that only 
  # contains colunsn with means and standard devations.
  # 
  # Args:
  #   inputDataFrame
  #
  # Returns:
  # outputDataFrame (data.Frame):
  #   Dataframe containing only columns with mean or std + activity + subject
  outputDataFrame <- data.frame(Subject=inputDataFrame['Subject'])
  outputDataFrame['Activity'] <- inputDataFrame['Activity']
  outputDataFrame['ActivityID'] <- inputDataFrame['ActivityID']
  for (i in 1:length((inputDataFrame[1,]))){
    meanPresent <- strcount(colnames(inputDataFrame[i]), "mean", "-")
    stdPresent <- strcount(colnames(inputDataFrame[i]), "std", "-")
    if (meanPresent > 0 | stdPresent > 0) {
      outputDataFrame[colnames(inputDataFrame[i])] <- inputDataFrame[[i]]
    }
  }
  outputDataFrame
}

produceCleanDataSet <- function(){
  # Method merges test and training data together and produces a new dataframe
  # containing only mean and standard deviation columns in addition to 
  # subject and activity information.
  mergedData <- dataMerger()
  cleanData <- extractMeansAndStdColumns(mergedData)
  cleanData
}

runAnalysis <- function(cleanedDataFrame){
  # Method produces a dataset containing averages of mean and std variables
  # for each activity and subject and outputs the results to a file.
  # 
  # Args:
  #   cleanedDataFrame (data.Frame):
  #     Cleaned data frame containing only subject, activity, and mean/std columns
  #
  # Return:
  #   outputDataFrame (data.Frame):
  #     Dataframe with the averages for each variable grouped by each 
  #     subject/activity.
  cleanData <- produceCleanDataSet()
  activity_labels <- read.table('./activity_labels.txt')
  completeOutput <- NULL
  for(subjectID in 1:30){
    for(activityID in 1:6){
      # Traverse each subject/activity combination and compute mean for
      # each variable.
      subjectActivityData <- filter(cleanData, Subject==subjectID & ActivityID==activityID)
      if (length(subjectActivityData[,2]>0)){
        partialResult <- sapply(subset(subjectActivityData, select = -c(Subject, ActivityID, Activity)), mean)
        if(length(completeOutput)==0){
          dim(partialResult) <- c(1,79)
          completeOutput <- data.frame(partialResult)
          completeOutput['Subject'] <- c(subjectID)
          completeOutput['Activity'] <- as.character(activity_labels[activityID, 2])
          completeOutput['ActivityID'] <- c(activityID)
        } else {
          partialResult['Subject'] <- c(subjectID)
          partialResult['Activity'] <- as.character(activity_labels[activityID, 2])          
          partialResult['ActivityID'] <- c(activityID)
          completeOutput <- rbind(completeOutput, partialResult)
        }
      }
    }
  }
    tempColNameList <- as.vector(colnames(subjectActivityData[,4:82]))
    colNameList <- append(tempColNameList, c('Subject', 'Activity', 'ActivityId'))
    colnames(completeOutput) <- colNameList
  write.table(completeOutput, file='./runAnalysis_results.txt', row.name=FALSE)
  completeOutput
}