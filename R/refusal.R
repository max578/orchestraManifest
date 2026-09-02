# refusal.R -- The cross-component refusal and abstention contract.
#
# More than one component exports a predicate named `is_refusal()`, and each
# recognises only its own class. When two such components are attached the
# bare name resolves to whichever was attached last, and it returns FALSE on
# the other component's genuine refusal -- a silent false negative that lets a
# gate which should have stopped sail straight through.
#
# The contract has two halves. A naming convention: a component's structured
# refusal has a class ending in `_refusal` and its structured abstention a
# class ending in `_abstention`, which holds across object systems because the
# class vector of an S3 refusal and of an S7 one both end that way. And a
# namespace discipline: code at a seam between components never calls a bare
# `is_refusal()`, it calls the producer-agnostic predicates below.
#
# A heavier design -- a common parent class stamped onto every component's
# refusal -- is deliberately not taken. It would force a coordinated release
# across every component and a unification of two object systems to solve a
# problem the naming convention plus a seam-side predicate already solve.

#' The shared refusal marker class
#'
#' The class a component may prepend to its refusal to declare conformance to
#' the refusal contract explicitly, rather than relying on the `_refusal`
#' naming convention. The predicates honour both routes, so opting in by
#' marker and opting in by name are equally valid.
#'
#' @format A length-1 character vector.
#'
#' @seealso [as_orchestra_refusal()] for stamping it,
#'   [is_orchestra_refusal()] for the predicate that honours it.
#'
#' @export
ORCHESTRA_REFUSAL_CLASS <- "orchestra_refusal"

#' Is this a refusal from any orchestra component?
#'
#' The producer-agnostic replacement for a bare `is_refusal()` at a seam
#' between components. Returns `TRUE` for the explicit
#' [ORCHESTRA_REFUSAL_CLASS] marker, or for any object whose class follows the
#' `<component>_refusal` naming convention.
#'
#' Testing the class vector rather than dispatching on a known type is what
#' makes this work across object systems and without attaching, or even
#' depending on, the producing component's namespace. An S3 refusal has class
#' `"example_refusal"` and an S7 one `c("example::example_refusal",
#' "S7_object")`; both are recognised.
#'
#' @param x Any object.
#'
#' @returns A length-1 logical.
#'
#' @seealso [is_orchestra_decline()] for the wider gate-facing union that also
#'   covers abstentions.
#'
#' @author Max Moldovan
#'
#' @examples
#' is_orchestra_refusal(structure(list(), class = "example_refusal"))
#' is_orchestra_refusal(structure(list(), class = "example_abstention"))
#' is_orchestra_refusal(42)
#'
#' @export
is_orchestra_refusal <- function(x) {
  cls <- class(x)
  any(cls == ORCHESTRA_REFUSAL_CLASS) || any(grepl("_refusal$", cls))
}

#' Did any orchestra component decline to stand behind a result?
#'
#' The gate-facing union. Returns `TRUE` for a refusal, where a component will
#' not produce the result at all, and also for an abstention, where a
#' component produces a typed "assumptions not met" object instead of a
#' number.
#'
#' Gate logic almost always wants this rather than [is_orchestra_refusal()],
#' because the two outcomes mean the same thing to the gate: no usable result
#' from this lens. Enumerating component classes at the gate is the
#' alternative, and it silently stops recognising declines the moment a new
#' component joins.
#'
#' @param x Any object.
#'
#' @returns A length-1 logical.
#'
#' @seealso [is_orchestra_refusal()] for the narrower refusal-only test.
#'
#' @author Max Moldovan
#'
#' @examples
#' is_orchestra_decline(structure(list(), class = "example_refusal"))
#' is_orchestra_decline(structure(list(), class = "example_abstention"))
#' is_orchestra_decline(42)
#'
#' @export
is_orchestra_decline <- function(x) {
  cls <- class(x)
  any(cls == ORCHESTRA_REFUSAL_CLASS) ||
    any(grepl("_(refusal|abstention)$", cls))
}

#' Stamp the shared refusal marker onto an object
#'
#' Prepends [ORCHESTRA_REFUSAL_CLASS] to an object's class vector so that
#' [is_orchestra_refusal()] recognises it by the explicit marker rather than
#' by the naming convention. Useful for seam-side code that mints a refusal of
#' its own and has no component name to follow the convention with.
#'
#' The operation is idempotent: stamping an object that already carries the
#' marker returns it unchanged, so a refusal can pass through several layers
#' without accumulating duplicate classes.
#'
#' @param x The refusal object to mark.
#'
#' @returns `x`, with [ORCHESTRA_REFUSAL_CLASS] prepended to its class vector
#'   if it was not already present.
#'
#' @seealso [is_orchestra_refusal()].
#'
#' @author Max Moldovan
#'
#' @examples
#' r <- as_orchestra_refusal(structure(list(why = "no data"), class = "list"))
#' class(r)
#' identical(as_orchestra_refusal(r), r)
#'
#' @export
as_orchestra_refusal <- function(x) {
  if (!any(class(x) == ORCHESTRA_REFUSAL_CLASS)) {
    class(x) <- c(ORCHESTRA_REFUSAL_CLASS, class(x))
  }
  x
}
