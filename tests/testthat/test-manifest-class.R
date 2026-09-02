test_that("every required slot is present and singly typed", {
  m <- new_test_manifest()
  required <- c("manifest_version", "emitter_package", "emitter_version",
                "inferential_target", "run_id", "method", "data_hash")
  present <- vapply(required, function(s) {
    v <- S7::prop(m, s)
    length(v) == 1L && nzchar(as.character(v))
  }, logical(1))
  expect_true(all(present))
})

test_that("a manifest self-identifies its emitter and contract version", {
  m <- new_test_manifest(emitter_package = "example")
  expect_identical(m@emitter_package, "example")
  expect_identical(m@manifest_version, manifest_version())
  expect_identical(manifest_version(), "2.0.0-draft")
})

test_that("the identity predicate is tolerant of the bare class name", {
  m <- new_test_manifest()
  expect_true(is_orchestra_manifest(m))
  expect_match(class(m)[1], "orchestra_manifest$")

  # The bare identity is what a component that implements the contract
  # without depending on this package mints.
  bare <- S7::new_class("orchestra_manifest", package = NULL,
                        properties = list(run_id = S7::class_character))
  expect_true(is_orchestra_manifest(bare(run_id = "bare-001")))
})

test_that("the identity predicate refuses lookalikes and non-manifests", {
  expect_false(is_orchestra_manifest(list(a = 1)))
  expect_false(is_orchestra_manifest(NULL))
  # A plain list wearing the class attribute is not an S7 object.
  expect_false(is_orchestra_manifest(
    structure(list(), class = c("orchestra_manifest", "list"))))
  # A different class that merely ends in the same word does not pass.
  other <- S7::new_class("other_orchestra_manifesto", package = NULL,
                         properties = list(x = S7::class_numeric))
  expect_false(is_orchestra_manifest(other(x = 1)))
})

test_that("the validator refuses an unknown inferential target", {
  expect_error(new_test_manifest(inferential_target = "vibes"),
               "must be one of")
})

test_that("the validator refuses an empty run identifier", {
  expect_error(new_test_manifest(run_id = ""),
               "single non-empty string")
})

test_that("a derived manifest must record its lineage", {
  expect_error(
    new_test_manifest(metadata = list(derived = TRUE)),
    "must record >= 1"
  )

  upstream <- new_test_manifest(run_id = "upstream-001")
  derived <- new_test_manifest(
    run_id = "derived-001",
    metadata = list(derived = TRUE),
    consumed_manifests = list(manifest_lineage(upstream))
  )
  expect_length(derived@consumed_manifests, 1L)
})

test_that("the permitted inferential targets are the closed set", {
  expect_identical(
    inferential_targets(),
    c("parameters", "predictions", "treatment_effects", "decisions",
      "breeding_values", "marker_associations", "structure")
  )
})
