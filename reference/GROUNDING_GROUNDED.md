# The token marking a fact as grounded

The canonical string stamped on a fact whose external referent has been
checked against a source that did not also produce the claim. A fact is
grounded if and only if it carries a non-missing verification date.

## Usage

``` r
GROUNDING_GROUNDED
```

## Format

A length-1 character vector.

## See also

[GROUNDING_UNVERIFIED](https://max578.github.io/orchestraManifest/reference/GROUNDING_UNVERIFIED.md)
for its complement,
[grounding_token](https://max578.github.io/orchestraManifest/reference/grounding_token.md)
for the function that mints either.
