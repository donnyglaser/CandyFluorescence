## configuration file that imports all relevant global variables ##

## Raw EEM collection parameters ##
emInc = 2 # the increment of the emission spectra you collected
exInc = 10 # the increment of the excitation spectra you collected
em = seq(300,550,emInc) # Emission start wavelength:eminc:emission ending wavelength
ex = seq(240,450,exInc) # Excitation start wavelength:exinc:excitation ending wavelength
corrFact = 0.959242 # Correction factor, take the xcorrect value at 350 for the specific instrument you used.
                    # For the McKnight Lab F3 this is 0.959242 and the McKnight Lab F2 it is 1.040614
emLen = length(em)
exLen = length(ex)

## raman collection parameters ##
ramanEnd = 450 # This is the end of your Raman scan, or where you want the raman scan to end the integration area
ramanBegin = 370 # Where you want the Raman scan to start integration
                   # Usually 370 but make sure its after your scan starts
                   # This should match the range for the mcRaman correction file input as "RC" in
                   # the RunCorrectionsII code
ramanInc = 0.5 # The increment on your raman scan

## file structure ##
