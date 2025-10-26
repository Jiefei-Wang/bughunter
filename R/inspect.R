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

#' Create UI for Bug Viewer Application
#'
#' Creates the user interface with menu bar, toolbar, and 4-panel layout for debugging R code.
#'
#' @param initial_trace Optional initial trace object
#' @return Shiny UI object
#' @keywords internal
create_ui <- function(initial_trace = NULL) {
    page_fillable(
        tags$head(
            tags$style(get_app_styles()),
            get_app_javascript()
        ),

        # Menu bar
        create_menu_bar(),

        # Panel container with 4-pane layout
        layout_columns(
            card(
                card_header("Card 1"),
                create_source_panel(),
                full_screen = FALSE,
                height = "100%"
            ),
            card(
                card_header("Card 2"),
                full_screen = FALSE,
                height = "100%"
            )
        ),
        
        layout_columns(
            card(
                card_header("Card 3"),
                full_screen = FALSE,
                height = "100%"
            ),
            card(
                card_header("Card 4"),
                create_callstack_panel(),
                full_screen = FALSE,
                height = "100%"
            )
        ),

        row_heights = c("auto", "1fr", "1fr")


        # class = "panel-container",
        # # Top row (Source | Environment)
        # div(
        #     class = "panel-row",
        #     div(
        #         class = "panel-col",
        #         create_source_panel()
        #     ),
        #     div(
        #         class = "panel-col",
        #         create_environment_panel()
        #     )
        # ),

        # # Bottom row (Console | Call Stack with Error)
        # div(
        #     class = "panel-row",
        #     div(
        #         class = "panel-col",
        #         create_console_panel()
        #     ),
        #     div(
        #         class = "panel-col",
        #         create_callstack_panel()
        #     )
        # )
    )
}

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

    # Reactive values to track content and highlighted line
    current_code <- reactiveVal("")
    highlighted_line <- reactiveVal(1)  # 1-based line number

    registerEditorEvents(input, output, session, trace, current_code, highlighted_line, selected_frame)

    registerCallStackEvents(input, output, session, trace, current_code, highlighted_line, selected_frame)


}
