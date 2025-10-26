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