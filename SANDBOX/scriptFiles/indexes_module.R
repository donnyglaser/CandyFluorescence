## calculate indexes from fluorescence EEM ##
## FI, HIX, Freshness (BIX), spectral slope, UV absorbance at 254 nm, total fluorescence ##

## fluorescence index (FI) ##
## interpolate to exact wavelengths ##
ex370 <- subset(corrEEM, Ex == 370)
em470 <- interp1(ex370$Em, ex370$CorrectedSignal, 470)
em520 <- interp1(ex370$Em, ex370$CorrectedSignal, 520)
## calculate ##
FI <- em470 / em520

## humification index (HIX) ##
interpEEM <- corrEEM[,c(1:2,8)]
interpEEM <- acast(interpEEM, Em ~ Ex, value.var = 'CorrectedSignal')

interpX <- expand.grid(seq(250,450,1), seq(297,550,1))$Var1
interpY <- expand.grid(seq(250,450,1), seq(297,550,1))$Var2
interpZ <- interp2(exSeq[length(exSeq):1], emSeq, interpEEM, interpX, interpY, 'linear')
interpEEM <- cbind(interpX, interpY, interpZ)

em254 <- subset(interpEEM, interpX == 254)

areaRed <- em254[em254[,2] >= 435 & em254[,2] <= 480,]
areaRed <- trapz(areaRed[,2], areaRed[,3])

areaBlue <- em254[em254[,2] >= 300 & em254[,2] <= 345,]
areaBlue <- trapz(areaBlue[,2], areaBlue[,3])

HIX <- areaRed / areaBlue

## freshness index (BIX) ##
ex310 <- subset(corrEEM, Ex == 310)
max310 <- subset(ex310, Em >= 419 & Em <= 437)
max310 <- max(max310$CorrectedSignal)
em380 <- interp1(ex310$Em, ex310$CorrectedSignal, 380)
freshI <- em380 / max310

## spectral slope ##
specSlope <- (rawUV[rawUV[,1] == 295,2] - rawUV[rawUV[,1] == 275,2]) / 20

## absorbance at 254 nm ##
abs254 <- rawUV[rawUV[,1] == 254,2]

## total fluorescence ##
totalFluor <- sum(corrEEM$MaskedSignal, na.rm = T)

## output row of data ##
## sample name, FI, HIX, Freshness (BIX), spectral slope, UV absorbance at 254 nm, total fluorescence ##

tIndexes <- data.frame(SampleName = tsampleName, RamanArea = ramanPeak, FI = FI, HIX = HIX, BIX = freshI, SpectralSlope = specSlope, Absorbance254 = abs254, TotalFluorescence = totalFluor)

