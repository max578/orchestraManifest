# Adapt a component's result into an orchestra manifest

The emitter generic. A component that produces its own result type gains
contract membership by having a method registered here, which lifts that
type into an
[orchestra_manifest](https://max578.github.io/orchestraManifest/reference/orchestra_manifest.md)
without the component itself changing.

## Usage

``` r
as_orchestra_manifest(x, ...)
```

## Arguments

- x:

  The component result to adapt.

- ...:

  Arguments passed to the method. See
  [`manifest_from_pesto()`](https://max578.github.io/orchestraManifest/reference/manifest_from_pesto.md)
  and
  [`manifest_from_gmm()`](https://max578.github.io/orchestraManifest/reference/manifest_from_gmm.md)
  for the two that ship here.

## Value

An
[orchestra_manifest](https://max578.github.io/orchestraManifest/reference/orchestra_manifest.md).

## Details

Two methods ship with this package, for a `PESTO` ensemble manifest and
a `proxymix` mixture fit, and each is registered only when its component
is installed. The equivalent plain functions are
[`manifest_from_pesto()`](https://max578.github.io/orchestraManifest/reference/manifest_from_pesto.md)
and
[`manifest_from_gmm()`](https://max578.github.io/orchestraManifest/reference/manifest_from_gmm.md).

## See also

[`manifest_from_pesto()`](https://max578.github.io/orchestraManifest/reference/manifest_from_pesto.md),
[`manifest_from_gmm()`](https://max578.github.io/orchestraManifest/reference/manifest_from_gmm.md).

## Author

Max Moldovan

## Examples

``` r
# Dispatch requires an installed component that carries a method.
if (requireNamespace("proxymix", quietly = TRUE)) {
  print(class(as_orchestra_manifest))
}
#> [1] "S7_generic" "function"   "S7_object" 
```
