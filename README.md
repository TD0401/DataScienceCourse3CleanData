---
title: "TidyData"
author: "Trina Dey"
date: "21/05/2020"
output: html_document
---

This repository contains code for reading, cleaning, filtering, structuring and aggregating data as part of Data Science Specialization Course 3. Please read the description below about the project. Please read CodeBook.md for futher info related to the data output generated. Files contained in this project - 

a. README.md to describe the project.
b. load_data.R to download the input files.
c. run_analysis.R to run analysis on the files.
d. CodeBook.md to describe the output files.

**Note**: we have not uploaded any data file because all of them can be generated on the go by running the script. However as part of code completion, only output file has been uploaded.


### Getting the Data

The data that has been provided as part of the assignment contains training and test data captured from people wearing smart devices. The data is captured through the in-built accelerometer and gyroscope of the device. There are multiple data points captured through these device along X, Y, Z axis. These data points has been named and some statistical functions applied over these data and then is stored in the text files. Read further about the input data in README.txt within the data downloaded when you run the analysis. The data is downloaded from the source https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip.

As part of this project two scripts has been created 

a. load_data.R
b. run_analysis.R

load_data.R performs following operations - 

a. Downloads the zip from the url mentioned and stores the zip with name *SamsungData.zip* in a folder named *data* within your working directory. This will download data only when it cant find the zip file. This stops the program to download the data multiple times. 

b. Unzips the SamsungData.zip into *SamsungData* in the *data* folder. Also since unzipping takes time, it's also unzipped only once. 

If by any chance you corrupt any of the data files, you can simply delete the *SamsungData* Folder inside the data folder and run the analysis again or run the load_data function again and it will unzip the fresh data again into the folders.

### Running the analysis
run_analysis.R sources the load_data.R file. It completes the five steps mentioned in the assigment. But before running the analysis we need to do some preprocessing. There are three types of data present in the data downloaded viz. Activity Data, Subject Ids, Measurement data. All three data relates to each other hence these three data need to be merged. Also, there is some training data and some test data that needs to be merged. 

##### Preprocessing Steps
Data has been read into data frames from csv files. The data files read into data frames are -  

a. *train_data* - Training data has been read from X_train.txt file.
b. *test_data* - Test data has been read from X_test.txt file.
c. *train_labels* - Training Activity Data has been read from y_train.txt file.
d. *test_labels* - Test Activity Data has been read from y_test.txt file. 
e. *activity_labels* - Data in training and test activity labels contains only label id. The defintion of these label ids is read from activity_labels.txt file.
f. *features* - Data in training and test set doesnt have any header. The vector in feature.txt file is the rows in data files.
g. *train_subjects* - Data for training Subjects has been read from subjects_train.txt file.
h. *test_subjects* - Data for test Subjects has been read from subjects_test.txt file.

Second thing done is provided some column names to the data frames since none of the files had header names defined in it. 

a. Data Frames *train_labels* and *test_labels* have only one column for activity id. 
b. Data Frame *activity_labels* contains the relation between activity id and activity name.
c. Data Frame *train_subjects* and *test_subjects* have only one column for subject id.
d. Data Frame *train_data* and *test_data* have many columns and each row in these frames is a vector in *features* data frame. So we mapped them and named the columns. Note that a lot of columns will not be named as the no. of columns are more than the features that exist. But we will not need them so we are not currently naming them and leaving them as is.


##### Analysis of the data frames 
1. First step is to merge the data. So we did these two processes - 

a. Merged each measurement data with their corresponding activity data and subject data using *cbind()* function. Note that *cbind* functions throws an error if the number of rows mismatches between the data frames. Since the data for which we have no subject id or activity is of no use to us, so we have truncated the *train_data* and *test_data* set to number of rows of *test_labels* data frame has.

```
    test_data <- cbind(test_data[1:nrow(test_labels),] , test_labels , test_subjects)
    train_data <- cbind(train_data[1:nrow(train_labels),] , train_labels , train_subjects)
    
```

b. Merged the training and test data frames using *rbind()*. Since the number of columns were mismatched this would also throw an error but a lot of columns has no names so we dont need them. So we truncated the rows of columns to number of rows features have and the last two columns we added in the above step - activity and subjectId.

```
    last_col_test <- ncol(test_data)
    last_col_train <- ncol(train_data)
    merged_data <- rbind (train_data[,c(1:nrow(features) , last_col_train -1 , last_col_train)] 
                          , test_data [,c(1:nrow(features),last_col_test -1 , last_col_test)])

```

**Note**: We didnt use the merge function because a lot of columns were not named and their names were marked NA. So merge function would have merged the NA named columns as well which we didnt need. 

2. Second step was to keep only mean and standard deviation columns. So we used *grep* function to find the column name index which matched with "mean" and "std". But along with these we needed the last two columns as well for activity and subject id. So we created a vector and took out all rows but only selected columns.

```
    mean_columns <- grep("mean", names(merged_data))
    std_columns <- grep("std", names(merged_data))
    last_col <- ncol(merged_data)
    req_columns <- append(mean_columns, std_columns )
    merged_data <- merged_data[,c(req_columns,last_col-1, last_col)]

```

**Note**: We created a merged_data which will take additional memory ideally we should free up the memory by updating the train_data itself while merging and freeing up the test_data data frame. For large data set efficiency would matter. But for now we kept the data set as is.

3. Third step was to provide descriptive name for acitivity id in the data frame. So used *mutate* function from package *dplyr* and updated the existing column of *merged_data* by mapping the id in each row within that column to the row number of *activity_labels* thereby fetching the name from *activity_labels* data frame.

```
    merged_data <- mutate(merged_data, activity = activity_labels$activityName[activity])
    
```
4. Fourth Step is to provide some meaningful name to the columns of the merged data set. Since we already named our columns from the features vector, it doesn't make sense to rename them using some different mapping. But a lot of column names can contain . or - or () which are unnecessary. We can simply replace these by _ for better readability by using gsub function. Note that we will use a regex so that multiple such special characters can be removed together.

```
    colnames(merged_data) <- gsub("[-().]+","_",colnames(merged_data))
    colnames(merged_data) <- gsub("^_|_$","",colnames(merged_data))

```

5. Final Step is to find the average of each measurement by activity name and subject id. So we used *group_by* , *summarise_if* from package *dplyr* and chained them to create our final data which we then wrote in the output.csv file in data folder.

```
    final_data <-  merged_data %>% group_by(activity, subjectId) %>% summarise_if(is.numeric, mean, na.rm=TRUE) 
    write.table(final_data , "data/output.csv", col.names=TRUE, row.names= FALSE,na= "NA" , sep = ",")

```


