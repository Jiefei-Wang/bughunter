
registerEnvironmentEvents <- function(input, output, session, capture, 
selected_frame, environment_dt) {
    # Observe changes in the selected frame
    observeEvent(selected_frame(), {
        colNames <- colnames(environment_dt())
        frame_idx <- selected_frame()
        if (!is.null(capture) && frame_idx <= length(capture)) {
            env_desc <- getEnvDescriptor(capture, frame_idx)
            environment_dt(env_desc)
        } else {
            dt <- data.frame(matrix(ncol = length(colNames), nrow = 0))
            colnames(dt) <- colNames
            environment_dt(dt)
        }
    })

    # Observe changes in the environment data table
    observeEvent(environment_dt(), {
        # Update the environment panel with the latest data
        output$env_table <- renderReactable({
            dt <- environment_dt()
            details <- dt$details
            dt <- dt[, !(names(dt) %in% c("details")), drop = FALSE]
            reactable(
                dt, 
                pagination = FALSE, 
                details = function(index) {
                    htmltools::div(
                        htmltools::tags$pre(details[[index]])
                    )
                }
            )
        })


        # output$env_table <- renderTable({
        #     environment_dt()
        # }, 
        # striped = TRUE, hover = TRUE, bordered = TRUE, align = "l"
        # )
    })

}