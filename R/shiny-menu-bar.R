
setGeneric("getErrorMsg", function(capture) standardGeneric("getErrorMsg"))
#' @export
setMethod("getErrorMsg", "Capture", function(capture) {
    # capture@error_message
    "test\nnew line\nanother line"
})



registerMenuBarEvents <- function(input, output, session, capture) {
  output$error_message <- renderUI({
    if (is.null(capture)) return(NULL)

    err_msg <- getErrorMsg(capture)
    ## multi-line support
    err_msg_lines <- strsplit(err_msg, "\n")[[1]]
    err_msg_html <- paste(err_msg_lines, collapse = "<br/>")
    if (nzchar(err_msg)) {
        div(
            style = "font-size: 12px; color: #721c24;",
            HTML(err_msg_html)
        )
    } else {
        NULL
    }
  })
}