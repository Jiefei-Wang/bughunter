# Package environment to store hunt data
bughunter_env <- new.env(parent = emptyenv())


#' Get the Last Stored Hunt Data
#'
#' Retrieves the most recent hunt data captured by hunter.
#'
#' @param as_object logical. If TRUE, returns a Hunt object; if FALSE, returns a list.
#' @return Either a Hunt object or a list containing the hunt data.
#' @export
getLastHunt <- function(as_object = TRUE) {
  hunt_data <- bughunter_env$last_hunt
  if (!as_object) {
    hunt_data <- as(hunt_data, "list")
  }
  hunt_data
}
