#' @param expr An R expression to evaluate with error hunting.
#' @return `hunt`: results of `eval(expr)`
#' @rdname hunt
#' @export
hunt <- function(expr, on.error = c("browse", "capture")) {
    on.error <- match.arg(on.error)
    # error <- getOption("error")
    # options(error = hunter)
    # on.exit(options(error = error), add = TRUE)
    # eval(substitute(expr), parent.frame())

    error_handler <- getOption("error")
    options(error = NULL)  # Disable global handler temporarily
    on.exit(options(error = error_handler), add = TRUE)
    
    error_occurred <- FALSE
    value <- tryCatch(
        withCallingHandlers(
            eval(substitute(expr), parent.frame()),
            error = function(e) {
                hunter()
            }
        ),
        error = function(e) {
            message("Error: ", conditionMessage(e))
            error_occurred <<- TRUE
        }
    )
    if (error_occurred) {
        if (on.error == "browse") {
            message("Entering browser at error location...")
            capture <- getLastCapture()
            inspect(capture)
        } else if (on.error == "capture") {
            # do nothing here, hunter() has already captured the error
        }
        invisible(NULL)
    } else {
        value
    }
}