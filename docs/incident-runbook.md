# YouTube Incident Runbook

Use this runbook when a previously working API, parser, or stream path fails.

## 1. Create the incident record

Record:

- UTC start time and first known affected release/commit;
- Dart/Flutter version, operating system, device/runtime, and network type;
- public video/channel/playlist IDs that reproduce the issue;
- exact library call and selected `YoutubeApiClient` profiles;
- exception type, HTTP status, and failing operation;
- whether watch page, player response, manifest, and actual media bytes succeeded;
- redacted logs at `FINE`/`FINER` where safe;
- known unaffected cases.

Never attach cookies, authorization values, visitor data, PO tokens, private IDs, or full signed media URLs.

## 2. Establish a baseline

Reproduce against:

1. the consumer's pinned fork commit;
2. this fork's current stable branch;
3. upstream `Hexer10/youtube_explode_dart` at an exact commit;
4. a minimal standalone Dart script.

This distinguishes application integration problems from library/protocol regressions.

## 3. Classify the failure

### HTTP 403

Check separately:

- player API request status;
- manifest/DASH/HLS fetch status;
- content-length/HEAD status;
- real range request status;
- whether the resource was fetched with the producing client's user agent/headers;
- current GVS/player PO-token policy for that client;
- content restrictions (age, geo, embed, members, made-for-kids).

A manifest followed by media 403 is not a successful extraction.

### HTTP 429 or `/sorry/`

Treat as rate limiting/IP reputation. Stop aggressive retries, record retry-after information when present, and reduce request volume. Do not rotate proxies or identities inside this core library.

### Empty manifest or missing stream type

Compare `formats`, `adaptiveFormats`, DASH/HLS URLs, SABR-only responses, signature fields, content length, and filtering/deduplication.

### Signature or `n` failure

Capture player URL/version and solver error without logging sensitive query data. Compare current EJS and mature implementations before changing heuristics.

### Parser failure

Capture a sanitised response fixture and exact JSON path. Check for `lockupViewModel`, continuation view models, `runs` versus `simpleText`, or renamed nodes.

## 4. Build the smallest regression

- Transport defect: fake HTTP client asserting method, range, headers, retries, and bytes.
- Parser defect: sanitised fixture asserting the exact field/item.
- Server-controlled client defect: isolated live test with stable public content and a finite timeout.

For media failures, test at least one audio-only and one video-only byte read when those formats exist.

## 5. Refresh external evidence

Follow [`maintenance-workflow.md`](maintenance-workflow.md) and refresh [`maintenance-sources.yaml`](maintenance-sources.yaml). Search upstream/forks/other languages by the exact status, exception, client, and response node.

Record findings as:

| Source | Exact revision | Finding | Adopt / adapt / reject | Reason |
| --- | --- | --- | --- | --- |

Do not count mirrors carrying the same commit as independent evidence.

## 6. Decide severity and response

- **P0:** widespread production playback/download failure with no safe workaround.
- **P1:** primary feature fails for a significant content class or platform.
- **P2:** limited parser/content class issue with a bounded workaround.
- **P3:** maintenance drift or non-blocking compatibility concern.

For P0/P1, keep the hotfix narrow and place discovered follow-ups in separate PRs.

## 7. Validate and close

Before closure:

- deterministic CI passes;
- targeted live evidence includes timestamp and environment;
- error cases remain visible;
- source registry/profile status/ADR/changelog are updated;
- consumer pins the merged tag/SHA;
- rollback is documented;
- a revalidation trigger is defined.

Do not close solely because one sample works once.