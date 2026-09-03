# YoutubeExplodeDart

This repository is a maintained fork of [Hexer10/youtube_explode_dart](https://github.com/Hexer10/youtube_explode_dart). It keeps the upstream package API and carries focused, reviewed compatibility fixes when YouTube changes undocumented player, parser, or media behaviour.

> **Fork status:** production consumers should pin an exact release tag or full commit SHA. Do not depend on a moving branch or an external contributor fork.

## Fork maintenance

- Start with the root [`AGENTS.md`](AGENTS.md) for repository-wide coding-agent and contributor rules.
- Use [`docs/maintenance-workflow.md`](docs/maintenance-workflow.md) for incident investigation, cross-language comparison, test-first implementation, and release.
- See [`docs/maintenance-sources.yaml`](docs/maintenance-sources.yaml) for the machine-readable registry of upstreams, maintained Dart forks, production downstream copies, and other-language references.
- See [`docs/fork-survey.md`](docs/fork-survey.md) for the dated comparative review and accepted/rejected ideas.
- See [`docs/client-profiles.md`](docs/client-profiles.md) for current, date-bound InnerTube client status.

The maintenance policy is to compare independent implementations and reproduce the failing layer before changing code. The fork does not use random client identities, user agents, timing, or proxy rotation. Compatibility changes use coherent client profiles, deterministic fallback, real media validation, bounded retries, and visible errors.

### Install this fork

Pin a release tag or full commit SHA:

```yaml
dependencies:
  youtube_explode_dart:
    git:
      url: https://github.com/mayanksharma2026/youtube_explode_dart.git
      ref: <release-tag-or-full-commit-sha>
```

For upstream pub.dev releases, follow the upstream package documentation and versioning.

![Pub Version](https://img.shields.io/pub/v/youtube_explode_dart)
![License](https://img.shields.io/github/license/Hexer10/youtube_explode_dart)
![Lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)

This is a Dart port of the [YoutubeExplode] library from C#. Most functions, documentation comments, and historical README information originate from the C# project and the Dart upstream.

YoutubeExplode provides an interface to query metadata for YouTube videos, playlists, and channels, and to resolve video streams and closed-caption tracks. It uses reverse-engineered page and player requests rather than the official YouTube Data API, so it does not require a YouTube API key or consume official API quotas.

Because these interfaces are undocumented and server-controlled, any client profile or parser can stop working without notice. Review the maintenance documentation before changing player identities, headers, retry behaviour, or response parsing.

## Features

- Retrieve metadata for videos, playlists, channels, streams, and closed captions.
- Execute search queries and inspect results.
- Resolve and download video streams.
- Retrieve closed captions.
- Retrieve video comments and related videos.

## Usage

- [Install](#install)
- [Getting video metadata](#getting-video-metadata)
- [Downloading a video stream](#downloading-a-video-stream)
- [Using a signature solver](#using-a-signature-solver)
- [Working with playlists](#working-with-playlists)
- [Extracting closed captions](#extracting-closed-captions)
- [Getting related videos](#getting-related-videos)
- [Getting comments](#getting-comments)
- [Cleanup](#cleanup)
- [Troubleshooting](#troubleshooting)

### Install

For the upstream pub.dev package, add the current compatible version to `pubspec.yaml`:

```yaml
dependencies:
  youtube_explode_dart: ^3.1.0
```

Import the library:

```dart
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
```

### Getting video metadata

```dart
final yt = YoutubeExplode();

final video = await yt.videos.get(
  'https://youtube.com/watch?v=Dpp1sIL1m5Q',
);

print(video.title);
print(video.author);
print(video.duration);
```

A video ID, URL string, or `VideoId` can be supplied where supported.

### Downloading a video stream

Streams are grouped into these main categories:

- muxed streams contain audio and video, generally at limited quality;
- audio-only streams contain audio only;
- video-only streams contain video only;
- HLS streams use playlists and media segments.

Resolve a manifest:

```dart
final yt = YoutubeExplode();
final manifest = await yt.videos.streams.getManifest('Dpp1sIL1m5Q');

print(manifest);
```

Callers can explicitly select one or more YouTube client profiles:

```dart
final manifest = await yt.videos.streams.getManifest(
  videoId,
  ytClients: const [
    YoutubeApiClient.visionOs,
  ],
);
```

When multiple clients are supplied, their streams are processed and merged. Do not add a long list of known-broken clients as a fallback strategy; it increases latency and obscures failures.

Choose a stream:

```dart
final audio = manifest.audioOnly.withHighestBitrate();
final video = manifest.videoOnly
    .where((stream) => stream.container == StreamContainer.mp4)
    .bestQuality;
final muxed = manifest.muxed.bestQuality;
```

Download the selected stream:

```dart
final stream = yt.videos.streams.get(audio);
final file = File(filePath);
final output = file.openWrite();

await stream.pipe(output);
await output.flush();
await output.close();
```

Muxed streams are normally limited compared with separate adaptive audio/video streams. For maximum quality, download audio-only and video-only streams separately and combine them with a media tool such as FFmpeg.

### Using a signature solver

Some YouTube clients require JavaScript challenge solving. This requires a supported JavaScript runtime. The currently implemented runtime is Deno:

```dart
import 'package:youtube_explode_dart/solvers.dart';

final solver = await DenoEJSSolver.init();
final yt = YoutubeExplode(jsSolver: solver);
```

Signature/`n` solving and PO-token support are separate concerns. A JavaScript solver does not automatically satisfy a client that requires a PO token.

### Working with playlists

```dart
final yt = YoutubeExplode();
final playlist = await yt.playlists.get('xxxxx');

print(playlist.title);
print(playlist.author);

await for (final video in yt.playlists.getVideos(playlist.id)) {
  print(video.title);
  print(video.author);
}
```

### Extracting closed captions

```dart
final yt = YoutubeExplode();
final manifest = await yt.videos.closedCaptions.getManifest('_QdPW8JrYzQ');
final trackInfo = manifest.getByLanguage('en');

if (trackInfo != null) {
  final track = await yt.videos.closedCaptions.get(trackInfo);
  final caption = track.getByTime(const Duration(seconds: 61));
  print(caption?.text);
}
```

### Getting related videos

```dart
final video = await yt.videos.get(
  'https://youtube.com/watch?v=Dpp1sIL1m5Q',
);

var related = await yt.videos.getRelatedVideos(video);
print(related);

related = await related?.nextPage();
```

`getRelatedVideos` and `nextPage` return `null` when no result/page is available.

### Getting comments

```dart
final comments = await yt.videos.comments.getComments(video);

for (final comment in comments) {
  print(comment.text);
}

final nextPage = await comments.nextPage();
```

Replies can be retrieved with `comments.getReplies(comment)`.

### Cleanup

Close `YoutubeExplode` when finished so its HTTP client and resources are released:

```dart
yt.close();
```

### Troubleshooting

Before reporting a problem:

1. reproduce it with a minimal standalone example;
2. check the upstream and fork issues/PRs;
3. identify whether player/manifest parsing succeeded and whether actual media bytes succeeded;
4. remove credentials, visitor data, tokens, and signed media URLs from logs;
5. follow [`docs/incident-runbook.md`](docs/incident-runbook.md).

Enable logging when needed:

```dart
import 'package:logging/logging.dart';

Logger.root.level = Level.FINER;
Logger.root.onRecord.listen((record) {
  print(record);
  if (record.error != null) {
    print(record.error);
    print(record.stackTrace);
  }
});
```

Do not publish logs containing cookies, authorization headers, PO tokens, visitor/account identifiers, or complete signed `googlevideo` URLs.

### Examples and API documentation

More examples are available in the [`example`][Examples] directory. Upstream API documentation is published on [pub.dev][API]. The `test/` directory also demonstrates many supported operations.

## Credits

- [Tyrrrz] for creating YoutubeExplode in C#.
- [Hexer10] for the Dart port and upstream maintenance.
- [yt-dlp] and other extractor maintainers for protocol research and implementation evidence.
- All upstream and fork contributors whose work is attributed in commits, PRs, and the maintenance source registry.

[YoutubeExplode]: https://github.com/Tyrrrz/YoutubeExplode/
[API]: https://pub.dev/documentation/youtube_explode_dart/latest/youtube_explode/youtube_explode-library.html
[Examples]: https://github.com/Hexer10/youtube_explode_dart/tree/master/example
[Tyrrrz]: https://github.com/Tyrrrz/
[Hexer10]: https://github.com/Hexer10/
[yt-dlp]: https://github.com/yt-dlp/yt-dlp
