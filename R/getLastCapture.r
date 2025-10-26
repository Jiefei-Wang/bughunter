# Package environment to store hunt data
bughunter_env <- new.env(parent = emptyenv())


#' Get the Last Stored Capture Data
#'
#' Retrieves the most recent data captured by hunter.
#'
#' @param as_object logical. If TRUE, returns a Capture object; if FALSE, returns a list.
#' @return Either a Capture object or a list containing the capture data.
#' @export
getLastCapture <- function(as_object = TRUE) {
  hunt_data <- bughunter_env$last_capture
  if (!as_object) {
    hunt_data <- as(hunt_data, "list")
  }
  hunt_data
}
