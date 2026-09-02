test_that("the payload hash is prefixed and stable", {
  params <- data.frame(a = c(0.1, 0.2))
  h <- manifest_data_hash(params, NULL, NULL, NULL, 1L)
  expect_match(h, "^sha256:[0-9a-f]{64}$")
  expect_identical(h, manifest_data_hash(params, NULL, NULL, NULL, 1L))
})

test_that("the hash separates every load-bearing slot", {
  params <- data.frame(a = c(0.1, 0.2))
  base <- manifest_data_hash(params, NULL, NULL, NULL, 1L)
  variants <- c(
    manifest_data_hash(data.frame(a = c(0.1, 0.3)), NULL, NULL, NULL, 1L),
    manifest_data_hash(params, 1, NULL, NULL, 1L),
    manifest_data_hash(params, NULL, 1, NULL, 1L),
    manifest_data_hash(params, NULL, NULL, 1, 1L),
    manifest_data_hash(params, NULL, NULL, NULL, 2L),
    manifest_data_hash(params, NULL, NULL, NULL, 1L,
                       manifest_summary("verdict"))
  )
  expect_false(any(variants == base))
  expect_length(unique(variants), length(variants))
})

test_that("the digest and openssl paths agree on the same bytes", {
  # An independent oracle on the hash primitive: two unrelated SHA-256
  # implementations must return the same digest for the stripped bytes, so a
  # component that falls back to `openssl` emits a manifest that verifies
  # against one hashed with `digest`.
  skip_if_not_installed("openssl")
  payload <- list(data.frame(a = c(0.1, 0.2)), NULL, NULL, NULL, 7L, NULL)
  raw <- serialize(payload, connection = NULL, version = 2L)[-seq_len(14L)]
  # `openssl` returns its hex string with a class attribute; the fallback
  # branch in `.sha256()` drops it by pasting the prefix on.
  expect_identical(
    digest::digest(raw, algo = "sha256", serialize = FALSE),
    unclass(as.character(openssl::sha256(raw)))
  )
})

test_that("the hash ignores the serialisation version header", {
  # The 14 stripped bytes are the only version-varying part of the
  # serialisation, so the digest is taken over the body alone.
  payload <- list(data.frame(a = 1), NULL, NULL, NULL, 1L, NULL)
  full <- serialize(payload, connection = NULL, version = 2L)
  expect_length(full[seq_len(14L)], 14L)
  expect_identical(
    manifest_data_hash(data.frame(a = 1), NULL, NULL, NULL, 1L),
    paste0("sha256:", digest::digest(full[-seq_len(14L)], algo = "sha256",
                                     serialize = FALSE))
  )
})
