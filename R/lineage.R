# lineage.R -- The compact provenance handle recorded in a derived manifest.
#
# A derived manifest records what it approximated, not a copy of it. The
# handle is small enough to carry cheaply through a long chain and specific
# enough to re-identify the upstream result exactly: the run identifies it,
# the hash pins the payload it had at the time, and the emitter pair says
# which component and version produced it.

#' Take a provenance handle from an upstream manifest
#'
#' Reduces a manifest to the four fields a downstream manifest records about
#' it in `consumed_manifests`.
#'
#' Recording the upstream `data_hash` is what makes the lineage load-bearing
#' rather than decorative. A run identifier alone says only which run was
#' consumed; the hash says which payload that run had when it was consumed,
#' so a later re-emission that changed the numbers cannot be passed off as the
#' same input.
#'
#' The check on the argument is deliberately the tolerant
#' [is_orchestra_manifest()], not a strict class test, because the upstream
#' result routinely comes from a component that implements the contract
#' without depending on this package.
#'
#' @param cm The upstream manifest that was consumed.
#'
#' @returns A named list with `run_id`, `data_hash`, `emitter_package` and
#'   `emitter_version`.
#'
#' @seealso [orchestra_manifest] for the `consumed_manifests` property this
#'   fills, and the lineage rule its validator enforces.
#'
#' @author Max Moldovan
#'
#' @examples
#' upstream <- orchestra_manifest(
#'   emitter_package = "example",
#'   emitter_version = "0.1.0",
#'   inferential_target = "parameters",
#'   run_id = "example-001",
#'   method = "example:demo",
#'   timestamp = Sys.time(),
#'   data_hash = manifest_data_hash(data.frame(), NULL, NULL, NULL,
#'                                  NA_integer_)
#' )
#' manifest_lineage(upstream)
#'
#' @export
manifest_lineage <- function(cm) {
  if (!is_orchestra_manifest(cm)) {
    stop(call. = FALSE,
         "consumed manifests must themselves be orchestra_manifest objects")
  }
  list(run_id = S7::prop(cm, "run_id"),
       data_hash = S7::prop(cm, "data_hash"),
       emitter_package = S7::prop(cm, "emitter_package"),
       emitter_version = S7::prop(cm, "emitter_version"))
}
