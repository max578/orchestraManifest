# Is this object an orchestra manifest?

Tests contract identity tolerantly, accepting both the package-qualified
class this package defines and the bare class minted by emitters that
implement the contract without depending on this package.

## Usage

``` r
is_orchestra_manifest(x)
```

## Arguments

- x:

  Any object.

## Value

A length-1 logical, `TRUE` when `x` is an `S7` object whose class vector
contains an `orchestra_manifest` entry in either the bare or the
package-qualified form.

## Details

A strict
[`S7::S7_inherits()`](https://rconsortium.github.io/S7/reference/S7_inherits.html)
check against the class object defined here would reject every manifest
built anywhere else, including all of those already in circulation,
because `S7` records the defining package in the class identity. Since
the contract is deliberately implementable without a dependency on this
package, identity has to be tested on the class name, which is the part
the contract actually fixes. The object must still be an `S7` object, so
an ordinary list carrying a lookalike class attribute does not pass.

## See also

[orchestra_manifest](https://max578.github.io/orchestraManifest/reference/orchestra_manifest.md)
for the class, and its `Class identity across homes` section for why the
tolerance is needed.

## Author

Max Moldovan

## Examples

``` r
m <- orchestra_manifest(
  emitter_package = "example",
  emitter_version = "0.1.0",
  inferential_target = "parameters",
  run_id = "example-001",
  method = "example:demo",
  timestamp = Sys.time(),
  data_hash = "sha256:example"
)
is_orchestra_manifest(m)
#> [1] TRUE
is_orchestra_manifest(list(a = 1))
#> [1] FALSE
```
