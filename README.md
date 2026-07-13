## Git repository for Fluorescence analysis and PARAFAC modeling ##
## Designed for use in the CaNdy Lab @ UW ##
Author: Donny Glaser (dglaser@uw.edu)
PI: Hilairy Hartnett (hartnett@uw.edu)

Brief Overview:
This script is designed to:
    i)   correct for inner filter effects using UVvis absorbance
    ii)  normalize fluorescence EEMs to the water raman peak @350 nm Excitation
    iii) blank subtract
    iv)  calculate fluorescence indexes: FI, HIX, Freshness (BIX), spectral slope, UV absorbance at 254 nm, and total fluorescence.
    v)   perform PARAFAC modeling (not yet implemented: 260713)
The correction method is based on Cory & McKnight (2005) and allows comparison of fluorescence results between samples as well as between different instruments.

How to use the script:
    1) Data Preparation: Each sample needs a UVvis absorbance spectrum and a fluorescence EEM and each day of sample correction needs a raman emission spectrum and a blank EEM. Refer to the fluorescence data collection protocol for more details. All data files should be in a single folder. All sample files (UVvis & EEM) must contain the same name. the raman file must contain the word "RAMAN" in it and the blank file must contain the word "BLANK" in it. Each folder will have 2n + 2 files where n is the number of samples.
        Example files:
        i)   260713_BLANK.txt
        ii)  260713_Sample1_AbsTSpec.txt
        iii) 260713_Sample1_EEM.txt
        iv)  260713_Sample2_AbsTSpec.txt
        v)   260713_Sample2_EEM.txt
        vi)  260713_RAMAN.txt
    2) Running the script: Copy the path of the folder where the files are (e.g., /Users/CaNdyLab/Documents/Fluorescence/260713). Open the .command or .bat file, depending on if you are using a MAC or PC, respectively. Paste the path and press enter, thats it! Once the 
    3) Accessing the data: All data produced by the script will be put in a new folder in the path named "scriptDataOut." For each sample there will be:
        i) 3 graphs with differing ranges of intensity (0-0.5, 0-0.05, and autoscaled)
        ii) an rds file with the EEM data.
    There will also be FluorescenceIndexes rds and csv files, which contains the indexes for all the samples in the run (i.e., folder)

Errors and troubleshooting:
The script was designed to assist with errors as much as possible. If there are issues with the file names, path, data, etc., there will be error messages that will help guide you to the problem. Examples include:
    i)   'Unknown file format. Exiting.'
    ii)  'Raman file missing'
    iii) 'Too many raman files'
    iv)  'Blank EEM file missing.'
    v)   'Unknown error finding EEM/UVvis file pair for sample'