## SECTION 4: correct samples:
### inner filter correction
### raman normalization
### blank subtract

rawUV <- candyReadAbs(tUVFile, 'aqualog-next-ezspec')
rawEEM <- candyReadEEM(tEEMFile, 'aqualog-next-ezspec', interpolate = F)

## hard coded EEM resolution ##
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

corrEEM <- join(rawEEM, uvCorrMatrix, by = c('Ex', 'Em'))

corrEEM <- mutate(corrEEM, SignalCorrIFC = Signal * corrCoefIFC) ## Inner filter correction
corrEEM <- mutate(corrEEM, SignalRamanNorm = SignalCorrIFC / ramanPeak) ## raman normalization
corrEEM <- join(corrEEM, blankEEM[,c(1:2,4)], by = c('Ex', 'Em'))
corrEEM <- rename(corrEEM, c('BlankSignal_Corr' = 'CorrectedSignal'))
corrEEM <- mutate(corrEEM, CorrectedSignal = SignalRamanNorm - BlankSignal_Corr)
corrEEM <- mutate(corrEEM, MaskedSignal = CorrectedSignal)

## remove rayleigh scattering 1st and 2nd order ##
for(iex in 1:length(exSeq)) {
    corrEEM$MaskedSignal[corrEEM$Em < (exSeq[iex] + mask_buffer) & corrEEM$Ex == exSeq[iex]] <- NA
    # test <- subset(corrEEM, Em <)
    # print(iex)
    # print(exSeq[iex])
}
for(iex in 1:length(exSeq)) {
    corrEEM$MaskedSignal[corrEEM$Em > ((2 * exSeq[iex]) - mask_buffer) & corrEEM$Ex == exSeq[iex]] <- NA
}


saveRDS(corrEEM, file = paste0(path, '/scriptDataOut/', tsampleName, '_CorrectedEEM.rds'))

candyPlotEEM_Mid(corrEEM, tsampleName, TRUE)
candyPlotEEM_Lo(corrEEM, tsampleName, TRUE)
candyPlotEEM_Auto(corrEEM, tsampleName, TRUE)


