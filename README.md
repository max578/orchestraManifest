# orchestraManifest

The manifest and refusal contract that lets independently developed
crop-analytics components exchange results without knowing anything about each
other beyond this package.

## What it is

A component's inference result is wrapped once into an `orchestra_manifest`:
what was inferred, which component emitted it, the method and seed behind it,
the load-bearing payload, and the lineage of any upstream manifest it was
derived from. A SHA-256 digest over version-stable serialised bytes lets any
consumer check that the payload has not been modified since emission, and a
consumer declares which contract versions it accepts so that schema drift
fails at the seam rather than as a wrong number downstream.

Alongside the manifest sit two smaller contracts that travel with it. The
provenance vocabulary propagates a worst-case grounding label, so a verdict
resting on an unverified fact is labelled unverified rather than asserted with
false confidence. The refusal contract lets a gate recognise any component's
structured refusal or abstention from its class alone, which closes a silent
false negative: more than one component exports a predicate named
`is_refusal()`, each recognises only its own class, and the bare name resolves
to whichever component was attached last.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("max578/orchestraManifest")
```

## A worked example

``` r
library(orchestraManifest)

params <- data.frame(a = c(0.12, 0.15), b = c(1.51, 1.44))

m <- orchestra_manifest(
  emitter_package    = "example",
  emitter_version    = "0.1.0",
  inferential_target = "parameters",
  run_id             = "example-001",
  method             = "example:demo",
  seed               = 7L,
  params             = params,
  timestamp          = Sys.time(),
  data_hash          = manifest_data_hash(params, NULL, NULL, NULL, 7L)
)

verify_manifest(m)$ok
#> [1] TRUE

m@params$a[1] <- 0.99
verify_manifest(m)$ok
#> [1] FALSE
```

## Where the contract came from

The contract was a script sourced into a coordination workspace before it was
a package, and manifests minted by that reference carry the bare class name
`orchestra_manifest` while manifests minted here carry the package-qualified
`orchestraManifest::orchestra_manifest`. Both are the same contract, so
identity is tested with `is_orchestra_manifest()` rather than a strict class
check, and the package's test suite includes a cross-implementation oracle
that hashes the same payload under both implementations and requires the two
strings to be identical.

## Licence

MIT.
