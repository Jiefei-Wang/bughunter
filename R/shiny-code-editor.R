
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
    # print(paste("Highlighting line:", line_number))
    # Remove existing highlights
    session$sendCustomMessage("aceEditor_clearHighlights", "code_editor")
    
    if (!is.null(line_number)&& !is.na(line_number)){
        start_line <- line_number - 1
        end_line <- line_number - 1
        session$sendCustomMessage("aceEditor_highlightLines", 
            list(editorId = "code_editor", start = start_line, end = end_line)
        )
    }
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
                value = code,
                readOnly = !isCodeEditable(capture)
            )
            
            # Set initial highlighted line if available
            call_line <- getStopAtLine(capture, selected_frame_idx)
            # print(paste("Initial highlight line:", call_line))
            highlight_line(session, call_line)
        }
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





