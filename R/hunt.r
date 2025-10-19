#' @param expr An R expression to evaluate with error hunting.
#' @return `hunt`: results of `eval(expr)`
#' @rdname hunt
#' @export
hunt <- function(expr){
    error <- getOption("error")
    options(error = hunter)
    on.exit(options(error = error), add = TRUE)
    eval(substitute(expr), parent.frame())
}