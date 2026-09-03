# YoutubeExplodeDart

This repository is a maintained fork of [Hexer10/youtube_explode_dart](https://github.com/Hexer10/youtube_explode_dart), a Dart port of [YoutubeExplode](https://github.com/Tyrrrz/YoutubeExplode). It preserves the upstream API while carrying narrowly scoped compatibility fixes needed when YouTube changes its undocumented player or media-delivery behaviour.

> **Maintainers and coding agents:** read [`AGENTS.md`](AGENTS.md) before making changes. Complex subtrees contain additional `AGENTS.md` files. The compatibility investigation process is documented in [`docs/maintenance.md`](docs/maintenance.md), current client assumptions in [`docs/client-profiles.md`](docs/client-profiles.md), and the maintained cross-language/fork research inventory in [`docs/reference-repositories.md`](docs/reference-repositories.md).

## Fork maintenance principles

- Keep changes small enough to review and contribute upstream independently.
- Research upstream Dart work, active forks and maintained extractors in other languages before designing compatibility fixes.
- Compare implementations and protocol evidence; do not copy a downstream patch wholesale.
- A parsed stream manifest is not considered proof of success when the reported failure is at the media CDN. Validate real media access.
- Keep client identities coherent and deterministic. Do not use speculative random spoofing as a substitute for understanding the protocol.
- Open reviewed PRs against this fork only unless the repository owner explicitly requests an upstream submission.

## Current compatibility note

The fork includes a VisionOS InnerTube profile for logged-out stream resolution. It was introduced after previously useful Android/iOS profiles began returning HTTP 403 for direct media under newer PO-token enforcement. Client selection remains explicit in this baseline patch so applications can adopt the profile deliberately and upstream behaviour is not changed globally. This is a time-sensitive compatibility option, not a stable YouTube API contract; see [`docs/client-profiles.md`](docs/client-profiles.md).

---

YoutubeExplode provides an interface to query metadata of YouTube videos, playlists and channels, and to resolve/download video streams and closed-caption tracks. It uses reverse-engineered web/InnerTube behaviour rather than the official YouTube Data API.

## Features

- Retrieve metadata on videos, playlists, channels, streams and closed captions.
- Execute search queries.
- Resolve and download video streams.
- Retrieve closed captions.
- Retrieve video comments.

## Installation

For the published upstream package, use the version documented on pub.dev. Applications that intentionally consume this maintained fork should pin an exact Git commit or reviewed tag for reproducible builds rather than tracking a moving branch.

```yaml
dependencies:
  youtube_explode_dart:
    git:
      url: https://github.com/mayanksharma2026/youtube_explode_dart.git
      ref: <reviewed-commit-or-tag>
```

Import the library:

```dart
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
```

## Getting video metadata

```dart
final yt = YoutubeExplode();
final video = await yt.videos.get('https://youtube.com/watch?v=Dpp1sIL1m5Q');

print(video.title);
print(video.author);
print(video.duration);
```

## Resolving streams

```dart
final yt = YoutubeExplode();
final manifest = await yt.videos.streams.getManifest('Dpp1sIL1m5Q');

final audioStreams = manifest.audioOnly;
final videoStreams = manifest.videoOnly;
final muxedStreams = manifest.muxed;
```

To use the VisionOS compatibility profile explicitly:

```dart
final manifest = await yt.videos.streams.getManifest(
  videoId,
  ytClients: [YoutubeApiClient.visionOs],
);
```

When several clients are supplied, their stream results may be merged and each client can add network work. Do not use a long list of speculative fallbacks as a reliability strategy.

To read a resolved stream:

```dart
final streamInfo = manifest.audioOnly.first;
final stream = yt.videos.streams.get(streamInfo);
```

Always close the client when finished:

```dart
yt.close();
```

## Signature solver

Some YouTube clients require JavaScript challenge solving. The package supports a Deno-based EJS solver:

```dart
import 'package:youtube_explode_dart/solvers.dart';

final solver = await DenoEJSSolver.init();
final yt = YoutubeExplode(jsSolver: solver);
```

## Troubleshooting

Before reporting or fixing a compatibility issue:

1. Enable detailed logging.
2. Capture a reproducible video ID/content category and exact failure.
3. Determine whether the player/manifest succeeds but media access fails.
4. Follow [`docs/maintenance.md`](docs/maintenance.md) before changing client identities or fallback behaviour.

```dart
import 'package:logging/logging.dart';

Logger.root.level = Level.FINER;
Logger.root.onRecord.listen((event) {
  print(event);
  if (event.error != null) {
    print(event.error);
    print(event.stackTrace);
  }
});
```

## Development

```bash
dart pub get
dart format --set-exit-if-changed .
dart analyze
dart test
```

Some YouTube network tests are skipped on GitHub-hosted runners because YouTube may block requests from those environments. Stream compatibility PRs therefore also require documented local network verification.

## Credits

- [Tyrrrz/YoutubeExplode](https://github.com/Tyrrrz/YoutubeExplode) — original .NET library and architecture.
- [Hexer10/youtube_explode_dart](https://github.com/Hexer10/youtube_explode_dart) — Dart port and primary upstream.
- [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) and other projects in [`docs/reference-repositories.md`](docs/reference-repositories.md) — independent reverse-engineering evidence used during compatibility research.
- Upstream and downstream contributors whose focused fixes and reports help identify YouTube protocol changes.

This fork retains the upstream BSD-3-Clause license; see [`LICENSE`](LICENSE).
