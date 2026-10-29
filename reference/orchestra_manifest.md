# The orchestra manifest

A versioned, integrity-hashed, provenance-tracked record of one
inference. It is the single result type components exchange: an emitter
fills it in once, and every downstream consumer reads the same
properties in the same places whatever produced them.

## Usage

``` r
orchestra_manifest(
  manifest_version = "2.0.0-draft",
  emitter_package = character(0),
  emitter_version = character(0),
  inferential_target = character(0),
  run_id = character(0),
  method = character(0),
  seed = NA_integer_,
  params = data.frame(),
  outputs = NULL,
  weights = NULL,
  obs_target = NULL,
  obs_schema = NULL,
  summary = NULL,
  consumed_manifests = list(),
  metadata = list(),
  timestamp = .POSIXct(double(), tz = ""),
  data_hash = character(0)
)
```

## Arguments

- manifest_version:

  The contract version this object conforms to. Defaults to
  [`manifest_version()`](https://max578.github.io/orchestraManifest/reference/manifest_version.md).
  A consumer refuses a version it does not accept rather than coercing
  across a schema boundary.

- emitter_package:

  The name of the component that emitted this manifest, as a single
  string.

- emitter_version:

  The version of the emitting component, as a single string.

- inferential_target:

  What the manifest is about. Must be one of
  [`inferential_targets()`](https://max578.github.io/orchestraManifest/reference/inferential_targets.md).

- run_id:

  A single non-empty string identifying this run. Emitters commonly
  derive it from a truncated payload digest so that it is stable under
  re-emission of the same result.

- method:

  A single string naming the method that produced the result,
  conventionally qualified by its component, as in
  `"PESTO:ies_callback"`.

- seed:

  The integer RNG seed behind the result, or `NA_integer_` when the
  result is deterministic or the seed is unknown.

- params:

  A data frame of parameter draws, one row per realisation. Defaults to
  an empty data frame, which suits a verdict manifest that carries its
  content in `summary`.

- outputs:

  Model-predicted outputs at each parameter draw, or `NULL` when the
  manifest carries no ensemble payload.

- weights:

  Observation weights, or `NULL`.

- obs_target:

  The observed targets the model was compared against, or `NULL`.

- obs_schema:

  A semantic descriptor of the observation columns, giving each one a
  quantity and a unit, or `NULL`. Populating it activates the
  correspondence guard in
  [`assert_obs_schema_correspondence()`](https://max578.github.io/orchestraManifest/reference/assert_obs_schema_correspondence.md).

- summary:

  A
  [`manifest_summary()`](https://max578.github.io/orchestraManifest/reference/manifest_summary.md)
  holding the headline verdict, or `NULL` for an ensemble manifest that
  has no verdict to state.

- consumed_manifests:

  A list of provenance handles, each as returned by
  [`manifest_lineage()`](https://max578.github.io/orchestraManifest/reference/manifest_lineage.md),
  for the upstream manifests this result was derived from. Required to
  be non-empty when `metadata$derived` is `TRUE`.

- metadata:

  A named list of caller-supplied metadata. The element `derived` is
  load-bearing: setting it to `TRUE` turns on the lineage requirement.

- timestamp:

  A `POSIXct` emission time.

- data_hash:

  The payload digest, as a single `"sha256:<hex>"` string. Emitters
  compute it over the payload slots;
  [`verify_manifest()`](https://max578.github.io/orchestraManifest/reference/verify_manifest.md)
  recomputes and compares.

## Value

An `orchestra_manifest` object.

## Details

The properties fall into four groups. Identity (`manifest_version`,
`emitter_package`, `emitter_version`, `run_id`, `method`, `timestamp`)
says what this is and what made it. Semantics (`inferential_target`,
`obs_schema`) says what it is about, in a closed vocabulary a consumer
can dispatch on. Payload (`params`, `outputs`, `weights`, `obs_target`,
`summary`, `seed`) carries the load-bearing content, and is exactly the
set covered by `data_hash`. Provenance (`consumed_manifests`,
`metadata`) records what this result was derived from.

Two rules are enforced by the validator rather than left to convention.
A manifest whose `metadata$derived` is `TRUE` must record at least one
entry in `consumed_manifests`: an approximation may never silently drop
the lineage of the thing it approximated. And a `summary`, when set,
must be a
[`manifest_summary()`](https://max578.github.io/orchestraManifest/reference/manifest_summary.md)
object, so a verdict has a typed home instead of riding in `params` as a
single-row pseudo-parameter table.

The `data_hash` deliberately covers the payload only. The schema
version, the emitter identity and the timestamp are metadata, so
re-tagging a manifest does not invalidate a payload that has not
changed, while any edit to the payload is detected by
[`verify_manifest()`](https://max578.github.io/orchestraManifest/reference/verify_manifest.md).

## Class identity across homes

The contract began as a script sourced into a workspace, where the class
was created outside any package and its class vector reads
`c("orchestra_manifest", "S7_object")`. Defined inside this package the
same class is package-qualified and reads
`c("orchestraManifest::orchestra_manifest", "S7_object")`, and
components that emit a manifest without depending on this package still
mint the bare form. Both are the same contract. Consumers in this
package therefore test identity with
[`is_orchestra_manifest()`](https://max578.github.io/orchestraManifest/reference/is_orchestra_manifest.md),
which accepts either, rather than with a strict class check that would
reject every manifest emitted outside this package.

## See also

[`verify_manifest()`](https://max578.github.io/orchestraManifest/reference/verify_manifest.md)
and
[`consume_manifest()`](https://max578.github.io/orchestraManifest/reference/consume_manifest.md)
for the integrity and schema guards,
[`as_orchestra_manifest()`](https://max578.github.io/orchestraManifest/reference/as_orchestra_manifest.md)
for the emitter generic.

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
  seed = 1L,
  params = data.frame(a = c(0.1, 0.2), b = c(1.5, 1.4)),
  timestamp = as.POSIXct("2026-07-05 09:00:00", tz = "UTC"),
  data_hash = "sha256:not-yet-computed"
)
m@emitter_package
#> [1] "example"
```
