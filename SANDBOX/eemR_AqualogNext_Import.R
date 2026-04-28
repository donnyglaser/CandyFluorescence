aqualogNext <- function(file) {
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

    ## this approach is in the import example, but I dont think it works here since emission values are decimals ##
    # em2 <- outer(ex, em, "+")
    # em2 <- as.vector(em2)
    # ex2 <- rep(ex, length(em))



    # res <- tibble(ex2, em2, x = as.vector(x)) %>%
    #     arrange(ex2, em2) %>%
    #     complete(ex2, em2, fill = list(x = NA))
    ## maybe retry rounding to nearest nm? ##


    colnames(res) <- ex
    row.names(res) <- round(em, digits = 2)

    res <- reshape2::melt(res, varnames = c('ex', 'em'), value.name = 'x')

    ex <- sort(unique(ex))
    em <- sort(unique(em))
    # x <- matrix(res$x, ncol = length(ex), byrow = F)

    # We need to interpolate because you do not have a regular grid (i.e. asynchronous)
    r <- MBA::mba.surf(res %>% drop_na(), no.X = 200, no.Y = 200, extend = FALSE)

    l <- list(
        file = file,
        x = r$xyz.est$z,
        ex = r$xyz.est$x,
        em = r$xyz.est$y
    )

    return(l)
}

## this works to import ASCII data from the aqualog next to eemR format ##