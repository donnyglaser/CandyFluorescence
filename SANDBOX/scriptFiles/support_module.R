## copy script files to path ##
scriptFiles <- c('MAIN.R', 'blankEEM_module.R', 'sampleCorrect_module.R', 'scriptCheck_module.R', 'support_module.R', 'userInput_config.txt')
## move all script files to path, then change wd ##
## after script finishes, delete script files ##
dir.create(paste0(path, '/scriptFiles/'))
file.copy(paste0(getwd(), '/scriptFiles/', scriptFiles), paste0(path, '/scriptFiles'), overwrite = T)

dir.create(paste0(path, '/scriptDataOut/'))

setwd(path)


## these external packages are necessary for this script ##
packages <- c('plyr', 'tidyverse', 'reshape2', 'MBA', 'pracma')

## this checks your computer for the necessary libraries, and installs them if they are missing ##
missingPackages <- packages[!packages %in% rownames(installed.packages())]
missingPackages <- as.character(missingPackages)
if (length(missingPackages) > 0) {
    cat("Warning, your version of R is missing necessary packages:\n")
    cat("Missing packages:\n")
    cat(paste("-", missingPackages), sep = "\n")
    cat("\n\n")
    log_msg('Warning', paste0('Missing packages: ', paste(missingPackages, collapse = ", ")))
    cat("Install missing packages? (y/n): ")
    answer <- readLines("stdin", n = 1)

    if (tolower(answer) %in% c("y", "yes")) {
        options(repos = c(CRAN = "https://cloud.r-project.org"))
        install.packages(missingPackages, dependencies = TRUE)
        log_msg('Action', 'Packages installed')

    } else {
        log_msg('Error', 'User declined installing required packages')
        stop("Required packages not installed. Exiting.")
    }
}
## load necessary libraries ##
lapply(packages, library, character.only = TRUE)



## auxillary support functions ##


## functions to log script messages ##
log_file <- 'scriptRunLog.txt'
log_msg <- function(type, msg) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  line <- paste0(type, ": [", timestamp, "]: ", msg, "\n")
  cat(line, file = log_file, append = TRUE)

  print(paste0(type, ': ', msg))
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

pTheme <- theme(plot.title = element_text(hjust = 0.5, size = 21,
            face = "bold"),
            text = element_text(size = 18),
            axis.text.x = element_text(size = 14),
            aspect.ratio = 0.625,
            axis.line = element_line(color = "black"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.background = element_blank(),
            panel.border = element_rect(color = "black", fill=NA, size=2),
            legend.key=element_blank(),
            legend.key.height = unit(0.25, "inch"),
            legend.key.width = unit(1.35, "inch"),
            legend.text.position = 'bottom', 
            legend.title.align=0.5,
            legend.title.position= 'bottom',
            plot.margin = margin(0.5, 0.75, 0.25, 0.25, "cm"),
            plot.tag.position = c(0.15, 0.02),
            axis.title.y.right = element_text(margin = margin(l = 83)),
            legend.position = 'bottom'
        )

candyPlotEEM_TEST <- function(rawEEM, name, save) {
    ggplot(rawEEM, aes(x = Ex, y = Em, z = CorrectedSignal)) +
    geom_contour_filled(breaks = seq(0, 0.5, length.out = 11)) +
    scale_x_continuous(expand = expansion(), limits = c(250,450)) +
    scale_y_continuous(expand = expansion(), limits = c(300,550)) +
    ggtitle(name) +
    xlab("Excitation Wavelength (nm)") +
    ylab("Emission Wavelength (nm)") +
    scale_fill_discrete(palette = 'viridis', drop = F,
        labels = function(x) {
            lab <- x
            if (length(x) > 2) {
                idx <- seq(1, length(x), by = 2)
                lab[idx] <- ""
            }
            lab
        }
    ) +
    guides(fill = guide_colorsteps(title = 'Raman Units (AU)', show.limits = T)) +
    pTheme

    if(save == TRUE) {
        ggsave(file = paste0(path, '/scriptDataOut/', name, '_CorrectedEEM_Plot.png'), height = 6.5, width = 8, unit = 'in', dpi = 300)
    }
}

## need to figure out best way to save plots ##

# ggsave('test.png', height = 6.2, width = 8, unit = 'in', dpi = 300)



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

