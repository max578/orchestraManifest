# Mint a grounding token for a set of facts

Reduces a vector of verification dates to a single grounding token. A
fact is grounded only when its verification date is present, so an empty
set and a set containing any missing date both yield
[GROUNDING_UNVERIFIED](https://max578.github.io/orchestraManifest/reference/GROUNDING_UNVERIFIED.md).

## Usage

``` r
grounding_token(verified_on)
```

## Arguments

- verified_on:

  A vector of verification dates, one per fact. Any type for which
  [`is.na()`](https://rdrr.io/r/base/NA.html) is meaningful is accepted;
  only missingness is inspected, never the date values themselves. A
  zero-length vector is valid and means "no facts were checked".

## Value

A length-1 character vector:
[GROUNDING_GROUNDED](https://max578.github.io/orchestraManifest/reference/GROUNDING_GROUNDED.md)
when every element is present,
[GROUNDING_UNVERIFIED](https://max578.github.io/orchestraManifest/reference/GROUNDING_UNVERIFIED.md)
otherwise.

## Details

The asymmetry is deliberate and is the whole point of the vocabulary. An
empty evidence set is not neutral – it is the absence of evidence – and
a partially checked set is not partially trustworthy, because the
consumer has no way to tell which element it may lean on. Both collapse
to the unverified token so that a downstream gate errs towards
abstention.

## See also

[combine_grounding](https://max578.github.io/orchestraManifest/reference/combine_grounding.md)
for combining tokens rather than dates.

## Author

Max Moldovan

## Examples

``` r
grounding_token(as.Date(c("2026-07-05", "2026-07-06")))
#> [1] "grounded"
grounding_token(as.Date(c("2026-07-05", NA)))
#> [1] "ungrounded"
grounding_token(as.Date(character(0)))
#> [1] "ungrounded"
```
