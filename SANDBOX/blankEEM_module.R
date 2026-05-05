## correct blank EEM ##

## raman normalization ##
rawRaman <- readLines(ramanFile)
rawRaman <- rawRaman[5:(length(rawRaman)-2)]
rawRaman <- strsplit(rawRaman, '\t')
rawRaman <- do.call(rbind, rawRaman)
rawRaman <- apply(rawRaman, 2, as.numeric)
colnames(rawRaman) <- c('Em', 'Signal')
rawRaman <- data.frame(rawRaman)
if(min(rawRaman$Em) < 385 & max(rawRaman$Em) < 411) {
    log_msg('Error', 'Raman file missing necessary emission wavelengths. it is necessary to measure emission from at least 380 - 420 nm (recommend 360 - 500 nm)')
    stop("Raman file missing necessary emission wavelengths. Exiting.")
}
if(rawRaman[which.max(rawRaman$Signal),1] < 395.5 | rawRaman[which.max(rawRaman$Signal),1] > 398.5) {
    log_msg('Warning', 'Water raman peak is outside recommended wavelength range (395.5 - 398.5 nm)')
}

if(nrow(rawRaman) < 25) {
    baseLine <- quantile(rawRaman$Signal, 0.25)
    log_msg('Warning', 'Raman file does not have sufficient data for a robust baseline calculation. recommend measuring raman emission from 360 - 500 nm')
} else {
    baseLine <- quantile(rawRaman$Signal, 0.75)
}

baseLine <- subset(rawRaman, Signal <= baseLine)
baseLine <- lm(Signal ~ Em, baseLine)
baseLine <- summary(baseLine)$coefficients[,1]
rawRaman <- mutate(rawRaman, Baseline = (Em * baseLine[2]) + baseLine[1])
rawRaman <- mutate(rawRaman, CorrectedSignal = Signal - Baseline)
rawRaman <- mutate(rawRaman, dEm = c(diff(Em), NA))
rawRaman <- mutate(rawRaman, Area = CorrectedSignal * dEm)

# dEm <- sum(diff(rawRaman$Em) * (rawRaman$CorrectedSignal[-nrow(rawRaman)] + rawRaman$CorrectedSignal[-1]) / 2)

# ramanPeak <- sum(rawRaman$CorrectedSignal)
ramanPeak <- sum(rawRaman$Area, na.rm = T)



blankEEM <- eem_read(blankFile, import_function = aqualogNextEz)

blankEEM[[1]]$x <- blankEEM[[1]]$x / ramanPeak

