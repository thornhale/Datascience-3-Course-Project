How to Use:
===========

To perform the data analysis you need to perform the following operation:

source('~/YOUR/DIRECTORY/PATH/run_analysis.R')

run_analysis.R contains the following functions:

dataMerger
strCount
extractMeansAndStdColumns
produceCleanDataSet
runAnalysis

To produce the output file specified in item 5 of the course project simply run:

runAnalysis()

This will produce a file named 'runAnalysis_results.txt' in the same folder as the current working directory.

Assumptions:
============

The script requires that the following files be in the same directory as run_analysis.R:

X_test.txt
X_train.txt
Y_test.txt
Y_train.txt
subject_test.txt
subject_train.txt
activity_labels.txt
features.txt

For this project, it wasn't clear what was meant by 'mean'. Looking through the file, I discovered column names that explicitly had mean() in the name or meanFreq(). This is what I assume is desired.

Structure of Output:
====================

The output file contains columns that that either contain mean(), meanFreq() or std() in the column name of the original input. The last 3 columns are named "Subject", "Activity", and "ActivityID". These last 3 columns are what's used to calculate means for each variable.