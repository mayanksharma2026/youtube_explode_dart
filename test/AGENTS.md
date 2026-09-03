# Test Agent Guidance

This file applies to `test/` and supplements the root `AGENTS.md`.

## Test intent

Tests for reverse-engineered YouTube behaviour must prove the failure class that motivated the change. A successful JSON parse is not equivalent to a playable stream.

## Deterministic vs live tests

Keep deterministic unit/parser tests suitable for CI wherever possible. Network integration tests are valuable but may be skipped on GitHub-hosted runners because YouTube can block or rate-limit shared runner IPs; the existing `skipGH` convention documents this limitation.

Do not remove network-test skipping merely to make CI appear stronger. Instead, document the local verification command and what was actually verified.

## Stream/client regressions

For a change to client profiles, player requests, or fallback selection, cover the relevant subset of:

- ordinary public video;
- explicit primary client manifest;
- audio-only streams;
- video-only streams;
- muxed streams when expected;
- a real read from a selected media stream (`first` chunk is sufficient to prove the media URL is fetchable);
- made-for-kids content if the fallback exists for that class;
- live content if HLS behaviour changed;
- expected failures such as unavailable/purchase-restricted videos.

Prefer stable public test IDs already used by mature upstream projects, but record why a new ID exists and replace it when it becomes unavailable.

## 403 regression rule

For a 403 incident, do not write only:

```dart
expect(manifest.audioOnly, isNotEmpty);
```

That proves extraction but not media access. Include a test that starts reading the selected stream and receives bytes without a 403. The library's own manifest validation may also exercise a URL, but an explicit byte-read regression is clearer and protects downstream playback/download behaviour.

## Fallback tests

If production code adds a fallback, there must be a test representing the content/failure class that requires it. Do not add speculative fallback clients without a reproducible test case.

## Test hygiene

- Keep network tests bounded with appropriate timeouts.
- Close `YoutubeExplode` instances.
- Avoid large downloads; read only what is necessary to prove access.
- Do not weaken assertions to accommodate intermittent behaviour without first identifying whether rate limiting, region, or content churn is responsible.
- If a network test is inherently region-sensitive, document that limitation.