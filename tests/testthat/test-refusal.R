test_that("an S3 refusal is recognised by the naming convention", {
  r <- structure(list(why = "no data"), class = "example_refusal")
  expect_true(is_orchestra_refusal(r))
  expect_true(is_orchestra_decline(r))
})

test_that("an S7-shaped refusal is recognised across the object systems", {
  # The class vector an S7 refusal carries: package-qualified name first,
  # `S7_object` last. Fabricated here so the test needs no component
  # installed, which is exactly the seam the contract has to cover.
  r <- structure(list(), class = c("example::example_refusal", "S7_object"))
  expect_true(is_orchestra_refusal(r))
  expect_true(is_orchestra_decline(r))
})

test_that("an abstention is a decline but not a refusal", {
  a <- structure(list(), class = "example_abstention")
  expect_false(is_orchestra_refusal(a))
  expect_true(is_orchestra_decline(a))

  a7 <- structure(list(), class = c("example::example_abstention",
                                    "S7_object"))
  expect_false(is_orchestra_refusal(a7))
  expect_true(is_orchestra_decline(a7))
})

test_that("an ordinary result is neither", {
  for (x in list(42, "ok", NULL, list(a = 1), data.frame(a = 1))) {
    expect_false(is_orchestra_refusal(x))
    expect_false(is_orchestra_decline(x))
  }
})

test_that("the explicit marker is honoured whatever the class name", {
  r <- structure(list(), class = c(ORCHESTRA_REFUSAL_CLASS, "list"))
  expect_identical(ORCHESTRA_REFUSAL_CLASS, "orchestra_refusal")
  expect_true(is_orchestra_refusal(r))
  expect_true(is_orchestra_decline(r))
})

test_that("stamping the marker is idempotent", {
  x <- structure(list(why = "no data"), class = "list")
  once <- as_orchestra_refusal(x)
  expect_identical(class(once)[1], ORCHESTRA_REFUSAL_CLASS)
  expect_true(is_orchestra_refusal(once))

  twice <- as_orchestra_refusal(once)
  expect_identical(twice, once)
  expect_identical(class(twice), class(once))
})

test_that("stamping preserves the original class vector beneath the marker", {
  r <- as_orchestra_refusal(structure(list(),
                                      class = "example_abstention"))
  expect_identical(class(r), c("orchestra_refusal", "example_abstention"))
})
