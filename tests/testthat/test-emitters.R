# The two adapters are exercised only where their component is installed. The
# contract itself is covered without them everywhere else in this suite, which
# is the point: a component implements the contract, it does not define it.

test_that("an adapter refuses when its component is absent", {
  # `.require_component()` is the guard the exported adapters run first.
  refuse <- orchestraManifest:::.require_component
  expect_error(refuse("aPackageThatIsNotInstalled", "manifest_from_pesto"),
               "needs the suggested package")
  expect_null(refuse("stats", "manifest_from_pesto"))
})

test_that("a PESTO ensemble manifest adapts and verifies", {
  skip_on_cran()
  skip_if_not_installed("PESTO")

  set.seed(1)
  design <- matrix(stats::rnorm(6), 3, 2)
  prior <- matrix(stats::rnorm(60), 30, 2,
                  dimnames = list(NULL, c("a", "b")))
  obs <- as.numeric(design %*% c(0.5, -1))
  names(obs) <- paste0("o", seq_len(3))
  fit <- PESTO::pesto_ies_callback(function(t) t %*% t(design), prior, obs,
                                   0.05, noptmax = 2L, verbose = FALSE)
  source_manifest <- PESTO::as_manifest(fit, seed = 1L)

  m <- manifest_from_pesto(source_manifest)
  expect_true(is_orchestra_manifest(m))
  expect_true(verify_manifest(m)$ok)
  expect_identical(m@emitter_package, "PESTO")
  expect_identical(m@inferential_target, "parameters")
  expect_false(m@metadata$derived)
  # PESTO's own digest is preserved for a cross-scheme audit.
  expect_identical(m@metadata$pesto_data_hash, source_manifest@data_hash)

  # Dispatching through the generic must give the same manifest.
  dispatched <- orchestraManifest::as_orchestra_manifest(source_manifest)
  expect_identical(dispatched@data_hash, m@data_hash)
})

test_that("a proxymix mixture fit adapts, verifies and records lineage", {
  skip_on_cran()
  skip_if_not_installed("proxymix")

  set.seed(1)
  draws <- matrix(stats::rnorm(200), 100, 2,
                  dimnames = list(NULL, c("a", "b")))
  fit <- proxymix::fit_proxymix(proxymix::gmm_target_from_samples(draws),
                                N = 2L, regime = "sample", max_iter = 50L)

  plain <- manifest_from_gmm(fit, seed = 1L)
  expect_true(is_orchestra_manifest(plain))
  expect_true(verify_manifest(plain)$ok)
  expect_identical(plain@emitter_package, "proxymix")
  expect_false(plain@metadata$derived)
  expect_match(plain@run_id, "^proxymix-[0-9a-f]{12}$")

  upstream <- new_test_manifest(run_id = "upstream-001")
  derived <- manifest_from_gmm(fit, seed = 1L, consumed = list(upstream))
  expect_true(derived@metadata$derived)
  expect_identical(derived@consumed_manifests[[1]]$run_id, "upstream-001")

  dispatched <- orchestraManifest::as_orchestra_manifest(fit, seed = 1L)
  expect_identical(dispatched@data_hash, plain@data_hash)
})
