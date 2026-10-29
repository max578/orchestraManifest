# Is this a refusal from any orchestra component?

The producer-agnostic replacement for a bare `is_refusal()` at a seam
between components. Returns `TRUE` for the explicit
[ORCHESTRA_REFUSAL_CLASS](https://max578.github.io/orchestraManifest/reference/ORCHESTRA_REFUSAL_CLASS.md)
marker, or for any object whose class follows the `<component>_refusal`
naming convention.

## Usage

``` r
is_orchestra_refusal(x)
```

## Arguments

- x:

  Any object.

## Value

A length-1 logical.

## Details

Testing the class vector rather than dispatching on a known type is what
makes this work across object systems and without attaching, or even
depending on, the producing component's namespace. An S3 refusal has
class `"example_refusal"` and an S7 one
`c("example::example_refusal", "S7_object")`; both are recognised.

## See also

[`is_orchestra_decline()`](https://max578.github.io/orchestraManifest/reference/is_orchestra_decline.md)
for the wider gate-facing union that also covers abstentions.

## Author

Max Moldovan

## Examples

``` r
is_orchestra_refusal(structure(list(), class = "example_refusal"))
#> [1] TRUE
is_orchestra_refusal(structure(list(), class = "example_abstention"))
#> [1] FALSE
is_orchestra_refusal(42)
#> [1] FALSE
```
