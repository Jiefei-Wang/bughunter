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
            style = "font-size: 11px; color: #666;",
            glue::glue("# {idx}: {name} at Line {stop_at_line}")
        )
        # div(
        #     style = "font-size: 11px; color: #666;",
        #     paste0("Line ", stop_at_line)
        # )
    )
}



registerCallStackEvents <- function(input, output, session, capture, selected_frame) {

  output$error_message <- renderUI({
    if (is.null(capture)) return(NULL)
    
    err_msg <- capture@error_message
    if (nzchar(err_msg)) {
        div(
            style = "font-size: 12px; color: #721c24;",
            paste("Error:", err_msg)
        )
    } else {
        NULL
    }
  })
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
    
  })
  
}
