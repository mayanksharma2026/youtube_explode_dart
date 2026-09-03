# InnerTube Client Profile Status

**Last reviewed:** 2026-09-03 UTC  
**Protocol reference:** `yt-dlp/yt-dlp@bbc809a1161d3bfca51fa36f59dda35556ee85a0`

Client status is observational and date-bound. YouTube may change enforcement by account, network, region, format, or experiment.

| Dart profile | Observed status | Default use | Required validation |
| --- | --- | --- | --- |
| `visionOs` | Candidate logged-out/no-JS profile; current reference implementations use it without a configured GVS PO-token requirement. Made-for-kids content may be unavailable. | Proposed primary profile for this fork. | Player response, representative audio/video range, download path, and known limitation. |
| `androidVr` | All formats were reported 403 with the then-current profile from 2026-08-17; current references no longer use it as the anonymous default. | Do not use as automatic fallback without fresh evidence. | Real bytes for each required protocol. |
| `ios` | Current reference policy marks media access as requiring/recommending PO-token support depending on protocol/context. | Explicit only. | Player and media tokens/headers; real bytes. |
| `android` | Current reference policy requires GVS PO-token support for HTTPS/DASH unless an applicable player token exemption exists. | Explicit only. | Token policy and real bytes. |
| `androidSdkless` | Historical workaround; observed returning inaccessible non-muxed URLs in the current incident. | Retain for source compatibility; not default. | Fresh independent evidence before reuse. |
| `safari`/web | May require player JS and current PO-token handling for broad format access. HLS availability can depend on session trust. | Add only when a configured JS/token path justifies it. | Challenge solution, token policy, formats, and bytes. |
| `tv` | Existing restricted-content fallback with separate embedding/signature limitations. | Keep existing bounded fallback pending a dedicated review. | Playability, signature, embedding, and media bytes. |

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