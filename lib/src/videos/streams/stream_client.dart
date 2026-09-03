import 'dart:collection';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../../exceptions/exceptions.dart';
import '../../extensions/helpers_extension.dart';
import '../../retry.dart';
import '../../reverse_engineering/challenges/js_challenge.dart';
import '../../reverse_engineering/heuristics.dart';
import '../../reverse_engineering/models/stream_info_provider.dart';
import '../../reverse_engineering/pages/watch_page.dart';
import '../../reverse_engineering/youtube_http_client.dart';
import '../video_id.dart';
import '../youtube_api_client.dart';
import 'stream_controller.dart';
import 'streams.dart';

/// Queries related to media streams of YouTube videos.
class StreamClient {
  static final _logger = Logger('YoutubeExplode.StreamsClient');

  final YoutubeHttpClient _httpClient;
  final StreamController _controller;
  final BaseJSChallengeSolver? _jsChallengeSolver;

  /// Weakly associates a stream object with the media headers of the client
  /// that produced it. This avoids changing every public StreamInfo model and
  /// does not keep manifests alive after callers release them.
  final Expando<Map<String, String>> _mediaHeadersByStream =
      Expando<Map<String, String>>('youtubeMediaHeaders');

  StreamClient(this._httpClient, {BaseJSChallengeSolver? jsSolver})
      : _controller = StreamController(_httpClient),
        _jsChallengeSolver = jsSolver;

  /// Gets the manifest containing media streams for [videoId].
  ///
  /// When [ytClients] is omitted, this fork uses
  /// [YoutubeApiClient.visionOs] as its primary anonymous client. If a JS
  /// solver is configured, [YoutubeApiClient.safari] is also evaluated. The
  /// existing TV fallback is attempted only when all implicit clients fail.
  ///
  /// Explicit [ytClients] are processed exactly in the supplied order and no
  /// hidden fallback is appended.
  ///
  /// The client is accepted only after representative media bytes are fetched;
  /// a parsed manifest or successful HEAD response is not sufficient.
  Future<StreamManifest> getManifest(
    dynamic videoId, {
    @Deprecated(
      'Use the ytClients parameter and pass the required YoutubeApiClient profiles.',
    )
    bool fullManifest = false,
    List<YoutubeApiClient>? ytClients,
    bool requireWatchPage = true,
  }) async {
    assert(
      ytClients == null || ytClients.isNotEmpty,
      'ytClients cannot be an empty list',
    );

    videoId = VideoId.fromString(videoId);
    final clients = ytClients ?? <YoutubeApiClient>[YoutubeApiClient.visionOs];

    if (_jsChallengeSolver != null && ytClients == null) {
      clients.add(YoutubeApiClient.safari);
    }

    final uniqueStreams = LinkedHashSet<StreamInfo>(
      equals: (a, b) {
        if (a.runtimeType != b.runtimeType) return false;
        if (a is AudioStreamInfo && b is AudioStreamInfo) {
          return a.tag == b.tag && a.audioTrack == b.audioTrack;
        }
        return a.tag == b.tag;
      },
      hashCode: (stream) {
        if (stream is AudioStreamInfo) {
          return stream.tag.hashCode ^ stream.audioTrack.hashCode;
        }
        return stream.tag.hashCode;
      },
    );

    Object? lastException;
    StackTrace? lastStackTrace;

    for (final client in clients) {
      final mediaHeaders = Map<String, String>.unmodifiable(
        client.mediaRequestHeaders,
      );
      _logger.fine(
        'Getting stream manifest for video $videoId with client: '
        '${client.clientName}',
      );

      try {
        await retry(_httpClient, () async {
          final streams = await _getStreams(
            videoId,
            ytClient: client,
            requireWatchPage: requireWatchPage,
          ).toList();

          if (streams.isEmpty) {
            throw VideoUnavailableException(
              'Video "$videoId" does not contain any playable streams.',
            );
          }

          await _validateRepresentativeStreams(streams, mediaHeaders);

          for (final stream in streams) {
            if (uniqueStreams.add(stream)) {
              _mediaHeadersByStream[stream] = mediaHeaders;
            }
          }
        });
      } catch (error, stackTrace) {
        _logger.severe(
          'Failed to get stream manifest for video $videoId with client: '
          '${client.clientName}. Reason: $error',
          error,
          stackTrace,
        );
        lastException = error;
        lastStackTrace = stackTrace;
      }
    }

    if (uniqueStreams.isEmpty && ytClients == null) {
      return getManifest(
        videoId,
        ytClients: const [YoutubeApiClient.tv],
        requireWatchPage: requireWatchPage,
      );
    }

    if (uniqueStreams.isEmpty) {
      if (lastException != null && lastStackTrace != null) {
        Error.throwWithStackTrace(lastException, lastStackTrace);
      }
      throw VideoUnavailableException(
        'Video "$videoId" has no available streams.',
      );
    }

    return StreamManifest(uniqueStreams.toList());
  }

  Future<void> _validateRepresentativeStreams(
    List<StreamInfo> streams,
    Map<String, String> mediaHeaders,
  ) async {
    AudioOnlyStreamInfo? audioOnly;
    VideoOnlyStreamInfo? videoOnly;

    for (final stream in streams) {
      if (audioOnly == null && stream is AudioOnlyStreamInfo) {
        audioOnly = stream;
      }
      if (videoOnly == null && stream is VideoOnlyStreamInfo) {
        videoOnly = stream;
      }
      if (audioOnly != null && videoOnly != null) break;
    }

    final candidates = <StreamInfo>[
      if (audioOnly != null) audioOnly,
      if (videoOnly != null) videoOnly,
      if (audioOnly == null && videoOnly == null) streams.first,
    ];

    for (final stream in candidates) {
      await _httpClient.validateMediaStream(
        stream,
        headers: mediaHeaders,
      );
    }
  }

  /// Gets the HTTP Live Stream (HLS) manifest URL for a live video.
  Future<String> getHttpLiveStreamUrl(VideoId videoId) async {
    final watchPage = await WatchPage.get(_httpClient, videoId.value);
    final playerResponse = watchPage.playerResponse;

    if (playerResponse == null) {
      throw TransientFailureException(
        "Couldn't extract the playerResponse from the Watch Page!",
      );
    }

    if (!playerResponse.isVideoPlayable) {
      throw VideoUnplayableException.unplayable(
        videoId,
        reason: playerResponse.videoPlayabilityError ?? '',
      );
    }

    final hlsManifest = playerResponse.hlsManifestUrl;
    if (hlsManifest == null) {
      throw VideoUnplayableException.notLiveStream(videoId);
    }
    return hlsManifest;
  }

  /// Downloads the bytes represented by [streamInfo].
  ///
  /// Streams returned directly by [getManifest] automatically retain the
  /// media headers of their producing client. If a StreamInfo has been
  /// deserialised or reconstructed, pass the original [ytClient]. Custom
  /// [headers] override both associated and client-derived values.
  Stream<List<int>> get(
    StreamInfo streamInfo, {
    YoutubeApiClient? ytClient,
    Map<String, String>? headers,
  }) {
    Map<String, String> resolveHeaders(StreamInfo stream) => {
          ...mediaRequestHeadersFor(stream),
          if (ytClient != null) ...ytClient.mediaRequestHeaders,
          if (headers != null) ...headers,
        };

    return _httpClient.getStream(
      streamInfo,
      streamClient: this,
      headers: resolveHeaders(streamInfo),
      resolveHeaders: resolveHeaders,
    );
  }

  /// Returns media headers associated with [streamInfo].
  ///
  /// This is exposed only for the low-level HTTP transport to preserve headers
  /// when a signed media URL is refreshed.
  @internal
  Map<String, String> mediaRequestHeadersFor(StreamInfo streamInfo) =>
      _mediaHeadersByStream[streamInfo] ?? const {};

  Stream<StreamInfo> _getStreams(
    VideoId videoId, {
    required YoutubeApiClient ytClient,
    bool requireWatchPage = true,
  }) async* {
    await for (final stream in _getStream(
      videoId,
      ytClient,
      requireWatchPage: requireWatchPage,
    )) {
      yield stream;
    }
  }

  Stream<StreamInfo> _getStream(
    VideoId videoId,
    YoutubeApiClient ytClient, {
    bool requireWatchPage = true,
  }) async* {
    WatchPage? watchPage;
    if (requireWatchPage) {
      watchPage = await WatchPage.get(_httpClient, videoId.value);
    }

    final playerResponse = await _controller.getPlayerResponse(
      videoId,
      ytClient,
      watchPage: watchPage,
    );

    if (!playerResponse.previewVideoId.isNullOrWhiteSpace) {
      throw VideoRequiresPurchaseException.preview(
        videoId,
        VideoId(playerResponse.previewVideoId!),
      );
    }

    if (playerResponse.videoPlayabilityError?.contains('payment') ?? false) {
      throw VideoRequiresPurchaseException(videoId);
    }

    if (!playerResponse.isVideoPlayable) {
      throw VideoUnplayableException.unplayable(
        videoId,
        reason: playerResponse.videoPlayabilityError ?? '',
      );
    }

    yield* _parseStreamInfo(
      playerResponse.streams,
      watchPage: watchPage,
      videoId: videoId,
      ytClient: ytClient,
    );

    if (!playerResponse.dashManifestUrl.isNullOrWhiteSpace) {
      final dashManifest = await _controller.getDashManifest(
        playerResponse.dashManifestUrl!,
        headers: ytClient.mediaRequestHeaders,
      );
      yield* _parseStreamInfo(
        dashManifest.streams,
        watchPage: watchPage,
        videoId: videoId,
        ytClient: ytClient,
      );
    }

    if (!playerResponse.hlsManifestUrl.isNullOrWhiteSpace) {
      final hlsManifest = await _controller.getHlsManifest(
        playerResponse.hlsManifestUrl!,
        headers: ytClient.mediaRequestHeaders,
      );
      yield* _parseStreamInfo(
        hlsManifest.streams,
        watchPage: watchPage,
        videoId: videoId,
        ytClient: ytClient,
      );
    }
  }

  Stream<StreamInfo> _parseStreamInfo(
    Iterable<StreamInfoProvider> streams, {
    WatchPage? watchPage,
    VideoId? videoId,
    required YoutubeApiClient ytClient,
  }) async* {
    final nChallenges = <String>{};
    final sigChallenges = <String>{};

    final solver = _jsChallengeSolver;
    if (solver != null) {
      for (final stream in streams) {
        try {
          final url = Uri.parse(stream.url);
          if (url.queryParameters.containsKey('n')) {
            nChallenges.add(url.queryParameters['n']!);
          }
          if (stream.signatureParameter != null) {
            sigChallenges.add(stream.signature!);
          }
        } catch (_) {
          // Invalid URLs are ignored here and handled in the parsing pass.
        }
      }
    }

    final solvedChallenges = <String, String?>{};
    if (watchPage != null &&
        solver != null &&
        (nChallenges.isNotEmpty || sigChallenges.isNotEmpty)) {
      final requests = <JSChallengeType, List<String>>{};
      if (nChallenges.isNotEmpty) {
        requests[JSChallengeType.n] = nChallenges.toList();
      }
      if (sigChallenges.isNotEmpty) {
        requests[JSChallengeType.sig] = sigChallenges.toList();
      }

      try {
        solvedChallenges.addAll(
          await solver.solveBulk(watchPage.sourceUrl!, requests),
        );
      } catch (error) {
        _logger.warning('Could not bulk solve challenges: $error');
      }
    }

    for (final stream in streams) {
      final itag = stream.tag;
      late Uri url;
      try {
        url = Uri.parse(stream.url);
      } catch (_) {
        continue;
      }

      if (solver != null && watchPage != null) {
        if (url.queryParameters.containsKey('n')) {
          final nParam = url.queryParameters['n']!;
          final decoded = solvedChallenges[nParam];
          if (decoded != null) {
            url = url.setQueryParam('n', decoded);
            _logger.fine(
              'Decoded n-sig for stream itag $itag. $nParam -> $decoded',
            );
          } else {
            try {
              final individualDecoded = await solver.solve(
                watchPage.sourceUrl!,
                JSChallengeType.n,
                nParam,
              );
              url = url.setQueryParam('n', individualDecoded);
              _logger.fine(
                'Decoded n-sig for stream itag $itag using individual solving.',
              );
            } catch (error) {
              _logger.warning('Could not decipher n-sig: $error');
            }
          }
        }

        if (stream.signatureParameter != null) {
          final sigParam = stream.signatureParameter!;
          final signature = stream.signature!;
          final decoded = solvedChallenges[signature];
          if (decoded != null) {
            url = url.setQueryParam(sigParam, decoded);
            _logger.fine('Decoded signature for stream itag $itag.');
          } else {
            try {
              final individualDecoded = await solver.solve(
                watchPage.sourceUrl!,
                JSChallengeType.sig,
                signature,
              );
              url = url.setQueryParam(sigParam, individualDecoded);
              _logger.fine(
                'Decoded signature for stream itag $itag using individual solving.',
              );
            } catch (error) {
              _logger.warning('Could not decipher signature: $error');
            }
          }
        }
      }

      final contentLength = stream.contentLength ??
          (await _httpClient.getContentLength(
            url,
            headers: ytClient.mediaRequestHeaders,
            validate: false,
          )) ??
          0;

      if (contentLength <= 0) {
        continue;
      }

      final container = StreamContainer.parse(stream.container!);
      final fileSize = FileSize(contentLength);
      final bitrate = Bitrate(stream.bitrate!);

      final audioCodec = stream.audioCodec;
      final videoCodec = stream.videoCodec;

      if (stream.source == StreamSource.hls) {
        if (stream.audioOnly) {
          yield HlsAudioStreamInfo(
            videoId ?? watchPage!.videoId,
            itag,
            url,
            container,
            fileSize,
            bitrate,
            '',
            '',
            stream.codec,
          );
          continue;
        }

        final framerate = Framerate(stream.framerate ?? 24);
        final videoQuality = VideoQualityUtil.fromLabel(stream.qualityLabel);
        final videoWidth = stream.videoWidth;
        final videoHeight = stream.videoHeight;
        final videoResolution = videoWidth != null && videoHeight != null
            ? VideoResolution(videoWidth, videoHeight)
            : videoQuality.toVideoResolution();

        if (stream.videoOnly) {
          yield HlsVideoStreamInfo(
            videoId ?? watchPage!.videoId,
            itag,
            url,
            container,
            fileSize,
            bitrate,
            videoCodec ?? '',
            videoQuality.qualityString,
            videoQuality,
            videoResolution,
            framerate,
            stream.codec,
            stream.audioItag,
          );
        } else {
          yield HlsMuxedStreamInfo(
            videoId ?? watchPage!.videoId,
            itag,
            url,
            container,
            fileSize,
            bitrate,
            audioCodec!,
            videoCodec!,
            videoQuality.qualityString,
            videoQuality,
            videoResolution,
            framerate,
            stream.codec,
          );
        }
        continue;
      }

      if (!videoCodec.isNullOrWhiteSpace) {
        final framerate = Framerate(stream.framerate ?? 24);
        final videoQuality = VideoQualityUtil.fromLabel(stream.qualityLabel);
        final videoWidth = stream.videoWidth;
        final videoHeight = stream.videoHeight;
        final videoResolution = videoWidth != null && videoHeight != null
            ? VideoResolution(videoWidth, videoHeight)
            : videoQuality.toVideoResolution();

        if (!audioCodec.isNullOrWhiteSpace &&
            stream.source != StreamSource.adaptive) {
          assert(stream.audioTrack == null);
          yield MuxedStreamInfo(
            videoId ?? watchPage!.videoId,
            itag,
            url,
            container,
            fileSize,
            bitrate,
            audioCodec!,
            videoCodec!,
            videoQuality.qualityString,
            videoQuality,
            videoResolution,
            framerate,
            stream.codec,
          );
          continue;
        }

        yield VideoOnlyStreamInfo(
          videoId ?? watchPage!.videoId,
          itag,
          url,
          container,
          fileSize,
          bitrate,
          videoCodec!,
          videoQuality.qualityString,
          videoQuality,
          videoResolution,
          framerate,
          stream.fragments ?? const [],
          stream.codec,
        );
        continue;
      }

      if (!audioCodec.isNullOrWhiteSpace) {
        yield AudioOnlyStreamInfo(
          videoId ?? watchPage!.videoId,
          itag,
          url,
          container,
          fileSize,
          bitrate,
          audioCodec!,
          stream.qualityLabel!,
          stream.fragments ?? const [],
          stream.codec,
          stream.audioTrack,
        );
        continue;
      }

      throw YoutubeExplodeException('Could not extract stream codec');
    }
  }
}
