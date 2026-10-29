# Stamp the shared refusal marker onto an object

Prepends
[ORCHESTRA_REFUSAL_CLASS](https://max578.github.io/orchestraManifest/reference/ORCHESTRA_REFUSAL_CLASS.md)
to an object's class vector so that
[`is_orchestra_refusal()`](https://max578.github.io/orchestraManifest/reference/is_orchestra_refusal.md)
recognises it by the explicit marker rather than by the naming
convention. Useful for seam-side code that mints a refusal of its own
and has no component name to follow the convention with.

## Usage

``` r
as_orchestra_refusal(x)
```

## Arguments

- x:

  The refusal object to mark.

## Value

`x`, with
[ORCHESTRA_REFUSAL_CLASS](https://max578.github.io/orchestraManifest/reference/ORCHESTRA_REFUSAL_CLASS.md)
prepended to its class vector if it was not already present.

## Details

The operation is idempotent: stamping an object that already carries the
marker returns it unchanged, so a refusal can pass through several
layers without accumulating duplicate classes.

## See also

[`is_orchestra_refusal()`](https://max578.github.io/orchestraManifest/reference/is_orchestra_refusal.md).

## Author

Max Moldovan

## Examples

``` r
r <- as_orchestra_refusal(structure(list(why = "no data"), class = "list"))
class(r)
#> [1] "orchestra_refusal" "list"             
identical(as_orchestra_refusal(r), r)
#> [1] TRUE
```
