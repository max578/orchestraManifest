# The contract version this package emits and accepts

Reports the semantic version of the manifest contract implemented here.
Emitters stamp it onto every manifest they build, and
[consume_manifest](https://max578.github.io/orchestraManifest/reference/consume_manifest.md)
uses it as the default accepted-version set.

## Usage

``` r
manifest_version()
```

## Value

A length-1 character vector, the contract's semantic version.

## Details

The version is a deliberate constant rather than the package version.
The contract and its reference implementation move at different speeds:
a patch release of this package must not look to a consumer like a new
schema, and a schema change must be visible even when the package
version happens not to have moved.

## See also

[consume_manifest](https://max578.github.io/orchestraManifest/reference/consume_manifest.md)
for the guard that uses it.

## Author

Max Moldovan

## Examples

``` r
manifest_version()
#> [1] "2.0.0-draft"
```
