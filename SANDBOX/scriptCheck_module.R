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
config <- read.table('scriptFiles/userInput_config.txt', header = T, sep = ' ', skip = 2) ## still need to work on this
config <- data.frame(config)
instrumentConfig <- subset(config, parameter = 'instrument')$setting


allFiles <- list.files(getwd(), recursive = T, include.dirs = F)
allFiles <- allFiles[!grepl("scriptRunLog.txt", allFiles)]
allFiles <- allFiles[!grepl('scriptFiles/', allFiles)]

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
        log_msg('Error', 'Blank EEM file missing.')
        stop("Blank EEM file missing. Exiting.")
    } else if(length(blankFile) > 1) {
        log_msg('Error', 'Too many blank EEM files.')
        stop("Too many blank EEM files. Exiting.")
    } else {
        log_msg('Error', 'Unknown error finding blank EEM file.')
        stop("Unknown error finding blank EEM file. Exiting.")
    }
}
## blank file exists ##

## check for sample files ##
## make a switch to check for file output types:
## intsrument
## software

sampleFiles <- allFiles[allFiles != ramanFile & allFiles != blankFile]
if(length(sampleFiles) %% 2 != 0) {
    log_msg('Error', 'Unmatched sample file, missing sample file. Each sample requires 1 UV/vis and 1 EEM spectra.')
    stop("Unmatched sample file. Exiting.")
}

if(instrumentConfig == 'Aqualog-Next-Ezspec') {
    ## check if there is 1 EEM and one UV for each sample here ##
    ## make sample name list
    sampleNames <- sub('^EzspecCompatible_', '', sampleFiles)
    sampleNames <- sub('\\.txt$', '', sampleNames)
    sampleNames <- sampleNames[grepl('\\_EEM$', sampleNames)]
    sampleNames <- sub('\\_EEM$', '', sampleNames)

    for(isample in 1:length(sampleNames)) {
        tSample <- sampleFiles[grepl(paste0(',*', sampleNames[isample], '.*'), sampleFiles)]

        if(all(c(
            any(grepl("_EEM.txt$", tSample)),
            any(grepl("_AbsTSpec.txt$", tSample))
        )) == F) {
            if(any(grepl("_EEM.txt$", tSample)) == F) {
                log_msg('Error', paste0('Sample ', sampleNames[isample], ' is missing EEM file.'))
                stop(paste0('Sample ', sampleNames[isample], ' is missing EEM file. Exiting.'))
            } else if(any(grepl("_AbsTSpec.txt$", tSample)) == F) {
                log_msg('Error', paste0('Sample ', sampleNames[isample], ' is missing UVvis (AbsTSpec) file.'))
                stop(paste0('Sample ', sampleNames[isample], ' is missing UVvis (AbsTSpec) file. Exiting.'))
            } else {
                log_msg('Error', paste0('Unknown error finding EEM/UVvis file pair for sample ', sampleNames[isample], '.'))
                stop(paste0('Unknown error finding EEM/UVvis file pair for sample ', sampleNames[isample], 'Exiting.'))
            }
        }
    }

} else if(instrumentConfig == 'Aqualog-Next-Origin') {
    log_msg('Error', 'Script does not support Aqualog-Next-Origin file format')
    stop("Unknown file format. Exiting.")

} else if(instrumentConfig == 'Fluoromax') {
    log_msg('Error', 'Script does not support Fluoromax file format')
    stop("Unknown file format. Exiting.")

} else {
    log_msg('Error', 'Instrument not specified in userInput_config.txt file')
    stop("Incomplete userInput_config.txt file. Exiting.")

}

log_msg('Notice', 'Pre-Script checks complete')

