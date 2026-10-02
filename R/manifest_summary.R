# manifest_summary.R -- The typed home for a non-ensemble result's headline.
#
# A causal verdict or a decision has no meaningful values for the ensemble payload
# slots, and forcing it into `params` as a single-row pseudo-parameter table
# makes it unreadable to any consumer that expects draws there. This gives it
# a small, validated, integrity-hashed home of its own.

#' Validate the inputs to a manifest summary
#'
#' Checks the four arguments of [manifest_summary()] before the object is
#' built, so a malformed verdict fails at its point of construction rather
#' than at the point some consumer tries to read it.
#'
#' @param headline The proposed headline.
#' @param abstained The proposed abstention flag.
#' @param metrics The proposed metrics list.
#'
#' @returns `NULL`, invisibly. Called for its side effect of erroring.
#'
#' @noRd
#' @keywords internal
.check_summary_inputs <- function(headline, abstained, metrics) {
  if (!is.character(headline) || length(headline) != 1L || !nzchar(headline)) {
    stop(call. = FALSE, "`headline` must be a single non-empty string")
  }
  if (!is.logical(abstained) || length(abstained) != 1L) {
    stop(call. = FALSE, "`abstained` must be a single logical value")
  }
  if (!is.list(metrics)) {
    stop(call. = FALSE, "`metrics` must be a list")
  }
  invisible(NULL)
}

#' A manifest's headline verdict
#'
#' Builds the typed, classed list that goes in a manifest's `summary`
#' property: the headline label of a non-ensemble inference, whether the
#' emitter abstained, why it abstained, and any key metrics behind the call.
#'
#' The slot exists because a verdict and an ensemble are different shapes of
#' result. A causal test or a decision produces one labelled conclusion, not a
#' matrix of draws, and the alternative -- smuggling it into `params` as a
#' single-row table -- leaves consumers unable to distinguish a verdict from a
#' degenerate posterior. Because `summary` is inside the integrity hash, a
#' tampered verdict is detected exactly like a tampered payload.
#'
#' An abstention is a first-class outcome here, not a failure. A component
#' that will not stand behind a number reports `abstained = TRUE` with a
#' reason, and a downstream gate treats that as "no usable result from this
#' lens" rather than reading a number that was never meant to be trusted.
#'
#' @param headline A single non-empty string stating the conclusion, for
#'   example `"effect detected"` or `"insufficient evidence"`.
#' @param abstained A single logical. `TRUE` when the emitter declined to
#'   stand behind a result. Coerced with [isTRUE()] on the way in, so a
#'   missing value is recorded as `FALSE`.
#' @param metrics A named list of the key numbers behind the headline, for
#'   example an effect size, a p-value, or an effective sample size. Keep it
#'   small; it is a summary, not a results table.
#' @param abstain_reason A single string explaining an abstention, or
#'   `NA_character_` when the emitter did not abstain.
#'
#' @returns A list of class `manifest_summary` with elements `headline`,
#'   `abstained`, `abstain_reason` and `metrics`.
#'
#' @seealso [orchestra_manifest] for the property this fills.
#'
#' @author Max Moldovan
#'
#' @examples
#' manifest_summary("effect detected", metrics = list(estimate = 0.42))
#'
#' manifest_summary(
#'   "insufficient evidence",
#'   abstained = TRUE,
#'   abstain_reason = "effective sample size below the floor"
#' )
#'
#' @export
manifest_summary <- function(headline, abstained = FALSE, metrics = list(),
                             abstain_reason = NA_character_) {
  .check_summary_inputs(headline, abstained, metrics)
  structure(list(headline = headline, abstained = isTRUE(abstained),
                 abstain_reason = abstain_reason, metrics = metrics),
            class = "manifest_summary")
}
