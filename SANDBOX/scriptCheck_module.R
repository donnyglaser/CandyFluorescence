## this module checks all the necessary files are there ##

## check libraries
## check configuration options file is present (sets instrument)
## check all script files are present
## check presence of raman, blank, and sample files 



## these external packages are necessary for this script ##
packages <- c('plyr', 'tidyverse', 'reshape2', 'eemR')

## this checks your computer for the necessary librarys, and installs them if they are missing ##
missingPackages <- packages[!packages %in% rownames(installed.packages())]
missingPackages <- as.character(missingPackages)
if (length(missingPackages) > 0) {
    cat("Warning, your version of R is missing necessary packages:\n")
    cat("Missing packages:\n")
    cat(paste("-", missingPackages), sep = "\n")
    cat("\n\n")
    log_msg('Warning', paste0('Missing packages: ', paste(missingPackages, collapse = ", ")))
    cat("Install missing packages? (y/n): ")
    answer <- readLines("stdin", n = 1)

    if (tolower(answer) %in% c("y", "yes")) {
        options(repos = c(CRAN = "https://cloud.r-project.org"))
        install.packages(missingPackages, dependencies = TRUE)
        log_msg('Action', 'Packages installed')

    } else {
        log_msg('Error', 'User declined installing required packages')
        stop("Required packages not installed. Exiting.")
    }
}
## load necessary libraries ##
lapply(packages, library, character.only = TRUE)

## SECTION 1: identify necessary files ##

## set congifuration settings ##
config <- readLines('userInput_config.txt') ## still need to work on this

allFiles <- list.files(getwd())
allFiles <- allFiles[!grepl("scriptRunLog.txt", allFiles)]

## 1.a. check for RAMAN file ##
ramanFile <- allFiles[grepl('.*raman.*', allFiles, ignore.case = T)]

if(length(ramanFile) != 1) {
    if(length(ramanFile) == 0) {
        log_msg('Error', 'Raman file missing')
        stop("Raman file missing. Exiting.")
    } else if(length(ramanFile) > 1) {
        log_msg('Error', 'Too many raman files')
        stop("Too many raman files. Exiting.")
    } else {
        log_msg('Error', 'Unknown error finding raman file')
        stop("Unknown error finding raman file. Exiting.")
    }
}
## raman file exists ##

## 1.b. check for blank file ##
blankFile <- allFiles[grepl('.*blank.*', allFiles, ignore.case = T)]
if(length(blankFile) != 1) {
    if(length(blankFile) == 0) {
        log_msg('Error', 'Blank EEM file missing')
        stop("Blank EEM file missing. Exiting.")
    } else if(length(blankFile) > 1) {
        log_msg('Error', 'Too many blank EEM files')
        stop("Too many blank EEM files. Exiting.")
    } else {
        log_msg('Error', 'Unknown error finding blank EEM file')
        stop("Unknown error finding blank EEM file. Exiting.")
    }
}
## blank file exists ##

## check for sample files ##
sampleFiles <- allFiles[allFiles != ramanFile & allFiles != blankFile]
if(length(sampleFiles) %% 2 != 0) {
    log_msg('Error', 'Unmatched sample file, missing sample file. Each sample requires 1 UV/vis and 1 EEM spectra')
    stop("Unmatched sample file. Exiting.")
}
sampleNames <- sampleFiles[!grepl('.*uv.*', sampleFiles, ignore.case = T)]
sampleNames <- sub('^EzspecCompatible_', '', sampleNames)
sampleNames <- sub('\\.txt$', '', sampleNames)

## left off here ##
## trying to figure out how to make sure each EEM has a paired UV file ##
## EEMS end in "_EEM.txt" and UV end in "_AbsTSpec.txt", but this could change ##
## trying to think about something more flexible ##