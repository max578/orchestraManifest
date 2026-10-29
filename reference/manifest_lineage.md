# Take a provenance handle from an upstream manifest

Reduces a manifest to the four fields a downstream manifest records
about it in `consumed_manifests`.

## Usage

``` r
manifest_lineage(cm)
```

## Arguments

- cm:

  The upstream manifest that was consumed.

## Value

A named list with `run_id`, `data_hash`, `emitter_package` and
`emitter_version`.

## Details

Recording the upstream `data_hash` is what makes the lineage
load-bearing rather than decorative. A run identifier alone says only
which run was consumed; the hash says which payload that run had when it
was consumed, so a later re-emission that changed the numbers cannot be
passed off as the same input.

The check on the argument is deliberately the tolerant
[`is_orchestra_manifest()`](https://max578.github.io/orchestraManifest/reference/is_orchestra_manifest.md),
not a strict class test, because the upstream result routinely comes
from a component that implements the contract without depending on this
package.

## See also

[orchestra_manifest](https://max578.github.io/orchestraManifest/reference/orchestra_manifest.md)
for the `consumed_manifests` property this fills, and the lineage rule
its validator enforces.

## Author

Max Moldovan

## Examples

``` r
upstream <- orchestra_manifest(
  emitter_package = "example",
  emitter_version = "0.1.0",
  inferential_target = "parameters",
  run_id = "example-001",
  method = "example:demo",
  timestamp = Sys.time(),
  data_hash = manifest_data_hash(data.frame(), NULL, NULL, NULL,
                                 NA_integer_)
)
manifest_lineage(upstream)
#> $run_id
#> [1] "example-001"
#> 
#> $data_hash
#> [1] "sha256:a6b9951f899999f0c69c3ee7a2cd726e946a130a4bf23d0f944470ea7c50bcc9"
#> 
#> $emitter_package
#> [1] "example"
#> 
#> $emitter_version
#> [1] "0.1.0"
#> 
```
