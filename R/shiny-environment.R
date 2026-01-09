
registerEnvironmentEvents <- function(input, output, session, capture, 
params) {
    selected_frame <- params$selected_frame
    environment_dt <- params$environment_dt
    
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
            dt <- dt[, c("var", "type", "value")]
            reactable(
                dt,
                details = function(index) {
                    htmltools::div(
                        htmltools::tags$pre(
                            getEnvVarDetail(capture, selected_frame(), dt$var[index])
                        )
                    )
                }, 
                pagination = FALSE,
                wrap = FALSE,
                style = list(fontSize = "12px")
            )
        })


        # output$env_table <- renderTable({
        #     environment_dt()
        # }, 
        # striped = TRUE, hover = TRUE, bordered = TRUE, align = "l"
        # )
    })

}