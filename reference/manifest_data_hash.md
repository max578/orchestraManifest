# Hash a manifest's load-bearing payload

Computes the digest that goes in a manifest's `data_hash` property, and
that
[`verify_manifest()`](https://max578.github.io/orchestraManifest/reference/verify_manifest.md)
recomputes and compares against. An emitter calls this once, on the
payload it is about to seal into a manifest.

## Usage

``` r
manifest_data_hash(params, outputs, weights, obs_target, seed, summary = NULL)
```

## Arguments

- params:

  The parameter draws, typically a data frame. Pass the value destined
  for the manifest's `params` property, including its default empty data
  frame when there are no draws.

- outputs:

  The model-predicted outputs, or `NULL` when the manifest holds no
  ensemble payload.

- weights:

  The observation weights, or `NULL`.

- obs_target:

  The observed targets, or `NULL`.

- seed:

  The integer RNG seed behind the result, or `NA_integer_`.

- summary:

  The typed verdict from
  [`manifest_summary()`](https://max578.github.io/orchestraManifest/reference/manifest_summary.md),
  or `NULL`.

## Value

A length-1 character vector of the form `"sha256:<hex>"`, ready to be
stored as a manifest's `data_hash`.

## Details

The hash covers the load-bearing data slots only. The schema version,
the emitter identity and the timestamp are metadata and are deliberately
outside it, so re-tagging a manifest does not invalidate a payload that
has not changed, while any edit to the payload is detected.

Argument order is part of the contract, not an implementation detail.
The six slots are hashed as a single list in exactly this order, over
the version-stable byte representation described in the class
documentation. A component that emits manifests without depending on
this package must reproduce that order and that representation exactly,
or its manifests will not verify here.

## See also

[`verify_manifest()`](https://max578.github.io/orchestraManifest/reference/verify_manifest.md),
which recomputes this and compares.

## Author

Max Moldovan

## Examples

``` r
params <- data.frame(a = c(0.1, 0.2), b = c(1.5, 1.4))
manifest_data_hash(params, NULL, NULL, NULL, 1L)
#> [1] "sha256:afce4f88bc4fb660de9cba5ffae54437021ec9b1ae7668aa7eaba36d192c94c7"
```
