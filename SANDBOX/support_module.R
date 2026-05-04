## auxillary support functions ##


## functions to log script messages ##
log_file <- 'scriptRunLog.txt'
log_msg <- function(type, msg) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  line <- paste0(type, ": [", timestamp, "]: ", msg, "\n")
  cat(line, file = log_file, append = TRUE)
}

aqualogNextEz <- function(file) {
    ex <- read.table(file, header = F, sep = '', skip = 2, nrows = 1)
    ex <- ex[1,seq(2, ncol(ex), 2)]
    ex <- as.matrix(ex)
    ex <- matrix(sapply(strsplit(ex, ":"), `[`, 1), nrow = nrow(ex))
    ex <- as.numeric(ex)

    datLength <- length(readLines(file)) - 6
    dat <- read.table(file, header = F, sep = '', skip = 4, nrow = datLength)

    em <- round(dat[,1], digits = 2)
    x <- dat[,seq(2, ncol(dat), 2)]
    x <- as.matrix(x)
    res <- x

    colnames(res) <- ex
    row.names(res) <- round(em, digits = 2)

    res <- reshape2::melt(res, varnames = c('em', 'ex'), value.name = 'x')

    ex <- sort(unique(ex))
    em <- sort(unique(em))
    # x <- matrix(res$x, ncol = length(ex), byrow = F)

    # We need to interpolate because you do not have a regular grid (i.e. asynchronous)
    r <- MBA::mba.surf(res %>% drop_na(), no.X = 200, no.Y = 200, extend = FALSE)

    l <- list(
        file = file,
        x = r$xyz.est$z,
        ex = r$xyz.est$y,
        em = r$xyz.est$x
    )

    return(l)
}
