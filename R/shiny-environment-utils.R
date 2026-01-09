#' get a description of a single variable
#' 
#' Describe a variable for environment display, returning a string representation
#'  
getVarValue <- function(val){
    value <- tryCatch({
        if (is.data.frame(val)) {
            columns <- paste0(colnames(val) , collapse = ", ")
            glue("[{nrow(val)} x {ncol(val)}] {columns}")
        } else if (is(val, "condition")) {
            val$message
        } else if (is.list(val)) {
            glue("{length(val)} values: {paste(names(val), collapse = ', ')}")
        } else if (is.function(val)) {
            capture.output(print(val))
        } else {
            capture.output(str(val, max.level = 1))
        }
    }, error = function(e) {
        "Error retrieving value"
    })
    paste0(value, collapse = "\n")
}