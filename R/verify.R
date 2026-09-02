# verify.R -- The two guards a consumer runs before it trusts a manifest.
#
# `verify_manifest()` answers "is this payload the one that was hashed?";
# `consume_manifest()` wraps it with the schema-version check and turns both
# failures into loud errors. Everything here reads properties through
# `S7::prop()` rather than `@` so that a manifest minted under the bare class
# identity is handled exactly like one minted here.

#' Read a property that older manifests may not have
#'
#' Returns the named property when the object's class declares it and `NULL`
#' otherwise, so a manifest emitted before an additive slot was introduced can
#' still be verified and consumed instead of erroring on a missing property.
#'
#' @param x A manifest.
#' @param name The property name, as a single string.
#'
#' @returns The property value, or `NULL` when the class does not declare it.
#'
#' @noRd
#' @keywords internal
.prop_or_null <- function(x, name) {
  if (name %in% S7::prop_names(x)) S7::prop(x, name) else NULL
}

#' Verify a manifest's payload against its stored hash
#'
#' Recomputes the payload digest from the manifest's own load-bearing slots
#' and compares it with the `data_hash` the emitter stored. A mismatch means
#' the payload was modified after emission.
#'
#' The check is deliberately total rather than throwing: a consumer often
#' wants to record that a manifest failed verification and carry on with the
#' other lenses it has, so the verdict is returned as data. The loud version
#' is [consume_manifest()], which is what a gate should call.
#'
#' Because the hash covers the payload only, re-tagging a manifest with a
#' different schema version, emitter or timestamp leaves verification intact
#' while any edit to `params`, `outputs`, `weights`, `obs_target`, `seed` or
#' `summary` breaks it.
#'
#' @param m The manifest to verify. Anything that is not a manifest yields a
#'   failed verdict rather than an error.
#'
#' @returns A list with `ok`, a length-1 logical, and `message`, a length-1
#'   character vector describing the outcome.
#'
#' @seealso [consume_manifest()] for the erroring guard that calls this.
#'
#' @author Max Moldovan
#'
#' @examples
#' params <- data.frame(a = c(0.1, 0.2))
#' m <- orchestra_manifest(
#'   emitter_package = "example",
#'   emitter_version = "0.1.0",
#'   inferential_target = "parameters",
#'   run_id = "example-001",
#'   method = "example:demo",
#'   seed = 1L,
#'   params = params,
#'   timestamp = Sys.time(),
#'   data_hash = manifest_data_hash(params, NULL, NULL, NULL, 1L)
#' )
#' verify_manifest(m)$ok
#'
#' m@params$a[1] <- 0.3
#' verify_manifest(m)$ok
#'
#' @export
verify_manifest <- function(m) {
  if (!is_orchestra_manifest(m)) {
    return(list(ok = FALSE, message = "not an orchestra_manifest"))
  }
  recomputed <- manifest_data_hash(S7::prop(m, "params"),
                                   S7::prop(m, "outputs"),
                                   S7::prop(m, "weights"),
                                   S7::prop(m, "obs_target"),
                                   S7::prop(m, "seed"),
                                   .prop_or_null(m, "summary"))
  ok <- identical(recomputed, S7::prop(m, "data_hash"))
  list(ok = ok,
       message = if (ok) "data_hash verified"
                 else "data_hash MISMATCH -- manifest payload was modified")
}

#' Consume a manifest, or refuse it loudly
#'
#' The consumer-side guard. Checks that the object is a manifest, that its
#' schema version is one the caller declared it accepts, and that its payload
#' still verifies, and errors informatively on any of the three rather than
#' proceeding.
#'
#' The version check is the point. Coercing silently across a schema boundary
#' is how a pipeline ends up reading a slot that means something else than it
#' did when the consumer was written, and the failure surfaces far downstream
#' as a wrong number rather than an error. Declaring the accepted set makes
#' the boundary explicit and moves the failure to the seam where it belongs.
#'
#' @param m The manifest to consume.
#' @param accept A character vector of accepted contract versions. Defaults to
#'   [manifest_version()], the version this package implements. Widen it
#'   deliberately, per consumer, when a consumer has been shown to read an
#'   older schema correctly.
#'
#' @returns `m`, invisibly, when all three checks pass. Errors otherwise.
#'
#' @seealso [verify_manifest()] for the non-erroring integrity check.
#'
#' @author Max Moldovan
#'
#' @examples
#' params <- data.frame(a = c(0.1, 0.2))
#' m <- orchestra_manifest(
#'   emitter_package = "example",
#'   emitter_version = "0.1.0",
#'   inferential_target = "parameters",
#'   run_id = "example-001",
#'   method = "example:demo",
#'   seed = 1L,
#'   params = params,
#'   timestamp = Sys.time(),
#'   data_hash = manifest_data_hash(params, NULL, NULL, NULL, 1L)
#' )
#' identical(consume_manifest(m), m)
#'
#' # A consumer that only reads a future schema refuses this one.
#' try(consume_manifest(m, accept = "9.9.9"))
#'
#' @export
consume_manifest <- function(m, accept = manifest_version()) {
  if (!is_orchestra_manifest(m)) {
    stop(call. = FALSE,
         "consume_manifest(): object is not an orchestra_manifest")
  }
  mv <- S7::prop(m, "manifest_version")
  if (!mv %in% accept) {
    stop(call. = FALSE,
         sprintf(paste0("consume_manifest(): manifest_version '%s' is not in ",
                        "the accepted set {%s} -- refusing to consume rather ",
                        "than silently coerce across a schema boundary"),
                 mv, paste(accept, collapse = ", ")))
  }
  v <- verify_manifest(m)
  if (!isTRUE(v$ok)) {
    stop(call. = FALSE,
         "consume_manifest(): integrity check failed -- ", v$message)
  }
  invisible(m)
}
