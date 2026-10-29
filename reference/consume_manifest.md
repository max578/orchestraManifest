# Consume a manifest, or refuse it loudly

The consumer-side guard. Checks that the object is a manifest, that its
schema version is one the caller declared it accepts, and that its
payload still verifies, and errors informatively on any of the three
rather than proceeding.

## Usage

``` r
consume_manifest(m, accept = manifest_version())
```

## Arguments

- m:

  The manifest to consume.

- accept:

  A character vector of accepted contract versions. Defaults to
  [`manifest_version()`](https://max578.github.io/orchestraManifest/reference/manifest_version.md),
  the version this package implements. Widen it deliberately, per
  consumer, when a consumer has been shown to read an older schema
  correctly.

## Value

`m`, invisibly, when all three checks pass. Errors otherwise.

## Details

The version check is the point. Coercing silently across a schema
boundary is how a pipeline ends up reading a slot that means something
else than it did when the consumer was written, and the failure surfaces
far downstream as a wrong number rather than an error. Declaring the
accepted set makes the boundary explicit and moves the failure to the
seam where it belongs.

## See also

[`verify_manifest()`](https://max578.github.io/orchestraManifest/reference/verify_manifest.md)
for the non-erroring integrity check.

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
identical(consume_manifest(m), m)
#> [1] TRUE

# A consumer that only reads a future schema refuses this one.
try(consume_manifest(m, accept = "9.9.9"))
#> Error : consume_manifest(): manifest_version '2.0.0-draft' is not in the accepted set {9.9.9} -- refusing to consume rather than silently coerce across a schema boundary
```
