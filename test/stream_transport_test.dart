import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:youtube_explode_dart/src/reverse_engineering/models/fragment.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  group('YoutubeApiClient media identity', () {
    test('VisionOS exposes its numeric client id and media user agent', () {
      final client = YoutubeApiClient.visionOs;

      expect(client.clientName, 'VISIONOS');
      expect(client.clientVersion, '1.02');
      expect(client.clientHeaderName, '101');
      expect(
        client.mediaRequestHeaders['User-Agent'],
        contains('Safari/605.1.15'),
      );
    });

    test('serialization preserves optional client media metadata', () {
      const client = YoutubeApiClient(
        {
          'context': {
            'client': {
              'clientName': 'TEST',
              'clientVersion': '1.0',
              'userAgent': 'test-agent',
            },
          },
        },
        'https://www.youtube.com/youtubei/v1/player',
        clientId: 123,
        mediaHeaders: {'X-Media-Test': 'enabled'},
      );

      final decoded = YoutubeApiClient.fromJson(client.toJson());

      expect(decoded.clientHeaderName, '123');
      expect(decoded.mediaRequestHeaders, {
        'User-Agent': 'test-agent',
        'X-Media-Test': 'enabled',
      });
    });
  });

  group('media transport', () {
    test('media probe performs a real bounded range request with headers',
        () async {
      final recorder = _RecordingClient((request, _) {
        return _response(request, const [1, 2, 3], statusCode: 206);
      });
      final client = YoutubeHttpClient(recorder);

      await client.validateMediaStream(
        _audioStream(size: 4096),
        headers: const {
          'User-Agent': 'visionos-agent',
          'X-Media-Test': 'probe',
        },
      );

      expect(recorder.requests, hasLength(1));
      final request = recorder.requests.single;
      expect(request.method, 'GET');
      expect(request.url.queryParameters['range'], '0-1023');
      expect(request.header('user-agent'), 'visionos-agent');
      expect(request.header('x-media-test'), 'probe');

      client.close();
    });

    test('normal stream download preserves the producing client user agent',
        () async {
      final recorder = _RecordingClient((request, _) {
        return _response(request, const [1, 2, 3], statusCode: 206);
      });
      final yt = YoutubeExplode(httpClient: YoutubeHttpClient(recorder));

      final chunks = await yt.videos.streams
          .get(
            _audioStream(size: 3),
            ytClient: YoutubeApiClient.visionOs,
          )
          .toList();

      expect(chunks, [
        [1, 2, 3],
      ]);
      expect(recorder.requests, hasLength(1));
      final request = recorder.requests.single;
      expect(request.url.queryParameters['range'], '0-2');
      expect(
        request.header('user-agent'),
        YoutubeApiClient.visionOs.mediaRequestHeaders['User-Agent'],
      );

      yt.close();
    });

    test('explicit download headers override client-derived values', () async {
      final recorder = _RecordingClient((request, _) {
        return _response(request, const [1, 2, 3], statusCode: 206);
      });
      final yt = YoutubeExplode(httpClient: YoutubeHttpClient(recorder));

      await yt.videos.streams
          .get(
            _audioStream(size: 3),
            ytClient: YoutubeApiClient.visionOs,
            headers: const {
              'User-Agent': 'caller-agent',
              'X-Media-Test': 'caller',
            },
          )
          .toList();

      final request = recorder.requests.single;
      expect(request.header('user-agent'), 'caller-agent');
      expect(request.header('x-media-test'), 'caller');

      yt.close();
    });

    test('fragmented downloads preserve media headers', () async {
      final recorder = _RecordingClient((request, _) {
        return _response(request, const [4, 5, 6]);
      });
      final yt = YoutubeExplode(httpClient: YoutubeHttpClient(recorder));

      final chunks = await yt.videos.streams
          .get(
            _fragmentedVideoStream(),
            headers: const {'X-Media-Test': 'fragment'},
          )
          .toList();

      expect(chunks, [
        [4, 5, 6],
      ]);
      expect(recorder.requests, hasLength(1));
      expect(
        recorder.requests.single.url,
        Uri.parse('https://media.example/videoplayback/segment-0'),
      );
      expect(
        recorder.requests.single.header('x-media-test'),
        'fragment',
      );

      yt.close();
    });

    test('HLS playlist and segment requests preserve media headers', () async {
      const playlist = '#EXTM3U\n'
          '#EXT-X-VERSION:3\n'
          '#EXT-X-PLAYLIST-TYPE:VOD\n'
          '#EXT-X-TARGETDURATION:10\n'
          '#EXTINF:1.0,\n'
          'https://media.example/segment.ts\n'
          '#EXT-X-ENDLIST';

      final recorder = _RecordingClient((request, index) {
        if (index == 0) {
          return _response(request, utf8.encode(playlist));
        }
        return _response(request, const [7, 8, 9]);
      });
      final yt = YoutubeExplode(httpClient: YoutubeHttpClient(recorder));

      final chunks = await yt.videos.streams
          .get(
            _hlsAudioStream(),
            headers: const {'X-Media-Test': 'hls'},
          )
          .toList();

      expect(chunks, [
        [7, 8, 9],
      ]);
      expect(recorder.requests, hasLength(2));
      expect(
        recorder.requests[0].url,
        Uri.parse('https://media.example/audio.m3u8'),
      );
      expect(
        recorder.requests[1].url,
        Uri.parse('https://media.example/segment.ts'),
      );
      expect(recorder.requests[0].header('x-media-test'), 'hls');
      expect(recorder.requests[1].header('x-media-test'), 'hls');

      yt.close();
    });
  });
}

AudioOnlyStreamInfo _audioStream({required int size}) => AudioOnlyStreamInfo(
      VideoId('mKdjycj-7eE'),
      140,
      Uri.parse('https://media.example/videoplayback?c=VISIONOS'),
      StreamContainer.mp4,
      FileSize(size),
      const Bitrate(128000),
      'mp4a.40.2',
      'medium',
      const [],
      MediaType('audio', 'mp4'),
      null,
    );

VideoOnlyStreamInfo _fragmentedVideoStream() => VideoOnlyStreamInfo(
      VideoId('mKdjycj-7eE'),
      137,
      Uri.parse('https://media.example/videoplayback'),
      StreamContainer.mp4,
      const FileSize(3),
      const Bitrate(1000000),
      'avc1.640028',
      '1080p',
      VideoQuality.high1080,
      const VideoResolution(1920, 1080),
      const Framerate(30),
      const [Fragment('/segment-0')],
      MediaType('video', 'mp4'),
    );

HlsAudioStreamInfo _hlsAudioStream() => HlsAudioStreamInfo(
      VideoId('mKdjycj-7eE'),
      140,
      Uri.parse('https://media.example/audio.m3u8'),
      StreamContainer.m3u8,
      const FileSize(3),
      const Bitrate(128000),
      'mp4a.40.2',
      'medium',
      MediaType('application', 'vnd.apple.mpegurl'),
    );

http.StreamedResponse _response(
  http.BaseRequest request,
  List<int> body, {
  int statusCode = 200,
}) =>
    http.StreamedResponse(
      Stream.value(body),
      statusCode,
      contentLength: body.length,
      request: request,
    );

typedef _Responder = FutureOr<http.StreamedResponse> Function(
  http.BaseRequest request,
  int requestIndex,
);

class _RecordingClient extends http.BaseClient {
  final _Responder _responder;
  final List<_RecordedRequest> requests = [];

  _RecordingClient(this._responder);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final requestIndex = requests.length;
    requests.add(
      _RecordedRequest(
        request.method,
        request.url,
        Map<String, String>.from(request.headers),
      ),
    );
    return _responder(request, requestIndex);
  }
}

class _RecordedRequest {
  final String method;
  final Uri url;
  final Map<String, String> headers;

  const _RecordedRequest(this.method, this.url, this.headers);

  String? header(String name) {
    final lowerName = name.toLowerCase();
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == lowerName) {
        return entry.value;
      }
    }
    return null;
  }
}
