# A manifest's headline verdict

Builds the typed, classed list that goes in a manifest's `summary`
property: the headline label of a non-ensemble inference, whether the
emitter abstained, why it abstained, and any key metrics behind the
call.

## Usage

``` r
manifest_summary(
  headline,
  abstained = FALSE,
  metrics = list(),
  abstain_reason = NA_character_
)
```

## Arguments

- headline:

  A single non-empty string stating the conclusion, for example
  `"effect detected"` or `"insufficient evidence"`.

- abstained:

  A single logical. `TRUE` when the emitter declined to stand behind a
  result. Coerced with [`isTRUE()`](https://rdrr.io/r/base/Logic.html)
  on the way in, so a missing value is recorded as `FALSE`.

- metrics:

  A named list of the key numbers behind the headline, for example an
  effect size, a p-value, or an effective sample size. Keep it small; it
  is a summary, not a results table.

- abstain_reason:

  A single string explaining an abstention, or `NA_character_` when the
  emitter did not abstain.

## Value

A list of class `manifest_summary` with elements `headline`,
`abstained`, `abstain_reason` and `metrics`.

## Details

The slot exists because a verdict and an ensemble are different shapes
of result. A causal test or a decision produces one labelled conclusion,
not a matrix of draws, and the alternative – smuggling it into `params`
as a single-row table – leaves consumers unable to distinguish a verdict
from a degenerate posterior. Because `summary` is inside the integrity
hash, a tampered verdict is detected exactly like a tampered payload.

An abstention is a first-class outcome here, not a failure. A component
that will not stand behind a number reports `abstained = TRUE` with a
reason, and a downstream gate treats that as "no usable result from this
lens" rather than reading a number that was never meant to be trusted.

## See also

[orchestra_manifest](https://max578.github.io/orchestraManifest/reference/orchestra_manifest.md)
for the property this fills.

## Author

Max Moldovan

## Examples

``` r
manifest_summary("effect detected", metrics = list(estimate = 0.42))
#> $headline
#> [1] "effect detected"
#> 
#> $abstained
#> [1] FALSE
#> 
#> $abstain_reason
#> [1] NA
#> 
#> $metrics
#> $metrics$estimate
#> [1] 0.42
#> 
#> 
#> attr(,"class")
#> [1] "manifest_summary"

manifest_summary(
  "insufficient evidence",
  abstained = TRUE,
  abstain_reason = "effective sample size below the floor"
)
#> $headline
#> [1] "insufficient evidence"
#> 
#> $abstained
#> [1] TRUE
#> 
#> $abstain_reason
#> [1] "effective sample size below the floor"
#> 
#> $metrics
#> list()
#> 
#> attr(,"class")
#> [1] "manifest_summary"
```
