
setGeneric("evalCode", function(capture, frameIdx, code) standardGeneric("evalCode"))

setMethod("evalCode", "Capture", function(capture, frameIdx, code) {
    frame <- capture@frames[[frameIdx]]
    eval(parse(text = code), envir = frame)
})



registerConsoleEvents <- function(input, output, session, capture, selected_frame) {
  # Receive command strings from JS: input$term_cmd
  observeEvent(input$term_cmd, {
    print(glue("Received console command: {input$term_cmd}"))
    cmd <- input$term_cmd
    # Safety: ignore empty
    if (!nzchar(trimws(cmd))) {
        print("Ignoring empty command")
        session$sendCustomMessage("term_out", list(
            type = "echo", text = ""
        ))
    }else{
        txt <- NULL
        err <- NULL
        warn <- NULL
        val <- NULL

        # Capture both printed output and value
        txt <- tryCatch(
            {
                val <- evalCode(capture, selected_frame(), cmd)
                output <- capture.output(print(val))
                paste(output, collapse = "\n")
            },
            error = function(e) {
                err <<- conditionMessage(e)
                ""
            },
            warning = function(w) {
                warn <<- conditionMessage(w)
                ""
            }
        )

        if (!is.null(err)) {
            session$sendCustomMessage("term_out", list(
                type = "error", text = err
            ))
        } else if (!is.null(warn)) {
            session$sendCustomMessage("term_out", list(
                type = "warning", text = warn
            ))
        } else {
            session$sendCustomMessage("term_out", list(
                type = "output", text = txt
            ))
        }
    }
  })

  # Clear request from JS (Ctrl+L)
  observeEvent(input$term_clear, {
    session$sendCustomMessage("term_out", list(
      type = "clear", text = ""
    ))
  })
}
