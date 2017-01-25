PlotAmpCurve <- function(hue.start.column, hue.end.column,
                         xlabel= "Time (min)", ylabel= "Hue", 
                         xlim = c(1, 60), ylim = c(210, 240),
                         legendx = "topright", legendy = NULL, legend = NULL) {
    # Plot amplification curves using the real-time hue data.
    #
    # Args:
    #   hue.start.column: from which column the hue data needs to be plotted on the amplification curve.
    #   hue.end.column: to which column the hue data needs to be plotted on the amplification curve.
    #   xlabel: x axis label of the amplification curve.
    #   ylabel: y axis label of the amplification curve.
    #   xlim: range of x axis.
    #   ylim: range of y axis.
    #   legendx: the x location to put the legend. Default is topright. 
    #   legendy: the y location to put the legend.
    #   legend: text in the legend.
    # Returns:
    #   --
    
    library(RColorBrewer)
    colpal <- brewer.pal(5, "Set1")
    set.seed(123)
    plot(x = hue$time, y = hue[, 2], 
         type = "n", 
         xlim = xlim, ylim = ylim,
         xlab = xlabel, ylab = ylabel)
    legend(x = legendx, y = legendy, legend = legend, bty = "n")
    for (i in hue.start.column : hue.end.column) {
        x <- hue$time
        y <- hue[, i]
        tryCatch({
            params <- SigmoidFit(x, y)
            if (params[1] < params[2] + 3) {
                points(x = hue$time, y = hue[, i], pch = 20, 
                       col = adjustcolor(sample(colpal, 1), alpha = 0.5))
            }
            else {
                color <- sample(colpal, 1)
                y2 <- Sigmoid(params, x)
                lines(x = hue$time, y = y2,
                      col = adjustcolor(color, alpha = 0.7), lwd = 2)
                points(x = hue$time, y, 
                       pch = 20, col = adjustcolor(color, alpha = 0.5))
            }
        }, error = function(p) {
            points(x = hue$time, y = hue[, i], 
                   pch = 20, 
                   col = adjustcolor(sample(colpal, 1), alpha = 0.5))
        })
    }
}
