f <- function(x) {
    x <- x + 1
    g(x)
}
g <- function(y) {
    n <- 1000
    x1 <- runif(n)
    x2 <- sample(letters, n,replace = TRUE)
    x3 <- rep(list(a = runif(n)),100)
    x4 <- data.frame(a=runif(n), b = sample(letters, n,replace = TRUE))
    y <- y + 2
    z <- 1
    f <- registerEditorEvents
    stop(paste0(letters, collapse = "\n"))
}

test_that("normal hunter", {
    capture <- hunt(f(1), on.error = "return")
    expect_s4_class(capture, "Capture")
})

test_that("recover hunter", {
    capture <- getLastCapture()
    expect_s4_class(capture, "Capture")
})

test_that("text only hunter", {
    capture <- hunt(f(1), text.only = TRUE, on.error = "return")
    expect_s4_class(capture, "TextCapture")
})
