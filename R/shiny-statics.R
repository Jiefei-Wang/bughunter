get_app_javascript <- function() {
    tagList(
    includeScript(system.file("js/ace-editor.js", package = "bughunter")),
    includeScript(system.file("js/terminal.js", package = "bughunter")),
    includeScript(system.file("js/menu-bar.js", package = "bughunter"))
    )
}

get_app_styles <- function() {
    tags$style(
        tagList(
            includeCSS(system.file("css/ace-editor.css", package = "bughunter")),
            includeCSS(system.file("css/panel_design.css", package = "bughunter")),
            includeCSS(system.file("css/terminal.css", package = "bughunter"))
        )
    )
}