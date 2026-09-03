# Maintenance Source Guide

The machine-readable registry is [`maintenance-sources.yaml`](maintenance-sources.yaml). This document explains how agents and maintainers should use it.

## Evidence order

Use sources in this order; do not stop at the first apparent fix.

1. **Local reproduction and tests.** Establish the exact failing layer in this Dart codebase.
2. **Dart upstream.** Search current issues, pull requests, branches, and recent commits in `Hexer10/youtube_explode_dart`.
3. **Maintained Dart forks.** Compare independent changes and identify common evidence, hidden regressions, and app-specific shortcuts.
4. **Production downstream copies.** Use these to discover failures that appear under real playback/download traffic, especially lifecycle defects such as dropped headers.
5. **Cross-language implementations.** Compare protocol semantics, client metadata, token policy, parsers, and tests.
6. **Local design review.** Re-implement the smallest coherent behaviour that fits this package and its public API.

A matching patch in two repositories is not independent confirmation when both contain the same commit. The registry marks known mirrors.

## Core references

### yt-dlp

Primary reference for current InnerTube client identities, numeric client IDs, default client chains, PO-token policy, player extraction, and EJS integration. Inspect exact revisions of `_base.py` and `_video.py`.

Do not port Python retry, downloader, authentication, or plugin architecture mechanically. Extract the protocol fact, then design the Dart change independently.

### Tyrrrz/YoutubeExplode

The original C# architecture is the best reference for domain modelling, stream abstractions, and test-data intent. It may choose a different extraction strategy; compare behaviour rather than class names.

### NewPipeExtractor

Useful independent evidence for mobile client behaviour, response-layout migrations, age/playability conditions, and stream observations. Its licensing and architecture require careful separation: reuse facts and independently implement unless a direct code port is explicitly reviewed.

### YouTube.js

Useful for InnerTube context/session mechanics and rapidly changing parser nodes. Generated parser structures are a discovery aid, not a reason to introduce untyped dynamic parsing in Dart.

### Invidious

Useful for incidents observed at service scale, throttling patterns, and response/player changes. Its deployment model differs substantially from a client-side Dart package.

### PO-token provider projects

`Brainicism/bgutil-ytdlp-pot-provider` is tracked to understand token lifecycle and protocol changes. PO-token support is not part of the current VisionOS patch. Adding it would require a separate public API, security, privacy, deployment, and maintenance design.

## Dart fork review rules

For every candidate fork:

- compare it against the exact upstream commit from which it diverged;
- inspect all commits, not only the final file state;
- identify whether the change is a library fix, an application policy, or a temporary workaround;
- verify that tests prove real media access where relevant;
- check whether exceptions or stream types are silently hidden;
- check header propagation from player request through the final media request;
- check whether the fallback profile was still healthy on the patch date;
- record the exact reviewed commit and outcome in `fork-survey.md` and `maintenance-sources.yaml`.

## Search terms by incident type

### Manifest succeeds, media returns 403

Search for: `403`, `googlevideo`, `PO token`, `GVS`, `range`, `User-Agent`, `client headers`, `android_vr`, `visionos`, and `stream URL`.

### Empty or missing streams

Search for: `streamingData`, `adaptiveFormats`, `formats`, `DASH`, `HLS`, `SABR`, `contentLength`, and `signatureCipher`.

### Signature or throttling failure

Search for: `n challenge`, `signature`, `player JS`, `EJS`, `sts`, and `nsig`.

### Playlist/channel/search parser failure

Search for: `lockupViewModel`, `continuationItemViewModel`, `richItemRenderer`, `runs`, `browse`, `continuation`, and the exact missing field.

## Attribution

Every PR that uses another implementation must identify:

- repository and exact commit;
- files/behaviour consulted;
- what was adopted, adapted, or rejected;
- licence review outcome when code was reused;
- original contributor attribution when applicable.

The preferred outcome is an independently designed Dart patch informed by multiple implementations, with clear credit in the PR and commit message.