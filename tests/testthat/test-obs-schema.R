test_that("matching quantities and units agree", {
  a <- new_test_manifest(obs_schema = new_test_schema("t/ha"),
                         run_id = "a-001")
  b <- new_test_manifest(obs_schema = new_test_schema("t/ha"),
                         run_id = "b-001")
  expect_null(assert_obs_schema_correspondence(a, b))
})

test_that("a wrong unit on a shared column is refused", {
  a <- new_test_manifest(obs_schema = new_test_schema("t/ha"),
                         run_id = "a-001")
  wrong <- new_test_schema("t/ha")
  wrong$outputs$unit[1] <- "kg/ha"          # a factor of one thousand out
  b <- new_test_manifest(obs_schema = wrong, run_id = "b-001")
  expect_error(assert_obs_schema_correspondence(a, b),
               "correspondence FAILED")
  expect_error(assert_obs_schema_correspondence(a, b),
               "incommensurable")
})

test_that("a wrong quantity on a shared column is refused", {
  a <- new_test_manifest(obs_schema = new_test_schema("t/ha"),
                         run_id = "a-001")
  wrong <- new_test_schema("t/ha")
  wrong$outputs$quantity[2] <- "grain_protein"
  b <- new_test_manifest(obs_schema = wrong, run_id = "b-001")
  expect_error(assert_obs_schema_correspondence(a, b), "grain_protein")
})

test_that("the guard is a graceful no-op until both sides carry a schema", {
  with_schema <- new_test_manifest(obs_schema = new_test_schema("t/ha"),
                                   run_id = "a-001")
  without <- new_test_manifest(run_id = "b-001")
  expect_null(assert_obs_schema_correspondence(with_schema, without))
  expect_null(assert_obs_schema_correspondence(without, with_schema))
  expect_null(assert_obs_schema_correspondence(without, without))
})

test_that("columns present on only one side are ignored", {
  a <- new_test_manifest(obs_schema = new_test_schema("t/ha", n = 3L),
                         run_id = "a-001")
  b <- new_test_manifest(obs_schema = new_test_schema("t/ha", n = 5L),
                         run_id = "b-001")
  expect_null(assert_obs_schema_correspondence(a, b))
})

test_that("the compared sides can be narrowed", {
  a <- new_test_manifest(obs_schema = new_test_schema("t/ha"),
                         run_id = "a-001")
  wrong <- new_test_schema("kg/ha")
  b <- new_test_manifest(obs_schema = wrong, run_id = "b-001")
  expect_error(assert_obs_schema_correspondence(a, b, what = "outputs"))
  # Narrowed to the parameter side, the outputs disagreement is out of scope.
  expect_null(assert_obs_schema_correspondence(a, b, what = "params"))
})

test_that("parameter schemas are compared on unit alone", {
  schema_of <- function(unit) {
    list(params = data.frame(name = c("a", "b"),
                             unit = c(unit, "kg/ha"),
                             stringsAsFactors = FALSE))
  }
  a <- new_test_manifest(obs_schema = schema_of("mm"), run_id = "a-001")
  b <- new_test_manifest(obs_schema = schema_of("mm"), run_id = "b-001")
  expect_null(assert_obs_schema_correspondence(a, b))

  c1 <- new_test_manifest(obs_schema = schema_of("cm"), run_id = "c-001")
  expect_error(assert_obs_schema_correspondence(a, c1),
               "params column 'a' disagrees on unit")
})
