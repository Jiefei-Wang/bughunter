#' Server Logic for Trace Management
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param trace_rv Reactive value containing the trace object
#' @keywords internal
trace_server <- function(input, output, session, trace_rv) {
  # Helper: safe get list element
  `%||%` <- function(a, b) if (!is.null(a)) a else b
  
  # Reactive: selected frame index
  selected_frame <- shiny::reactiveVal(1)
  current_frame <- shiny::reactive({ as.numeric(selected_frame() %||% 1) })
  
  # Status values
  console_buffer <- shiny::reactiveVal("")
  execution_status <- shiny::reactiveVal("Ready")
  
  # Error presence for banner
  output$has_error <- shiny::reactive({
    trace <- trace_rv()
    if (is.null(trace)) return(FALSE)
    is.character(trace$error_message) && length(trace$error_message) > 0 && nzchar(trace$error_message[1])
  })
  shiny::outputOptions(output, "has_error", suspendWhenHidden = FALSE)
  
  # Error message text
  output$error_message <- shiny::renderText({ 
    trace <- trace_rv()
    if (is.null(trace)) return("")
    trace$error_message 
  })
  
  # Code view with line numbers and highlight
  output$code_display <- shiny::renderUI({
    trace <- trace_rv()
    if (is.null(trace)) return(div("No trace loaded"))
    
    idx <- current_frame()
    code <- trace$code[[idx]]
    line <- trace$line_numbers[[idx]]
    
    lines <- strsplit(code %||% "", "\n", fixed = TRUE)[[1]]
    if (length(lines) == 0) lines <- ""
    
    # Build HTML string manually to avoid whitespace issues
    html_lines <- vapply(seq_along(lines), function(i) {
      ln <- sprintf("%3d", i)
      cls <- if (!is.na(line) && i == as.integer(line)) " class='hl-line'" else ""
      # Escape HTML entities in code
      escaped_line <- gsub("&", "&amp;", lines[i], fixed = TRUE)
      escaped_line <- gsub("<", "&lt;", escaped_line, fixed = TRUE)
      escaped_line <- gsub(">", "&gt;", escaped_line, fixed = TRUE)
      sprintf("<div%s><span class='line-num'>%s</span><span>%s</span></div>", cls, ln, escaped_line)
    }, character(1))
    
    shiny::HTML(paste0("<div class='code-block'>", paste(html_lines, collapse = ""), "</div>"))
  })
  
  # Environment panel
  output$environment_display <- shiny::renderText({
    trace <- trace_rv()
    if (is.null(trace)) return("<no trace>")
    
    idx <- current_frame()
    env <- trace$stack[[idx]]
    out <- tryCatch({
      vars <- ls(envir = env)
      if (!length(vars)) return("<empty>")
      paste(vapply(vars, function(v) {
        val <- tryCatch(get(v, envir = env), error = function(e) structure("<error>", class = "try-error"))
        preview <- capture.output(utils::str(val, max.level = 1, give.attr = FALSE))
        paste0(v, ": ", paste(preview, collapse = " "))
      }, character(1)), collapse = "\n")
    }, error = function(e) paste("<error reading env>", e$message))
    out
  })
  
  # Call stack list
  output$stack_list <- shiny::renderUI({
    trace <- trace_rv()
    if (is.null(trace)) return(div("No trace loaded"))
    
    n <- length(trace$stack)
    sel <- current_frame()
    items <- lapply(seq_len(n), function(i) {
      lbl <- paste0("Frame ", i)
      div(
        class = paste("stack-item", if (i == sel) "selected" else ""),
        id = paste0("stack_item_", i),
        `data-index` = i,
        lbl
      )
    })
    shiny::tagList(items)
  })
  
  # Handle stack item clicks via JS binding
  shiny::observe({
    trace <- trace_rv()
    if (is.null(trace)) return()
    
    n <- length(trace$stack)
    lapply(seq_len(n), function(i) {
      shiny::observeEvent(input[[paste0("stack_item_click_", i)]], ignoreInit = TRUE, {
        selected_frame(i)
      })
    })
  })
  
  # Console: handle submit on Enter
  shiny::observeEvent(input$console_submit, {
    trace <- trace_rv()
    if (is.null(trace)) return()
    
    code <- input$console_submit$code %||% ""
    if (!nzchar(code)) return()
    
    # Append prompt and code like R console
    buf <- console_buffer()
    buf <- paste0(buf, if (nzchar(buf)) "\n" else "", "> ", code)
    console_buffer(buf)
    
    execution_status("Running...")
    idx <- current_frame()
    env <- trace$stack[[idx]]
    
    res_txt <- tryCatch({
      out <- utils::capture.output({
        res <- eval(parse(text = code), envir = env)
        if (!is.null(res)) print(res)
      })
      paste(out, collapse = "\n")
    }, error = function(e) paste("Error:", e$message))
    
    if (nzchar(res_txt)) {
      console_buffer(paste0(console_buffer(), if (nzchar(res_txt)) "\n" else "", res_txt))
    }
    execution_status("Ready")
  })
  
  # Status output
  output$execution_status <- shiny::renderText({ execution_status() })
  
  # Console output binding
  output$console_output_ui <- shiny::renderUI({
    buf <- console_buffer()
    # Only render if buffer has content to avoid initial blank space
    if (!nzchar(buf)) {
      return(NULL)
    }
    # Escape HTML but preserve line breaks - use pre tag to avoid extra spacing
    buf <- gsub("&", "&amp;", buf, fixed = TRUE)
    buf <- gsub("<", "&lt;", buf, fixed = TRUE)
    buf <- gsub(">", "&gt;", buf, fixed = TRUE)
    # Use pre tag instead of br tags to preserve exact formatting
    shiny::HTML(paste0("<pre style='margin:0; padding:0; font:inherit; white-space:pre-wrap;'>", buf, "</pre>"))
  })
  
  return(list(
    selected_frame = selected_frame,
    console_buffer = console_buffer,
    execution_status = execution_status
  ))
}

#' Server Logic for File Operations
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param trace_rv Reactive value containing the trace object
#' @keywords internal
file_server <- function(input, output, session, trace_rv) {
  # Toggle file menu
  shiny::observeEvent(input$file_menu, {
    current <- input$show_file_menu
    shiny::updateCheckboxInput(session, "show_file_menu", value = !isTRUE(current))
  })
  
  # Handle open file button
  shiny::observeEvent(input$open_file, {
    # Close the menu
    shiny::updateCheckboxInput(session, "show_file_menu", value = FALSE)
    
    # Show file selection dialog
    tryCatch({
      file_path <- file.choose()
      if (!is.null(file_path) && file.exists(file_path)) {
        # Load the RDS file
        trace <- readRDS(file_path)
        
        # Validate trace object
        if (!is.list(trace)) {
          shiny::showNotification("Invalid trace file: must be a list object", type = "error")
          return()
        }
        
        required_fields <- c("stack", "code", "line_numbers", "error_message")
        missing_fields <- setdiff(required_fields, names(trace))
        
        if (length(missing_fields) > 0) {
          shiny::showNotification(
            paste("Invalid trace file. Missing fields:", paste(missing_fields, collapse = ", ")),
            type = "error"
          )
          return()
        }
        
        # Update the trace reactive value
        trace_rv(trace)
        shiny::showNotification("Trace file loaded successfully", type = "message")
      }
    }, error = function(e) {
      shiny::showNotification(paste("Error loading file:", e$message), type = "error")
    })
  })
}