# Assert that two manifests describe the same quantities the same way

Compares the observation schemas of two manifests and refuses the
pairing when a column they share by name disagrees on its quantity or
its unit.

## Usage

``` r
assert_obs_schema_correspondence(m1, m2, what = c("outputs", "params"))
```

## Arguments

- m1:

  The first manifest.

- m2:

  The second manifest.

- what:

  Which schema sides to compare. Any subset of `"outputs"` and
  `"params"`; both by default.

## Value

`NULL`, invisibly, when the schemas agree or when either side carries no
schema. Errors on a disagreement.

## Details

The check is opt-in by presence. When either manifest lacks an
`obs_schema` it is a graceful no-op, so the guard activates only once
both emitters populate the field and no existing pipeline breaks on the
day the guard lands. Columns present in only one schema are ignored;
only the shared names are compared, and only on the fields that carry
meaning for that side – quantity and unit for `outputs`, unit for
`params`.

Refusing rather than warning is the deliberate choice. A unit mismatch
between two manifests is not a degraded comparison, it is an
incommensurable one, and any number produced from it is wrong by a
factor nobody downstream can recover.

## See also

[orchestra_manifest](https://max578.github.io/orchestraManifest/reference/orchestra_manifest.md)
for the `obs_schema` property.

## Author

Max Moldovan

## Examples

``` r
schema_of <- function(unit) {
  list(outputs = data.frame(name = c("o1", "o2"),
                            quantity = c("grain_yield", "grain_yield"),
                            unit = c(unit, "t/ha")))
}
build <- function(unit) {
  orchestra_manifest(
    emitter_package = "example",
    emitter_version = "0.1.0",
    inferential_target = "predictions",
    run_id = paste0("example-", unit),
    method = "example:demo",
    obs_schema = schema_of(unit),
    timestamp = Sys.time(),
    data_hash = manifest_data_hash(data.frame(), NULL, NULL, NULL,
                                   NA_integer_)
  )
}
assert_obs_schema_correspondence(build("t/ha"), build("t/ha"))
try(assert_obs_schema_correspondence(build("t/ha"), build("kg/ha")))
#> Error : obs_schema correspondence FAILED: outputs column 'o1' disagrees on unit ('t/ha' vs 'kg/ha') -- refusing to compare incommensurable quantities across manifests
```
