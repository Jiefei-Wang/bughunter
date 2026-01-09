

#####################################
# Call stack generics
#####################################

#' @export
setGeneric("getStopAtLine", function(capture, frameIdx) standardGeneric("getStopAtLine"))

#' @export
setGeneric("getCallName", function(capture, frameIdx) standardGeneric("getCallName"))


#####################################
# Environment generics
#####################################

#' @export
setGeneric("getEnvDescriptor", function(capture, frameIdx) standardGeneric("getEnvDescriptor"))

#' @export
setGeneric("getEnvVarDetail", function(capture, frameIdx, varName) standardGeneric("getEnvVarDetail"))


#####################################
# Code editor generics
#####################################
#' @export
setGeneric("getEditorCode", function(capture, frameIdx) standardGeneric("getEditorCode"))

#' @export
setGeneric("isCodeEditable", function(capture, frameIdx) standardGeneric("isCodeEditable"))


#####################################
# console code evaluation generics
#####################################

#' @export
setGeneric("evalCode", function(capture, frameIdx, code) standardGeneric("evalCode"))
