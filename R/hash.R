# hash.R -- The integrity hash over a manifest's load-bearing payload.
#
# `.sha256()` fixes the byte representation that gets hashed;
# `manifest_data_hash()` fixes which slots go into it and in what order. The
# second is exported because the contract is deliberately implementable
# without a dependency on this package: a component that emits a manifest of
# its own has to be able to produce a digest this package will accept, and
# handing it the function is safer than handing it a prose description of the
# byte layout.

#' SHA-256 over a version-stable serialisation
#'
#' Serialises an object to raw bytes and hashes them. Serialisation is pinned
#' to format 2 and its fixed 14-byte header -- the magic bytes, the format
#' number, and the writer and minimum reader R versions -- is dropped before
#' hashing.
#'
#' The header strip is the whole reason this helper exists. Those 14 bytes are
#' the only part of the serialisation that varies with the R version doing the
#' writing, so hashing them made a manifest emitted under one R version fail
#' verification under any other. The stripped body is hashed as plain bytes so
#' the `digest` and `openssl` paths agree exactly.
#'
#' @param obj Any serialisable R object.
#'
#' @returns A length-1 character vector, the lower-case hexadecimal SHA-256
#'   digest, with no algorithm prefix.
#'
#' @noRd
#' @keywords internal
.sha256 <- function(obj) {
  raw <- serialize(obj, connection = NULL, version = 2L)
  raw <- raw[-seq_len(14L)]
  if (requireNamespace("digest", quietly = TRUE)) {
    digest::digest(raw, algo = "sha256", serialize = FALSE)
  } else if (requireNamespace("openssl", quietly = TRUE)) {
    as.character(openssl::sha256(raw))
  } else {
    stop(call. = FALSE,
         "orchestraManifest needs either `digest` or `openssl` for hashing")
  }
}

#' Hash a manifest's load-bearing payload
#'
#' Computes the digest that goes in a manifest's `data_hash` property, and
#' that [verify_manifest()] recomputes and compares against. An emitter calls
#' this once, on the payload it is about to seal into a manifest.
#'
#' @details
#' The hash covers the load-bearing data slots only. The schema version, the
#' emitter identity and the timestamp are metadata and are deliberately
#' outside it, so re-tagging a manifest does not invalidate a payload that has
#' not changed, while any edit to the payload is detected.
#'
#' Argument order is part of the contract, not an implementation detail. The
#' six slots are hashed as a single list in exactly this order, over the
#' version-stable byte representation described in the class documentation.
#' A component that emits manifests without depending on this package must
#' reproduce that order and that representation exactly, or its manifests will
#' not verify here.
#'
#' @param params The parameter draws, typically a data frame. Pass the value
#'   destined for the manifest's `params` property, including its default
#'   empty data frame when there are no draws.
#' @param outputs The model-predicted outputs, or `NULL` when the manifest
#'   holds no ensemble payload.
#' @param weights The observation weights, or `NULL`.
#' @param obs_target The observed targets, or `NULL`.
#' @param seed The integer RNG seed behind the result, or `NA_integer_`.
#' @param summary The typed verdict from [manifest_summary()], or `NULL`.
#'
#' @returns A length-1 character vector of the form `"sha256:<hex>"`, ready to
#'   be stored as a manifest's `data_hash`.
#'
#' @seealso [verify_manifest()], which recomputes this and compares.
#'
#' @author Max Moldovan
#'
#' @examples
#' params <- data.frame(a = c(0.1, 0.2), b = c(1.5, 1.4))
#' manifest_data_hash(params, NULL, NULL, NULL, 1L)
#'
#' @export
manifest_data_hash <- function(params, outputs, weights, obs_target, seed,
                               summary = NULL) {
  paste0("sha256:", .sha256(list(params, outputs, weights, obs_target, seed,
                                 summary)))
}
