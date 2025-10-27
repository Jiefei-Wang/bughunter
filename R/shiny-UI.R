panel_card <- function(...){
    card(
        ...,
        full_screen = TRUE,
        height = "100%",
        fill = FALSE
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
        get_app_styles(),
        get_app_javascript(),

        # Menu bar
        create_menu_bar(),
        # Panel container with 4-pane layout
        layout_columns(
            panel_card(
                card_header("Code"),
                create_source_panel()
            ),
            panel_card(
                card_header("Environment"),
                create_environment_panel()
            ),
            height = "50%"
        ),
        layout_columns(
            panel_card(
                card_header("Console"),
                create_console_panel()
            ),
            panel_card(
                card_header("Call Stack"),
                create_callstack_panel()
            ),
            height = "50%"
        )
    )
}





#' Create Menu Bar UI
#'
#' @return Shiny UI element for the menu bar
#' @keywords internal
create_menu_bar <- function() {
  div(
    class = "menu-bar",
    # Left side - File menu
    div(
      class = "file-menu-container",
      shiny::actionLink("file_menu", "File", class = "file-menu-link"),
      shiny::conditionalPanel(
        condition = "input.show_file_menu",
        div(
          id = "file_menu_dropdown",
          div(
            shiny::actionButton("open_file", "Open File...", 
                               class = "file-menu-button",
                               onclick = "this.style.background='#f0f0f0'",
                               onmouseout = "this.style.background='white'")
          )
        )
      )
    ),
    # Right side - Error message
    div(
      id = "error_message_container",
      div(
        class = "error-message-box",
        shiny::uiOutput("error_message")
      )
    )
  )
}


#' Create Source Panel UI
#'
#' @return Shiny UI element for the source code panel
#' @keywords internal
create_source_panel <- function() {
  shinyAce::aceEditor(
        outputId = "code_editor",
        value = "",
        mode = "r",
        theme = "github",
        height = "100%",
        fontSize = 12,
        showLineNumbers = TRUE,
        highlightActiveLine = TRUE,
        wordWrap = FALSE,
        readOnly = FALSE,
        autoComplete = "enabled",
        autoScrollEditorIntoView = TRUE,
        maxLines = Inf,
        minLines = 1
    )
}

#' Create Environment Panel UI
#'
#' @return Shiny UI element for the environment panel
#' @keywords internal
create_environment_panel <- function() {
#   tableOutput("env_table") 
  reactableOutput("env_table")
}

#' Create Console Panel UI
#'
#' @return Shiny UI element for the console panel
#' @keywords internal
create_console_panel <- function() {
    tags$div(id = "terminal", class = "terminal")
}

#' Create Call Stack Panel UI
#'
#' @return Shiny UI element for the call stack panel
#' @keywords internal
create_callstack_panel <- function() {
  div(class = "stack-container",
      div(class = "stack-block",
        shiny::uiOutput("stack_list")
      )
    )
}