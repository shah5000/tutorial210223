# https://stackoverflow.com/questions/27368195/r-ts-with-missing-values
#https://www.stat.berkeley.edu/~s133/dates.html
library(zoo)
library(arrow)
#library(chron)
#library(lubridate)

allDates <-seq(as.POSIXct("2019-1-1 00:00:00"), as.POSIXct("2019-9-30 23:59:00"), by = "min")
timestampdf <- data.frame(dataTimestamp=allDates)
timestampdf$dataTimestamp <- as.character(timestampdf$dataTimestamp)

flist <- list.files(path = ".", pattern = ".parquet", 
                    all.files = FALSE,full.names = FALSE, 
                    recursive = TRUE,ignore.case = FALSE, 
                    include.dirs = FALSE, no.. = FALSE)



for (x in length(flist)) {
  df <- read_parquet(flist[x],as_data_frame = TRUE)
  rowindex1 <- which(df$attributeName == "upsEfficiency")
  rowindex2 <- which(df$attributeName == "upsOutputActivePower")
  UEFFdf <- rbind(df[rowindex1,])
  UOAPdf <- rbind(df[rowindex2,])
}

#for (x in length(flist)) {
#  df <- read_parquet(flist[x],as_data_frame = TRUE)
#  rowindex <- which(df$attributeName == "upsOutputActivePower")
#  UOAPdf <- rbind(df[rowindex,])
#}



#tempdf <- UEFFdf
#tempdf$dataTimestamp <- strptime(tempdf[,3],format = "%Y-%m-%d %H:%M")
#tempdf <- tempdf[,2:3]
#tempdf$dataTimestamp <- as.character(tempdf$dataTimestamp)
#tempdf$attributeValue <- as.numeric(tempdf$attributeValue)


UEFFdf$dataTimestamp <- strptime(UEFFdf[,3],format = "%Y-%m-%d %H:%M")
UEFFdf <- UEFFdf[,2:3]
UEFFdf$dataTimestamp <- as.character(UEFFdf$dataTimestamp)
UEFFdf$attributeValue <- as.numeric(UEFFdf$attributeValue)

mergedf <- merge(timestampdf,UEFFdf, 
                 by.x = "dataTimestamp",by.y = "dataTimestamp",all.x = TRUE)

if ( is.na( mergedf$attributeValue[1] ) ) {
  mergedf$attributeValue[1] <- mean( mergedf$attributeValue, na.rm = T )
}
mergedf$attributeValue <- na.locf(mergedf$attributeValue)


adf <- cbind(mergedf)
names(adf)[2] <- "upsEfficiency"


UOAPdf$dataTimestamp <- strptime(UOAPdf[,3],"%Y-%m-%d %H:%M")
UOAPdf <- UOAPdf[,2:3]
UOAPdf$dataTimestamp <- as.character(UOAPdf$dataTimestamp)
UOAPdf$attributeValue <- as.numeric(UOAPdf$attributeValue)

mergedf <- merge(timestampdf,UOAPdf, 
                 by.x = "dataTimestamp",by.y = "dataTimestamp",all.x = TRUE)

if ( is.na( mergedf$attributeValue[1] ) ) {
  mergedf$attributeValue[1] <- mean( mergedf$attributeValue, na.rm = T )
}
mergedf$attributeValue <- na.locf(mergedf$attributeValue)

adf <- cbind(adf, mergedf$attributeValue) # check why cbind tranforms column to factor
names(adf)[3] <- "upsOutputActivePower"

cor(adf$upsOutputActivePower,adf$upsEfficiency)

plot(adf$upsOutputActivePower,adf$upsEfficiency)

