#Merge_duplicates_functions.R
#Contains all functions to be used by auto_merge_duplicates.R

#Obtains field's relative priority for that source (i.e., whether other sources should be relied on for that field instead)
#returns a number indicating the priority
get_source_field_priority <- function(source_name, field_name) {
  p <- subset(sfp, sfp$"Source Name" == source_name)[field_name]
  if (nrow(p) == 0) {
    p <- 0
  }
  return(p)
}

# Merge duplicate rows
#  First row will keep all values but "flag" columns
#  For "flag" columns, rows will be compared in pairs
#  If both members have same value for same flag column, merge without issue
#  Otherwise, "Flag" columns will be determined by comparing their source field prioritizations 
#   Flag column value for Row with higher source field priority will be kept
#   If both rows have same source field priority for that flag column, first row's value will be kept
#  After all members in pair have been merged, the merged row will be compared with the next row, if another row exists
#  Otherwise, return merged row
merge_duplicates <- function(rows_to_merge, source_field_prioritization) {
  #browser() #Browser function for debugging
  flag_columns <- colnames(source_field_prioritization)[-1]   #Get names of flag columns(excluding source field column) 
  if(!is.data.frame((rows_to_merge))) {
    stop("Argument for 'merge_duplicates' must be a data frame")
  }
  primary <- rows_to_merge[1,]                      #Set first row as primary row
  id_concat <- primary$id                           #Add first of concatenated ID's to variable
  while (nrow(rows_to_merge) > 1) {                 #As long as there are additional rows... 
    rows_to_merge <- rows_to_merge[-c(1),]          #Remove row most recently added/merged into primary
    #Iterate through all columns and, if primary field is NA but compared field is not, replace primary field with compared
    for(i in names(rows_to_merge)){
      if (is.na(primary[[i]]) && !is.na(rows_to_merge[c(1),][[i]])) {
        primary[[i]] <- rows_to_merge[c(1),][[i]]
      }
    }
    ps <- primary$source_file                        #Get primary source
    cs <- rows_to_merge[c(1),]$source_file           #Get source of compared row
    id_concat <- paste(id_concat, rows_to_merge[c(1),]$id, sep="_")
    for (col in flag_columns) {                     #Iterate through all flag columns
      pv <- as.numeric(primary[col])                #Get value of primary row column
      cv <- as.numeric(rows_to_merge[c(1),][col])   #Get value of compared row column
      if (!is.na(pv) && !is.na(cv) && (pv != cv)) { #If values are the same (or at least one value is NA), ignore. Otherwise...
        pp <- get_source_field_priority(ps, col)    #Get primary's field priority
        cp <- get_source_field_priority(cs, col)    #Get compared's field priority
        if(pp < cp) {                               #ONLY IF primary's priority is less than compared's priority...
          primary[col] = cv                         #Set primary's value to compared's value 
        }
      }
    }
  }
  primary$id <- id_concat
  primary$source_org <- paste("M_", primary$source_org)
  primary$source_file <- paste("M_", primary$source_file)
  primary$group_id <- NA
  return(primary)
}

merge_all_duplicates_in_dataframe <- function(df, source_field_prioritization) {
  #Collect all distinct group_id values
  group_ids <- unique(df$group_id)
  group_ids <- group_ids[!is.na(group_ids)] #Remove the NA value
  #For each of these group_id values, get ids for all rows whose group_id matches that group_id
  for (i in 1:length(group_ids)) {
    dup_rows <- subset(df, group_id %in% group_ids[i])
    result <- merge_duplicates(dup_rows, sfp)
    result$merged_record <- '1'
    df <- rbind(df, result)
  }
  #Then remove id's from md that were in dup rows
  df <- df[which(!df$group_id %in% group_ids ),]
  #Then merge duplicates with those ids.
  return(df)
}