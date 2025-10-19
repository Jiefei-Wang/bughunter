

#' Hunt Call Stacks for Error Debugging
#'
#' This function captures the call stack, deparsed code for each frame, and line numbers
#' when an error occurs. It stores the information in a package environment for later retrieval.
#' Use with options(error = hunter) to automatically capture errors.
#'
#' @param condition The condition object (typically an error)
#' @return Invisible NULL
#' @export
hunter <- function() {
    # Temporarily unset the error handler to prevent recursion
    error <- getOption("error")
    options(error = NULL)
    on.exit(options(error = error), add = TRUE)

    # browser()
    # Get the error message from R's last error
    error_msg <- geterrmessage()

    # Get the call stack (excluding this function itself)
    calls <- sys.calls()
    frames <- sys.frames()

    # Remove the last call (this hunter function)
    if (length(calls) > 0) {
        calls <- calls[-length(calls)]
        frames <- frames[-length(frames)]
    }

    #######################
    ## Obtain information about the function being called
    #######################

    func_names <- sapply(calls, function(call) as.character(call[[1]]))
    functions <- list()
    for (i in seq_along(func_names)){
        func_name <- func_names[i]
        if (i == 1) {
            # If at the top frame, the function should be from the global environment
            frame <- .GlobalEnv
        }else{
            # Otherwise, get the function from the previous frame
            frame <- frames[[i - 1]]
        }
        if (exists(func_name, envir = frame, inherits = TRUE)) {
            func <- get(func_name, envir = frame, inherits = TRUE)
            functions[[i]] <- func
        } else {
            functions[[i]] <- NULL
        }
    } 
    
    func_srcrefs <- lapply(functions, attr, "srcref")
    func_srcfiles <- lapply(func_srcrefs, attr, "srcfile")
    func_src_codes <- sapply(func_srcfiles, function(sf) if (!is.null(sf)) sf$lines else NA)
    func_src_start <- sapply(func_srcrefs, function(sr) if (!is.null(sr)) sr[1] else NA)
    func_src_end <- sapply(func_srcrefs, function(sr) if (!is.null(sr)) sr[3] else NA)
    # browser()
    func_src_available <- sapply(func_src_codes, function(code) !identical(code, NA))
    # Handle cases where source code is not available
    for (i in seq_along(func_src_codes)) {
        if (!func_src_available[[i]]) {
            func_src_code <- deparse(functions[[i]])
            func_src_start[[i]] <- 1
            func_src_end[[i]] <- length(func_src_code)
            func_src_codes[[i]] <- func_src_code
        }
    }
    #######################
    ## Obtain information about the location of each call
    #######################
    call_srcrefs <- lapply(calls, attr, "srcref")
    call_lines <- sapply(call_srcrefs, function(sr) if (!is.null(sr)) sr[1] else NA)

    calls_char <- sapply(calls, function(call) deparse(call))

    # Store in package environment
    bughunter_env$last_hunt <- .Hunt(
        error_message = error_msg,
        frames = frames,
        func_names = func_names,
        func_src_codes = func_src_codes,
        func_src_available = func_src_available,
        func_src_start = func_src_start,
        func_src_end = func_src_end,
        call_lines = call_lines,
        calls = calls_char,
        timestamp = Sys.time()
    )
  
  
    # Don't re-throw - let R handle the error normally
    invisible(NULL)
}
