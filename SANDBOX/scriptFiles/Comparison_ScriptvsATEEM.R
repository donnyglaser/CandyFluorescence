## run ASCIIImport.R and EEMCorrection_Test first ##
library(viridis)

scriptData <- corrSample
aTeemData <- corraTeemSample
aTeemData <- rename(aTeemData, c('Signal' = 'aTeemSignal'))

joinData <- join(scriptData, aTeemData, by = c('Ex', 'Em'))

## manual correction (just corrected for IFC) ##
ggplot(joinData, aes(x = Ex, y = Em, z = SignalCorrIFC)) +
    ggtitle('DMG Aquarium Sample: Manual Correction') +
    geom_contour_filled() +
    scale_x_continuous(expand = expansion(), limits = c(250,450)) +
    xlab('Excitation Wavelength (nm)') +
    scale_y_continuous(expand = expansion(), limits = c(300,550)) +
    ylab('Emission Wavelength (nm)') +
    # scale_fill_discrete(breaks = function(x) x[seq(1, length(x), by = 2)]) +
    scale_fill_discrete(palette = 'viridis',
        labels = function(x) {
            lab <- x
            lab[seq(2, length(x), by = 2)] <- ""   # blank every other label
            lab
        }
    ) +
    guides(fill = guide_colorsteps(title = 'Intensity (counts/µA)')) +
    theme(plot.title = element_text(hjust = 0.5, size = 21,
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
    legend.title.position = 'bottom',
    plot.margin = margin(0.25, 0.25, 0.25, 0.25, "cm"),
    plot.tag.position = c(0.15, 0.02),
    axis.title.y.right = element_text(margin = margin(l = 83)),
    legend.position = 'bottom'
    )

ggsave(file = paste0(dir, '/DMGAquariumEEM_Manual_Intensity', '.png'), height = 7, width = 9, unit = 'in', dpi = 300)


## manual correction (IFC, RAMAN, and Blank correction) ##
ggplot(joinData, aes(x = Ex, y = Em, z = SignalBlankCorr)) +
    ggtitle('DMG Aquarium Sample: Manual Correction') +
    geom_contour_filled(breaks = seq(-0.2,1,length.out = 16)) + #breaks = seq(0,1,16)
    scale_x_continuous(expand = expansion(), limits = c(250,450)) +
    xlab('Excitation Wavelength (nm)') +
    scale_y_continuous(expand = expansion(), limits = c(300,550)) +
    ylab('Emission Wavelength (nm)') +
    # scale_fill_viridis_d(drop = F) +
    # scale_fill_discrete(breaks = function(x) x[seq(1, length(x), by = 2)]) +
    scale_fill_discrete(palette = 'viridis', drop = F,
        labels = function(x) {
        lab <- x
        lab[seq(1, length(x), by = 2)] <- ""   # blank every other label
        lab
        }
    ) +
    guides(fill = guide_colorsteps(title = 'A.U.')) +
    theme(plot.title = element_text(hjust = 0.5, size = 21,
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
    legend.title.position = 'bottom',
    plot.margin = margin(0.25, 0.25, 0.25, 0.25, "cm"),
    plot.tag.position = c(0.15, 0.02),
    axis.title.y.right = element_text(margin = margin(l = 83)),
    legend.position = 'bottom'
    )

ggsave(file = paste0(dir, '/DMGAquariumEEM_Manual_AU', '.png'), height = 7, width = 9, unit = 'in', dpi = 300)


## aTEEM ##
ggplot(joinData, aes(x = Ex, y = Em, z = aTeemSignal)) +
    ggtitle('DMG Aquarium Sample: aTEEM') +
    geom_contour_filled() +
    scale_x_continuous(expand = expansion(), limits = c(250,450)) +
    xlab('Excitation Wavelength (nm)') +
    scale_y_continuous(expand = expansion(), limits = c(300,550)) +
    ylab('Emission Wavelength (nm)') +
    # scale_fill_discrete(breaks = function(x) x[seq(1, length(x), by = 2)]) +
    scale_fill_discrete(palette = 'viridis',
        labels = function(x) {
            lab <- x
            lab[seq(2, length(x), by = 2)] <- ""   # blank every other label
            lab
        }
    ) +
    guides(fill = guide_colorsteps(title = 'Intensity (counts/µA)')) +
    theme(plot.title = element_text(hjust = 0.5, size = 21,
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
    legend.title.position = 'bottom',
    plot.margin = margin(0.25, 0.25, 0.25, 0.25, "cm"),
    plot.tag.position = c(0.15, 0.02),
    axis.title.y.right = element_text(margin = margin(l = 83)),
    legend.position = 'bottom'
    )

ggsave(file = paste0(dir, '/DMGAquariumEEM_aTEEM_Intensity', '.png'), height = 7, width = 9, unit = 'in', dpi = 300)
