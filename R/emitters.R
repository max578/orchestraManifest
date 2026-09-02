# emitters.R -- The adapt-into-the-contract generic and its two adapters.
#
# Components join the contract by adapting, not by being rewritten: a
# component keeps its own result type and this layer lifts it into a manifest.
# Each adapter appears twice, as a method on the `as_orchestra_manifest`
# generic for callers who dispatch, and as a plain named function for callers
# who would rather say what they mean. The methods are registered from
# `.onLoad()` only when the component is installed, because both components
# are suggested rather than required and a suggested package must never be
# needed to load this one.

#' Adapt a component's result into an orchestra manifest
#'
#' The emitter generic. A component that produces its own result type gains
#' contract membership by having a method registered here, which lifts that
#' type into an [orchestra_manifest] without the component itself changing.
#'
#' Two methods ship with this package, for a `PESTO` ensemble manifest and a
#' `proxymix` mixture fit, and each is registered only when its component is
#' installed. The equivalent plain functions are [manifest_from_pesto()] and
#' [manifest_from_gmm()].
#'
#' @param x The component result to adapt.
#' @param ... Arguments passed to the method. See [manifest_from_pesto()] and
#'   [manifest_from_gmm()] for the two that ship here.
#'
#' @returns An [orchestra_manifest].
#'
#' @seealso [manifest_from_pesto()], [manifest_from_gmm()].
#'
#' @author Max Moldovan
#'
#' @examples
#' # Dispatch requires an installed component that carries a method.
#' if (requireNamespace("proxymix", quietly = TRUE)) {
#'   print(class(as_orchestra_manifest))
#' }
#'
#' @export
as_orchestra_manifest <- S7::new_generic("as_orchestra_manifest", "x")

#' Adapt a PESTO ensemble manifest
#'
#' Wraps a `pesto_ensemble_manifest` into the generic contract. The wrap is
#' deliberate: `PESTO` is untouched, its own class and its own hash scheme
#' stay exactly as they are, and the wrapper re-hashes the same payload under
#' the contract's scheme so the result is self-verifying here.
#'
#' `PESTO`'s original digest is preserved in `metadata$pesto_data_hash`, which
#' makes a cross-scheme audit possible: the two hashes cover the same slots by
#' different rules, so a payload that verifies under one and not the other
#' localises the disagreement to the hashing, not to the data.
#'
#' The observation schema is carried through when the source manifest has one,
#' guarded so that a manifest emitted before the schema slot existed still
#' adapts cleanly.
#'
#' @param x A `PESTO::pesto_ensemble_manifest`.
#' @param ... Unused, present for method compatibility.
#' @param inferential_target What the wrapped manifest is about, one of
#'   [inferential_targets()]. Defaults to `"parameters"`, which is what a
#'   calibration ensemble carries.
#'
#' @returns An [orchestra_manifest] with `emitter_package` set to `"PESTO"`.
#'
#' @seealso [as_orchestra_manifest()] for the generic this mirrors.
#'
#' @author Max Moldovan
#'
#' @examplesIf requireNamespace("PESTO", quietly = TRUE)
#' set.seed(1)
#' design <- matrix(stats::rnorm(6), 3, 2)
#' prior <- matrix(stats::rnorm(60), 30, 2, dimnames = list(NULL, c("a", "b")))
#' obs <- as.numeric(design %*% c(0.5, -1))
#' names(obs) <- paste0("o", 1:3)
#' fit <- PESTO::pesto_ies_callback(function(t) t %*% t(design), prior, obs,
#'                                  0.05, noptmax = 2, verbose = FALSE)
#' m <- manifest_from_pesto(PESTO::as_manifest(fit, seed = 1L))
#' verify_manifest(m)$ok
#'
#' @export
manifest_from_pesto <- function(x, ..., inferential_target = "parameters") {
  .require_component("PESTO", "manifest_from_pesto")
  .manifest_from_pesto(x, ..., inferential_target = inferential_target)
}

#' Adapt a proxymix mixture fit
#'
#' Lifts a fitted Gaussian-mixture proxy into the contract. In orchestra terms
#' such a fit is an approximation to a posterior over parameters, so it emits
#' a manifest with `inferential_target = "parameters"`, the mixture as the
#' payload, and the manifold it approximated recorded as lineage.
#'
#' Passing `consumed` is what marks the result derived, and the class
#' validator then requires the lineage to be non-empty. That is the rule that
#' stops an approximation from quietly losing the provenance of the thing it
#' approximated -- a proxy of a calibration ensemble must be traceable back to
#' that ensemble, or a reader has no way to tell an approximation from a fit.
#'
#' @param x A `proxymix::gmm_fit`.
#' @param ... Unused, present for method compatibility.
#' @param seed The integer RNG seed behind the fit, or `NA_integer_`.
#' @param consumed A list of upstream manifests this fit approximated. A
#'   non-empty list marks the emitted manifest as derived.
#' @param run_id A run identifier. Defaults to `"proxymix-"` followed by the
#'   first twelve hexadecimal digits of a digest of the payload, which makes
#'   it stable under re-emission of the same fit.
#' @param emitter_version The emitting component's version. Defaults to the
#'   installed `proxymix` version.
#'
#' @returns An [orchestra_manifest] with `emitter_package` set to
#'   `"proxymix"`.
#'
#' @seealso [as_orchestra_manifest()] for the generic this mirrors,
#'   [manifest_lineage()] for the handle recorded in `consumed_manifests`.
#'
#' @author Max Moldovan
#'
#' @examplesIf requireNamespace("proxymix", quietly = TRUE)
#' set.seed(1)
#' draws <- matrix(stats::rnorm(200), 100, 2, dimnames = list(NULL,
#'                                                            c("a", "b")))
#' fit <- proxymix::fit_proxymix(proxymix::gmm_target_from_samples(draws),
#'                               N = 2L, regime = "sample", max_iter = 50L)
#' m <- manifest_from_gmm(fit, seed = 1L)
#' verify_manifest(m)$ok
#'
#' @export
manifest_from_gmm <- function(x, ..., seed = NA_integer_, consumed = list(),
                              run_id = NULL, emitter_version = NULL) {
  .require_component("proxymix", "manifest_from_gmm")
  .manifest_from_gmm(x, ..., seed = seed, consumed = consumed,
                     run_id = run_id, emitter_version = emitter_version)
}

#' Refuse an adapter call when its component is not installed
#'
#' Both adapters name a suggested component. Calling one without that
#' component installed is a caller error, and this turns it into a message
#' that names the missing component and the call that needed it rather than a
#' failure deep inside the adapter.
#'
#' @param pkg The component's package name.
#' @param fn The adapter that was called.
#'
#' @returns `NULL`, invisibly. Called for its side effect of erroring.
#'
#' @noRd
#' @keywords internal
.require_component <- function(pkg, fn) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(call. = FALSE,
         sprintf("%s() needs the suggested package `%s`, which is not %s",
                 fn, pkg, "installed"))
  }
  invisible(NULL)
}

#' Adapter body for a PESTO ensemble manifest
#'
#' Shared by [manifest_from_pesto()] and by the method registered on
#' [as_orchestra_manifest()], so the dispatching and the named routes cannot
#' drift apart.
#'
#' @param x A `PESTO::pesto_ensemble_manifest`.
#' @param ... Unused.
#' @param inferential_target The target to stamp on the wrapped manifest.
#'
#' @returns An [orchestra_manifest].
#'
#' @noRd
#' @keywords internal
.manifest_from_pesto <- function(x, ..., inferential_target = "parameters") {
  dh <- manifest_data_hash(S7::prop(x, "params"), S7::prop(x, "outputs"),
                           S7::prop(x, "weights"), S7::prop(x, "obs_target"),
                           S7::prop(x, "seed"))
  orchestra_manifest(
    manifest_version   = .MANIFEST_VERSION,
    emitter_package    = "PESTO",
    emitter_version    = S7::prop(x, "pesto_version"),
    inferential_target = inferential_target,
    run_id             = S7::prop(x, "run_id"),
    method             = paste0("PESTO:", S7::prop(x, "method")),
    seed               = S7::prop(x, "seed"),
    params             = S7::prop(x, "params"),
    outputs            = S7::prop(x, "outputs"),
    weights            = S7::prop(x, "weights"),
    obs_target         = S7::prop(x, "obs_target"),
    obs_schema         = .prop_or_null(x, "obs_schema"),
    consumed_manifests = list(),
    metadata           = list(derived = FALSE,
                              wrapped_from = "pesto_ensemble_manifest",
                              pesto_data_hash = S7::prop(x, "data_hash")),
    timestamp          = S7::prop(x, "timestamp"),
    data_hash          = dh
  )
}

#' Adapter body for a proxymix mixture fit
#'
#' Shared by [manifest_from_gmm()] and by the method registered on
#' [as_orchestra_manifest()], so the dispatching and the named routes cannot
#' drift apart.
#'
#' @param x A `proxymix::gmm_fit`.
#' @param ... Unused.
#' @param seed The integer RNG seed behind the fit.
#' @param consumed Upstream manifests this fit approximated.
#' @param run_id A run identifier, or `NULL` to derive one.
#' @param emitter_version The emitting version, or `NULL` to read it.
#'
#' @returns An [orchestra_manifest].
#'
#' @noRd
#' @keywords internal
.manifest_from_gmm <- function(x, ..., seed = NA_integer_, consumed = list(),
                               run_id = NULL, emitter_version = NULL) {
  n_comp <- proxymix::gmm_n_components(x)
  n_dim <- proxymix::gmm_dim(x)
  weights <- S7::prop(x, "weights")
  means <- S7::prop(x, "means")

  means_mat <- do.call(rbind, means)
  colnames(means_mat) <- paste0("par", seq_len(n_dim))
  params <- data.frame(component = seq_len(n_comp),
                       weight = weights,
                       means_mat,
                       check.names = FALSE)

  derived <- length(consumed) > 0L
  meta <- list(
    derived = derived,
    gmm = list(weights = weights, means = means,
               covariances = S7::prop(x, "covariances")),
    regime = S7::prop(x, "regime"),
    diagnostics = S7::prop(x, "diagnostics")
  )

  ev <- emitter_version %||% as.character(utils::packageVersion("proxymix"))
  seed <- as.integer(seed)
  # The load-bearing payload of a parameter manifest is `params`, which
  # encodes the weights and the means, plus the seed. A mixture proxy has no
  # model outputs, observation weights or observation targets to record.
  dh <- manifest_data_hash(params, NULL, NULL, NULL, seed)
  rid <- run_id %||% paste0("proxymix-",
                            substr(.sha256(list(params, seed)), 1L, 12L))

  orchestra_manifest(
    manifest_version   = .MANIFEST_VERSION,
    emitter_package    = "proxymix",
    emitter_version    = ev,
    inferential_target = "parameters",
    run_id             = rid,
    method             = paste0("proxymix:", S7::prop(x, "regime")),
    seed               = seed,
    params             = params,
    consumed_manifests = lapply(consumed, manifest_lineage),
    metadata           = meta,
    timestamp          = Sys.time(),
    data_hash          = dh
  )
}
