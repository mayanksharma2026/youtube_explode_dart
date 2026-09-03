## Summary

<!-- What changed and which failing layer does it address? -->

## Reproduction

- First observed:
- Package/base commit:
- Client profile(s):
- Public test case(s):
- Failure stage/status/exception:
- Manifest resolved: yes/no/not applicable
- Actual media bytes retrieved before fix: yes/no/not applicable

## Evidence

<!-- Link exact upstream issues, PRs, commits or source files. Explain why the behaviour maps to this Dart implementation. -->

| Source | Link | Relevant behaviour | Licence reviewed |
| --- | --- | --- | --- |
|  |  |  |  |

## Implementation

<!-- Describe the smallest coherent change. Mention public API or request-count impact. -->

## Deliberate non-goals

<!-- State what related behaviour was not changed, for example default client, retry policy, generic WEB payload, stream filtering, live streams or authentication. -->

## Validation

- [ ] `dart pub get`
- [ ] Changed Dart files formatted only
- [ ] `dart analyze`
- [ ] `dart test`
- [ ] Focused deterministic regression test
- [ ] Focused network/manual smoke test where applicable

Manual result (safe output only; no signed URLs/tokens):

```text

```

## Compatibility matrix

| Case | Result | Notes |
| --- | --- | --- |
| Public VOD |  |  |
| Adaptive audio |  |  |
| Adaptive video |  |  |
| Muxed |  |  |
| Live/HLS |  |  |
| Invalid/deleted |  |  |
| Restricted/paid |  |  |
| Made for kids |  |  |

## Risk and rollback

- Risk:
- Request/latency impact:
- Known limitations:
- Rollback commit/tag or procedure:

## Documentation

- [ ] Relevant `AGENTS.md` guidance remains accurate
- [ ] Client profile ledger updated when applicable
- [ ] ADR added/updated for defaults, fallback, authentication, public API or broad validation semantics
- [ ] Release/upstream-sync documentation updated when applicable

## Final checks

- [ ] The change does not log cookies, tokens, visitor data, authorisation or complete signed media URLs.
- [ ] The patch does not silently remove stream classes or replace useful failures with an empty manifest.
- [ ] Client fields form one coherent identity and were not assembled speculatively.
- [ ] Retry and client iteration worst-case request counts are understood.
- [ ] Production consumers can pin an immutable commit or tag.
