#' Bug Capture Class
#'
#' An S4 class to represent a bug capture captured by the hunter function.
#' This class provides a structured container for all capture information
#' including error details, call stack, and source code information.
#'
#' @slot error_message character. The error message that was captured.
#' @slot frames list. List of environment frames from the call stack.
#' @slot func_src_codes list. Source codes of the functions in the call stack.
#' @slot func_src_available logical. Whether source code is available for each function.
#' @slot func_src_start numeric. Starting line numbers for each function's source code.
#' @slot func_src_end numeric. Ending line numbers for each function's source code.
#' @slot stop_at_lines numeric. Line numbers where the code stopped in each call.
#' @slot calls list. The actual call expressions from the stack.
#' @slot timestamp POSIXct. When the capture was captured.
#'
#' @exportClass Capture
.Capture <- setClass(
    "Capture",
    slots = list(
        error_message = "character",
        frames = "list",
        func_names = "character",
        func_src_codes = "list",
        func_src_available = "logical",
        func_src_start = "numeric",
        func_src_end = "numeric",
        stop_at_lines = "numeric",
        calls = "character",
        timestamp = "POSIXct"
    )
)

#' Create a new Capture object
#'
#' Constructor function for creating a Capture object from the components
#' typically captured by the hunter function.
#'
#' @param error_message character. The error message.
#' @param frames list. Environment frames from the call stack.
#' @param func_src_codes list. Source codes of functions.
#' @param func_src_available logical. Source code availability flags.
#' @param func_src_start numeric. Starting line numbers.
#' @param func_src_end numeric. Ending line numbers.
#' @param stop_at_lines numeric. Stop at line numbers.
#' @param calls list. Call expressions.
#' @param timestamp POSIXct. Timestamp when capture was captured.
#'
#' @return A Capture object
#' @export
newCapture <- function(
    error_message, frames, 
    func_names, func_src_codes, func_src_available,
    func_src_start, func_src_end, 
    stop_at_lines, calls, timestamp) {
    .Capture(
        error_message = error_message,
        frames = frames,
        func_names = func_names,
        func_src_codes = func_src_codes,
        func_src_available = func_src_available,
        func_src_start = func_src_start,
        func_src_end = func_src_end,
        stop_at_lines = stop_at_lines,
        calls = calls,
        timestamp = timestamp
    )
}

#' @export
setAs("Capture", "list", function(from) {
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

# setMethod("as.list", signature = "Capture",
#   definition = function(x) {
#     as(x, "list")
#   }
# )




#' Show method for Capture
#'
#' @param object Capture object
#' @export 
setMethod("show", "Capture", function(object) {
    cat(glue("Capture Object with {length(object)} calls"))
    cat("\n")
    for (i in seq_len(length(object))) {
        msg <- glue("Frame {i}: {object@calls[i]} stopped at line {object@stop_at_lines[i]}")
        cat(msg)
        cat("\n")
    }
})

#' Length method for Capture
#'
#' Returns the number of frames/calls in the capture
#'
#' @param x Capture object
#' @export 
setMethod("length", "Capture", function(x) {
    length(x@calls)
})
