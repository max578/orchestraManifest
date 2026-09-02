# constants.R -- The contract's version and its closed vocabulary of targets.
#
# Both values are load-bearing across every component that emits or consumes a
# manifest, so they are read through accessor functions rather than exported
# as mutable bindings. The internal constants are collated first (this file
# sorts ahead of `manifest_class.R`) because the class definition consumes
# `.MANIFEST_VERSION` at build time as a property default.

# The contract version stamped onto every manifest this package emits.
#
# 2.0.0 (2026-07-05) made the integrity hash version-stable: serialisation is
# pinned to format 2 and its 14-byte header (magic, format, writer and minimum
# R versions) is dropped before hashing. Before that change the header was
# hashed too, so a manifest emitted under one R version failed verification
# under any other. That is breaking for the verification of older manifests,
# which must be re-emitted, hence the major bump.
.MANIFEST_VERSION <- "2.0.0-draft"

# The closed set of things a manifest may claim to be about.
#
# `breeding_values` (genomic estimated breeding values) and
# `marker_associations` (marker effects from an association scan) were added
# 2026-06-11; `structure` (a recovered causal or graphical-model edge set, as
# opposed to a parameter vector or a prediction) was added 2026-06-24. Both
# additions are purely additive -- existing targets are unchanged and existing
# manifests stay valid -- so neither bumped the contract version.
.INFERENTIAL_TARGETS <- c("parameters", "predictions",
                          "treatment_effects", "decisions",
                          "breeding_values", "marker_associations",
                          "structure")

#' Default value operator
#'
#' Returns `a` unless it is `NULL`, in which case it returns `b`.
#'
#' @param a The value to prefer.
#' @param b The fallback used when `a` is `NULL`.
#'
#' @returns `a` when `a` is not `NULL`, otherwise `b`.
#'
#' @noRd
#' @keywords internal
`%||%` <- function(a, b) if (is.null(a)) b else a

#' The contract version this package emits and accepts
#'
#' Reports the semantic version of the manifest contract implemented here.
#' Emitters stamp it onto every manifest they build, and [consume_manifest]
#' uses it as the default accepted-version set.
#'
#' The version is a deliberate constant rather than the package version. The
#' contract and its reference implementation move at different speeds: a patch
#' release of this package must not look to a consumer like a new schema, and
#' a schema change must be visible even when the package version happens not
#' to have moved.
#'
#' @returns A length-1 character vector, the contract's semantic version.
#'
#' @seealso [consume_manifest] for the guard that uses it.
#'
#' @author Max Moldovan
#'
#' @examples
#' manifest_version()
#'
#' @export
manifest_version <- function() {
  .MANIFEST_VERSION
}

#' The permitted inferential targets
#'
#' Reports the closed vocabulary a manifest's `inferential_target` property
#' must draw from. The vocabulary tells a consumer what kind of thing the
#' manifest holds before it inspects any payload, so a consumer that only
#' understands parameter posteriors can decline a decision manifest without
#' guessing from the shape of `params`.
#'
#' The set grows additively. A new target is a minor, non-breaking change to
#' the contract: manifests already in circulation stay valid, and consumers
#' that do not recognise the new value simply refuse it.
#'
#' @returns A character vector of the permitted `inferential_target` values.
#'
#' @seealso [orchestra_manifest] for the property this vocabulary constrains.
#'
#' @author Max Moldovan
#'
#' @examples
#' inferential_targets()
#'
#' @export
inferential_targets <- function() {
  .INFERENTIAL_TARGETS
}
