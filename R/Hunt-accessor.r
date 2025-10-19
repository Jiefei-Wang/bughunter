setGeneric("getFrameNumber", function(object) standardGeneric("getFrameNumber"))
setGeneric("getFrame", function(object, i) standardGeneric("getFrame"))
setGeneric("getFunction", function(object, i) standardGeneric("getFunction"))


setMethod("getFrameNumber", "Hunt", function(object) {
    length(object@frames)
})

setMethod("getFrame", "Hunt", function(object, i) {
    if (i < 1 || i > length(object@frames)) {
        stop("Frame index out of bounds")
    }
    list(
        frame = object@frames[[i]],
        func_name = object@func_names[[i]],
        call = object@calls[[i]]
    )
})

setMethod("getFunction", "Hunt", function(object, i) {
    if (i < 1 || i > length(object@calls)) {
        stop("Function index out of bounds")
    }
    list(
        call = object@calls[[i]],
        src_code = object@func_src_codes[[i]],
        src_available = object@func_src_available[[i]],
        src_start = object@func_src_start[[i]],
        src_end = object@func_src_end[[i]]
    )
})