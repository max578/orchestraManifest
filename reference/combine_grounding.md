# Combine grounding tokens worst-case

Reduces the tokens of several input facts to the token of a verdict that
rests on all of them. The combination is worst-case: the verdict is
grounded only when every input is grounded.

## Usage

``` r
combine_grounding(tokens)
```

## Arguments

- tokens:

  A character vector of grounding tokens, each of which should be
  [GROUNDING_GROUNDED](https://max578.github.io/orchestraManifest/reference/GROUNDING_GROUNDED.md)
  or
  [GROUNDING_UNVERIFIED](https://max578.github.io/orchestraManifest/reference/GROUNDING_UNVERIFIED.md).
  The token emitted up to 0.1.0 and any unrecognised string are treated
  as not grounded, which is the safe reading. A zero-length vector is
  valid and means "the verdict rests on nothing checked".

## Value

A length-1 character vector:
[GROUNDING_GROUNDED](https://max578.github.io/orchestraManifest/reference/GROUNDING_GROUNDED.md)
when every token is grounded,
[GROUNDING_UNVERIFIED](https://max578.github.io/orchestraManifest/reference/GROUNDING_UNVERIFIED.md)
otherwise.

## Details

Worst-case combination is what stops a grounding label from being
laundered through a pipeline. Any other rule – a majority, a mean, an
optimistic "at least one" – would let a verdict inherit confidence from
the checked inputs while quietly resting on an unchecked one. As with
[grounding_token](https://max578.github.io/orchestraManifest/reference/grounding_token.md),
an empty set of inputs is unverified rather than vacuously grounded.

## See also

[grounding_token](https://max578.github.io/orchestraManifest/reference/grounding_token.md)
for minting a token from verification dates.

## Author

Max Moldovan

## Examples

``` r
combine_grounding(c(GROUNDING_GROUNDED, GROUNDING_GROUNDED))
#> [1] "grounded"
combine_grounding(c(GROUNDING_GROUNDED, GROUNDING_UNVERIFIED))
#> [1] "ungrounded"
combine_grounding(character(0))
#> [1] "ungrounded"
```
