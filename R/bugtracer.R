# Package environment to store trace data
bugtracer_env <- new.env(parent = emptyenv())

#' Trace Condition Handler for Error Debugging
#'
#' This function captures the call stack, deparsed code for each frame, and line numbers
#' when an error occurs. It stores the information in a package environment for later retrieval.
#' Use with options(error = traceCondition) to automatically capture errors.
#'
#' @param condition The condition object (typically an error)
#' @return Invisible NULL
#' @export
traceCondition <- function() {
  # Temporarily unset the error handler to prevent recursion
  options(error = NULL)

  tryCatch({
    # Get the error message from R's last error
    error_msg <- geterrmessage()
    
    # Get the call stack (excluding this function itself)
    calls <- sys.calls()
    frames <- sys.frames()
    
    # Remove the last call (this traceCondition function)
    if (length(calls) > 0) {
      calls <- calls[-length(calls)]
      frames <- frames[-length(frames)]
    }

    # Initialize lists to store data
    stack <- list()
    code <- list()
    line_numbers <- list()

    # Iterate through the call stack
    for (i in seq_along(calls)) {
      call <- calls[[i]]
      frame <- frames[[i]]

      # Get the function name or call
      func_name <- deparse(call[[1]])[1]

      # Get the source code for this frame if available
      src <- tryCatch({
        deparse(call)
      }, error = function(e) {
        "Source not available"
      })

      # Attempt to get line number (this is approximate)
      line_num <- tryCatch({
        # Use sys.parent to find the calling frame
        calling_frame <- sys.parent(i)
        if (calling_frame > 0) {
          # Get the source reference if available
          srcref <- attr(sys.function(calling_frame), "srcref")
          if (!is.null(srcref)) {
            # Return the line number where the call was made
            srcref[1]
          } else {
            NA
          }
        } else {
          NA
        }
      }, error = function(e) {
        NA
      })

      # Store the information
      stack[[i]] <- func_name
      code[[i]] <- src
      line_numbers[[i]] <- line_num
    }

    # Store in package environment
    bugtracer_env$last_trace <- list(
      error_message = error_msg,
      stack = stack,
      code = code,
      line_numbers = line_numbers,
      timestamp = Sys.time()
    )
  }, error = function(e) {
    # If something goes wrong, silently fail to avoid breaking error handling
    warning("bugtracer::traceCondition failed: ", conditionMessage(e))
  })
  
  # Don't re-throw - let R handle the error normally
  invisible(NULL)
}

#' Get the Last Stored Trace Data
#'
#' Retrieves the most recent trace data captured by traceCondition.
#'
#' @return A list containing error_message, stack, code, line_numbers, and timestamp,
#'         or NULL if no trace data is available.
#' @export
getLastTrace <- function() {
  bugtracer_env$last_trace
}