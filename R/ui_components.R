#' Create Menu Bar UI
#'
#' @return Shiny UI element for the menu bar
#' @keywords internal
create_menu_bar <- function() {
  div(
    style = "background: #f5f5f5; border-bottom: 1px solid #ddd; padding: 4px 10px;",
    div(
      style = "display: inline-block; position: relative;",
      shiny::actionLink("file_menu", "File", 
                       style = "padding: 4px 12px; display: inline-block; cursor: pointer;"),
      shiny::conditionalPanel(
        condition = "input.show_file_menu",
        div(
          id = "file_menu_dropdown",
          style = "position: absolute; top: 100%; left: 0; background: white; border: 1px solid #ddd; box-shadow: 0 2px 4px rgba(0,0,0,0.1); z-index: 1000; min-width: 150px;",
          div(
            shiny::actionButton("open_file", "Open File...", 
                               style = "width: 100%; text-align: left; border: none; background: white; padding: 8px 12px; cursor: pointer;",
                               onclick = "this.style.background='#f0f0f0'",
                               onmouseout = "this.style.background='white'")
          )
        )
      )
    ),
    tags$script(shiny::HTML("
      $(document).on('click', '#file_menu', function(e) {
        e.stopPropagation();
        Shiny.setInputValue('show_file_menu', !Shiny.shinyapp.$inputValues.show_file_menu, {priority: 'event'});
      });
      $(document).on('click', function(e) {
        if (!$(e.target).closest('#file_menu').length) {
          Shiny.setInputValue('show_file_menu', false, {priority: 'event'});
        }
      });
    "))
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
  div(class = "panel",
    div(class = "panel-header", "Environment"),
    div(class = "panel-body",
      shiny::verbatimTextOutput("environment_display", placeholder = TRUE)
    )
  )
}

#' Create Console Panel UI
#'
#' @return Shiny UI element for the console panel
#' @keywords internal
create_console_panel <- function() {
  div(class = "panel",
    div(class = "panel-header", "Console"),
    div(class = "panel-body",
      div(class = "console-container",
        div(id = "console_output", class = "console-output",
          shiny::uiOutput("console_output_ui")
        ),
        div(class = "console-inputline",
          shiny::span(class = "console-prompt", "> "),
          tags$textarea(id = "console_input", class = "console-input", rows = 1,
                              placeholder = "Type R code. Enter to run, Ctrl+Enter for newline...")
        )
      )
    )
  )
}

#' Create Call Stack Panel UI
#'
#' @return Shiny UI element for the call stack panel with error message at bottom
#' @keywords internal
create_callstack_panel <- function() {
  div(
    div(class = "stack-container",
      div(class = "stack-block",
        shiny::uiOutput("stack_list")
      ),
      # Error message at the bottom
      shiny::conditionalPanel(
        condition = "output.has_error == true",
        div(
          style = "margin-top: 8px; padding: 8px; background: #ffebee; border: 1px solid #ef5350; border-radius: 3px; flex-shrink: 0;",
          div(style = "font-weight: 600; color: #c62828; margin-bottom: 4px;", "Error:"),
          div(style = "color: #b00020; font-family: 'SFMono-Regular', Consolas, monospace; font-size: 12px;",
            shiny::textOutput("error_message")
          )
        )
      )
    )
  )
}