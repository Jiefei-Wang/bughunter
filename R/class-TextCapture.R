.TextCapture <- setClass(
    "TextCapture",
    contains = "Capture"
)


#' Create a new TextCapture object
newTextCapture <- function(capture){
    frames <- capture@frames
    env_list <- list()
    for (i in seq_along(frames)){
        env_desc <- getEnvDescriptor(capture, i)
        for (j in seq_len(nrow(env_desc))){
            var_name <- env_desc$var[j]
            details <- getEnvVarDetail(capture, i, var_name)
            env_desc$details[j] <- details
        }
        env_list[[i]] <- env_desc
    }
    new(Class = "TextCapture", capture, frames = env_list)
}