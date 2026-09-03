# ADR 0001: Use VisionOS as the primary anonymous stream client

- **Status:** Proposed
- **Date:** 2026-09-03
- **Owners:** Fork maintainers

## Context

The upstream default `androidSdkless` client and the previously useful iOS/Android VR profiles began returning player manifests whose direct media URLs failed with HTTP 403. Current `yt-dlp` client policy uses `visionos` as its JS-less default and records PO-token enforcement for the affected alternatives. Upstream Dart PR #389 provides a focused VisionOS profile and live manifest regression.

Reviewing maintained downstream code also exposed a local transport defect: the package accepted media headers but did not apply them to normal byte-range or fragmented requests. Selecting a new client alone is therefore insufficient for a durable fix.

## Decision

1. Add a coherent `YoutubeApiClient.visionOs` profile based on a dated, exact protocol reference.
2. Use VisionOS as the primary default when callers do not supply `ytClients`.
3. Preserve the producing client's media headers from manifest acquisition through validation and download.
4. Validate representative audio-only and video-only media bytes.
5. Keep fallback deterministic and short. Explicit caller client lists remain unchanged.
6. Retain older profiles for source compatibility and explicit testing, while documenting their observed status.
7. Do not introduce random client versions, user agents, timing, proxies, or other anti-detection behaviour.

## Alternatives considered

### Use a contributor fork directly

Rejected for production ownership. It transfers availability and supply-chain control to an external branch and does not provide our maintenance process.

### Copy PR #389 only

Rejected as incomplete. It adds the right candidate profile but does not prove or repair the full media-download header lifecycle.

### Adopt PR #390 wholesale

Rejected. It mixes client, parser, web payload, live stream, and non-muxed filtering changes. Silent non-muxed removal can hide an audio/video failure.

### Try many clients or randomise identities

Rejected. Known-broken clients add latency/noise, and incoherent/random fingerprints are less reliable, harder to test, and may trigger enforcement.

### Implement PO-token support now

Deferred. It requires a separate architecture, API, security, privacy, deployment, and maintenance review.

## Consequences

- Anonymous streaming depends primarily on one currently healthy profile, so health monitoring and rapid revalidation remain necessary.
- VisionOS may not support every content class, including made-for-kids content observed by reference implementations.
- Transport APIs gain enough metadata/association to preserve media headers.
- Follow-up work such as HLS master URL exposure, invalid URL filtering, parser migrations, and PO-token support stays in separate PRs.

## Validation

- deterministic tests for range/fragment/header propagation;
- live test that obtains a VisionOS manifest and reads real audio/video bytes;
- existing unavailable/purchase tests remain visible;
- `dart format`, `dart analyze`, and `dart test` pass;
- manual test matrix and timestamp recorded in the implementation PR.

## Revalidation trigger

Any sustained 403/429 increase, missing required stream type, change in reference default clients/token policy, or consumer playback failure opens a new incident and requires this decision to be revisited.