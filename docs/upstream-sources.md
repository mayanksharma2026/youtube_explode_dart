# Upstream and cross-language research sources

A YouTube extraction failure is often fixed first in another language or application. Research those implementations before designing a Dart-specific workaround, but port behaviour deliberately rather than copying code blindly.

## Source map

| Source | Primary value for this fork | Typical evidence to inspect |
| --- | --- | --- |
| [`Hexer10/youtube_explode_dart`](https://github.com/Hexer10/youtube_explode_dart) | Canonical Dart upstream and public API history | Open issues/PRs, recent commits, current branch, package tests |
| [`yt-dlp/yt-dlp`](https://github.com/yt-dlp/yt-dlp) | Fast-moving Python/CLI extractor and detailed YouTube client/token policy knowledge | YouTube client table, extractor commits, PO-token documentation, signature/`n` changes, issue reproductions |
| [`Tyrrrz/YoutubeExplode`](https://github.com/Tyrrrz/YoutubeExplode) | Original .NET project and architectural reference for this port | Player/stream extraction changes, models, exceptions and compatibility decisions |
| [`TeamNewPipe/NewPipeExtractor`](https://github.com/TeamNewPipe/NewPipeExtractor) | Mature Android/Java extraction behaviour | Player clients, throttling/signature changes, age/content restrictions, regression fixtures |
| [`LuanRT/YouTube.js`](https://github.com/LuanRT/YouTube.js) | TypeScript InnerTube implementation | Client contexts, protobuf/player flows, session and visitor data handling |
| [`iv-org/invidious`](https://github.com/iv-org/invidious) | Server-side Crystal extractor with broad operational exposure | Region/session failures, player parsing, format delivery and issue reports |
| [`pytubefix/pytubefix`](https://github.com/pytubefix/pytubefix) | Python library focused on YouTube breakage recovery | Cipher/throttling updates, player parsing and compact reproductions |
| [`kkdai/youtube`](https://github.com/kkdai/youtube) | Go implementation used by command-line and server consumers | Stream URL changes, client selection and transport regressions |

Other sources may be relevant. Add a repository only when it contributes evidence for the failing layer; do not create a long undifferentiated watchlist.

## Search method

For a new incident, search recent issues, pull requests and commits using combinations of:

- exact HTTP status (`403`, `429`, `400`);
- exact exception or playability reason;
- client name (`VISIONOS`, `IOS`, `ANDROID_VR`, `WEB`, `TVHTML5`);
- affected protocol (`HTTPS`, `DASH`, `HLS`, `SABR`);
- `PO token`, `player token`, `GVS`, `visitorData`, `signature`, `nsig`, `n parameter`;
- failing itag, codec or stream class;
- the approximate date the regression began.

Prioritise changes made near the incident date. A two-year-old workaround may explain the architecture but is weak evidence for current client constants.

## How to use another implementation

1. Identify the behaviour that changed, not merely the final diff.
2. Map its abstraction to this repository: client profile, player request, watch page, parser, challenge solver, manifest or transport.
3. Confirm inputs and outputs through a minimal Dart reproduction.
4. Reimplement the smallest behaviour in the existing Dart architecture.
5. Add Dart-native error handling and tests; do not transplant unrelated abstractions.
6. Record the source repository, file/commit/PR, date and rationale in the local PR.
7. State any differences from the source implementation.

A fix in another project is evidence, not automatic proof. Projects can use cookies, authentication, proxy servers, native runtimes, protobuf services or token providers that this package does not have.

## Licence and attribution rule

Before copying any implementation:

- read the source repository's current licence;
- check whether the code is compatible with this repository's BSD-3-Clause licence and intended distribution;
- distinguish uncopyrightable protocol facts/constants from substantial implementation code;
- reimplement behaviour when direct copying is not clearly permitted;
- retain required notices and attribution;
- call out licence uncertainty in the issue/PR instead of silently copying.

Several useful extractor projects use different or copyleft licences. Do not paste their classes, algorithms or fixtures into this repository without an explicit review.

## Evidence quality

Strong evidence combines:

- a reproducible Dart failure;
- a source project change explaining the same failure;
- matching request/response observations;
- a focused test proving the proposed Dart behaviour.

Weak evidence includes a social-media snippet, an unexplained user-agent string, a random fork with no tests, or a profile assembled from several clients.

## Keeping this map current

When a source becomes inactive, moves repository, changes licence or is no longer technically relevant, update this document in the same maintenance PR. Do not remove historical evidence links from ADRs; replace dead links with stable commit links where possible.
