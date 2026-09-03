# Reference Repositories and Fork Ledger

Last reviewed: **2026-09-04**

This document is a research index, not a dependency list. Future maintainers must refresh it during an incident because YouTube behaviour and fork activity change quickly.

## Canonical Dart repositories

| Repository | Role | Review notes |
| --- | --- | --- |
| `Hexer10/youtube_explode_dart` | Canonical Dart upstream | Source of public API and upstream history. `master` head reviewed for this incident: `44a39a65` (2026-05-09). Always check new issues/PRs before fork-only work. |
| `mayanksharma2026/youtube_explode_dart` | Maintained production fork | Keep close to canonical upstream. Compatibility work is reviewed and merged here first. |

## High-signal cross-language references

These repositories are useful because they independently track YouTube protocol/client changes. Do not copy code blindly; compare the request behaviour and port only the relevant protocol conclusion.

| Repository | Language | Why it matters | Current review focus |
| --- | --- | --- | --- |
| `yt-dlp/yt-dlp` | Python / CLI | Highest-signal source for current InnerTube client definitions, PO-token policies, JS-player requirements, and rollout notes. | For August 2026, its client table records GVS PO-token enforcement for Android/iOS/Android VR and a VISIONOS profile without the same explicit GVS requirement. |
| `Tyrrrz/YoutubeExplode` | C# / .NET | Original project family and closest architectural parity to this Dart port. | Commit `ea791ab1` (2026-08-25) moved normal playback primarily to VISIONOS, added visitor data, and uses Android as a targeted fallback for made-for-kids content. |
| `TeamNewPipe/NewPipeExtractor` | Java | Mature mobile extractor with independent client/player/parser work. | Check recent YouTube extractor commits/issues for client, player, signature and parser changes. Default branch reviewed: `dev`. |
| `LuanRT/YouTube.js` | TypeScript | Active InnerTube implementation; useful for request context, player/continuation changes and client behaviour. | Check recent `main` changes and issues around the incident date. |
| `iv-org/invidious` | Crystal | Independent YouTube frontend/extractor; useful confirmation for client/user-agent/header and parser changes. | Check player/API issues and recent commits before changing global HTTP behaviour. |
| `JuanBindez/pytubefix` | Python | Actively adapted Python extractor derived from pytube concepts; useful secondary evidence for signature/client changes. | Use as corroboration, not sole source for client-policy decisions. |
| `kkdai/youtube` | Go | Independent Go implementation with practical download/stream handling. | Useful for transport and player changes when recent commits match the incident. |

### Reference priority

For a client/403/PO-token incident, normally inspect in this order:

1. `yt-dlp/yt-dlp`
2. `Tyrrrz/YoutubeExplode`
3. canonical Dart issues/PRs and divergent Dart forks
4. `NewPipeExtractor` / `YouTube.js`
5. `Invidious` / `pytubefix` / `kkdai/youtube`

Change the order when the failure is parser-specific or project-specific.

For every high-signal repository, inspect not only code commits but also recent issues, PR descriptions, review threads, issue/PR comments, and discussions around the incident window. Important rollout observations and failed experiments often appear there before they are reflected in code. Treat comments as leads that still need reproducible or code-level corroboration.

## Dart fork ledger

### How this list was built

For the 2026-09-04 review we searched GitHub for `youtube_explode_dart` forks/derivatives, compared activity against canonical upstream head `44a39a65` (2026-05-09), inspected incident branches and discussion threads, and grouped duplicate implementations.

A fork is labelled **active/divergent** when it has meaningful post-upstream work or a distinct maintained branch. A fork is **incident evidence** when it carries a fix/experiment directly relevant to the current failure. A **snapshot** may be recent but is not independent maintenance evidence.

### Current incident evidence

| Repository / branch | Status | Relevant evidence | Assessment |
| --- | --- | --- | --- |
| `lydonator/youtube_explode_dart` PR branch for upstream #389 | Incident evidence | Commit `f6c104c8` adds a focused `visionOs` profile plus a regression test; reports a 10-video sample where VisionOS media was fetchable while prior clients failed. | Cleanest minimal Dart baseline. Use as evidence, not as a production dependency. |
| `justacalico/youtube_explode_dart` | Active incident fork | Commit `c80de273` changes streaming to VisionOS. Branch `fix-386-and-page-parsing` / commit `292778ec` adds broader HTTP visitor-data/parser/non-muxed handling. | Valuable experiments; branch is mixed-scope, so review deltas individually rather than cherry-picking wholesale. |
| `its-ashutosh-pathak/youtube_explode_dart` | Incident fork | Commit `edad2760` / upstream #390 combines VisionOS default with generic WEB payload updates, non-muxed filtering and HLS changes. | Useful comparison, but too broad for a single compatibility fix; silent stream filtering is not preferred. |
| `vargasgustavo/youtube_explode_dart` | Duplicate incident branch | Carries the same `edad2760` VisionOS-403 commit. | Downstream validation only; not independent evidence. |

### Other currently divergent/maintained Dart forks

| Repository | Evidence reviewed | Why to watch |
| --- | --- | --- |
| `jameszhou123/youtube_explode_dart` | `5fa4f73f` (2026-06-14) channel `lockupViewModel` handling; `cbe63502` (2026-07-14) search `runs`/lockup parsing. | Demonstrates continued parser maintenance after canonical upstream head. Useful when YouTube layout changes break channel/search parsing. Some changes include app-policy filtering, so isolate protocol fixes before porting. |
| `hamza72x/youtube_explode_dart` | `86cd5a97` (2026-06-12) playlist extraction fix. | Post-upstream parser maintenance; useful for playlist/layout incidents. |
| `navidicted/youtube_explode_dart` | `7fe96143` (2026-05-14) course-playlist channel-ID workaround; tracks upstream. | Divergent application needs and parser edge cases; treat temporary workarounds cautiously. |
| `luskan/youtube_explode_dart` | `4112fc73` (2026-03-13) client-specific Android UA for caption URL fetches; documentation work in Aug 2026. | Strong historical signal that response URLs may require client-consistent transport headers. Re-check current delta before using it for stream transport. |
| `ritesh-kanwar/youtube_explode_dart` | `f5b73b00` (2026-03-23) client-specific UA overrides for `googlevideo.com`; authentication/playlist work. | Useful transport/authentication reference even though the reviewed stream work predates canonical 3.1.0. Verify against current YouTube behaviour before porting. |

### Reviewed recent snapshots / duplicates

These are not promoted to maintenance sources solely because they are newly created or recently synced:

- `oli-music/youtube_explode_dart` — recent initial snapshot (2026-09-02) but no independent incident delta identified in this review.
- forks whose latest visible commit is canonical `44a39a65` — treat as mirrors until a divergent branch/commit is found.
- forks carrying the exact same incident commit as another fork — count as downstream validation, not independent protocol evidence.

## Re-scan procedure for future agents

Do not rely on this list unchanged.

1. Record canonical upstream head SHA/date.
2. Search repositories for `youtube_explode_dart` and forks.
3. Search recent commits across candidates, sorted by commit date.
4. Inspect branches containing terms related to the incident (`403`, `stream`, `client`, `token`, `player`, `parser`, `playlist`, etc.).
5. Read recent issue/PR comments, review threads and discussions for reported successes, regressions, region-specific behaviour and failed experiments.
6. Compare each relevant branch against its upstream base.
7. Group identical commit SHAs so duplicate forks do not create false confidence.
8. Add newly active forks to the appropriate table with a dated note.
9. Downgrade forks that have become stale or only mirror upstream.

For an urgent outage, prioritise forks with a small reproducible delta and downstream reports, but still corroborate the underlying behaviour against at least one maintained cross-language implementation.

## What not to do

- Do not automatically cherry-pick the newest fork.
- Do not combine parser, transport, client and solver changes because one fork bundled them.
- Do not infer that multiple forks carrying the same commit are independent confirmations.
- Do not add arbitrary client/device/User-Agent randomisation as a reliability strategy.
- Do not use an external project's workaround without checking its licensing and architectural assumptions.

The desired output of this research is a short protocol conclusion and the smallest reviewed Dart-native implementation.