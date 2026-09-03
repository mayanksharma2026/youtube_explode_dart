# Reference Repository Inventory

Last reviewed: 2026-09-04.

This is the research map for compatibility incidents. It is not a list of code to copy. Agents must compare behaviour, commits, issues and comments, then implement the smallest solution appropriate to this Dart architecture.

## Primary repositories

| Repository | Language | Why inspect it |
| --- | --- | --- |
| `Hexer10/youtube_explode_dart` | Dart | Primary upstream. Check issues, open PRs, commits and discussion before fork-specific work. |
| `yt-dlp/yt-dlp` | Python | High-value source for current InnerTube client identities, PO-token policy, formats, player/challenge behaviour and dated compatibility comments. |
| `Tyrrrz/YoutubeExplode` | C# | Original YoutubeExplode design. Compare stream extraction/fallback decisions and recent YouTube compatibility work. |
| `TeamNewPipe/NewPipeExtractor` | Java | Mature extractor used by NewPipe; useful for client/API/player changes and Android-focused behaviour. |
| `LuanRT/YouTube.js` | TypeScript | Active InnerTube implementation; useful for client contexts, sessions, player and protocol changes. |
| `iv-org/invidious` | Crystal | Server-side YouTube extraction ecosystem with useful issues around player/API changes. |
| `pytubefix/pytubefix` | Python | Active Python extractor/fork lineage; useful as an independent implementation check. |
| `kkdai/youtube` | Go | Independent Go implementation; useful to corroborate stream URL/player changes. |

Repository URLs:

- https://github.com/Hexer10/youtube_explode_dart
- https://github.com/yt-dlp/yt-dlp
- https://github.com/Tyrrrz/YoutubeExplode
- https://github.com/TeamNewPipe/NewPipeExtractor
- https://github.com/LuanRT/YouTube.js
- https://github.com/iv-org/invidious
- https://github.com/pytubefix/pytubefix
- https://github.com/kkdai/youtube

## Dart fork watchlist

Fork activity is volatile. During each compatibility incident query the upstream fork network and recent commits rather than assuming this list is complete.

Forks/branches that materially informed the 2026-08/09 investigation:

| Repository / work | Why it matters |
| --- | --- |
| `lydonator/youtube_explode_dart` / upstream PR #389 | Minimal VisionOS client addition plus a regression proving manifest stream reachability. Good baseline because scope is narrow. |
| `justacalico/youtube_explode_dart` / upstream PR #388 | VisionOS default plus deprecation/status notes for Android SDK-less. Useful for default-client behaviour comparison. |
| `justacalico/youtube_explode_dart` / upstream PR #390 | Broader experiment: visitor-data propagation, VisionOS default, stream filtering and HLS handling. Review individual ideas; do not adopt wholesale because multiple protocol layers are mixed and non-muxed failures can be hidden. |

Important upstream PRs:

- https://github.com/Hexer10/youtube_explode_dart/pull/388
- https://github.com/Hexer10/youtube_explode_dart/pull/389
- https://github.com/Hexer10/youtube_explode_dart/pull/390

## How to review forks

For a new incident:

1. Enumerate recently pushed forks of `Hexer10/youtube_explode_dart`.
2. Compare each active fork against upstream `master`; ignore forks with no meaningful divergence.
3. Search commits for the failing concept/status (`403`, `PO token`, `visitorData`, `client`, `player`, `stream`, `range`, `HLS`, etc.).
4. Read issue/PR comments after the fix date. A patch may initially work and later be reported broken or location-specific.
5. Identify whether a fork changed one layer or several. Prefer narrow evidence when deriving our fix.
6. Cross-check the same protocol assumption against at least one maintained non-Dart implementation.
7. Record the evidence and trade-offs in the PR; do not merge a fork's branch wholesale.

## Maintenance rule

Update this inventory when a repository becomes inactive, renamed, superseded, or a new implementation repeatedly proves useful. Use dates and factual descriptions; avoid permanent labels such as "always working".
