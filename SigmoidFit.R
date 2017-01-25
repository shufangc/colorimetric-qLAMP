SigmoidFit <- function(x, y) {
    # Fit the data with four-parameter sigmoidal function.
    # 
    # Args:
    #   x: predictive variable in Sigmoid function. e.g. time.
    #   y: response variable in Sigmoid funtion. e.g. Hue of a specific group.
    #
    # Returns:
    #   If a Sigmoid function can be applied to the provided y, return 4 coefs. 
    #   Four params: Max, Min, Tt, Slope. 
    #   Otherwise, return 4 "NA"s.
    
    library(nls2)
    coefs <- c()
    tryCatch({
        start.df <- data.frame(a = c(232, 230, 228),
                               b = c(210, 215, 220),
                               c = c(20, 30, 50),
                               d = c(0.07, 0.08, 0.15))
        # calculate starting value for nls optimization
        start.value <- nls2(y ~ a + (b - a) / (1 + 10 ^ ((c - x) * d)), 
                            start     = start.df,
                            algorithm = "brute-force",
                            control   = list(maxiter = 500))
        coefs <- coef(nls2(y ~ a + (b - a) / (1 + 10 ^ ((c - x) * d)),
                           start   = start.value,
                           control = list(maxiter = 500)))
        
    }, error = function(p) {
        coefs <- c(NA, NA, NA, NA)
    })
    return(coefs)
}