## this script orchestrates the EEM correction process ##
## goals: ##
## 1. identify the necessary files:
##### 1.a. raman
##### 1.b. blank EEM
##### 1.c. samples:UV/vis
##### 1.d. samples:EEM
##### 1.e. check n samples:UV/vis == n samples:EEM
##### 1.f. check EEM resolution
## 2. calculate raman peak area
## 3. correct blank
## 4. correct samples for(isample in 1:n){}
##### 4.a. calculate UV/vis IFC correction matrix
##### 4.b. IFC correction
##### 4.c. raman normalization
##### 4.d. blank correct
## 5. calculate indexes
## 6. plots
## 7. save data
##### 7.a. corrected EEMS to:
########## 7.a.i. project directory (working dir)
########## 7.a.ii. all EEMs directory
##### 7.b. indexes to:
########## 7.b.i. project directory (working dir)
########## 7.b.ii. all EEMs directory
##### 7.c. script run information text file (file that has summary information about how the script ran: time, how many samples, model version, any errors/warnings, etc.)

path <- commandArgs(trailingOnly = TRUE)


## copy script files to path ##
scriptFiles <- c('MAIN.R', 'ramanPeak_module.R', 'blankEEM_module.R', 'scriptCheck_module.R', 'userInput_config.txt')
## move all script files to path, then change wd ##
## after script finishes, delete script files ##

setwd(path)
print(getwd()) # testing

## functions to log script messages ##
log_file <- 'scriptRunLog.txt'
log_msg <- function(type, msg) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  line <- paste0(type, ": [", timestamp, "]: ", msg, "\n")
  cat(line, file = log_file, append = TRUE)
}
log_msg('Action', 'Script start')




## SECTION 1: check necessary files are present
source(scriptCheck_module.R)



## SECTION 2: calculate raman peak area ##
source('ramanPeak_module.R')
log_msg('Alert', paste0('Raman peak area = ', ramanPeak))


