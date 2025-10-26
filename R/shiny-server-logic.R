

#' Create Server Logic for Bug Viewer Application
#'
#' Handles the reactive state management and user interactions for the debugging interface.
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param initial_trace Optional initial trace object
#' @return Server function
#' @keywords internal
create_server <- function(input, output, session, trace = NULL) {
    
    nCalls <- length(trace)
    # Reactive value to track selected frame
    selected_frame <- reactiveVal(nCalls)

    environment_dt <- reactiveVal(data.frame(var = 1, value = 2))

    # Reactive values to track content and highlighted line
    current_code <- reactiveVal("")
    highlighted_line <- reactiveVal(1)  # 1-based line number

    registerEditorEvents(input, output, session, trace, current_code, highlighted_line, selected_frame)

    registerCallStackEvents(input, output, session, trace, selected_frame)

    registerEnvironmentEvents(input, output, session, trace, selected_frame, environment_dt)
}



