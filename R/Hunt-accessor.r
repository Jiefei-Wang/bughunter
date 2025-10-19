#' @include Hunt-class.r
NULL

#' @export 
setGeneric("getFrameNumber", function(object) standardGeneric("getFrameNumber"))
#' @export 
setGeneric("getFrame", function(object, i) standardGeneric("getFrame"))
#' @export 
setGeneric("getFunction", function(object, i) standardGeneric("getFunction"))

#' @export 
setMethod("getFrameNumber", "Hunt", function(object) {
    length(object@frames)
})

#' @export 
setMethod("getFrame", "Hunt", function(object, i) {
    if (i < 1 || i > length(object@frames)) {
        stop("Frame index out of bounds")
    }
    frame
})

#' @export 
setMethod("getFunction", "Hunt", function(object, i) {
    if (i < 1 || i > length(object@calls)) {
        stop("Function index out of bounds")
    }
    list(
        call = object@calls[[i]],
        func_name = object@func_names[[i]],
        src_code = object@func_src_codes[[i]],
        src_available = object@func_src_available[[i]],
        src_start = object@func_src_start[[i]],
        src_end = object@func_src_end[[i]]
    )
})