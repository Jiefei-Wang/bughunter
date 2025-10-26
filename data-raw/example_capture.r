library(bughunter)

f <- function(x) {
    x <- x + 1
    g(x)
}
g <- function(y) {
    y <- y + 2
    z <- 1
    stop("Test error")
}

hunt(f(1))
example_capture <- getLastCapture()
usethis::use_data(example_capture, internal = FALSE, overwrite = TRUE)
