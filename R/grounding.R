# grounding.R -- The provenance vocabulary shared across the orchestra.
#
# Two canonical tokens and the two functions that mint and combine them. A
# component that cannot depend on this package must hardcode these exact
# strings rather than a synonym, because a consumer decides whether to trust a
# result by string comparison and a synonym reads as an unknown state.
#
# The vocabulary is orthogonal to the refusal contract in `refusal.R`: a
# grounding token describes how well a fact is evidenced, a refusal describes
# a control-flow outcome. A refusal may carry a token; neither implies the
# other.

#' The token marking a fact as grounded
#'
#' The canonical string stamped on a fact whose external referent has been
#' checked against a source that did not also produce the claim. A fact is
#' grounded if and only if it carries a non-missing verification date.
#'
#' @format A length-1 character vector.
#'
#' @seealso [GROUNDING_UNVERIFIED] for its complement, [grounding_token] for
#'   the function that mints either.
#'
#' @export
GROUNDING_GROUNDED <- "grounded"

#' The token marking a fact as unverified
#'
#' The canonical string stamped on a fact whose external referent has not been
#' checked, or whose evidence set contains at least one unchecked element. It
#' is the safe default: a fact is unverified until something grounds it, never
#' the other way round.
#'
#' @format A length-1 character vector.
#'
#' @seealso [GROUNDING_GROUNDED] for its complement, [combine_grounding] for
#'   how one unverified input taints a set.
#'
#' @export
GROUNDING_UNVERIFIED <- "[unverified]"

#' Mint a grounding token for a set of facts
#'
#' Reduces a vector of verification dates to a single grounding token. A fact
#' is grounded only when its verification date is present, so an empty set and
#' a set containing any missing date both yield [GROUNDING_UNVERIFIED].
#'
#' The asymmetry is deliberate and is the whole point of the vocabulary. An
#' empty evidence set is not neutral -- it is the absence of evidence -- and a
#' partially checked set is not partially trustworthy, because the consumer
#' has no way to tell which element it may lean on. Both collapse to the
#' unverified token so that a downstream gate errs towards abstention.
#'
#' @param verified_on A vector of verification dates, one per fact. Any type
#'   for which [is.na()] is meaningful is accepted; only missingness is
#'   inspected, never the date values themselves. A zero-length vector is
#'   valid and means "no facts were checked".
#'
#' @returns A length-1 character vector: [GROUNDING_GROUNDED] when every
#'   element is present, [GROUNDING_UNVERIFIED] otherwise.
#'
#' @seealso [combine_grounding] for combining tokens rather than dates.
#'
#' @author Max Moldovan
#'
#' @examples
#' grounding_token(as.Date(c("2026-07-05", "2026-07-06")))
#' grounding_token(as.Date(c("2026-07-05", NA)))
#' grounding_token(as.Date(character(0)))
#'
#' @export
grounding_token <- function(verified_on) {
  if (length(verified_on) == 0L || all(is.na(verified_on))) {
    GROUNDING_UNVERIFIED
  } else if (any(is.na(verified_on))) {
    GROUNDING_UNVERIFIED            # any un-grounded element taints the set
  } else {
    GROUNDING_GROUNDED
  }
}

#' Combine grounding tokens worst-case
#'
#' Reduces the tokens of several input facts to the token of a verdict that
#' rests on all of them. The combination is worst-case: the verdict is
#' grounded only when every input is grounded.
#'
#' Worst-case combination is what stops a grounding label from being laundered
#' through a pipeline. Any other rule -- a majority, a mean, an optimistic
#' "at least one" -- would let a verdict inherit confidence from the checked
#' inputs while quietly resting on an unchecked one. As with
#' [grounding_token], an empty set of inputs is unverified rather than
#' vacuously grounded.
#'
#' @param tokens A character vector of grounding tokens, each of which should
#'   be [GROUNDING_GROUNDED] or [GROUNDING_UNVERIFIED]. An unrecognised string
#'   is treated as not-grounded, which is the safe reading. A zero-length
#'   vector is valid and means "the verdict rests on nothing checked".
#'
#' @returns A length-1 character vector: [GROUNDING_GROUNDED] when every token
#'   is grounded, [GROUNDING_UNVERIFIED] otherwise.
#'
#' @seealso [grounding_token] for minting a token from verification dates.
#'
#' @author Max Moldovan
#'
#' @examples
#' combine_grounding(c(GROUNDING_GROUNDED, GROUNDING_GROUNDED))
#' combine_grounding(c(GROUNDING_GROUNDED, GROUNDING_UNVERIFIED))
#' combine_grounding(character(0))
#'
#' @export
combine_grounding <- function(tokens) {
  if (length(tokens) == 0L) {
    return(GROUNDING_UNVERIFIED)
  }
  if (all(tokens == GROUNDING_GROUNDED)) {
    GROUNDING_GROUNDED
  } else {
    GROUNDING_UNVERIFIED
  }
}
