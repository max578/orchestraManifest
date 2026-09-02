# orchestraManifest-package.R -- Package-level documentation.
#
# The package extracts the crop-analytics orchestra's composition-layer
# contract -- the `orchestra_manifest` result type, its integrity hash, its
# consumer guard, its provenance vocabulary and its refusal predicates -- from
# a sourced workspace script into an installable, checkable, testable unit.
# Every symbol here is a seam between two components, never a component's own
# domain logic.

#' orchestraManifest: the crop-analytics orchestra contract
#'
#' A single installable home for the artefacts that let independently
#' developed analytics components exchange inference results without knowing
#' anything about each other beyond this contract.
#'
#' The package has four faces. The manifest itself ([orchestra_manifest]) is a
#' versioned, integrity-hashed, provenance-tracked `S7` record of one
#' inference. The consumer guard ([verify_manifest] and [consume_manifest])
#' turns silent schema drift and silent payload tampering into loud, early
#' failures. The provenance vocabulary ([grounding_token],
#' [combine_grounding]) propagates a worst-case grounding label so a verdict
#' resting on an unverified fact is labelled as such. The refusal contract
#' ([is_orchestra_refusal], [is_orchestra_decline]) lets a gate recognise any
#' component's structured refusal or abstention without enumerating component
#' classes.
#'
#' @keywords internal
"_PACKAGE"
