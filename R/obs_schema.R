# obs_schema.R -- The correspondence guard between two manifests' semantics.
#
# A purely structural conformance check cannot catch a wrong-but-agreed
# convention: two components that both label a column `o1` will compare
# happily even when one means tonnes per hectare and the other kilograms per
# hectare. The guard here is the assertion that breaks that trap, by
# comparing the semantic descriptors rather than the column positions.

#' Assert that two manifests describe the same quantities the same way
#'
#' Compares the observation schemas of two manifests and refuses the pairing
#' when a column they share by name disagrees on its quantity or its unit.
#'
#' @details
#' The check is opt-in by presence. When either manifest lacks an
#' `obs_schema` it is a graceful no-op, so the guard activates only once both
#' emitters populate the field and no existing pipeline breaks on the day the
#' guard lands. Columns present in only one schema are ignored; only the
#' shared names are compared, and only on the fields that carry meaning for
#' that side -- quantity and unit for `outputs`, unit for `params`.
#'
#' Refusing rather than warning is the deliberate choice. A unit mismatch
#' between two manifests is not a degraded comparison, it is an
#' incommensurable one, and any number produced from it is wrong by a factor
#' nobody downstream can recover.
#'
#' @param m1 The first manifest.
#' @param m2 The second manifest.
#' @param what Which schema sides to compare. Any subset of `"outputs"` and
#'   `"params"`; both by default.
#'
#' @returns `NULL`, invisibly, when the schemas agree or when either side
#'   carries no schema. Errors on a disagreement.
#'
#' @seealso [orchestra_manifest] for the `obs_schema` property.
#'
#' @author Max Moldovan
#'
#' @examples
#' schema_of <- function(unit) {
#'   list(outputs = data.frame(name = c("o1", "o2"),
#'                             quantity = c("grain_yield", "grain_yield"),
#'                             unit = c(unit, "t/ha")))
#' }
#' build <- function(unit) {
#'   orchestra_manifest(
#'     emitter_package = "example",
#'     emitter_version = "0.1.0",
#'     inferential_target = "predictions",
#'     run_id = paste0("example-", unit),
#'     method = "example:demo",
#'     obs_schema = schema_of(unit),
#'     timestamp = Sys.time(),
#'     data_hash = manifest_data_hash(data.frame(), NULL, NULL, NULL,
#'                                    NA_integer_)
#'   )
#' }
#' assert_obs_schema_correspondence(build("t/ha"), build("t/ha"))
#' try(assert_obs_schema_correspondence(build("t/ha"), build("kg/ha")))
#'
#' @export
assert_obs_schema_correspondence <- function(m1, m2,
                                             what = c("outputs", "params")) {
  os1 <- .prop_or_null(m1, "obs_schema")
  os2 <- .prop_or_null(m2, "obs_schema")
  if (is.null(os1) || is.null(os2)) {
    return(invisible(NULL))
  }
  what <- match.arg(what, several.ok = TRUE)
  cmp_cols <- list(outputs = c("quantity", "unit"),
                   params  = c("unit"))
  for (side in what) {
    a <- os1[[side]]
    b <- os2[[side]]
    if (is.null(a) || is.null(b)) {
      next
    }
    shared <- intersect(as.character(a$name), as.character(b$name))
    for (col in shared) {
      ra <- a[a$name == col, , drop = FALSE]
      rb <- b[b$name == col, , drop = FALSE]
      for (field in cmp_cols[[side]]) {
        va <- as.character(ra[[field]])
        vb <- as.character(rb[[field]])
        if (!identical(va, vb)) {
          stop(call. = FALSE,
               sprintf(paste0("obs_schema correspondence FAILED: %s column ",
                              "'%s' disagrees on %s ('%s' vs '%s') -- ",
                              "refusing to compare incommensurable ",
                              "quantities across manifests"),
                       side, col, field, va, vb))
        }
      }
    }
  }
  invisible(NULL)
}
