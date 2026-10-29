# Adapt a PESTO ensemble manifest

Wraps a `pesto_ensemble_manifest` into the generic contract. The wrap is
deliberate: `PESTO` is untouched, its own class and its own hash scheme
stay exactly as they are, and the wrapper re-hashes the same payload
under the contract's scheme so the result is self-verifying here.

## Usage

``` r
manifest_from_pesto(x, ..., inferential_target = "parameters")
```

## Arguments

- x:

  A
  [`PESTO::pesto_ensemble_manifest`](https://max578.github.io/PESTO/reference/pesto_ensemble_manifest.html).

- ...:

  Unused, present for method compatibility.

- inferential_target:

  What the wrapped manifest is about, one of
  [`inferential_targets()`](https://max578.github.io/orchestraManifest/reference/inferential_targets.md).
  Defaults to `"parameters"`, which is what a calibration ensemble
  carries.

## Value

An
[orchestra_manifest](https://max578.github.io/orchestraManifest/reference/orchestra_manifest.md)
with `emitter_package` set to `"PESTO"`.

## Details

`PESTO`'s original digest is preserved in `metadata$pesto_data_hash`,
which makes a cross-scheme audit possible: the two hashes cover the same
slots by different rules, so a payload that verifies under one and not
the other localises the disagreement to the hashing, not to the data.

The observation schema is carried through when the source manifest has
one, guarded so that a manifest emitted before the schema slot existed
still adapts cleanly.

## See also

[`as_orchestra_manifest()`](https://max578.github.io/orchestraManifest/reference/as_orchestra_manifest.md)
for the generic this mirrors.

## Author

Max Moldovan

## Examples

``` r
set.seed(1)
design <- matrix(stats::rnorm(6), 3, 2)
prior <- matrix(stats::rnorm(60), 30, 2, dimnames = list(NULL, c("a", "b")))
obs <- as.numeric(design %*% c(0.5, -1))
names(obs) <- paste0("o", 1:3)
fit <- PESTO::pesto_ies_callback(function(t) t %*% t(design), prior, obs,
                                 0.05, noptmax = 2, verbose = FALSE)
m <- manifest_from_pesto(PESTO::as_manifest(fit, seed = 1L))
verify_manifest(m)$ok
#> [1] TRUE
```
