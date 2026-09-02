# orchestraManifest (development version)

* Additive inferential-target token `consensus` (emitted by quorum, the
  consensus layer); the workspace reference carries the same token.

* The manifest-and-refusal-contract vignette is brought to the orchestra
  vignette quality bar: a why/what/do/read/limits shape, an
  inferential-target-to-emitter table, and a ggplot2 diagram of the
  emit-verify-consume flow.

# orchestraManifest 0.1.0

## New features

* Extracted the ORCHESTRA workspace manifest + refusal contract into an
  installable package; hash- and semantics-compatible with the 2.0.0-draft
  reference.

* `orchestra_manifest` is the versioned, integrity-hashed and
  provenance-tracked `S7` result type components exchange. Its validator
  enforces the two rules that were previously left to convention: a derived
  manifest must record at least one entry in `consumed_manifests`, and a
  `summary`, when set, must be a `manifest_summary()`.

* `verify_manifest()` recomputes the payload digest and reports whether the
  payload was modified since emission. `consume_manifest()` wraps it with the
  accepted-version check and refuses loudly rather than coercing silently
  across a schema boundary.

* `manifest_data_hash()` exposes the contract's digest so that a component can
  emit a conforming manifest without depending on this package. The digest is
  taken over a serialisation pinned to format 2 with its 14-byte header
  dropped, which is what makes a manifest emitted under one R version verify
  under any other.

* `is_orchestra_manifest()` tests contract identity tolerantly, accepting both
  the package-qualified class defined here and the bare class minted by
  emitters that implement the contract independently. The consumer guards use
  it in place of a strict class check, which would otherwise reject every
  manifest already in circulation.

* `assert_obs_schema_correspondence()` refuses to compare two manifests whose
  shared observation columns disagree on quantity or unit, and is a graceful
  no-op until both sides populate the schema.

* `grounding_token()` and `combine_grounding()` mint and combine the
  provenance tokens `GROUNDING_GROUNDED` and `GROUNDING_UNVERIFIED`. Both are
  worst-case: an empty or partially dated evidence set is unverified, and one
  unverified input taints a downstream verdict.

* `is_orchestra_refusal()`, `is_orchestra_decline()` and
  `as_orchestra_refusal()` recognise any component's structured refusal or
  abstention across object systems, replacing the ambiguous bare
  `is_refusal()` at a seam between components.

* `as_orchestra_manifest()` is the emitter generic, with adapters for a
  `PESTO` ensemble manifest and a `proxymix` mixture fit. Both are also
  available as the plain functions `manifest_from_pesto()` and
  `manifest_from_gmm()`, and both components are suggested rather than
  required: the methods register at load time only where the component is
  installed.
