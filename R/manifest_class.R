# manifest_class.R -- The contract class and the tolerant identity predicate.
#
# One `S7` class and one predicate that recognises it across the two class
# identities in circulation. Everything else in the package either builds one
# of these, checks one of these, or reads provenance off one of these.

#' The orchestra manifest
#'
#' A versioned, integrity-hashed, provenance-tracked record of one inference.
#' It is the single result type components exchange: an emitter fills it in
#' once, and every downstream consumer reads the same properties in the same
#' places whatever produced them.
#'
#' @details
#' The properties fall into four groups. Identity (`manifest_version`,
#' `emitter_package`, `emitter_version`, `run_id`, `method`, `timestamp`) says
#' what this is and what made it. Semantics (`inferential_target`,
#' `obs_schema`) says what it is about, in a closed vocabulary a consumer can
#' dispatch on. Payload (`params`, `outputs`, `weights`, `obs_target`,
#' `summary`, `seed`) carries the load-bearing content, and is exactly the set
#' covered by `data_hash`. Provenance (`consumed_manifests`, `metadata`)
#' records what this result was derived from.
#'
#' Two rules are enforced by the validator rather than left to convention. A
#' manifest whose `metadata$derived` is `TRUE` must record at least one entry
#' in `consumed_manifests`: an approximation may never silently drop the
#' lineage of the thing it approximated. And a `summary`, when set, must be a
#' [manifest_summary()] object, so a verdict has a typed home instead of
#' riding in `params` as a single-row pseudo-parameter table.
#'
#' The `data_hash` deliberately covers the payload only. The schema version,
#' the emitter identity and the timestamp are metadata, so re-tagging a
#' manifest does not invalidate a payload that has not changed, while any edit
#' to the payload is detected by [verify_manifest()].
#'
#' @section Class identity across homes:
#' The contract began as a script sourced into a workspace, where the class
#' was created outside any package and its class vector reads
#' `c("orchestra_manifest", "S7_object")`. Defined inside this package the
#' same class is package-qualified and reads
#' `c("orchestraManifest::orchestra_manifest", "S7_object")`, and components
#' that emit a manifest without depending on this package still mint the bare
#' form. Both are the same contract. Consumers in this package therefore test
#' identity with [is_orchestra_manifest()], which accepts either, rather than
#' with a strict class check that would reject every manifest emitted outside
#' this package.
#'
#' @param manifest_version The contract version this object conforms to.
#'   Defaults to [manifest_version()]. A consumer refuses a version it does
#'   not accept rather than coercing across a schema boundary.
#' @param emitter_package The name of the component that emitted this
#'   manifest, as a single string.
#' @param emitter_version The version of the emitting component, as a single
#'   string.
#' @param inferential_target What the manifest is about. Must be one of
#'   [inferential_targets()].
#' @param run_id A single non-empty string identifying this run. Emitters
#'   commonly derive it from a truncated payload digest so that it is stable
#'   under re-emission of the same result.
#' @param method A single string naming the method that produced the result,
#'   conventionally qualified by its component, as in `"PESTO:ies_callback"`.
#' @param seed The integer RNG seed behind the result, or `NA_integer_` when
#'   the result is deterministic or the seed is unknown.
#' @param params A data frame of parameter draws, one row per realisation.
#'   Defaults to an empty data frame, which is the honest value for a verdict
#'   manifest that carries its content in `summary`.
#' @param outputs Model-predicted outputs at each parameter draw, or `NULL`
#'   when the manifest carries no ensemble payload.
#' @param weights Observation weights, or `NULL`.
#' @param obs_target The observed targets the model was compared against, or
#'   `NULL`.
#' @param obs_schema A semantic descriptor of the observation columns, giving
#'   each one a quantity and a unit, or `NULL`. Populating it activates the
#'   correspondence guard in [assert_obs_schema_correspondence()].
#' @param summary A [manifest_summary()] holding the headline verdict, or
#'   `NULL` for an ensemble manifest that has no verdict to state.
#' @param consumed_manifests A list of provenance handles, each as returned by
#'   [manifest_lineage()], for the upstream manifests this result was derived
#'   from. Required to be non-empty when `metadata$derived` is `TRUE`.
#' @param metadata A named list of caller-supplied metadata. The element
#'   `derived` is load-bearing: setting it to `TRUE` turns on the lineage
#'   requirement.
#' @param timestamp A `POSIXct` emission time.
#' @param data_hash The payload digest, as a single `"sha256:<hex>"` string.
#'   Emitters compute it over the payload slots; [verify_manifest()]
#'   recomputes and compares.
#'
#' @returns An `orchestra_manifest` object.
#'
#' @seealso [verify_manifest()] and [consume_manifest()] for the integrity and
#'   schema guards, [as_orchestra_manifest()] for the emitter generic.
#'
#' @author Max Moldovan
#'
#' @examples
#' m <- orchestra_manifest(
#'   emitter_package = "example",
#'   emitter_version = "0.1.0",
#'   inferential_target = "parameters",
#'   run_id = "example-001",
#'   method = "example:demo",
#'   seed = 1L,
#'   params = data.frame(a = c(0.1, 0.2), b = c(1.5, 1.4)),
#'   timestamp = as.POSIXct("2026-07-05 09:00:00", tz = "UTC"),
#'   data_hash = "sha256:not-yet-computed"
#' )
#' m@emitter_package
#'
#' @export
orchestra_manifest <- S7::new_class(
  "orchestra_manifest",
  properties = list(
    manifest_version   = S7::new_property(S7::class_character,
                                          default = .MANIFEST_VERSION),
    emitter_package    = S7::class_character,
    emitter_version    = S7::class_character,
    inferential_target = S7::class_character,
    run_id             = S7::class_character,
    method             = S7::class_character,
    seed               = S7::new_property(S7::class_integer,
                                          default = NA_integer_),
    # The two composite defaults are quoted rather than evaluated so that the
    # constructor's formals deparse to a readable call instead of an inlined
    # object, which is what keeps the generated documentation and the code in
    # agreement.
    params             = S7::new_property(S7::class_data.frame,
                                          default = quote(data.frame())),
    outputs            = S7::new_property(S7::class_any, default = NULL),
    weights            = S7::new_property(S7::class_any, default = NULL),
    obs_target         = S7::new_property(S7::class_any, default = NULL),
    obs_schema         = S7::new_property(S7::class_any, default = NULL),
    summary            = S7::new_property(S7::class_any, default = NULL),
    consumed_manifests = S7::new_property(S7::class_list, default = list()),
    metadata           = S7::new_property(S7::class_list, default = list()),
    timestamp          = S7::new_property(
      S7::class_POSIXct,
      default = quote(.POSIXct(double(), tz = ""))
    ),
    data_hash          = S7::class_character
  ),
  validator = function(self) {
    errs <- character(0)
    if (length(self@run_id) != 1L || !nzchar(self@run_id)) {
      errs <- c(errs, "`run_id` must be a single non-empty string")
    }
    if (length(self@inferential_target) != 1L ||
        !self@inferential_target %in% .INFERENTIAL_TARGETS) {
      errs <- c(errs, sprintf("`inferential_target` must be one of %s",
                              paste(.INFERENTIAL_TARGETS, collapse = ", ")))
    }
    if (length(self@data_hash) != 1L) {
      errs <- c(errs, "`data_hash` must be a single string")
    }
    # A set `summary` must be a manifest_summary(): the typed verdict home.
    if (!is.null(self@summary) && !inherits(self@summary, "manifest_summary")) {
      errs <- c(errs,
                "`summary`, when set, must be a manifest_summary() object")
    }
    # A derived manifest MUST carry provenance lineage.
    if (isTRUE(self@metadata$derived) &&
        length(self@consumed_manifests) < 1L) {
      errs <- c(errs, paste0("a derived manifest must record >= 1 ",
                             "`consumed_manifests` (provenance lineage ",
                             "is required, not optional)"))
    }
    if (length(errs) == 0L) NULL else paste(errs, collapse = "; ")
  }
)

#' Is this object an orchestra manifest?
#'
#' Tests contract identity tolerantly, accepting both the package-qualified
#' class this package defines and the bare class minted by emitters that
#' implement the contract without depending on this package.
#'
#' A strict `S7::S7_inherits()` check against the class object defined here
#' would reject every manifest built anywhere else, including all of those
#' already in circulation, because `S7` records the defining package in the
#' class identity. Since the contract is deliberately implementable without a
#' dependency on this package, identity has to be tested on the class name,
#' which is the part the contract actually fixes. The object must still be an
#' `S7` object, so an ordinary list carrying a lookalike class attribute does
#' not pass.
#'
#' @param x Any object.
#'
#' @returns A length-1 logical, `TRUE` when `x` is an `S7` object whose class
#'   vector contains an `orchestra_manifest` entry in either the bare or the
#'   package-qualified form.
#'
#' @seealso [orchestra_manifest] for the class, and its `Class identity across
#'   homes` section for why the tolerance is needed.
#'
#' @author Max Moldovan
#'
#' @examples
#' m <- orchestra_manifest(
#'   emitter_package = "example",
#'   emitter_version = "0.1.0",
#'   inferential_target = "parameters",
#'   run_id = "example-001",
#'   method = "example:demo",
#'   timestamp = Sys.time(),
#'   data_hash = "sha256:placeholder"
#' )
#' is_orchestra_manifest(m)
#' is_orchestra_manifest(list(a = 1))
#'
#' @export
is_orchestra_manifest <- function(x) {
  inherits(x, "S7_object") &&
    any(grepl("(^|::|/)orchestra_manifest$", class(x)))
}
