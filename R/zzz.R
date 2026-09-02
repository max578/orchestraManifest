# zzz.R -- Conditional registration of the adapter methods.
#
# The two adapters dispatch on classes owned by suggested components, so the
# methods cannot be declared at build time: doing so would evaluate
# `PESTO::pesto_ensemble_manifest` while the namespace is being built and make
# a suggested package a hard requirement for loading this one. They are
# registered at load time instead, each behind its own availability guard, so
# the package loads and every contract function works with neither component
# installed.

#' Register the adapter methods that their components make possible
#'
#' Runs at namespace load. For each suggested component that is installed, the
#' matching adapter body is registered as a method on
#' [as_orchestra_manifest()]. A missing component leaves the generic without
#' that method, which is the honest state: the named function
#' [manifest_from_pesto()] or [manifest_from_gmm()] then refuses with a
#' message that says which component is missing.
#'
#' @param libname The library where the package is installed.
#' @param pkgname The package name.
#'
#' @returns `NULL`, invisibly. Called for its registration side effects.
#'
#' @noRd
#' @keywords internal
.onLoad <- function(libname, pkgname) {
  if (requireNamespace("PESTO", quietly = TRUE)) {
    S7::method(as_orchestra_manifest, PESTO::pesto_ensemble_manifest) <-
      .manifest_from_pesto
  }
  if (requireNamespace("proxymix", quietly = TRUE)) {
    S7::method(as_orchestra_manifest, proxymix::gmm_fit) <-
      .manifest_from_gmm
  }
  invisible(NULL)
}
