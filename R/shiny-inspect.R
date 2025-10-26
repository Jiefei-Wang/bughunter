#' Launch Bug Viewer Shiny Application
#'
#' This function launches a Shiny application for debugging R code using trace information
#' from the bugtracer package. It can be called with a trace object directly, or without
#' arguments to launch the app with a file menu for loading trace files.
#'
#' @param trace Optional trace object containing stack frames, code, line numbers, and error message.
#'   If NULL, the app launches with a file menu to load trace files.
#' @return Launches a Shiny application (invisible return)
#' @export
inspect <- function(trace = NULL) {
    # Launch the Shiny application
    shiny::shinyApp(
        ui = create_ui(trace),
        server = function(input, output, session) {
            create_server(input, output, session, trace)
        }
    )
}
