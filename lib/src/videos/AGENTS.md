# Video Client Agent Guidance

This file applies to `lib/src/videos/` and supplements the root `AGENTS.md`.

## High-risk files

- `youtube_api_client.dart` — InnerTube client compatibility profiles.
- `video_controller.dart` — player request construction, visitor/session data, headers, and response semantics.
- `streams/stream_client.dart` — client selection, manifest extraction, validation, and fallbacks.

Changes here can turn a successful player response into unusable media URLs, so a parsed manifest is not sufficient proof of correctness.

## Client-profile invariants

A profile is one coherent identity. Keep these fields consistent with the maintained implementation used as evidence:

- `clientName` and `clientVersion`;
- device make/model when applicable;
- OS name/version;
- `User-Agent`;
- client-specific API URL/headers;
- visitor/session data requirements;
- known PO-token and JS-player requirements.

Do not update one identity field in isolation because a newer value “looks better”. Do not randomise profiles.

## Visitor data

Prefer using visitor data from the current watch-page/session context when available. If a client requires visitor data and the current context does not provide it, use the existing resolver/cache rather than generating arbitrary values.

Do not mutate a shared static client payload while injecting request-scoped data. Copy the required nested maps before adding visitor/session fields.

If `visitorData` is placed in the request body, keep the corresponding `X-Goog-Visitor-Id` header aligned when the request path expects it.

## Client selection

The default strategy should be narrow:

1. primary profile that covers the common case;
2. a fallback only for a known failure/content class;
3. legacy/special clients only when required by an explicit capability such as age restriction or signature deciphering.

Do not pass a long list of clients to `getManifest` as a defensive fallback. The implementation merges every supplied client and therefore pays the request/retry cost for each one.

## Current 2026 incident context

As of late August 2026, Android VR and iOS direct media URLs became subject to stronger GVS PO-token enforcement. VISIONOS is the current primary logged-out profile in maintained references such as yt-dlp and the .NET YoutubeExplode implementation.

VISIONOS has a known coverage gap for some “Made for kids” content. The .NET implementation uses a current Android profile as a targeted fallback for that content class. See `docs/client-profiles.md` before changing the fallback strategy.

## Failure semantics

Do not hide a media failure by silently dropping the stream type that failed validation. An audio caller should not receive an apparently successful manifest whose audio streams were removed because one request returned 403.

Preserve meaningful exceptions and log enough context to distinguish:

- player response unavailable/unplayable;
- stream URL 403;
- rate limiting/429;
- signature or n-challenge failure;
- no progressive URL / SABR-only format;
- parser failure.

## Required verification

For client/fallback changes, verify at minimum:

- normal video manifest;
- audio-only availability;
- video-only availability when expected;
- at least one real media-byte read from the chosen stream;
- the content class motivating each fallback (for example a known made-for-kids video);
- deterministic existing tests and `dart analyze`.

Network checks must be marked honestly if GitHub Actions cannot run them.