# Adapt a proxymix mixture fit

Lifts a fitted Gaussian-mixture proxy into the contract. In orchestra
terms such a fit is an approximation to a posterior over parameters, so
it emits a manifest with `inferential_target = "parameters"`, the
mixture as the payload, and the manifold it approximated recorded as
lineage.

## Usage

``` r
manifest_from_gmm(
  x,
  ...,
  seed = NA_integer_,
  consumed = list(),
  run_id = NULL,
  emitter_version = NULL
)
```

## Arguments

- x:

  A
  [`proxymix::gmm_fit`](https://max578.github.io/proxymix/reference/gmm_fit.html).

- ...:

  Unused, present for method compatibility.

- seed:

  The integer RNG seed behind the fit, or `NA_integer_`.

- consumed:

  A list of upstream manifests this fit approximated. A non-empty list
  marks the emitted manifest as derived.

- run_id:

  A run identifier. Defaults to `"proxymix-"` followed by the first
  twelve hexadecimal digits of a digest of the payload, which makes it
  stable under re-emission of the same fit.

- emitter_version:

  The emitting component's version. Defaults to the installed `proxymix`
  version.

## Value

An
[orchestra_manifest](https://max578.github.io/orchestraManifest/reference/orchestra_manifest.md)
with `emitter_package` set to `"proxymix"`.

## Details

Passing `consumed` is what marks the result derived, and the class
validator then requires the lineage to be non-empty. That is the rule
that stops an approximation from quietly losing the provenance of the
thing it approximated – a proxy of a calibration ensemble must be
traceable back to that ensemble, or a reader has no way to tell an
approximation from a fit.

## See also

[`as_orchestra_manifest()`](https://max578.github.io/orchestraManifest/reference/as_orchestra_manifest.md)
for the generic this mirrors,
[`manifest_lineage()`](https://max578.github.io/orchestraManifest/reference/manifest_lineage.md)
for the handle recorded in `consumed_manifests`.

## Author

Max Moldovan

## Examples

``` r
set.seed(1)
draws <- matrix(stats::rnorm(200), 100, 2, dimnames = list(NULL,
                                                           c("a", "b")))
fit <- proxymix::fit_proxymix(proxymix::gmm_target_from_samples(draws),
                              N = 2L, regime = "sample", max_iter = 50L)
m <- manifest_from_gmm(fit, seed = 1L)
verify_manifest(m)$ok
#> [1] TRUE
```
