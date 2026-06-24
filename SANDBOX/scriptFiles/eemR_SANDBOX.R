library(eemR)

tFile <- '/Users/dmglaser/Documents/Research/UW/~PostDoc/CaNDyLab/Data/Fluorescence/AquariumTestDMG_260417/EzspecCompatible_aquaDMG_05_EEM.txt'

tEEM <- eem_read(tFile, recursive = F, 'aqualog')
## this imports the "raw"

## this doesnt work ##
# tFile <- '/Users/dmglaser/Documents/Research/UW/~PostDoc/CaNDyLab/Data/Fluorescence/AquariumTestDMG_260417/aquaDMG_05_EEM_2026-04-17T15-19-21/aquaDMG_05_EEM_raw_signals.ezspec_data'

# tEEM <- eem_read(tFile, recursive = F, 'aqualog')
######################

## it seems like the data format for aqualog and aqualog next are different ##