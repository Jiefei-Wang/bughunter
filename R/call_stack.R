# Create a single clickable item in the call stack list
call_stack_item <- function(idx, name, stop_at_line, is_selected) {
    # Style for selected vs unselected
    item_style <- if (is_selected) {
    "padding: 8px 12px; margin: 2px 0; background: #e3f2fd; border-left: 3px solid #2196F3; cursor: pointer; border-radius: 3px;"
    } else {
    "padding: 8px 12px; margin: 2px 0; background: white; border-left: 3px solid transparent; cursor: pointer; border-radius: 3px; transition: background 0.2s;"
    }
    
    div(
        id = paste0("stack_frame_", idx),
        style = item_style,
        onclick = sprintf("Shiny.setInputValue('selected_frame', %d, {priority: 'event'});", idx),
        onmouseover = if (!is_selected) "this.style.background='#f5f5f5';" else "",
        onmouseout = if (!is_selected) "this.style.background='white';" else "",
        div(
            style = "font-weight: 500; color: #333; margin-bottom: 2px;",
            paste0("#", idx, ": ", name)
        ),
        div(
            style = "font-size: 11px; color: #666;",
            paste0("Line ", stop_at_line)
        )
    )
}



registerCallStackEvents <- function(input, output, session, capture, current_code, highlighted_line, selected_frame) {
  # Render the call stack list
  output$stack_list <- renderUI({
    if (is.null(capture)) return(NULL)
    
    # Get all frames from capture
    num_frames <- length(capture)
    
    # Create clickable stack items
    stack_items <- lapply(1:num_frames, function(i) {
        frame_call <- getCallName(capture, i)
        
        # Determine if this frame is selected
        is_selected <- !is.null(selected_frame()) && selected_frame() == i

        call_stack_item(i, frame_call, getStopAtLine(capture, i), is_selected)
    })
    
    tagList(stack_items)
  })
  
  # Handle frame selection
  observeEvent(input$selected_frame, {
    frame_idx <- input$selected_frame
    selected_frame(frame_idx)
    
    # # Update editor with selected frame's code
    # code <- getEditorCode(capture, frame_idx)
    # current_code(code)
    
    # shinyAce::updateAceEditor(
    #   session = session,
    #   editorId = "code_editor",
    #   value = code
    # )
    
    # # Highlight the line where this frame was called
    # highlightCalledLine(capture, frame_idx, session)
  })
  
  # Initialize with the last (most recent) frame
#   observe({
#     if (!is.null(capture) && is.null(selected_frame())) {
#       selected_frame(length(capture))
#     }
#   })
}
