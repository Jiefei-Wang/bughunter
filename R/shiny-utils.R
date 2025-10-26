#' get a description of a single variable
#' 
#' Describe a variable for environment display, returning a string representation
#'  
describeVariable <- function(val){
    desc <- tryCatch({
        if (is.atomic(val)) {
            values <- capture.output(dput(val))
            paste(values, collapse = "\n")
        } else if (is.data.frame(val)) {
            values <- paste0(colnames(val) , collapse = ", ")
            glue("[{nrow(val)} x {ncol(val)}] {values}")
        } else if (is(val, "condition")) {
            val$message
        } else if (is.list(val)) {
            glue("{length(val)} values: {paste(names(val), collapse = ', ')}")
        } else if (is.function(val)) {
            values <- capture.output(print(val))
            paste(values, collapse = "\n")
        } else {
            values <- capture.output(str(val, max.level = 1))
            paste(values, collapse = "\n")
        }
    }, error = function(e) {
        glue("Error retrieving value")
    })
}
