library(Hmisc)
library(tidyverse)
library(stringr)
# function to differentiate address, i.e to put them under address field or split into street 1 and street 2 fields if exact addresses aren't given 

addr_fun <- function(addr_column) {
        df <- data.frame(matrix(nrow = length(addr_column),ncol = 3))
        names(df)<- c("address","street_one","street_two")
        df$address <- ifelse(str_detect(addr_column,"&"),NA,addr_column)
        df$street_one <- ifelse(str_detect(addr_column,"&"),sapply(strsplit(addr_column, " & "),"[", 1),NA)
        df$street_two <- ifelse(str_detect(addr_column,"&"),sapply(strsplit(addr_column, " & "),"[", 2),NA)
        return(df)
}


# function for extracting days and filling in their respective values (in boolean form) in a new dataframe with days as column names

days_fun <- function(days_column){
        days_abbr=c("M","TU","W","TH","F","SA","SU")   #character vector with abbreviated days
        days_df <- data.frame(matrix(nrow = length(days_column),ncol=7))                     ## creating a new df and then populating them as per the days column 
        names(days_df)<-c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")
        for (i in 1:length(days_column)) {
                
                if (!is.na(days_column[i])){
                        
                        if (str_detect(days_column[i],"-")) {      ##handle values with '-' 
                                tmp_days <- strsplit(days_column[i],"-")[[1]]   #extracting from and to day
                                tmp_from_day<- str_extract(tmp_days[1],"[A-Za-z]{1,2}")
                                tmp_to_day <- str_extract(tmp_days[2],"[:alpha:]{1,2}")
                                indx <- grep(tmp_from_day,days_abbr,ignore.case = T):grep(tmp_to_day,days_abbr,ignore.case = T)
                                days_df[i,indx]<-1  #assigning value as 1 to those days included
                }
                
                
                else if (str_detect(days_column[i],",")) {    ## handle values with ','
                                tmp_days <- strsplit(days_column[i],",")[[1]] %>% str_extract("[:alpha:][:alpha:]?")
                                indx<- which(days_abbr %in% tmp_days)
                                days_df[i,indx]<-1
                }
                }
                
                
        }
        return(days_df)
}

        
         
# function for extracting time intervals

time_fun<- function(time_interval_1,time_interval_2) {
        time_interval_1<- time_interval_1 %>% str_replace("noon","12:00 pm")
        time_interval_2 <- time_interval_2 %>% str_replace("noon","12:00 pm")
        n <-length(time_interval_1)
        time_df <- data.frame(matrix(nrow = n,ncol=4))
        names(time_df)<- c("open_time1","close_time1","open_time2","close_time2")
        for (i in 1:n){
                
              tmp_t1<-  unlist(strsplit(time_interval_1[i],"-"))        #extracting first time interval
             tmp_open_t1 <- tmp_t1[1]  %>% str_extract("\\d+:?\\d*")      #pulling open time
             tmp_close_t1 <-tmp_t1[2] %>% str_extract("\\d+:?\\d*")       #pulling closing time
             tmp_t1_am_pm <-  tmp_t1[2] %>% str_extract("[:alpha:]{2}")  #am or pm
             
             tmp_t2 <-  unlist(strsplit(time_interval_2[i],"-"))
             tmp_open_t2 <- tmp_t2[1]  %>% str_extract("\\d+:?\\d*")      #pulling open time
             tmp_close_t2 <-tmp_t2[2] %>% str_extract("\\d+:?\\d*")       #pulling closing time
             tmp_t2_close_ampm <- tmp_t2[2] %>% str_extract("[:alpha:]{2}")
             tmp_t2_open_ampm <-  tmp_t2[1] %>% str_extract("[:alpha:]{2}")
             tmp_t2_open_ampm <- ifelse(is.na(tmp_t2_open_ampm),tmp_t2_close_ampm,tmp_t2_open_ampm)
             
             
             if ((!is.na(time_interval_1[i])) & (!is.na(time_interval_2[i]))) {
                     time_df[i,1] <- paste(tmp_open_t1,toupper(tmp_t1_am_pm))
                     time_df[i,2] <- paste(tmp_close_t1,toupper(tmp_t1_am_pm))
                     time_df[i,3]<-paste(tmp_open_t2,toupper(tmp_t2_open_ampm))
                     time_df[i,4]<-paste(tmp_close_t2,toupper(tmp_t2_close_ampm))
             } 
             else if (is.na(time_interval_1[i]) & (!is.na(time_interval_2[i]))) {
                     time_df[i,1]<-paste(tmp_open_t2,toupper(tmp_t2_open_ampm))
                     time_df[i,2]<-paste(tmp_close_t2,toupper(tmp_t2_close_ampm))
             }
             else if (!is.na(time_interval_1[i])) {
                     time_df[i,1] <- paste(tmp_open_t1,toupper(tmp_t1_am_pm))
                     time_df[i,2] <- paste(tmp_close_t1,toupper(tmp_t1_am_pm))
             }
        
        }
        
        return(time_df)
}



