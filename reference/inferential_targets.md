# The permitted inferential targets

Reports the closed vocabulary a manifest's `inferential_target` property
must draw from. The vocabulary tells a consumer what kind of thing the
manifest holds before it inspects any payload, so a consumer that only
understands parameter posteriors can decline a decision manifest without
guessing from the shape of `params`.

## Usage

``` r
inferential_targets()
```

## Value

A character vector of the permitted `inferential_target` values.

## Details

The set grows additively. A new target is a minor, non-breaking change
to the contract: manifests already in circulation stay valid, and
consumers that do not recognise the new value simply refuse it.

## See also

[orchestra_manifest](https://max578.github.io/orchestraManifest/reference/orchestra_manifest.md)
for the property this vocabulary constrains.

## Author

Max Moldovan

## Examples

``` r
inferential_targets()
#> [1] "parameters"          "predictions"         "treatment_effects"  
#> [4] "decisions"           "breeding_values"     "marker_associations"
#> [7] "structure"           "consensus"          
```
