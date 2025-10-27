

#####################################
# Call stack methods
#####################################

#' @export
setGeneric("getEditorCode", function(capture, frameIdx) standardGeneric("getEditorCode"))
#' @export
setMethod("getEditorCode", "Capture", function(capture, frameIdx) {
    paste0(capture@func_src_codes[[frameIdx]], collapse = "\n")
})

#' @export
setGeneric("getStopAtLine", function(capture, frameIdx) standardGeneric("getStopAtLine"))

#' @export
setMethod("getStopAtLine", "Capture", function(capture, frameIdx) {
    capture@stop_at_lines[[frameIdx]]
})

#' @export
setGeneric("getCallName", function(capture, frameIdx) standardGeneric("getCallName"))

#' @export
setMethod("getCallName", "Capture", function(capture, frameIdx) {
    capture@calls[[frameIdx]]
})



#####################################
# Environment methods
#####################################

#' @export
setGeneric("getEnvDescriptor", function(capture, frameIdx) standardGeneric("getEnvDescriptor"))

#' @export
setMethod("getEnvDescriptor", "Capture", function(capture, frameIdx) {
    nchar <- 40
    frame <- capture@frames[[frameIdx]]
    env_desc <- list()
    for (nm in ls(envir = frame, all.names = TRUE)) {
        val <- suppressWarnings(
            tryCatch(
                get(nm, envir = frame, inherits = FALSE), 
                error = function(e) e
            )
        )
        details <- describeVariable(val)

        value <- details
        if (nchar(value) > nchar) {
            value <- paste0(substr(value, 1, nchar - 3), "...")
        }
        env_desc[[nm]] <- data.frame(
            Var = nm,
            Type = class(val)[1],
            Value = value,
            details = details,
            stringsAsFactors = FALSE
        )
    }
    env_desc <- do.call(rbind, env_desc)
    if (is.null(env_desc)) {
        env_desc <- data.frame(
            Var = character(0),
            Type = character(0),
            Value = character(0),
            details = character(0),
            stringsAsFactors = FALSE
        )
    }


    # order by: type, var name
    env_desc <- env_desc[order(env_desc$Type, env_desc$Var), ]
    rownames(env_desc) <- NULL
    env_desc
})


#####################################
# Code editor methods
#####################################

#' @export
setGeneric("isCodeEditable", function(capture, frameIdx) standardGeneric("isCodeEditable"))
#' @export
setMethod("isCodeEditable", "Capture", function(capture, frameIdx) {
    FALSE
})



#####################################
# console code evaluation methods
#####################################
#' @export
setGeneric("isEvalable", function(capture, frameIdx) standardGeneric("isEvalable"))
#' @export
setMethod("isEvalable", "Capture", function(capture, frameIdx) {
    FALSE
})

#' @export
setGeneric("evalCode", function(capture, frameIdx, code) standardGeneric("evalCode"))
#' @export
setMethod("evalCode", "Capture", function(capture, frameIdx, code) {
    frame <- capture@frames[[frameIdx]]
    eval(parse(text = code), envir = frame)
})
