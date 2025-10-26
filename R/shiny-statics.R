get_app_javascript <- function() {
    tagList(
    includeScript(system.file("js/myscript.js", package = "bughunter")),
    includeScript(system.file("js/terminal.js", package = "bughunter"))
    )
}

get_app_styles <- function() {
    tags$style(
        tagList(
            includeCSS(system.file("css/mycss.css", package = "bughunter")),
            includeCSS(system.file("css/panel_design.css", package = "bughunter")),
            includeCSS(system.file("css/terminal.css", package = "bughunter"))
        )
    )
}