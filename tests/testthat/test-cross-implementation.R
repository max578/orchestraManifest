# test-cross-implementation.R -- The cross-implementation oracle.
#
# Every other test in this suite checks the package against itself, which
# proves self-consistency and nothing about correspondence. This one checks it
# against the independent reference implementation of the same contract: a
# script that lives outside any package, was written first, and shares no code
# with what is tested here. If the two agree byte for byte on a hash, the
# extraction preserved the contract; if they disagree, every manifest already
# in circulation stops verifying.
#
# The reference is a working file on one machine, not a dependency, so the
# path below is absolute. It is the single sanctioned absolute path in this
# package: the test skips on CRAN and skips wherever the file is absent, which
# is everywhere except the machine that holds the reference.

reference_implementation <- file.path(
  "/Users/a1222812/Projects/CLAUDE_PROJECTS_LOCAL/ORCHESTRA_dev",
  "integration", "orchestra_manifest.R"
)

skip_unless_reference_available <- function() {
  skip_on_cran()
  skip_if(!file.exists(reference_implementation),
          "the reference implementation is not on this machine")
  # Sourcing the reference registers methods on two components' classes, so
  # both have to be installed for the file to load at all.
  skip_if_not_installed("PESTO")
  skip_if_not_installed("proxymix")
}

test_that("a manifest built by the reference verifies under this package", {
  skip_unless_reference_available()

  rds <- tempfile(fileext = ".rds")
  on.exit(unlink(rds), add = TRUE)

  run <- run_in_vanilla_r(sprintf('
    suppressMessages({library(S7); library(PESTO); library(proxymix)})
    source("%s")
    params <- data.frame(a = c(0.1, 0.2), b = c(1.5, 1.4))
    outputs <- matrix(c(1.1, 1.2, 1.3, 1.4), 2, 2)
    weights <- c(1, 0.5)
    obs_target <- c(2.2, 2.4)
    summary <- manifest_summary("reference verdict",
                                metrics = list(estimate = 0.42))
    m <- orchestra_manifest(
      emitter_package    = "reference",
      emitter_version    = "0.0.1",
      inferential_target = "parameters",
      run_id             = "reference-001",
      method             = "reference:demo",
      seed               = 7L,
      params             = params,
      outputs            = outputs,
      weights            = weights,
      obs_target         = obs_target,
      summary            = summary,
      timestamp          = as.POSIXct("2026-07-05 09:00:00", tz = "UTC"),
      data_hash          = .hash_payload(params, outputs, weights,
                                         obs_target, 7L, summary))
    saveRDS(m, "%s")
  ', reference_implementation, rds))

  expect_identical(run$status, 0L,
                   info = paste(run$output, collapse = "\n"))
  expect_true(file.exists(rds))

  m <- readRDS(rds)

  # The reference mints the bare class identity; this package mints the
  # package-qualified one. Both are the same contract, which is why the
  # identity predicate is tolerant.
  expect_identical(class(m)[1], "orchestra_manifest")
  expect_true(is_orchestra_manifest(m))

  # The load-bearing assertion: this package's hash of the same payload is
  # the exact string the reference stored.
  own_hash <- manifest_data_hash(S7::prop(m, "params"),
                                 S7::prop(m, "outputs"),
                                 S7::prop(m, "weights"),
                                 S7::prop(m, "obs_target"),
                                 S7::prop(m, "seed"),
                                 S7::prop(m, "summary"))
  expect_identical(own_hash, S7::prop(m, "data_hash"))

  expect_true(verify_manifest(m)$ok)
  expect_identical(consume_manifest(m), m)
})

test_that("a manifest built by this package hashes identically under the reference", {
  skip_unless_reference_available()

  rds <- tempfile(fileext = ".rds")
  answer <- tempfile(fileext = ".rds")
  on.exit(unlink(c(rds, answer)), add = TRUE)

  m <- new_test_manifest(
    outputs = matrix(c(1.1, 1.2, 1.3, 1.4), 2, 2),
    weights = c(1, 0.5),
    obs_target = c(2.2, 2.4),
    summary = manifest_summary("package verdict",
                               metrics = list(estimate = 0.42)),
    emitter_package = "orchestraManifest"
  )
  saveRDS(m, rds)

  run <- run_in_vanilla_r(sprintf('
    suppressMessages({library(S7); library(PESTO); library(proxymix)})
    source("%s")
    m <- readRDS("%s")
    saveRDS(list(
      hash = .hash_payload(prop(m, "params"), prop(m, "outputs"),
                           prop(m, "weights"), prop(m, "obs_target"),
                           prop(m, "seed"), prop(m, "summary")),
      strict = verify_manifest(m)
    ), "%s")
  ', reference_implementation, rds, answer))

  expect_identical(run$status, 0L,
                   info = paste(run$output, collapse = "\n"))

  reference_view <- readRDS(answer)

  # Byte-level agreement in the other direction.
  expect_identical(reference_view$hash, m@data_hash)

  # The reference tests identity strictly, so it declines a manifest minted
  # under the package-qualified class even though the payload is intact.
  # That asymmetry is the whole reason this package tests identity
  # tolerantly; recording it here keeps it a known property rather than a
  # surprise the next time a component is extracted.
  expect_false(reference_view$strict$ok)
  expect_identical(reference_view$strict$message, "not an orchestra_manifest")
})
