dir <- '/Users/dmglaser/Documents/Research/UW/~PostDoc/CaNDyLab/Data/Fluorescence/AquariumTestDMG_260417'

testFile <- 'EzspecCompatible_aquaDMG_02_EEM.txt'
testBlank <- 'EzspecCompatible_waterBLANK_EEM.txt'

## aTEEM files have slightly different layout than raw EEMS ##
## 21 excitation wavelengths x 2 = 42 columns (same as raw EEM) + absorbance and transmission x 2 = 4 columns for a total of 46 ##
## 46 columns for the first 31 rows (31 abs and trans wavelengths), then only 42 columms for the remaining 81 rows ##
aTeem <- read.table(file = '/Users/dmglaser/Documents/Research/UW/~PostDoc/CaNDyLab/Data/Fluorescence/AquariumTestDMG_260417/EzspecCompatible_aquaDMGaTEEM_05_EEM_IFE.txt', header = F, sep = '', skip = 4, nrows = 111, fill = T)
aTeemABS <- aTeem[,43:44]
aTeem <- aTeem[,1:42]

raw <- read.table(file = paste0(dir, '/', testFile), header = F, sep = '', skip = 4, nrows = 112)

exSeq <- seq(450,250,-10)

unCorrSample <- data.frame()
for(iex in 1:length(exSeq)){
    tempIndex <- ((iex - 1) * 2) + 1
    tempOut <- raw[,tempIndex:(tempIndex+1)]
    tempOut <- data.frame(exSeq[iex], tempOut)
    colnames(tempOut) <- c('Ex', 'Em', 'Signal')
    unCorrSample <- rbind(unCorrSample, tempOut)
}
unCorrSample$Em <- round(unCorrSample$Em, digits = 3)

emSeq <- unique(unCorrSample$Em)
emSeq <- round(emSeq, digits = 3)

raw <- read.table(file = paste0(dir, '/', testBlank), header = F, sep = '', skip = 4, nrows = 112)

unCorrBlank <- data.frame()
for(iex in 1:length(exSeq)){
    tempIndex <- ((iex - 1) * 2) + 1
    tempOut <- raw[,tempIndex:(tempIndex+1)]
    tempOut <- data.frame(exSeq[iex], tempOut)
    colnames(tempOut) <- c('Ex', 'Em', 'Signal')
    unCorrBlank <- rbind(unCorrBlank, tempOut)
}
unCorrBlank$Em <- round(unCorrBlank$Em, digits = 3)



corraTeemSample <- data.frame()
for(iex in 1:length(exSeq)){
    tempIndex <- ((iex - 1) * 2) + 1
    tempOut <- aTeem[,tempIndex:(tempIndex+1)]
    tempOut <- data.frame(exSeq[iex], tempOut)
    colnames(tempOut) <- c('Ex', 'Em', 'Signal')
    corraTeemSample <- rbind(corraTeemSample, tempOut)
}
corraTeemSample$Em <- round(corraTeemSample$Em, digits = 3)

## now we have uncorrected EEM matrixes for sample and blank ##
