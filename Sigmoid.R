Sigmoid <- function(params, x) {
    # Four-parameter sigmoidal function.
    params[1] + (params[2] - params[1]) / (1 + 10 ^ ((params[3] - x) * params[4]))
}