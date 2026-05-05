## correct blank EEM ##
blankEEM <- candyReadEEM(blankFile, instrumentConfig, interpolate = T)


## raman normalization ##
if(ramanStatus == TRUE) {
    rawRaman <- candyRead_Em(ramanFile, instrumentConfig)

    if(min(rawRaman$Em) > 385 & max(rawRaman$Em) < 411) {
        log_msg('Warning', 'Raman file missing necessary emission wavelengths. Attempting to use blank EEM to raman normalize samples')
        ramanStatus <- FALSE
    }
    if(rawRaman[which.max(rawRaman$Signal),1] < 395.5 | rawRaman[which.max(rawRaman$Signal),1] > 398.5) {
        log_msg('Warning', 'Water raman peak is outside recommended wavelength range (395.5 - 398.5 nm)')
    }
}

## if the raman file is too small, use blank EEM ##
if(ramanStatus == FALSE) {
    blank350 <- blankEEM$Ex[which.min(abs(blankEEM$Ex - 350))]
    rawRaman <- subset(blankEEM, Ex == blank350)
    rawRaman <- rawRaman[,2:3]
    colnames(rawRaman) <- c('Em', 'Signal')
    rawRaman <- subset(rawRaman, Em > 360 & Em < 503)
}

baseLine <- quantile(rawRaman$Signal, 0.75)
baseLine <- subset(rawRaman, Signal <= baseLine)
baseLine <- lm(Signal ~ Em, baseLine)
baseLine <- summary(baseLine)$coefficients[,1]
rawRaman <- mutate(rawRaman, Baseline = (Em * baseLine[2]) + baseLine[1])
rawRaman <- mutate(rawRaman, CorrectedSignal = Signal - Baseline)
rawRaman <- mutate(rawRaman, dEm = c(diff(Em), NA))
rawRaman <- mutate(rawRaman, Area = CorrectedSignal * dEm)

ramanPeak <- sum(rawRaman$Area, na.rm = T)
log_msg('Alert', paste0('Water raman peak area = ', ramanPeak))

blankEEM <- mutate(blankEEM, CorrectedSignal = Signal / ramanPeak)
log_msg('Alert', 'Blank EEM corrected')
