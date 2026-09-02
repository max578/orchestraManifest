# helper-subprocess.R -- Run R code in a clean, separate R session.
#
# Used by the cross-implementation oracle, which has to evaluate a second
# implementation of the contract in a session that knows nothing about this
# package. Nothing here names a path outside the session's own temporary
# directory; the one file path the oracle needs lives in the guarded test
# that uses it.

run_in_vanilla_r <- function(code) {
  script <- tempfile(fileext = ".R")
  on.exit(unlink(script), add = TRUE)
  writeLines(code, script)
  output <- suppressWarnings(
    system2(file.path(R.home("bin"), "Rscript"),
            c("--vanilla", shQuote(script)),
            stdout = TRUE, stderr = TRUE)
  )
  status <- attr(output, "status")
  list(status = if (is.null(status)) 0L else as.integer(status),
       output = as.character(output))
}
