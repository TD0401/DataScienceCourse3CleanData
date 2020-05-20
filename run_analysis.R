## This function reads the data from some text file, cleans them, merges them and produce average of some columns and 
## stores them in a file named output.txt

run_analysis <- function() {
    source("load_data.R")
    downloaddata()
    library(dplyr)
    
    ## pre processing begins
    #reading train and test data 
    train_data <- tbl_df(read.csv("data/SamsungData/UCI\ HAR\ Dataset/train/X_train.txt" , sep=" ", header = FALSE))
    test_data <- read.csv("data/SamsungData/UCI\ HAR\ Dataset/test/X_test.txt", sep = " ", header = FALSE)
    features <-  read.csv("data/SamsungData/UCI\ HAR\ Dataset/features.txt" , sep=" ", header = FALSE)
    
    #reading labels data
    train_labels <- read.csv("data/SamsungData/UCI\ HAR\ Dataset/train/y_train.txt" , sep=" ", header = FALSE)
    test_labels <- read.csv("data/SamsungData/UCI\ HAR\ Dataset/test/y_test.txt", sep = " ", header = FALSE)
    activity_labels <- read.csv("data/SamsungData/UCI\ HAR\ Dataset/activity_labels.txt" , sep=" ", header = FALSE)
    
    #subjects data
    train_subjects <- tbl_df(read.csv("data/SamsungData/UCI\ HAR\ Dataset/train/subject_train.txt" , sep=" ", header = FALSE))
    test_subjects <- read.csv("data/SamsungData/UCI\ HAR\ Dataset/test/subject_test.txt", sep = " ", header = FALSE)
    
    #setting some column names
    colnames(test_labels) <- c("activity")
    colnames(train_labels) <- c("activity")
    colnames(activity_labels) <- c("activityId", "activityName")
    colnames(train_subjects) <- c("subjectId")
    colnames(test_subjects) <- c("subjectId")
    colnames(train_data) <- c(features[,2])
    colnames(test_data) <- c(features[,2])
    
    ## preprocessing ends
    
    #Step 1 part A - merging test/train data with their test/train labels and subjects
    #Data which has no activity is not of any use, so discarding by taking those many rows from data 
    #as many present in the labels
    #note that test_labels and test_subjects has same no of rows
    test_data <- cbind(test_data[1:nrow(test_labels),] , test_labels , test_subjects)
    train_data <- cbind(train_data[1:nrow(train_labels),] , train_labels , train_subjects)
    
    #Step 1 part B - merging train and test data with columns same as features length and last two columns activity and subject id
    last_col_test <- ncol(test_data)
    last_col_train <- ncol(train_data)
    merged_data <- rbind (train_data[,c(1:nrow(features) , last_col_train -1 , last_col_train)] 
                          , test_data [,c(1:nrow(features),last_col_test -1 , last_col_test)])
    
    
    #Step 2 keeping only mean and std deviation columns along with activity and subjectid 
    mean_columns <- grep("mean", names(merged_data))
    std_columns <- grep("std", names(merged_data))
    last_col <- ncol(merged_data)
    req_columns <- append(mean_columns, std_columns )
    merged_data <- merged_data[,c(req_columns,last_col-1, last_col)]
    
    #Step 3 providing descriptive names to the activity in the table
    merged_data <- mutate(merged_data, activity = activity_labels$activityName[activity])
    
    #Step 4 appropriate names for each column in merged_data from features vector is already present
    # replacing some special characters with _ for better readability. Here ().:- has been removed but other 
    #special characters can also be removed if need be
    colnames(merged_data) <- gsub("[-().]+","_",colnames(merged_data))
    colnames(merged_data) <- gsub("^_|_$","",colnames(merged_data))
    
    #Step5 finding average of all by subject id and activity and writing into a file
    final_data <-  merged_data %>% group_by(activity, subjectId) %>% summarise_if(is.numeric, mean, na.rm=TRUE) 
    write.table(final_data , "data/output.csv", col.names=TRUE, row.names= FALSE,na= "NA" , sep = ",")
}










