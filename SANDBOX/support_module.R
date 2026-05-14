## auxillary support functions ##


## functions to log script messages ##
log_file <- 'scriptRunLog.txt'
log_msg <- function(type, msg) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  line <- paste0(type, ": [", timestamp, "]: ", msg, "\n")
  cat(line, file = log_file, append = TRUE)
}

candyReadEEM <- function(file, format, interpolate = TRUE) {
    if(tolower(format) == 'aqualog-next-ezspec') {
        ex <- read.table(file, header = F, sep = '', skip = 2, nrows = 1)
        ex <- ex[1,seq(2, ncol(ex), 2)]
        ex <- as.matrix(ex)
        ex <- matrix(sapply(strsplit(ex, ":"), `[`, 1), nrow = nrow(ex))
        ex <- as.numeric(ex)

        datLength <- suppressWarnings(length(readLines(file)) - 6)
        dat <- read.table(file, header = F, sep = '', skip = 4, nrow = datLength)

        em <- round(dat[,1], digits = 2)
        x <- dat[,seq(2, ncol(dat), 2)]
        x <- as.matrix(x)
        res <- x

        colnames(res) <- ex
        row.names(res) <- round(em, digits = 2)

        out <- reshape2::melt(res, varnames = c('Em', 'Ex'), value.name = 'Signal')
        
    } else if(tolower(format) == 'aqualog-next-origin') {
        out <- NULL
    } else if(tolower(format) == 'fluoromax') {
        out <- NULL
    } else {
        out <- NULL
    }

    if(interpolate == TRUE) {
        r <- MBA::mba.surf(out %>% drop_na(), no.X = 200, no.Y = 200, extend = FALSE)
        out <- expand.grid(Ex = r$xyz.est$y, Em = r$xyz.est$x)
        out$Signal <- as.vector(t(r$xyz.est$z))

    }

    return(out)
}

candyRead_Em <- function(file, format) {
    if(tolower(format) == 'aqualog-next-ezspec') {
        rawRaman <- suppressWarnings(readLines(file))
        rawRaman <- rawRaman[5:(length(rawRaman)-2)]
        rawRaman <- strsplit(rawRaman, '\t')
        rawRaman <- do.call(rbind, rawRaman)
        rawRaman <- apply(rawRaman, 2, as.numeric)
        colnames(rawRaman) <- c('Em', 'Signal')
        rawRaman <- data.frame(rawRaman)
        # rawRaman <- apply(rawRaman, 2, as.numeric)
        out <- rawRaman
    } else if(tolower(format) == 'aqualog-next-origin') {
        out <- NULL
    } else if(tolower(format) == 'fluoromax') {
        out <- NULL
    } else {
        out <- NULL
    }

    return(out)
}

candyReadAbs <- function(file, format) {
    if(tolower(format) == 'aqualog-next-ezspec') {
        rawUV <- suppressWarnings(readLines(file))
        rawUV <- rawUV[5:(length(rawUV)-2)]
        rawUV <- data.frame(uv = rawUV)
        rawUV <- data.frame(do.call('rbind', strsplit(as.character(rawUV$uv),'\t',fixed=TRUE)))
        colnames(rawUV) <- c('Wavelength', 'Absorbance')
        rawUV <- sapply(rawUV, as.numeric)
        out <- data.frame(rawUV)
    } else if(tolower(format) == 'aqualog-next-origin') {
        out <- NULL
    } else if(tolower(format) == 'uvmini') {
        out <- NULL
    } else {
        out <- NULL
    }

    return(out)
}

## eemR function, depreciating eemR from script (260505) ##
# aqualogNextEz <- function(file) {
#     ex <- read.table(file, header = F, sep = '', skip = 2, nrows = 1)
#     ex <- ex[1,seq(2, ncol(ex), 2)]
#     ex <- as.matrix(ex)
#     ex <- matrix(sapply(strsplit(ex, ":"), `[`, 1), nrow = nrow(ex))
#     ex <- as.numeric(ex)

#     datLength <- length(readLines(file)) - 6
#     dat <- read.table(file, header = F, sep = '', skip = 4, nrow = datLength)

#     em <- round(dat[,1], digits = 2)
#     x <- dat[,seq(2, ncol(dat), 2)]
#     x <- as.matrix(x)
#     res <- x

#     colnames(res) <- ex
#     row.names(res) <- round(em, digits = 2)

#     res <- reshape2::melt(res, varnames = c('em', 'ex'), value.name = 'x')

#     ex <- sort(unique(ex))
#     em <- sort(unique(em))
#     # x <- matrix(res$x, ncol = length(ex), byrow = F)

#     # We need to interpolate because you do not have a regular grid (i.e. asynchronous)
#     r <- MBA::mba.surf(res %>% drop_na(), no.X = 200, no.Y = 200, extend = FALSE)

#     l <- list(
#         file = file,
#         x = r$xyz.est$z,
#         ex = r$xyz.est$y,
#         em = r$xyz.est$x
#     )

#     return(l)
# }

