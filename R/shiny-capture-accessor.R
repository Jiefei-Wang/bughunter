setGeneric("getEditorCode", function(capture, frameIdx) standardGeneric("getEditorCode"))

setMethod("getEditorCode", "Capture", function(capture, frameIdx) {
    paste0(capture@func_src_codes[[frameIdx]], collapse = "\n")
})

# getCallLine
setGeneric("getStopAtLine", function(capture, frameIdx) standardGeneric("getStopAtLine"))

setMethod("getStopAtLine", "Capture", function(capture, frameIdx) {
    capture@stop_at_lines[[frameIdx]]
})

setGeneric("getCallName", function(capture, frameIdx) standardGeneric("getCallName"))

setMethod("getCallName", "Capture", function(capture, frameIdx) {
    capture@calls[[frameIdx]]
})




setGeneric("getEnvDescriptor", function(capture, frameIdx) standardGeneric("getEnvDescriptor"))

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
    # order by: type, var name
    env_desc <- env_desc[order(env_desc$Type, env_desc$Var), ]
    rownames(env_desc) <- NULL
    env_desc
})




setGeneric("isCodeEditable", function(capture, frameIdx) standardGeneric("isCodeEditable"))

setMethod("isCodeEditable", "Capture", function(capture, frameIdx) {
    FALSE
})
