# Maintenance Workflow

Last reviewed: **2026-09-04**

This fork is maintained for periods when YouTube changes break `youtube_explode_dart` before a canonical upstream release is available. The objective is to restore compatibility with the smallest reviewed change while remaining easy to sync with and contribute back to upstream.

## 1. Triage the incident

Capture a minimal reproduction and identify the first failing boundary.

| Failure | First places to investigate |
| --- | --- |
| Player API unavailable/unplayable | `YoutubeApiClient`, `VideoController`, client policy/reference implementations |
| Manifest resolves, media URL returns 403 | GVS PO-token policy, client profile, visitor/session data, stream request headers |
| HTTP 429 / Google `/sorry/` | request volume, retry behaviour, environment/IP; do not misdiagnose as parser failure |
| Missing/invalid signature or `n` | player script, EJS/solver, signature timestamp |
| Search/playlist/channel data missing | current page/continuation JSON shape |
| HLS/DASH failure | manifest parsing and client-specific stream delivery |
| Streams have no progressive URL | determine whether the client is returning SABR/server-side formats |

Enable detailed library logging and retain the exact video ID, chosen client, HTTP status, stream itag/type, and request stage. Remove secrets/cookies before publishing logs.

## 2. Establish the current upstream baseline

Before implementing anything, record:

- current `Hexer10/youtube_explode_dart` head/release;
- related open issues and PRs;
- the date the failure began or was first reported;
- any existing Dart workaround and its scope.

Do not assume an old “403 fix” remains valid. YouTube client policies change repeatedly.

## 3. Re-scan Dart forks

Search GitHub for forks/derivatives of `youtube_explode_dart`. The static list in `reference-repositories.md` is a starting point, not an exhaustive registry.

A useful scan compares each candidate against the canonical upstream head. Prioritise:

1. commits newer than upstream;
2. branches named for the current issue/failure;
3. forks referenced by downstream applications;
4. forks with repeated maintenance rather than a one-time snapshot;
5. distinct approaches rather than ten forks carrying the same commit.

For every relevant fork, determine whether the delta is:

- client identity/policy;
- visitor/session handling;
- stream transport/headers/ranges;
- solver/signature logic;
- parser/layout handling;
- unrelated application-specific behaviour.

Do not copy a mixed branch wholesale. Extract only the evidence relevant to the incident.

## 4. Compare maintained cross-language implementations

Use `reference-repositories.md`. The highest-signal sources for client/token incidents are currently:

- **yt-dlp** — current InnerTube client definitions, PO-token policy, JS-player requirements, comments documenting server rollouts;
- **Tyrrrz/YoutubeExplode (.NET)** — architectural parity with this Dart port and regression coverage;
- **NewPipeExtractor**, **YouTube.js**, **Invidious**, **pytubefix**, and **kkdai/youtube** — independent confirmation of request/client/parser changes when relevant.

Search recent commits, issues, and PRs around the incident date. Compare the behaviour, not syntax.

Useful questions:

- Which InnerTube client is being used and why?
- Is a PO token required for PLAYER, GVS, subtitles, HLS, or DASH?
- Does the request include `visitorData`, and where did it come from?
- Are body client identity and HTTP headers consistent?
- Is a fallback content-specific or generic?
- Does the implementation validate a progressive media URL or only parse metadata?
- Did it add a regression for a content class such as made-for-kids or age-restricted video?
- Is the patch compensating for a rollout/parser change unrelated to our failure?

## 5. Form a protocol conclusion

Write a short internal conclusion before coding. Example for the August 2026 incident:

> Android VR/iOS direct media delivery became subject to stronger GVS PO-token enforcement. VISIONOS remained a no-JS-player profile providing fetchable logged-out progressive URLs in maintained references, but it does not cover all made-for-kids content. A coherent VisionOS primary profile plus a targeted fallback is therefore preferable to globally filtering failed streams or cycling historical clients.

A good conclusion explains *why* the proposed change should work and its known limits.

## 6. Design the Dart-native fix

Principles:

- keep public behaviour compatible where practical;
- keep client identities coherent;
- copy request maps before adding request-scoped fields;
- keep visitor/session data consistent between body and headers;
- use one primary client and narrow evidence-based fallbacks;
- preserve meaningful errors instead of silently deleting stream classes;
- avoid unrelated parser/continuation/formatting changes;
- make the diff easy to upstream.

Do not add arbitrary User-Agent/device/version randomisation. Reliability comes from matching a real supported request profile and understanding its requirements, not from fingerprint noise.

## 7. Prove the fix

Run:

```bash
dart pub get
dart analyze
dart test
```

For stream incidents, also run the relevant live tests locally. At minimum prove:

1. the manifest resolves;
2. the required stream type exists;
3. an actual selected stream returns media bytes;
4. each fallback has a reproducible content case.

GitHub Actions may skip live YouTube calls due hosted-runner blocking. State that limitation in the PR rather than implying CI verified live playback.

## 8. Deep review before opening a PR

Review the complete branch against `master`.

### Correctness

- Does the change address the reproduced root cause?
- Are fallbacks restricted to expected errors/content classes?
- Are exception semantics preserved?
- Could a caller receive a successful-but-incomplete manifest?

### Request integrity

- Are client payload, User-Agent, headers and visitor data consistent?
- Are shared static maps being mutated?
- Are retries using refreshed URLs/required headers correctly?

### Performance

- Are broken clients called unnecessarily?
- Does a successful primary request stop additional fallback traffic?
- Could retry/fallback nesting multiply latency?

### Compatibility

- Normal video, audio, video-only, muxed, live and restricted behaviour considered where relevant?
- Any region/content limitation documented?
- Any public API break?

### Maintainability

- Small focused diff?
- Tests explain the regression?
- Comments describe current evidence without claiming permanence?
- `client-profiles.md` and `reference-repositories.md` updated if needed?

Only after this review should the agent create the PR.

## 9. Pull request policy for this fork

Agents create PRs only in `mayanksharma2026/youtube_explode_dart` unless explicitly instructed otherwise.

For multiple changes:

- base each independent PR on `master` when files do not overlap;
- document merge order;
- avoid stacked branches that require the maintainer to rebase or retarget manually;
- title and describe PRs as if they may later be submitted upstream.

A human maintainer may manually submit an equivalent change to `Hexer10/youtube_explode_dart` after it has proven stable here.

## 10. After merging

Update the reference/client ledger when new evidence appears. When canonical upstream merges/releases an equivalent fix:

1. compare behaviour and tests;
2. prefer returning to upstream code where it is equivalent or better;
3. remove fork-only patches that are no longer necessary;
4. keep only maintenance infrastructure that remains useful.

The success metric is not the size of this fork. It is how quickly and safely it can understand the next YouTube change while remaining close to upstream.