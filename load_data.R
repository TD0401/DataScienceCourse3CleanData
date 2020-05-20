## This function downloads the data for activity monitors from a specified url

downloaddata <- function(){
    if(!file.exists("data")){
        dir.create("data")
    }
    file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    
    ##only downloads if the zip is not downloaded already
    if(!file.exists("data/SamsungData.zip")){
        download.file(file_url, "data/SamsungData.zip" , method ="curl")
    }
    
    ##only unzips if not previously unzipped
    if(!file.exists("data/SamsungData") & file.exists("data/SamsungData.zip")){
        unzip("data/SamsungData.zip",exdir = "data/SamsungData")
    }
}
