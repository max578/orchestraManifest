test_that("a freshly built manifest verifies", {
  m <- new_test_manifest()
  v <- verify_manifest(m)
  expect_true(v$ok)
  expect_identical(v$message, "data_hash verified")
})

test_that("verification fails on anything that is not a manifest", {
  v <- verify_manifest(list(a = 1))
  expect_false(v$ok)
  expect_identical(v$message, "not an orchestra_manifest")
})

test_that("a tampered payload is detected in every hashed slot", {
  slots <- list(
    params = function(m) {
      m@params$a[1] <- m@params$a[1] + 0.01
      m
    },
    outputs = function(m) {
      m@outputs <- matrix(1, 1, 1)
      m
    },
    weights = function(m) {
      m@weights <- 2
      m
    },
    obs_target = function(m) {
      m@obs_target <- 3
      m
    },
    seed = function(m) {
      m@seed <- 99L
      m
    },
    summary = function(m) {
      m@summary <- manifest_summary("tampered")
      m
    }
  )
  for (slot in names(slots)) {
    tampered <- slots[[slot]](new_test_manifest())
    v <- verify_manifest(tampered)
    expect_false(v$ok, info = slot)
    expect_match(v$message, "MISMATCH", info = slot)
  }
})

test_that("re-tagging the metadata leaves verification intact", {
  m <- new_test_manifest()
  m@emitter_package <- "relabelled"
  m@timestamp <- as.POSIXct("2026-08-01", tz = "UTC")
  expect_true(verify_manifest(m)$ok)
})

test_that("a serialisation round trip preserves the object and its integrity", {
  m <- new_test_manifest(summary = manifest_summary("round trip"))
  rt <- unserialize(serialize(m, NULL))
  expect_true(is_orchestra_manifest(rt))
  expect_true(verify_manifest(rt)$ok)
  expect_identical(rt@run_id, m@run_id)
  expect_identical(rt@data_hash, m@data_hash)
})

test_that("a consensus manifest round-trips through serialisation and verifies", {
  m <- new_test_manifest(inferential_target = "consensus",
                         summary = manifest_summary("consensus reached"))
  rt <- unserialize(serialize(m, NULL))
  expect_true(is_orchestra_manifest(rt))
  expect_identical(rt@inferential_target, "consensus")
  expect_true(verify_manifest(rt)$ok)
  expect_identical(rt@data_hash, m@data_hash)
})

test_that("a consumer accepts a known-valid manifest", {
  m <- new_test_manifest()
  expect_identical(consume_manifest(m), m)
})

test_that("a consumer refuses a version it did not declare", {
  m <- new_test_manifest()
  expect_error(consume_manifest(m, accept = "9.9.9"),
               "not in the accepted set")
  expect_error(consume_manifest(m, accept = "9.9.9"),
               "refusing to consume rather than silently coerce")
})

test_that("a consumer refuses a corrupted payload", {
  m <- new_test_manifest()
  m@params$a[1] <- m@params$a[1] + 0.01
  expect_error(consume_manifest(m), "integrity check failed")
})

test_that("a consumer refuses an object that is not a manifest", {
  expect_error(consume_manifest(list(a = 1)),
               "is not an orchestra_manifest")
})
