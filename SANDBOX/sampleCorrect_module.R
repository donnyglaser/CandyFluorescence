## SECTION 4: correct samples:
### inner filter correction
### raman normalization
### blank subtract

rawUV <- candyReadAbs(tUVFile, 'aqualog-next-ezspec')
rawEEM <- candyReadEEM(tEEMFile, 'aqualog-next-ezspec', interpolate = F)

exSeq <- seq(450,250,-10)
emSeq <- unique(rawEEM$Em)
emSeq <- round(emSeq, digits = 3)

## IFC ##
uvCorrMatrix <- data.frame(ExcitationWv = NA, EmissionWv = NA, EmissionWvUV = NA, ExcitationSig = NA, EmissionSig = NA)
for(iex in 1:length(exSeq)){
    exSig <- subset(rawUV, Wavelength == exSeq[iex])$Absorbance

    for(iem in 1:length(emSeq)){
        emWvUV <- rawUV$Wavelength[which.min(abs(rawUV$Wavelength - emSeq[iem]))]
        emSig <- rawUV$Absorbance[which.min(abs(rawUV$Wavelength - emSeq[iem]))]

        uvCorrMatrix[(((iex - 1)*length(emSeq))+iem), ] <- data.frame(ExcitationWv = exSeq[iex], EmissionWv = emSeq[iem], EmissionWvUV = emWvUV, ExcitationSig = exSig, EmissionSig = emSig)

    }
}

uvCorrMatrix <- mutate(uvCorrMatrix, corrCoefIFC = (10^((ExcitationSig + EmissionSig)*0.5)))
uvCorrMatrix <- uvCorrMatrix %>% select('ExcitationWv', 'EmissionWv', 'corrCoefIFC')
uvCorrMatrix <- rename(uvCorrMatrix, c('Ex' = 'ExcitationWv'))
uvCorrMatrix <- rename(uvCorrMatrix, c('Em' = 'EmissionWv'))

rawEEM <- join(rawEEM, uvCorrMatrix, by = c('Ex', 'Em'))

rawEEM <- mutate(rawEEM, SignalCorrIFC = Signal * corrCoefIFC) ## Inner filter correction
rawEEM <- mutate(rawEEM, SignalRamanNorm = SignalCorrIFC / ramanPeak) ## raman normalization
rawEEM <- join(rawEEM, blankEEM[,c(1:2,4)], by = c('Ex', 'Em'))
rawEEM <- rename(rawEEM, c('BlankSignal_Corr' = 'CorrectedSignal'))
rawEEM <- mutate(rawEEM, CorrectedSignal = SignalRamanNorm - BlankSignal_Corr)

saveRDS(rawEEM, file = paste0(path, '/scriptDataOut/', tsampleName, '_CorrectedEEM.rds'))

## havent tested this yet ##