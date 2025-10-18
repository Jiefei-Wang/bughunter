# Fix for NA Values in Deparsed Code

## Issue Description

When functions were defined interactively in the R terminal (without source files), the `traceCondition` function was appending "NA\nNA\nNA" to the deparsed function code.

**Example of the problem:**
```
$code[[1]]
[1] "function(x) {\n    x <- x + 1\n    g(x)\n}\n\nNA\nNA\nNA"
```

## Root Cause

The issue was in [`R/bugtracer.R`](R/bugtracer.R:74) at line 74:

```r
func_lines <- srcfile$lines[func_srcref[1]:func_srcref[3]]
```

When accessing `srcfile$lines` with a range that exceeded the array bounds, R returns NA values for out-of-bounds indices. For example:

```r
lines <- c("line1", "line2", "line3", "line4")
lines[1:7]  # Returns: "line1" "line2" "line3" "line4" NA NA NA
```

When these NA values were concatenated with `paste(..., collapse = "\n")`, they appeared as literal "NA" strings in the output.

## The Fix

Modified lines 72-76 in [`R/bugtracer.R`](R/bugtracer.R:72) to limit the range to available lines:

```r
if (!is.null(srcfile) && !is.null(srcfile$lines)) {
  # Extract all lines of the function definition
  # Ensure we don't access beyond the available lines
  start_line <- func_srcref[1]
  end_line <- min(func_srcref[3], length(srcfile$lines))
  func_lines <- srcfile$lines[start_line:end_line]
  
  # ... rest of the code
}
```

The key change is using `min(func_srcref[3], length(srcfile$lines))` to ensure we never access beyond the available lines.

## Testing

To test the fix, run the following in your R console:

```r
devtools::load_all()
options(error = traceCondition)

f <- function(x) {
    x <- x + 1
    g(x)
}

g <- function(y) {
    y <- y + 2
    stop("Test error")
}

f(1)

trace <- getLastTrace()
print(trace)
```

The code should now display cleanly without "NA" strings appended.

## Files Modified

- [`R/bugtracer.R`](R/bugtracer.R:72) - Lines 72-76

## Test Scripts Created

- `testScripts/debug_lines_access.R` - Demonstrates the root cause
- `testScripts/interactive_test_fix.R` - Interactive testing script
- `testScripts/TESTING_INSTRUCTIONS.md` - Detailed testing instructions