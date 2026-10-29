# The shared refusal marker class

The class a component may prepend to its refusal to declare conformance
to the refusal contract explicitly, rather than relying on the
`_refusal` naming convention. The predicates honour both routes, so
opting in by marker and opting in by name are equally valid.

## Usage

``` r
ORCHESTRA_REFUSAL_CLASS
```

## Format

A length-1 character vector.

## See also

[`as_orchestra_refusal()`](https://max578.github.io/orchestraManifest/reference/as_orchestra_refusal.md)
for stamping it,
[`is_orchestra_refusal()`](https://max578.github.io/orchestraManifest/reference/is_orchestra_refusal.md)
for the predicate that honours it.
