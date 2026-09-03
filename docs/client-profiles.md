# InnerTube Client Profiles

Last reviewed: **2026-09-04**

YouTube client behaviour is server-controlled and changes without notice. This file records the current compatibility model and the evidence behind it; it is not a permanent API contract.

## Current strategy

For ordinary logged-out stream extraction, the maintained fork should prefer a **coherent VISIONOS client profile**. If VISIONOS reports content unavailable/unplayable for a known coverage gap such as made-for-kids content, use a **targeted current Android fallback**. Keep TV/embedded clients for capabilities that actually require them (for example age-restricted paths requiring signature handling), rather than calling every historical client.

This strategy is based on current evidence from yt-dlp and the .NET YoutubeExplode implementation, plus Dart upstream PRs addressing the August 2026 403 incident.

## Profile matrix

| Profile | Current role | GVS / media state reviewed in 2026-08/09 | JS player | Notes |
| --- | --- | --- | --- | --- |
| `VISIONOS` | Primary logged-out progressive-stream profile | Current maintained references use it because direct media remains fetchable without the PO-token requirement affecting the older default clients | Not required in current yt-dlp profile | Known gap: some made-for-kids content is not available. Must keep request identity coherent and include visitor/session data where appropriate. |
| `ANDROID` | Targeted fallback | Current yt-dlp policy marks HTTPS/DASH GVS PO tokens as required/recommended; however .NET YoutubeExplode observes a usable muxed itag-18 path for some made-for-kids videos when VISIONOS is unavailable | No JS player in current yt-dlp definition | Do not use as a generic second request after every successful VISIONOS response. Use only for the known fallback case and validate actual media bytes. |
| `ANDROID_VR` | Historical / explicit testing | yt-dlp notes selective enforcement from 2026-07 and all formats 403 with its reviewed 1.65.10 profile from 2026-08-17 | No JS player | Was previously a useful no-token profile. Do not treat it as a current default fallback. |
| `IOS` | Historical / explicit testing | Current yt-dlp policy requires GVS PO tokens for HTTPS and HLS paths | No JS player | Dart manifests may still resolve while direct media URLs fail. |
| `ANDROID` sdkless variant | Historical Dart compatibility profile | The Dart fork previously used it by default, but issue #386 reports current non-muxed media 403s | No JS player | Retain for explicit compatibility tests unless upstream removes it, but do not document it as token-free. |
| `WEB` / Safari | Search/page/solver-dependent uses | WEB paths have their own PO-token and JS/challenge considerations | Depends on path | Do not change generic WEB continuation payloads as part of a media-client fix without direct evidence. |
| `TVHTML5` / embedded | Special fallback | Useful for specific restricted/embedded paths but may require signature deciphering | Often required | Keep special-purpose; avoid using as a universal fallback because of extra complexity/latency. |

## VISIONOS profile reviewed for this incident

The reviewed profile used by current references contains:

```text
clientName: VISIONOS
clientVersion: 1.02
deviceMake: Apple
deviceModel: RealityDevice17,1
osName: visionOS
osVersion: 26.5.23O471
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 15_7_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Safari/605.1.15
```

Do not independently “modernise” one field. Update the profile only when a maintained implementation or reproducible request demonstrates a coherent newer identity.

## Visitor data

`visitorData` is request/session context, not a random fingerprint value.

Preferred order:

1. reuse visitor data from the current YouTube/watch-page context when available;
2. otherwise resolve it through the existing `sw.js_data` mechanism for profiles that need it;
3. cache the resolved value for the client/session lifetime;
4. keep body `visitorData` and `X-Goog-Visitor-Id` consistent when both are sent.

Do not mutate the static `YoutubeApiClient.payload` map to inject visitor data. Clone the nested request maps first.

## Fallback decision model

A fallback should happen because the primary profile **cannot serve the content**, not simply because a second client exists.

Conceptually:

```text
VISIONOS
  ├─ playable + fetchable media -> return
  └─ known unavailable/unplayable class
       └─ targeted ANDROID fallback
            ├─ usable media -> return
            └─ fail with meaningful error / special legacy path if explicitly supported
```

Avoid:

```text
VISIONOS + ANDROID + IOS + ANDROID_VR + TV + WEB
```

as one default list. `StreamClient.getManifest` processes each supplied client and merges results, so such a list adds latency, retry noise, and more server-facing requests even after the primary profile succeeds.

## Validation requirements

When changing a profile or fallback:

- capture the exact reference commit/issue used as evidence;
- verify the player response;
- verify expected audio/video stream types;
- read actual bytes from a selected media URL;
- exercise the content class that requires the fallback;
- check 403 and 429 behaviour separately;
- update this document with the date and limitation.

## August 2026 incident record

Observed Dart failure: `getManifest` could resolve data with older clients but the returned media URL produced HTTP 403. Canonical issue: `Hexer10/youtube_explode_dart#386`.

Relevant Dart proposals:

- #389: focused VISIONOS profile plus regression coverage — preferred minimal baseline.
- #388: VISIONOS plus package-wide default switch — useful evidence, but changes default behaviour globally.
- #390: VISIONOS plus unrelated WEB payload, non-muxed filtering and HLS changes — do not treat the whole patch as one required fix.

Cross-language corroboration:

- yt-dlp current client-policy table documents stronger GVS PO-token requirements for Android/iOS/Android VR and retains VISIONOS as a no-JS-player profile without the same explicit GVS requirement.
- `Tyrrrz/YoutubeExplode` commit `ea791ab1` (2026-08-25) makes VISIONOS primary, supplies visitor data, tests made-for-kids content, and uses Android only as the targeted fallback.

## Reliability boundary

No reverse-engineered profile can guarantee that YouTube “will not catch” or change it. The maintainable approach is rapid evidence-based rotation to a coherent supported profile, narrow fallbacks, real media regression tests, and clear failure telemetry—not arbitrary fingerprint randomisation or concealment.