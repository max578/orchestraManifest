test_that("the canonical tokens are the exact strings components hardcode", {
  expect_identical(GROUNDING_GROUNDED, "grounded")
  expect_identical(GROUNDING_UNVERIFIED, "ungrounded")
})

test_that("a fully dated evidence set is grounded", {
  expect_identical(grounding_token(as.Date(c("2026-07-05", "2026-07-06"))),
                   GROUNDING_GROUNDED)
})

test_that("any undated element taints the evidence set", {
  expect_identical(grounding_token(as.Date(c("2026-07-05", NA))),
                   GROUNDING_UNVERIFIED)
  expect_identical(grounding_token(as.Date(c(NA, NA))),
                   GROUNDING_UNVERIFIED)
})

test_that("an empty evidence set is unverified, not vacuously grounded", {
  expect_identical(grounding_token(as.Date(character(0))),
                   GROUNDING_UNVERIFIED)
  expect_identical(grounding_token(NULL), GROUNDING_UNVERIFIED)
})

test_that("combining tokens is worst-case", {
  expect_identical(
    combine_grounding(rep(GROUNDING_GROUNDED, 3L)),
    GROUNDING_GROUNDED
  )
  expect_identical(
    combine_grounding(c(GROUNDING_GROUNDED, GROUNDING_UNVERIFIED)),
    GROUNDING_UNVERIFIED
  )
  expect_identical(combine_grounding(character(0)), GROUNDING_UNVERIFIED)
})

test_that("an unrecognised token reads as not grounded", {
  expect_identical(combine_grounding(c(GROUNDING_GROUNDED, "probably")),
                   GROUNDING_UNVERIFIED)
})

test_that("the token used up to 0.1.0 still reads as not grounded", {
  expect_identical(combine_grounding(c(GROUNDING_GROUNDED, "[unverified]")),
                   GROUNDING_UNVERIFIED)
})
