# ADR 0001: Add VisionOS as an explicit client profile

- **Status:** Accepted
- **Date:** 3 September 2026
- **Scope:** `YoutubeApiClient` and stream-consumer guidance

## Context

`youtube_explode_dart` 3.1.0 uses `androidSdkless` as the default stream client. During the 2026 regression tracked in [`Hexer10/youtube_explode_dart#386`](https://github.com/Hexer10/youtube_explode_dart/issues/386), several existing profiles could still obtain player/manifest data but the returned media URLs failed with HTTP 403.

Current yt-dlp client-policy data indicated GVS PO-token enforcement for affected Android/Android VR/iOS paths. Its VisionOS client remained configured without the same declared requirement and without a JavaScript player dependency. Upstream Dart PR [`#389`](https://github.com/Hexer10/youtube_explode_dart/pull/389) proposed a narrow VisionOS profile and focused stream test.

Other proposals changed the global default or combined the profile with generic WEB payload, stream filtering and live-stream changes. Those changes have different risk and validation requirements.

## Decision

Add `YoutubeApiClient.visionOs` using one coherent Apple Vision Pro/InnerTube identity based on current yt-dlp data and upstream Dart PR #389.

Do **not** change the package default in this patch. Consumers that require the compatibility profile must opt in explicitly:

```dart
final manifest = await yt.videos.streams.getManifest(
  videoId,
  ytClients: const [YoutubeApiClient.visionOs],
);
```

Add:

- a deterministic payload contract test;
- focused network validation for manifest stream classes;
- actual media-byte validation;
- a manual verifier for networks where GitHub-hosted runners are blocked;
- documentation for profile maintenance and upstream research.

## Rationale

An explicit profile:

- keeps the fork's behavioural diff small;
- avoids silently changing every existing caller;
- lets consuming applications own selection/fallback policy;
- is easy to remove when upstream adopts an equivalent fix;
- makes failure attribution clear in tests and logs.

The spoof itself should not be randomised or expanded speculatively. Robustness comes from coherent profiles, focused validation, observability, immutable releases and a documented repair process.

## Alternatives considered

### Change the default to VisionOS

Rejected for this patch. It would restore default callers more directly but changes behaviour globally and VisionOS has content-class limitations. A default change needs a separate compatibility matrix, ADR and rollback plan.

### Merge upstream PR #388 wholesale

Rejected. It changes the default and deprecates an existing public client in addition to adding VisionOS. Those decisions are broader than the immediate profile addition.

### Merge upstream PR #390 wholesale

Rejected. It combines VisionOS with generic WEB client changes, visitor-data handling, non-muxed stream filtering and live-stream playability changes. In particular, dropping non-muxed streams after a failed probe could hide audio/video transport failures as a reduced manifest.

### Use a contributor fork directly

Rejected for production. Depending on a third-party working branch reduces control over review, release pinning, documentation and future maintenance.

### Randomise or remotely download client identities

Rejected. Mixed or unreviewed identities can be less reliable and can change production behaviour without a source-controlled release. Remote configuration may select among reviewed built-in profiles at the application layer, but should not inject arbitrary request payloads into this package.

### Add many clients as fallbacks

Rejected. The current `getManifest` implementation processes and merges every supplied client. Known-broken clients add network traffic, retry time and noisy failures; the list is not first-success fallback semantics.

## Consequences

Positive:

- consumers have a current token-free compatibility option;
- public API impact is additive;
- fork/upstream comparison remains straightforward;
- the repair is independently testable and revertible.

Trade-offs:

- existing consumers that rely on the implicit default must update their call or wrapper;
- VisionOS can stop working or fail for particular content classes;
- GitHub-hosted CI cannot fully validate live YouTube delivery;
- applications still need their own controlled fallback, telemetry and rollout strategy.

## Revisit conditions

Revisit this ADR when:

- upstream changes its default or merges an equivalent profile;
- VisionOS begins requiring a PO token/authentication or stops returning usable media;
- this package adds explicit first-success client strategy semantics;
- a reviewed profile supports the required content classes more reliably;
- the consuming application can no longer opt in cleanly.

A replacement decision must include current request evidence and actual media-byte validation.

## References

- [`Hexer10/youtube_explode_dart#386`](https://github.com/Hexer10/youtube_explode_dart/issues/386)
- [`Hexer10/youtube_explode_dart#389`](https://github.com/Hexer10/youtube_explode_dart/pull/389)
- [`Hexer10/youtube_explode_dart#388`](https://github.com/Hexer10/youtube_explode_dart/pull/388)
- [`Hexer10/youtube_explode_dart#390`](https://github.com/Hexer10/youtube_explode_dart/pull/390)
- [`yt-dlp` YouTube client definitions](https://github.com/yt-dlp/yt-dlp/blob/master/yt_dlp/extractor/youtube/_base.py)
