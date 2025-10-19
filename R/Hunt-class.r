#' Bug Hunt Class
#'
#' An S4 class to represent a bug hunt captured by the hunter function.
#' This class provides a structured container for all hunt information
#' including error details, call stack, and source code information.
#'
#' @slot error_message character. The error message that was captured.
#' @slot frames list. List of environment frames from the call stack.
#' @slot func_src_codes list. Source codes of the functions in the call stack.
#' @slot func_src_available logical. Whether source code is available for each function.
#' @slot func_src_start numeric. Starting line numbers for each function's source code.
#' @slot func_src_end numeric. Ending line numbers for each function's source code.
#' @slot call_lines numeric. Line numbers where each call was made.
#' @slot calls list. The actual call expressions from the stack.
#' @slot timestamp POSIXct. When the hunt was captured.
#'
#' @exportClass Hunt
.Hunt <- setClass(
    "Hunt",
    slots = list(
        error_message = "character",
        frames = "list",
        func_names = "character",
        func_src_codes = "list",
        func_src_available = "logical",
        func_src_start = "numeric",
        func_src_end = "numeric",
        call_lines = "numeric",
        calls = "character",
        timestamp = "POSIXct"
    )
)

#' Create a new Hunt object
#'
#' Constructor function for creating a Hunt object from the components
#' typically captured by the hunter function.
#'
#' @param error_message character. The error message.
#' @param frames list. Environment frames from the call stack.
#' @param func_src_codes list. Source codes of functions.
#' @param func_src_available logical. Source code availability flags.
#' @param func_src_start numeric. Starting line numbers.
#' @param func_src_end numeric. Ending line numbers.
#' @param call_lines numeric. Call line numbers.
#' @param calls list. Call expressions.
#' @param timestamp POSIXct. Timestamp when hunt was captured.
#'
#' @return A Hunt object
#' @export
newHunt <- function(
    error_message, frames, 
    func_names, func_src_codes, func_src_available,
    func_src_start, func_src_end, 
    call_lines, calls, timestamp) {
    .Hunt(
        error_message = error_message,
        frames = frames,
        func_names = func_names,
        func_src_codes = func_src_codes,
        func_src_available = func_src_available,
        func_src_start = func_src_start,
        func_src_end = func_src_end,
        call_lines = call_lines,
        calls = calls,
        timestamp = timestamp
    )
}

setAs("Hunt", "list", function(from) {
    list(
        error_message = from@error_message,
        frames = from@frames,
        func_names = from@func_names,
        func_src_codes = from@func_src_codes,
        func_src_available = from@func_src_available,
        func_src_start = from@func_src_start,
        func_src_end = from@func_src_end,
        call_lines = from@call_lines,
        calls = from@calls,
        timestamp = from@timestamp
    )
})

setMethod("as.list", signature = "Hunt",
  definition = function(x) {
    as(x, "list")
  }
)




#' Show method for Hunt
#'
#' @param object Hunt object
#' @export 
setMethod("show", "Hunt", function(object) {
    cat("Hunt object\n")
    cat("==================\n")
    cat("Error message:", object@error_message, "\n")
    cat("Timestamp:", format(object@timestamp), "\n")
    cat("Number of frames:", length(object@frames), "\n")
    
    if (length(object@calls) > 0) {
        cat("\nCall stack:\n")
        for (i in seq_along(object@calls)) {
            src_info <- if (!is.na(object@call_lines[i])) {
                paste0(" (line ", object@call_lines[i], ")")
            } else {
                ""
            }
            cat("  ", i, ": ", object@func_names[i], src_info, "\n", sep = "")
        }
    }
})

#' Length method for Hunt
#'
#' Returns the number of frames/calls in the hunt
#'
#' @param x Hunt object
#' @export 
setMethod("length", "Hunt", function(x) {
    length(x@calls)
})

#' Summary method for Hunt
#'
#' @param object Hunt object
#' @export 
setMethod("summary", "Hunt", function(object) {
    cat("Hunt Summary\n")
    cat("===================\n")
    cat("Error:", object@error_message, "\n")
    cat("Captured:", format(object@timestamp), "\n")
    cat("Stack depth:", length(object@calls), "\n")
    cat("Functions with source available:", sum(object@func_src_available), "of", length(object@func_src_available), "\n")
    
    if (any(!is.na(object@call_lines))) {
        cat("Line numbers available for", sum(!is.na(object@call_lines)), "calls\n")
    }
})