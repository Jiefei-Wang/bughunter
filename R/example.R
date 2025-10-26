#' Example Capture Object
#' 
#' An example Capture object obtained by running the following code:
#' ```r
#' f <- function(x) {
#'     x <- x + 1
#'     g(x)
#' }
#' g <- function(y) {
#'     y <- y + 2
#'     z <- 1
#'     stop("Test error")
#' }
#' hunt(f(1))
#' example_capture <- getLastCapture()
#' ```
#' 
"example_capture"