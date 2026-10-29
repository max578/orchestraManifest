# The token marking a fact as unverified

The canonical string stamped on a fact whose external referent has not
been checked, or whose evidence set contains at least one unchecked
element. It is the safe default: a fact is unverified until something
grounds it, never the other way round.

## Usage

``` r
GROUNDING_UNVERIFIED
```

## Format

A length-1 character vector.

## Details

The value is `"ungrounded"`.
[`combine_grounding()`](https://max578.github.io/orchestraManifest/reference/combine_grounding.md)
also reads the token that releases up to 0.1.0 emitted as not grounded.

## See also

[GROUNDING_GROUNDED](https://max578.github.io/orchestraManifest/reference/GROUNDING_GROUNDED.md)
for its complement,
[combine_grounding](https://max578.github.io/orchestraManifest/reference/combine_grounding.md)
for how one unverified input taints a set.
