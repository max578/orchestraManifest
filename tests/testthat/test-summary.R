test_that("a summary carries its four typed fields", {
  s <- manifest_summary("effect detected", metrics = list(estimate = 0.42))
  expect_s3_class(s, "manifest_summary")
  expect_identical(s$headline, "effect detected")
  expect_false(s$abstained)
  expect_true(is.na(s$abstain_reason))
  expect_identical(s$metrics, list(estimate = 0.42))
})

test_that("an abstention records its reason", {
  s <- manifest_summary("insufficient evidence", abstained = TRUE,
                        abstain_reason = "effective sample size below floor")
  expect_true(s$abstained)
  expect_identical(s$abstain_reason, "effective sample size below floor")
})

test_that("a missing abstention flag is recorded as not abstained", {
  expect_false(manifest_summary("verdict", abstained = NA)$abstained)
})

test_that("a malformed summary is refused at construction", {
  expect_error(manifest_summary(""), "single non-empty string")
  expect_error(manifest_summary(c("a", "b")), "single non-empty string")
  expect_error(manifest_summary(42), "single non-empty string")
  expect_error(manifest_summary("verdict", abstained = "yes"),
               "single logical value")
  expect_error(manifest_summary("verdict", metrics = 1:3), "must be a list")
})

test_that("the manifest validator refuses an untyped summary", {
  expect_error(new_test_manifest(summary = list(headline = "raw list")),
               "must be a manifest_summary")
})

test_that("a verdict manifest leaves the parameter table empty", {
  m <- new_test_manifest(params = data.frame(),
                         inferential_target = "decisions",
                         summary = manifest_summary("apply 90 kg/ha"))
  expect_identical(nrow(m@params), 0L)
  expect_true(verify_manifest(m)$ok)
  expect_identical(m@summary$headline, "apply 90 kg/ha")
})
