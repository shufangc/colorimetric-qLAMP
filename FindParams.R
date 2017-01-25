FindParams <- function(hue, groups = 2 : ncol(hue), 
                       save2file = "threshold") {
    # Find four parameters of the sigmoidal function for multiple groups.
    #
    # Args:
    #   hue: an input data frame that contains real time hue data. 
    #       (Format: first column is time, following columns are reaction groups;
    #                colnames:"time", "R0.1"(Reaction logConcentration.Replicate), "R2.1": first replicate in 100 copies reaction.)
    #   groups: a list contains column numbers that need to be analyzed.
    #   save2file: types of data that need to be saved to csv files. Three choices available: 
    #              "all": a data frame containing four parameters of all analyzed groups; 
    #              "reacted": a data frame containing four parameters of all reacted groups (max > min + 3); 
    #              "tt": a data frame containing the threshold times for all reacted groups. 
    # Returns:
    #   --
    
    library(nls2)
    params <- c()
    coefs <- c()
    for (i in groups) {
        x <- hue[, 1]
        y <- hue[, i]
        coefs      <- SigmoidFit(x, y)
        params.new <- as.data.frame(matrix(c(colnames(hue)[i], coefs), ncol = 5))
        params     <- rbind(params, params.new)
    }
    params[, 2:5]    <- as.numeric(as.character(unlist(params[, 2:5])))
    colnames(params) <- c("groups", "Max", "Min", "Tt", "Slope")
    params.reacted    <- params[which(params$Max > params$Min + 3), ]
    result <- list("all"       = params,
                   "reacted"   = params.reacted,
                   "threshold" = data.frame("groups"    = params.reacted[, 1], 
                                            "threshold" = params.reacted[, 4]))
    if ("threshold" %in% save2file) {
        write.csv(result$threshold, "tt.csv")
    }
    if ("all" %in% save2file) {
        write.csv(result$all, "parameters_all.csv")
    }
    if ("reacted" %in% save2file) {
        write.csv(result$reacted, "parameters_reacted.csv")
    }
}