#' @include class-Capture.R
NULL

#####################################
# Call stack methods
#####################################

#' @export
setMethod("getEditorCode", "Capture", function(capture, frameIdx) {
    paste0(capture@func_src_codes[[frameIdx]], collapse = "\n")
})

#' @export
setMethod("getStopAtLine", "Capture", function(capture, frameIdx) {
    capture@stop_at_lines[[frameIdx]]
})

#' @export
setMethod("getCallName", "Capture", function(capture, frameIdx) {
    capture@calls[[frameIdx]]
})



#####################################
# Environment methods
#####################################

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
        value <- getVarValue(val)
        env_desc[[nm]] <- data.frame(
            var = nm,
            type = class(val)[1],
            value = value,
            stringsAsFactors = FALSE
        )
    }
    env_desc <- do.call(rbind, env_desc)
    if (is.null(env_desc)) {
        env_desc <- data.frame(
            var = character(0),
            type = character(0),
            value = character(0),
            stringsAsFactors = FALSE
        )
    }


    # order by: type, var name
    env_desc <- env_desc[order(env_desc$type, env_desc$var), ]
    rownames(env_desc) <- NULL
    env_desc
})


#' @export
setMethod("getEnvVarDetail", "Capture", function(capture, frameIdx, varName) {
    frame <- capture@frames[[frameIdx]]
    val <- suppressWarnings(
        tryCatch(
            get(varName, envir = frame, inherits = FALSE), 
            error = function(e) e
        )
    )
    details <- tryCatch({
        if (is.function(val)) {
            capture.output(print(val))
        } else {
            capture.output(str(val))
        }
    }, error = function(e) {
        "Error retrieving details"
    })
    paste(details, collapse = "\n")
})

#####################################
# Code editor methods
#####################################

#' @export
setMethod("isCodeEditable", "Capture", function(capture, frameIdx) {
    FALSE
})


#####################################
# console code evaluation methods
#####################################

#' @export
setMethod("evalCode", "Capture", function(capture, frameIdx, code) {
    frame <- capture@frames[[frameIdx]]
    eval(parse(text = code), envir = frame)
})
