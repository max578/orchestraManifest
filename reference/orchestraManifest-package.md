# orchestraManifest: the crop-analytics orchestra contract

A single installable home for the artefacts that let independently
developed analytics components exchange inference results without
knowing anything about each other beyond this contract.

## Details

The package has four faces. The manifest itself
([orchestra_manifest](https://max578.github.io/orchestraManifest/reference/orchestra_manifest.md))
is a versioned, integrity-hashed, provenance-tracked `S7` record of one
inference. The consumer guard
([verify_manifest](https://max578.github.io/orchestraManifest/reference/verify_manifest.md)
and
[consume_manifest](https://max578.github.io/orchestraManifest/reference/consume_manifest.md))
turns silent schema drift and silent payload tampering into loud, early
failures. The provenance vocabulary
([grounding_token](https://max578.github.io/orchestraManifest/reference/grounding_token.md),
[combine_grounding](https://max578.github.io/orchestraManifest/reference/combine_grounding.md))
propagates a worst-case grounding label so a verdict resting on an
unverified fact is labelled as such. The refusal contract
([is_orchestra_refusal](https://max578.github.io/orchestraManifest/reference/is_orchestra_refusal.md),
[is_orchestra_decline](https://max578.github.io/orchestraManifest/reference/is_orchestra_decline.md))
lets a gate recognise any component's structured refusal or abstention
without enumerating component classes.

## See also

Useful links:

- <https://github.com/max578/orchestraManifest>

- <https://max578.github.io/orchestraManifest/>

- Report bugs at <https://github.com/max578/orchestraManifest/issues>

## Author

**Maintainer**: Max Moldovan <max.moldovan@adelaide.edu.au>
([ORCID](https://orcid.org/0000-0001-9680-8474)) \[copyright holder\]

Authors:

- Max Moldovan <max.moldovan@adelaide.edu.au>
  ([ORCID](https://orcid.org/0000-0001-9680-8474)) \[copyright holder\]
