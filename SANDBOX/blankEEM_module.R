## correct blank EEM ##

blankEEM <- eem_read(blankFile, import_function = aqualogNextEz)

blankEEM[[1]]$x <- blankEEM[[1]]$x / ramanPeak

