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

      # Store the environment object for the stack
      stack[[i]] <- frame

      # Attempt to get line number and source code
      line_num <- NA
      src <- paste(deparse(call), collapse = "\n")  # Default to the call itself
      
      tryCatch({
        # Get the function being called
        func_name <- as.character(call[[1]])
        
        # Try to get the actual function object
        func <- tryCatch({
          # First try to get from the frame
          if (exists(func_name, envir = frame, inherits = FALSE)) {
            get(func_name, envir = frame)
          } else if (exists(func_name, envir = parent.frame(i), inherits = TRUE)) {
            get(func_name, envir = parent.frame(i), inherits = TRUE)
          } else {
            NULL
          }
        }, error = function(e) NULL)
        
        if (is.function(func)) {
          # Get the source reference from the function
          func_srcref <- attr(func, "srcref")
          
          if (!is.null(func_srcref)) {
            # Get the complete function body from source
            srcfile <- attr(func_srcref, "srcfile")
            if (!is.null(srcfile) && !is.null(srcfile$lines)) {
              # Extract all lines of the function
              func_lines <- srcfile$lines[func_srcref[1]:func_srcref[3]]
              src <- paste(func_lines, collapse = "\n")
            } else {
              # Try to get from the srcref itself
              src <- paste(as.character(func_srcref), collapse = "\n")
            }
          } else {
            # No srcref, deparse the function
            src <- paste(deparse(func), collapse = "\n")
          }
          
          # Get line number from the call's srcref
          call_srcref <- attr(call, "srcref")
          if (!is.null(call_srcref)) {
            line_num <- as.integer(call_srcref[1])
          }
        } else {
          # Not a function, just get the call line
          srcref <- attr(call, "srcref")
          if (!is.null(srcref)) {
            line_num <- as.integer(srcref[1])
            src_text <- as.character(srcref)
            if (length(src_text) > 0) {
              src <- paste(src_text, collapse = "\n")
            }
          }
        }
      }, error = function(e) {
        # If extraction fails, keep defaults
      })

      # Store the information
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