# Dart Fork and Downstream Survey

**Snapshot:** 2026-09-03 UTC  
**Upstream baseline:** `Hexer10/youtube_explode_dart@44a39a65d8e274806247d52af8f0bacd77691d38`

This survey records forks with independent activity or useful production evidence. It is not a recommendation to depend on any fork directly. The machine-readable list is [`maintenance-sources.yaml`](maintenance-sources.yaml).

## Selection criteria

A repository is listed as maintained/relevant only when at least one of these signals exists:

- independent commits after the upstream baseline;
- active issue/PR work on current YouTube breakages;
- a production application carrying and exercising an embedded copy;
- focused parser/protocol fixes with reproducible detail;
- sustained maintenance beyond merely creating a fork.

Unmodified mirrors and new forks containing only the upstream history are excluded. Repositories sharing the same patch commit are grouped rather than counted as independent confirmation.

## Current stream/403 work

### `lydonator/youtube_explode_dart`

Reviewed `f6c104c8a0efe3e7bb9e3f859ca4addc45ad5926` (upstream PR #389). It adds a coherent `VISIONOS` profile and a focused live regression. This is the cleanest baseline for the client definition because it does not bundle unrelated parser or filtering changes.

**Adopt:** client identity and focused incident evidence.  
**Improve locally:** validate actual media bytes, make the default decision explicit, preserve numeric client/header affinity, and cover the download path.

### `justacalico/youtube_explode_dart`

Reviewed `c80de2735c18be0cccc283fe840b48f1b183b4e1`. It treats VisionOS as the default and records older client limitations, but the change is broader than the focused profile addition.

**Use for:** comparison of default/client-status decisions.  
**Do not import wholesale:** review every changed path and separate transport, fallback, and parser concerns.

### `its-ashutosh-pathak/youtube_explode_dart` and `vargasgustavo/youtube_explode_dart`

Both expose `edad2760cc7998bcc18013dc9880c052ad32598f`, associated with the broad PR #390 approach. It combines VisionOS, stream handling, web payload/visitor data, and parser changes.

**Use for:** discovering affected response paths.  
**Reject for the current hotfix:** silently converting a non-muxed failure into a muxed-only manifest hides audio/video breakage; mixed-scope changes are difficult to validate and upstream.

### `gmstyle/youtube_explode_dart`

Reviewed master `fe43c513ea35c2352f00b2ce650083c81c3e4a57`. Independent work includes non-absolute stream URL handling, adaptive probes, HLS master URL exposure, VisionOS support, and parser fixes.

**Strong follow-up candidates:**

- skip empty/non-absolute URLs with a deterministic test;
- expose the HLS master URL through a deliberate API design;
- add focused regressions for related-video and Shorts response migrations.

**Do not bundle now:** its earlier Android VR fallback assumption became stale after the 2026-08-17 enforcement change. Review each commit separately.

### `onyxmusic/youtube_explode_dart`

Reviewed `ada5cb6758388421c931ebf10f63e1a1cf2acfa5`. It carries extensive manual updates and switches to VisionOS.

**Use for:** early warning and comparison.  
**Do not adopt:** removing validation, broad catch blocks around watch-page access, and falling back to Android SDK-less can mask current failures.

### `Bikram-Kumar/youtube_explode_dart`

Reviewed `6f28a8bf0f00c1ef7073c335bafe48f8bab05edc`. It combines non-muxed 403 handling with playlist/search/channel parser updates.

**Use for:** identifying new lockup/continuation layouts.  
**Do not adopt as one patch:** transport and parser changes need separate regressions; non-muxed filtering conflicts with this fork's fail-visible policy.

## Client-header affinity evidence

### `gokadzev/Musify` embedded package

Reviewed application head `0285d0b63398317faa41c12d74388d204b1955a2` and relevant change `ad9c95f12cae5b0f9ceb6ca4e96c77bb579a2d82` under `packages/youtube_explode_dart`.

This production downstream found a second defect beyond selecting VisionOS: the Dart transport accepted stream headers but did not apply them to normal byte-range requests or fragmented downloads. A URL minted for an app-style client could therefore be fetched with the package's generic desktop user agent.

**Adopt conceptually:** preserve the producing client's media headers through validation and download, including fragments.  
**Improve locally:** retain origin metadata deterministically rather than probing a list of clients for every download; keep player-request headers separate from media-request headers; add fake-HTTP unit tests; refresh headers when a stream URL is renewed.

This is the most important improvement discovered by reviewing maintained downstream code rather than copying PR #389 alone.

### `luskan/youtube_explode_dart`

Its caption user-agent fix is earlier evidence of the same general rule: resources returned to one client identity may require that identity on subsequent fetches. It supports a shared client-affinity design, while captions remain a separate feature path.

## Parser-focused forks

### `jameszhou123/youtube_explode_dart`

Focused commits cover runs-format counts and `lockupViewModel` search/channel items. The commit descriptions include concrete response paths and stronger assertions.

**Good source for:** future search/channel incidents.  
**Caution:** separate general parsing from application policy, such as dropping members-only items.

### `hamza72x/youtube_explode_dart`

Focused on playlist lockup extraction and continuation changes. Useful for playlist-specific failures after reproduction.

### `isacRU11/youtube_explode_dart`

Contains dynamic-list casting and numeric parsing hardening. Useful when a `NoSuchMethodError` or radix parse error identifies the same response path.

### `navidicted/youtube_explode_dart`

Contains course-playlist/channel-ID and CORS-proxy changes. The parser change may be useful; proxy behaviour is application-specific and should not be added to the core library as a protocol workaround.

## Historical/watch-only repositories

`KRTirtho/youtube_explode_dart`, `krishnapalsendhav/youtube_explode_dart_plus`, and `5alafawyyy/youtube_explode_dart_plus` contain useful older signature, related-video, live-stream, or modernisation work. They are not current enough to establish the 2026 VisionOS/PO-token behaviour, so agents should consult them only for a matching historical subsystem.

## Decisions from this survey

1. Use the focused VisionOS identity from PR #389 as one input, not the complete solution.
2. Add deterministic client-to-media header affinity based on the producing client.
3. Validate representative audio-only and video-only media bytes rather than only parsing a manifest or accepting a HEAD response.
4. Keep a short, documented default/fallback chain; do not spray requests across broken clients.
5. Do not add randomised fingerprints, versions, user agents, timing, or proxy rotation. Coherent identities and transparent health-based fallback are safer and easier to review.
6. Keep HLS exposure, invalid URL handling, and parser migrations as independent follow-up work with their own tests and PRs.
7. Refresh this survey and source registry on every YouTube incident and at least before each fork release.

## 2026-09-16 branch-metadata correction

For `souravkaushik-dev/chameleon`, GitHub repository metadata identified `main`
as the default branch. The `commits/master` endpoint returned HTTP 422
(`No commit found for SHA: master`), while `commits/main` resolved to
[`9360b48dc4f08ab14329a57da6b2d23f9f4ab48a`](https://github.com/souravkaushik-dev/chameleon/commit/9360b48dc4f08ab14329a57da6b2d23f9f4ab48a).
The source registry's incorrect `master` entry caused the single lookup error in
[watch run 34825002484](https://github.com/mayanksharma2026/youtube_explode_dart/actions/runs/34825002484).

Only the tracked branch is corrected to `main`. The reviewed code revision
`d20b589a6ad82b3486f3b88a7a8be0c487b0d147`, its review date, and the original survey
snapshot remain unchanged. This is a branch-metadata verification, not a renewed
protocol review or endorsement of the newer downstream changes.

## 2026-09-16 regular maintenance follow-up

The [verified maintenance plan](maintenance-plans/2026-09-16-regular-maintenance.md) contains the complete 24-source inventory, exact before/current revisions, review depth, decisions and validation limitations. Initial head comparison found 12 equal checkpoints, 9 mismatches and 3 sources without reviewed checkpoints. One mismatch was Lydonator's incorrectly tracked branch; after the provenance corrections, eight sources have genuine forward ranges. Head refresh is not blanket approval of newer implementations.

- Lydonator's reviewed PR #389 commit `f6c104c8a0efe3e7bb9e3f859ca4addc45ad5926` remains on `add-visionos-client`; its default `master` points to the canonical upstream baseline. Track the feature branch without changing its historical review date. Closed PR #391 carries that same commit and is not independent evidence.
- Jameszhou's invalid stored `cbe63502884da2fa0f0f09a9784fa831ab5867` is corrected to the resolved historical `cbe63502884da2fa0afc0f09a9784fa831ab5867`, not advanced to current `a1ce972191d13a257e21394bcb4bd4268b4a2b75`. The newer About/header parser fix needs exact fixtures and locale/contract review; the separate Streams-tab/filtering/generated-file changes are not imported.
- yt-dlp's new embedded-player UA change does not map to an existing Dart profile. NewPipe's new commit is a Java dependency update. YouTube.js feature additions, Invidious per-request headers, and downstream media-affinity work remain separately classified in the plan rather than bundled into a protocol patch.
- Musify's embedded package has no delta in the reviewed range; its audio-selection change is app policy. Chameleon's selected probe code passes client headers but also changes defaults; neither app is imported wholesale.
- The provider's [2.0.0 security release](https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases/tag/2.0.0) is relevant to any future PO-token integration review, not a vulnerability claim or dependency update for this package.

The fork already implements the VisionOS profile/default at the audited base, but the full media-header lifecycle and fresh playback validation remain outstanding. See [client profiles](client-profiles.md) and the appended [ADR audit](decisions/0001-visionos-default-client.md). The regular maintenance PR changes only metadata, tests and documentation; it does not repair or endorse the remaining runtime gaps.
