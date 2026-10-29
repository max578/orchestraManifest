# Did any orchestra component decline to stand behind a result?

The gate-facing union. Returns `TRUE` for a refusal, where a component
will not produce the result at all, and also for an abstention, where a
component produces a typed "assumptions not met" object instead of a
number.

## Usage

``` r
is_orchestra_decline(x)
```

## Arguments

- x:

  Any object.

## Value

A length-1 logical.

## Details

Gate logic almost always wants this rather than
[`is_orchestra_refusal()`](https://max578.github.io/orchestraManifest/reference/is_orchestra_refusal.md),
because the two outcomes mean the same thing to the gate: no usable
result from this lens. Enumerating component classes at the gate is the
alternative, and it silently stops recognising declines the moment a new
component joins.

## See also

[`is_orchestra_refusal()`](https://max578.github.io/orchestraManifest/reference/is_orchestra_refusal.md)
for the narrower refusal-only test.

## Author

Max Moldovan

## Examples

``` r
is_orchestra_decline(structure(list(), class = "example_refusal"))
#> [1] TRUE
is_orchestra_decline(structure(list(), class = "example_abstention"))
#> [1] TRUE
is_orchestra_decline(42)
#> [1] FALSE
```
