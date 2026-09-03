# YouTube Compatibility Maintenance Playbook

YouTube extraction depends on undocumented interfaces. Treat breakages as protocol investigations, not as opportunities to accumulate ad-hoc spoofing.

## Investigation phases

### Phase 1 — Reproduce and classify

Capture:

- failing video/content category;
- exception and HTTP status;
- client profile used;
- whether the watch page/player response succeeds;
- whether streams are parsed;
- whether the actual CDN URL is readable;
- whether failure changes by audio/video/muxed/HLS/DASH;
- whether authentication, PO token, signature or `n` challenge is involved.

A manifest followed by media HTTP 403 is a different failure from an unplayable player response.

### Phase 2 — Research before implementation

Review in this order:

1. `Hexer10/youtube_explode_dart` issues, PRs and recent commits.
2. Recently active forks of the Dart repository. Compare their divergence; many forks are unchanged snapshots.
3. Current `yt-dlp` YouTube extractor/client policy.
4. `Tyrrrz/YoutubeExplode` recent stream/client changes.
5. NewPipeExtractor and YouTube.js when the affected protocol area overlaps.
6. Additional maintained projects in `reference-repositories.md`.

Search recent issues/comments as well as code. A workaround may have been reported unreliable after its initial commit.

### Phase 3 — Compare candidate solutions

Build an evidence table before coding substantial changes:

| Candidate | Fixes root cause? | Real media verified? | Token/auth requirement | Extra latency | Content limitations | Risk |
| --- | --- | --- | --- | --- | --- | --- |

Reject solutions that merely hide broken stream types, add broad retries, or combine unrelated parser/transport changes without necessity.

### Phase 4 — Implement the smallest coherent fix

Prefer:

- a coherent known client profile over randomized identity fields;
- bounded, content-aware fallback over trying every client;
- preserving server-provided stream headers/range semantics;
- explicit failure over silently returning a degraded manifest;
- centralised client configuration over scattered request payloads.

Randomizing user agents/client versions is not a robustness strategy by itself. It can create impossible device/version combinations, make failures nondeterministic, increase server suspicion and make regression testing harder. Only introduce variation when a maintained implementation or controlled experiment demonstrates a protocol requirement, and keep it bounded/testable.

### Phase 5 — Verify

Minimum for a direct-stream compatibility change:

- `dart format --set-exit-if-changed .`;
- `dart analyze`;
- `dart test`;
- local network test for a normal video;
- audio-only media bytes readable;
- video-only media bytes readable;
- expected failure for an unavailable/restricted fixture;
- no new requests/retries on the healthy path unless justified.

Test additional categories implicated by the change: live, music, made-for-kids, age-restricted, region-restricted or authenticated content as applicable.

### Phase 6 — Deep review and PR

Before opening a PR, review the complete branch diff and answer:

- Is every changed file required?
- Did any public API change accidentally?
- Are errors still observable?
- Are comments/docs time-bounded and accurate?
- Is the implementation independently reasoned rather than copied wholesale?
- Are source projects credited/linked where they informed protocol behaviour?
- Can this PR plausibly be submitted upstream without internal cleanup?

Only then open a PR against this fork. Do not create an upstream PR automatically.

## Current incident: August/September 2026 media 403

Observed ecosystem evidence indicates newer GVS PO-token enforcement made previously useful Android SDK-less, Android VR and iOS profiles return unusable direct media URLs even when player/manifest extraction succeeded. VisionOS (`VISIONOS`, version `1.02`) emerged across maintained extractor work as a logged-out profile whose media URLs remained fetchable without JS signature solving at the time of review.

Our baseline fix therefore uses a coherent VisionOS profile and validates actual media bytes. This is a compatibility state, not a permanent assumption. Re-run the research phases when it fails.

## Follow-up areas to evaluate separately

Do not bundle these into the VisionOS baseline unless required by reproduced evidence:

- preserving per-format HTTP headers on all stream/range/fragment requests;
- content-aware fallback for categories unsupported by VisionOS;
- PO-token provider integration if token-free profiles disappear;
- visitor/session propagation changes;
- HLS/live-specific playability handling.

Each deserves its own issue/PR because each changes a different layer and has different failure modes.
