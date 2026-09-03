## Summary

<!-- What changes and why? Keep this specific. -->

## User-visible failure

<!-- Include first observed UTC date, affected API/client/content class, and exact symptom. Use N/A for non-protocol changes. -->

## Root cause and evidence

<!-- Separate reproduced facts, source findings, and inference. Do not include secrets or signed media URLs. -->

## Sources reviewed

<!-- Include exact commits/PRs/issues. State adopted, adapted, and rejected ideas. -->

- Dart upstream:
- Maintained Dart forks/downstreams:
- Cross-language references:
- Licence/attribution review:

## Design

<!-- Explain why this is the smallest coherent solution and how it preserves public API compatibility. -->

## Alternatives considered

<!-- Include why broader patches, hidden fallbacks, filtering, randomisation, or other options were rejected. -->

## Validation

- [ ] `dart format --output=none --set-exit-if-changed .`
- [ ] `dart analyze`
- [ ] `dart test`
- [ ] Targeted deterministic regression
- [ ] Targeted live test, when server behaviour is involved
- [ ] Actual media bytes verified, when stream access is involved
- [ ] Existing failure cases remain visible

### Live test evidence

<!-- UTC time, coarse network/region, Dart version, public sample categories, and results. Do not paste signed URLs. -->

## Risk and rollback

<!-- Failure modes, limitations, revalidation trigger, and previous tag/SHA for rollback. -->

## Documentation

- [ ] Root/folder `AGENTS.md` remains accurate
- [ ] `docs/client-profiles.md` updated when relevant
- [ ] `docs/maintenance-sources.yaml` / `docs/fork-survey.md` updated when relevant
- [ ] ADR added/updated for defaults, fallback, API, or architecture
- [ ] `docs/fork-changelog.md` updated
- [ ] README/user documentation updated

## Upstreamability

<!-- Is this suitable for upstream? Note any fork-specific pieces that must be removed before manual submission. -->