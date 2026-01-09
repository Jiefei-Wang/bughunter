#' @include class-TextCapture.R
NULL

#####################################
# Environment methods for TextCapture
#####################################

#' Get environment descriptor for TextCapture
#' 
#' TextCapture stores serialized environment information as character strings.
#' This method extracts the pre-saved descriptor information.
#' 
#' @export
setMethod("getEnvDescriptor", "TextCapture", function(capture, frameIdx) {
    frame <- capture@frames[[frameIdx]]
    
    # The descriptor should be saved in the frame
    if (is.list(frame) && !is.null(frame$descriptor)) {
        return(frame$descriptor)
    }
    
    # If stored as a single element, return it directly
    if (is.data.frame(frame)) {
        return(frame)
    }
    
    # Return empty descriptor if nothing found
    data.frame(
        var = character(0),
        type = character(0),
        value = character(0),
        details = character(0),
        stringsAsFactors = FALSE
    )
})


#' Get environment variable detail for TextCapture
#' 
#' TextCapture stores serialized variable details as character strings.
#' This method extracts the pre-saved detail information for a specific variable.
#' 
#' @export
setMethod("getEnvVarDetail", "TextCapture", function(capture, frameIdx, varName) {
    frame <- capture@frames[[frameIdx]]
    
    # Get the descriptor to find the details
    descriptor <- getEnvDescriptor(capture, frameIdx)
    
    # Find the row for the requested variable
    if (nrow(descriptor) > 0 && varName %in% descriptor$var) {
        idx <- which(descriptor$var == varName)
        if (length(idx) > 0 && "details" %in% names(descriptor)) {
            return(descriptor$details[idx[1]])
        }
    }
    
    # If stored differently in the frame structure
    if (is.list(frame) && !is.null(frame$details) && !is.null(frame$details[[varName]])) {
        return(frame$details[[varName]])
    }
    
    # Return message if details not found
    "Details not available for this variable"
})


#####################################
# Console code evaluation methods for TextCapture
#####################################

#' Evaluate code for TextCapture
#' 
#' TextCapture does not have live environments, so code evaluation is limited.
#' If the code is a simple variable name, returns the variable's details.
#' Otherwise, returns an error message.
#' 
#' @export
setMethod("evalCode", "TextCapture", function(capture, frameIdx, code) {
    # Parse code to check if it's a single variable
    parsed <- tryCatch(parse(text = code), error = function(e) NULL)
    
    # Check if parsed successfully and is a single symbol (variable name)
    if (!is.null(parsed) && length(parsed) == 1 && is.symbol(parsed[[1]])) {
        varName <- as.character(parsed[[1]])
        frame <- capture@frames[[frameIdx]]
        if (varName %in% frame$var) {
            # Return the variable detail if it exists
            return(getEnvVarDetail(capture, frameIdx, varName))
        } else {
            return(paste0("Variable '", varName, "' not found in this frame."))
        }
    }
    
    # Return error message as character
    "Error: Code evaluation is not supported for TextCapture. Only a single variable can be displayed."
})
