# Changelog

## orchestraManifest (development version)

- The package has a logo.
- README has status badges and lists related packages.
- CI runs lintr (report-only) and test coverage.

## orchestraManifest 0.2.0

- `GROUNDING_UNVERIFIED` is now `"ungrounded"`;
  [`combine_grounding()`](https://max578.github.io/orchestraManifest/reference/combine_grounding.md)
  still reads the token emitted up to 0.1.0 as not grounded.

- Added a `CITATION` file.

- Additive inferential-target token `consensus` (emitted by quorum, the
  consensus layer); the workspace reference carries the same token.

- The manifest-and-refusal-contract vignette is brought to the orchestra
  vignette quality bar: a why/what/do/read/limits shape, an
  inferential-target-to-emitter table, and a ggplot2 diagram of the
  emit-verify-consume flow.

## orchestraManifest 0.1.0

### New features

- Extracted the ORCHESTRA workspace manifest + refusal contract into an
  installable package; hash- and semantics-compatible with the
  2.0.0-draft reference.

- `orchestra_manifest` is the versioned, integrity-hashed and
  provenance-tracked `S7` result type components exchange. Its validator
  enforces the two rules that were previously left to convention: a
  derived manifest must record at least one entry in
  `consumed_manifests`, and a `summary`, when set, must be a
  [`manifest_summary()`](https://max578.github.io/orchestraManifest/reference/manifest_summary.md).

- [`verify_manifest()`](https://max578.github.io/orchestraManifest/reference/verify_manifest.md)
  recomputes the payload digest and reports whether the payload was
  modified since emission.
  [`consume_manifest()`](https://max578.github.io/orchestraManifest/reference/consume_manifest.md)
  wraps it with the accepted-version check and refuses loudly rather
  than coercing silently across a schema boundary.

- [`manifest_data_hash()`](https://max578.github.io/orchestraManifest/reference/manifest_data_hash.md)
  exposes the contract’s digest so that a component can emit a
  conforming manifest without depending on this package. The digest is
  taken over a serialisation pinned to format 2 with its 14-byte header
  dropped, which is what makes a manifest emitted under one R version
  verify under any other.

- [`is_orchestra_manifest()`](https://max578.github.io/orchestraManifest/reference/is_orchestra_manifest.md)
  tests contract identity tolerantly, accepting both the
  package-qualified class defined here and the bare class minted by
  emitters that implement the contract independently. The consumer
  guards use it in place of a strict class check, which would otherwise
  reject every manifest already in circulation.

- [`assert_obs_schema_correspondence()`](https://max578.github.io/orchestraManifest/reference/assert_obs_schema_correspondence.md)
  refuses to compare two manifests whose shared observation columns
  disagree on quantity or unit, and is a graceful no-op until both sides
  populate the schema.

- [`grounding_token()`](https://max578.github.io/orchestraManifest/reference/grounding_token.md)
  and
  [`combine_grounding()`](https://max578.github.io/orchestraManifest/reference/combine_grounding.md)
  mint and combine the provenance tokens `GROUNDING_GROUNDED` and
  `GROUNDING_UNVERIFIED`. Both are worst-case: an empty or partially
  dated evidence set is unverified, and one unverified input taints a
  downstream verdict.

- [`is_orchestra_refusal()`](https://max578.github.io/orchestraManifest/reference/is_orchestra_refusal.md),
  [`is_orchestra_decline()`](https://max578.github.io/orchestraManifest/reference/is_orchestra_decline.md)
  and
  [`as_orchestra_refusal()`](https://max578.github.io/orchestraManifest/reference/as_orchestra_refusal.md)
  recognise any component’s structured refusal or abstention across
  object systems, replacing the ambiguous bare `is_refusal()` at a seam
  between components.

- [`as_orchestra_manifest()`](https://max578.github.io/orchestraManifest/reference/as_orchestra_manifest.md)
  is the emitter generic, with adapters for a `PESTO` ensemble manifest
  and a `proxymix` mixture fit. Both are also available as the plain
  functions
  [`manifest_from_pesto()`](https://max578.github.io/orchestraManifest/reference/manifest_from_pesto.md)
  and
  [`manifest_from_gmm()`](https://max578.github.io/orchestraManifest/reference/manifest_from_gmm.md),
  and both components are suggested rather than required: the methods
  register at load time only where the component is installed.
