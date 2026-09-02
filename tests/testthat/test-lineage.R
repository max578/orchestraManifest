test_that("a lineage handle carries the four provenance fields", {
  upstream <- new_test_manifest(run_id = "upstream-001",
                                emitter_package = "upstream")
  handle <- manifest_lineage(upstream)
  expect_named(handle, c("run_id", "data_hash", "emitter_package",
                         "emitter_version"))
  expect_identical(handle$run_id, "upstream-001")
  expect_identical(handle$data_hash, upstream@data_hash)
  expect_identical(handle$emitter_package, "upstream")
})

test_that("a lineage handle pins the payload the upstream had", {
  upstream <- new_test_manifest(run_id = "upstream-001")
  handle <- manifest_lineage(upstream)
  reemitted <- new_test_manifest(run_id = "upstream-001",
                                 params = data.frame(a = c(0.1, 0.9),
                                                     b = c(1.5, 1.4)))
  expect_false(identical(handle$data_hash,
                         manifest_lineage(reemitted)$data_hash))
})

test_that("lineage refuses anything that is not a manifest", {
  expect_error(manifest_lineage(list(run_id = "faked")),
               "must themselves be orchestra_manifest objects")
})
