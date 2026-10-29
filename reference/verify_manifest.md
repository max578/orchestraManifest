# Verify a manifest's payload against its stored hash

Recomputes the payload digest from the manifest's own load-bearing slots
and compares it with the `data_hash` the emitter stored. A mismatch
means the payload was modified after emission.

## Usage

``` r
verify_manifest(m)
```

## Arguments

- m:

  The manifest to verify. Anything that is not a manifest yields a
  failed verdict rather than an error.

## Value

A list with `ok`, a length-1 logical, and `message`, a length-1
character vector describing the outcome.

## Details

The check is deliberately total rather than throwing: a consumer often
wants to record that a manifest failed verification and carry on with
the other lenses it has, so the verdict is returned as data. The loud
version is
[`consume_manifest()`](https://max578.github.io/orchestraManifest/reference/consume_manifest.md),
which is what a gate should call.

Because the hash covers the payload only, re-tagging a manifest with a
different schema version, emitter or timestamp leaves verification
intact while any edit to `params`, `outputs`, `weights`, `obs_target`,
`seed` or `summary` breaks it.

## See also

[`consume_manifest()`](https://max578.github.io/orchestraManifest/reference/consume_manifest.md)
for the erroring guard that calls this.

## Author

Max Moldovan

## Examples

``` r
params <- data.frame(a = c(0.1, 0.2))
m <- orchestra_manifest(
  emitter_package = "example",
  emitter_version = "0.1.0",
  inferential_target = "parameters",
  run_id = "example-001",
  method = "example:demo",
  seed = 1L,
  params = params,
  timestamp = Sys.time(),
  data_hash = manifest_data_hash(params, NULL, NULL, NULL, 1L)
)
verify_manifest(m)$ok
#> [1] TRUE

m@params$a[1] <- 0.3
verify_manifest(m)$ok
#> [1] FALSE
```
