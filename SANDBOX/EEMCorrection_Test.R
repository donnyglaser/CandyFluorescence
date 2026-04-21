## run ASCIIImport.R first ##
library(plyr)
library(tidyverse)

dir <- '/Users/dmglaser/Documents/Research/UW/~PostDoc/CaNDyLab/Data/Fluorescence/AquariumTestDMG_260417'

uvFile <- 'EzspecCompatible_aquaDMGUV_02_AbsTSpec.txt'

ramanFile <- 'EzspecCompatible_waterRAMAN_EM.txt'

rawUV <- read.table(file = paste0(dir, '/', uvFile), header = F, sep = '', skip = 4, nrows = 401)
colnames(rawUV) <- c('Ex', 'Absorption')
rawRaman <- read.table(file = paste0(dir, '/', ramanFile), header = F, sep = '', skip = 4, nrows = 62)
colnames(rawRaman) <- c('Em', 'Signal')

exSeq <- seq(450,250,-10)

## calculate RAMAN peak ##
baseLine <- quantile(rawRaman$Signal, 0.75)
baseLine <- subset(rawRaman, Signal <= baseLine)
baseLine <- lm(Signal ~ Em, baseLine)
baseLine <- summary(baseLine)$coefficients[,1]
rawRaman <- mutate(rawRaman, Baseline = (Em * baseLine[2]) + baseLine[1])
rawRaman <- mutate(rawRaman, BaselineCorr = Signal - Baseline)
ramanCorr <- sum(rawRaman$BaselineCorr)

## test plot to see baseline correction of Raman peak ##
ggplot(rawRaman) + geom_line(aes(x = Em, y = Signal), color = 'black') + geom_line(aes(x = Em, y = Baseline), color = 'red')

## create UVvis correction matrix ##

uvCorrMatrix <- data.frame(ExcitationWv = NA, EmissionWv = NA, EmissionWvUV = NA, ExcitationSig = NA, EmissionSig = NA)
for(iex in 1:length(exSeq)){
    exSig <- subset(rawUV, Ex == exSeq[iex])$Absorption

    for(iem in 1:length(emSeq)){
        emWvUV <- rawUV$Ex[which.min(abs(rawUV$Ex - emSeq[iem]))]
        emSig <- rawUV$Absorption[which.min(abs(rawUV$Ex - emSeq[iem]))]

        uvCorrMatrix[(((iex - 1)*length(emSeq))+iem), ] <- data.frame(ExcitationWv = exSeq[iex], EmissionWv = emSeq[iem], EmissionWvUV = emWvUV, ExcitationSig = exSig, EmissionSig = emSig)

    }
}

uvCorrMatrix <- mutate(uvCorrMatrix, corrCoefIFC = (10^((ExcitationSig + EmissionSig)*0.5)))
uvCorrMatrix <- uvCorrMatrix %>% select('ExcitationWv', 'EmissionWv', 'corrCoefIFC')
uvCorrMatrix <- rename(uvCorrMatrix, c('ExcitationWv' = 'Ex'))
uvCorrMatrix <- rename(uvCorrMatrix, c('EmissionWv' = 'Em'))

## now we have raman peak, plus UVvis correction matrix ##

## from ASCIIImport: ##

# unCorrSample <- mutate(unCorrSample, SignalRamanNorm = Signal / ramanCorr)
unCorrBlank <- mutate(unCorrBlank, BlankRamanNorm = Signal / ramanCorr)
unCorrBlank <- unCorrBlank %>% select('Ex', 'Em', 'BlankRamanNorm')

# corrSample <- join(unCorrSample, unCorrBlank, by = c('Ex', 'Em'))
# corrSample <- mutate()
corrSample <- join(unCorrSample, uvCorrMatrix, by = c('Ex', 'Em'))
corrSample <- mutate(corrSample, SignalCorrIFC = Signal * corrCoefIFC)
corrSample <- mutate(corrSample, SignalRamanNorm = SignalCorrIFC / ramanCorr)
corrSample <- join(corrSample, unCorrBlank, by = c('Ex', 'Em'))
corrSample <- mutate(corrSample, SignalBlankCorr = SignalRamanNorm - BlankRamanNorm)