
# Helper function to get current line content
get_current_line_content <- function(input) {
    if (!is.null(input$code_editor_cursor)) {
        line_num <- input$code_editor_cursor$row + 1  # Convert from 0-based
        code_lines <- strsplit(input$code_editor, "\n")[[1]]
        if (line_num <= length(code_lines)) {
            return(code_lines[line_num])
        }
    }
    return("")
}


# Function to highlight a specific line
highlight_line <- function(session, line_number) {
    # Remove existing annotations
    session$sendCustomMessage("aceEditor_clearAnnotations", "code_editor")
    
    # Add highlight annotation (0-based for Ace Editor)
    annotation <- list(
        row = line_number - 1,  # Convert to 0-based
        column = 0,
        text = "",
        type = "info"
    )
    
    session$sendCustomMessage("aceEditor_setAnnotations", list(
        editorId = "code_editor",
        annotations = list(annotation)
    ))
    
    # Also set the cursor to that line
    session$sendCustomMessage("aceEditor_gotoLine", list(
        editorId = "code_editor",
        line = line_number,
        column = 0
    ))
}



##################################
## Editor Event Registration
##################################


registerEditorEvents <- function(input, output, session, capture, current_code, highlighted_line, selected_frame) {
    # Initialize the editor with content
    observe({
        if (!is.null(capture)) {
            selected_frame_idx <- selected_frame()
            code <- getEditorCode(capture, selected_frame_idx)
            
            # Update the editor with content
            shinyAce::updateAceEditor(
                session = session,
                editorId = "code_editor",
                value = code
            )
            
            # Set initial highlighted line if available
            call_line <- getStopAtLine(capture, selected_frame_idx)
            if (!is.null(call_line)) {
                highlight_line(session, call_line)
            }
        }
    })
    
    # Update highlighted line when user clicks on call stack or other triggers
    observeEvent(input$highlight_line_trigger, {
        new_line <- input$highlight_line_trigger
        highlighted_line(new_line)
        highlight_line(session, new_line)
    })
    
    # Handle Ctrl+Enter for executing selected code
    observeEvent(input$code_editor_key, {
        print("event triggered")
        if (!is.null(input$code_editor_key) && input$code_editor_key$key == "Ctrl-Enter") {
            selected_text <- input$code_editor_selection
            if (is.null(selected_text) || selected_text == "") {
                # Execute current line
                current_line_content <- get_current_line_content(input)
                # Your execution logic here
                print(paste("Executing line:", current_line_content))
            } else {
                # Execute selected text
                # Your execution logic here
                print(paste("Executing selected code:", selected_text))
            }
        }
    })
}





