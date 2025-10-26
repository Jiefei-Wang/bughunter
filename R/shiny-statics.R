get_app_javascript <- function() {
tagList(
    includeScript(system.file("js/myscript.js", package = "bugviewer"))
    # includeScript(system.file("js/panel_design.js", package = "bugviewer"))
  )
}

get_app_styles <- function() {
    tagList(
        includeCSS(system.file("css/mycss.css", package = "bugviewer")),
        includeCSS(system.file("css/panel_design.css", package = "bugviewer"))
    )
}