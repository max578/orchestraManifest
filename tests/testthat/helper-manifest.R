# helper-manifest.R -- Builders shared across the test files.
#
# The contract can be exercised end to end without any emitting component
# installed, which is the point of these helpers: the suite that guards the
# contract must not depend on the components that happen to implement it.

# A valid manifest whose stored hash matches its payload.
new_test_manifest <- function(params = data.frame(a = c(0.1, 0.2),
                                                  b = c(1.5, 1.4)),
                              outputs = NULL,
                              weights = NULL,
                              obs_target = NULL,
                              obs_schema = NULL,
                              summary = NULL,
                              seed = 7L,
                              emitter_package = "example",
                              inferential_target = "parameters",
                              consumed_manifests = list(),
                              metadata = list(derived = FALSE),
                              run_id = "example-001") {
  orchestra_manifest(
    emitter_package    = emitter_package,
    emitter_version    = "0.1.0",
    inferential_target = inferential_target,
    run_id             = run_id,
    method             = "example:demo",
    seed               = seed,
    params             = params,
    outputs            = outputs,
    weights            = weights,
    obs_target         = obs_target,
    obs_schema         = obs_schema,
    summary            = summary,
    consumed_manifests = consumed_manifests,
    metadata           = metadata,
    timestamp          = as.POSIXct("2026-07-05 09:00:00", tz = "UTC"),
    data_hash          = manifest_data_hash(params, outputs, weights,
                                            obs_target, seed, summary)
  )
}

# An observation schema naming three yield columns in a given unit.
new_test_schema <- function(unit = "t/ha", n = 3L) {
  list(outputs = data.frame(name = paste0("o", seq_len(n)),
                            quantity = rep("grain_yield", n),
                            unit = rep(unit, n),
                            stringsAsFactors = FALSE))
}
