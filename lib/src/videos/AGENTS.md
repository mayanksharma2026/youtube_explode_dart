# Video and Stream Agent Guide

This file extends the root [`AGENTS.md`](../../../AGENTS.md) for `lib/src/videos/`.

## Scope

This subtree owns video/player requests, InnerTube client profiles, stream manifests, stream selection, media URL validation, comments, and related-video behaviour.

## Client profiles

- `youtube_api_client.dart` contains compatibility profiles, not guaranteed APIs.
- A profile must be internally coherent: client name, numeric client ID when known, version, device, OS, user agent, API host, headers, and token assumptions must describe one real client family.
- Do not mix fields from Android, iOS, web, TV, or VisionOS to create a synthetic “stronger” fingerprint.
- Do not randomise versions or identities. Use deterministic profiles with dated evidence.
- Keep temporarily unhealthy profiles for explicit compatibility testing unless removal is deliberately versioned.
- Update `docs/client-profiles.md`, the source registry, ADR, tests, and changelog when profile defaults or policy change.

## Stream lifecycle

A stream URL can be tied to the identity that requested it. Preserve media-request headers from player response through:

1. content-length/probe request;
2. direct byte-range download;
3. DASH fragments;
4. HLS master/media playlists and segments;
5. retry/refresh.

Do not assume that a successful player response or non-empty manifest proves media access. Probe real bytes when selecting a default/fallback profile.

## Fallback

- Explicit `ytClients` are processed exactly as supplied.
- Default fallback must be deterministic, documented, and based on current health evidence.
- Do not try a long list of known-broken clients. It adds latency and obscures the root failure.
- Do not silently remove audio-only or video-only streams because a probe fails.
- Distinguish unsupported content from an unhealthy profile; VisionOS, for example, may not support every content class.

## Public API

Adding an optional named parameter is generally safer than changing existing positional behaviour. Any new public field/method must have tests and documentation. Avoid leaking internal signed URLs or tokens through logs/toString methods.