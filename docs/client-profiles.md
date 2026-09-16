# InnerTube Client Profile Status

**Protocol observation snapshot:** 2026-09-03 UTC

**Historical protocol reference:** `yt-dlp/yt-dlp@bbc809a1161d3bfca51fa36f59dda35556ee85a0`

**Implementation audit:** 2026-09-16 UTC, base `b1cef42590420b0b8dd1707f37c1cd9598eaf19c`.

The protocol observations below retain their 2026-09-03 date; the default-use column reflects the audited code. This is not fresh live-playback validation. YouTube may change enforcement by account, network, region, format, or experiment.

| Dart profile | Historical protocol observations | Default use at audited base | Required validation |
| --- | --- | --- | --- |
| `visionOs` | Candidate logged-out/no-JS profile; current reference implementations use it without a configured GVS PO-token requirement. Made-for-kids content may be unavailable. | Already implemented as the primary default when `ytClients` is omitted. | Player response, representative audio/video range, download path, and known limitation. |
| `androidVr` | All formats were reported 403 with the then-current profile from 2026-08-17; current references no longer use it as the anonymous default. | Do not use as automatic fallback without fresh evidence. | Real bytes for each required protocol. |
| `ios` | Current reference policy marks media access as requiring/recommending PO-token support depending on protocol/context. | Explicit only. | Player and media tokens/headers; real bytes. |
| `android` | Current reference policy requires GVS PO-token support for HTTPS/DASH unless an applicable player token exemption exists. | Explicit selection or classified compatibility fallback after primary failure. | Token policy and real bytes. |
| `androidSdkless` | Historical workaround; observed returning inaccessible non-muxed URLs in the current incident. | Retain for source compatibility; not default. | Fresh independent evidence before reuse. |
| `safari`/web | May require player JS and current PO-token handling for broad format access. HLS availability can depend on session trust. | Added when a JS solver is configured and `ytClients` is omitted; this does not provide PO-token support. | Challenge solution, token policy, formats, and bytes. |
| `tv` | Existing restricted-content fallback with separate embedding/signature limitations. | Compatibility fallback after eligible Android failure; also available explicitly. | Playability, signature, embedding, and media bytes. |

## Implementation is not completed media validation

The audited base already contains the VisionOS profile/default and request-scoped client-context copying. It does **not** complete the resource-affinity requirements below: the manifest HEAD probe lacks producing-client headers, normal range/fragment requests accept but do not apply supplied headers, and HLS/URL refresh need an end-to-end producing-client review. The player client-name header also needs a separate symbolic/numeric identity review.

The [regular maintenance plan](maintenance-plans/2026-09-16-regular-maintenance.md) records exact source revisions, deferred work and unavailable local Dart/network gates. No new runtime fix or fresh audio/video byte result is claimed. The existence of a default in code does not establish that all default-selection acceptance criteria have passed. See the appended audit in [ADR 0001](decisions/0001-visionos-default-client.md).

## Profile coherence

A profile is one coherent identity. The following must be reviewed together:

- `clientName` and numeric client ID;
- `clientVersion`;
- device make/model;
- OS name/version;
- user agent;
- API host/key behaviour;
- player headers;
- media-request headers;
- JS-player requirement;
- GVS/player/subtitle PO-token policy;
- supported content classes and formats.

Do not combine values from different clients. Do not randomise them. A version bump without matching user agent/device/policy evidence is not maintenance.

## Resource affinity

The identity used to mint a resource URL may matter when fetching it. Preserve the producing client's media headers through:

- validation/probe;
- content-length request;
- direct range download;
- fragmented DASH requests;
- HLS playlists and segments;
- URL refresh/retry.

Player/API headers and media headers are related but not identical. Do not blindly send `Content-Type`, cookies, or player-only headers to `googlevideo` URLs.

## Default selection criteria

A client can become the default only when:

1. at least one mature reference documents the profile and policy;
2. a small multi-video sample returns required stream types;
3. actual audio-only and video-only bytes are fetched;
4. download headers survive the complete transport path;
5. unsupported content classes are documented;
6. fallback and rollback are explicit;
7. no randomisation or hidden client spraying is introduced.

## Revalidation triggers

Revalidate immediately when:

- media 403/429 rate changes materially;
- manifest succeeds but playback/download fails;
- an authoritative reference changes default clients or token policy;
- a client version/device identity changes;
- format types disappear;
- made-for-kids, live, age-restricted, or embedded behaviour changes;
- a consumer reports platform-specific header differences.