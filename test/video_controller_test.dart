import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:youtube_explode_dart/src/videos/video_controller.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  test('VisionOS player request keeps a coherent request-scoped identity',
      () async {
    final originalPayload = jsonEncode(YoutubeApiClient.visionOs.payload);
    final transport = _RecordingClient();
    final httpClient = YoutubeHttpClient(transport);
    final controller = VideoController(httpClient);

    final response = await controller.getPlayerResponse(
      VideoId('mKdjycj-7eE'),
      YoutubeApiClient.visionOs,
    );

    expect(response.isVideoPlayable, isTrue);
    expect(jsonEncode(YoutubeApiClient.visionOs.payload), originalPayload);

    final profileClient = YoutubeApiClient.visionOs.payload['context']['client']
        as Map<String, dynamic>;
    expect(profileClient['clientName'], 'VISIONOS');
    expect(profileClient['clientVersion'], '1.02');
    expect(profileClient['deviceMake'], 'Apple');
    expect(profileClient['deviceModel'], 'RealityDevice17,1');
    expect(profileClient['osName'], 'visionOS');
    expect(profileClient.containsKey('visitorData'), isFalse);

    expect(transport.requests, hasLength(2));

    final visitorRequest = transport.requests.first;
    expect(visitorRequest.method, 'GET');
    expect(visitorRequest.url.path, '/sw.js_data');
    expect(
      visitorRequest.header('user-agent'),
      profileClient['userAgent'],
    );

    final playerRequest = transport.requests.last;
    expect(playerRequest.method, 'POST');
    expect(playerRequest.url.path, '/youtubei/v1/player');
    expect(playerRequest.header('x-goog-visitor-id'), 'test-visitor-data');
    expect(playerRequest.header('x-youtube-client-name'), 'VISIONOS');
    expect(playerRequest.header('x-youtube-client-version'), '1.02');
    expect(playerRequest.header('user-agent'), profileClient['userAgent']);

    final body = jsonDecode(playerRequest.body) as Map<String, dynamic>;
    final context = body['context'] as Map<String, dynamic>;
    final requestClient = context['client'] as Map<String, dynamic>;
    expect(requestClient['visitorData'], 'test-visitor-data');
    expect(requestClient['clientName'], 'VISIONOS');
    expect(requestClient['clientVersion'], '1.02');

    httpClient.close();
  });
}

class _RecordingClient extends http.BaseClient {
  final List<_RecordedRequest> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final recorded = _RecordedRequest(
      request.method,
      request.url,
      Map<String, String>.from(request.headers),
      request is http.Request ? request.body : '',
    );
    requests.add(recorded);

    if (request.url.path == '/sw.js_data') {
      final leaf = List<dynamic>.filled(14, null);
      leaf[13] = 'test-visitor-data';
      final body = jsonEncode([
        [
          null,
          null,
          [
            [leaf]
          ]
        ]
      ]);
      return _response(request, ")]}'$body");
    }

    if (request.url.path == '/youtubei/v1/player') {
      return _response(
        request,
        jsonEncode({
          'playabilityStatus': {'status': 'OK'},
          'videoDetails': <String, dynamic>{},
        }),
      );
    }

    throw StateError('Unexpected request: ${request.method} ${request.url}');
  }
}

http.StreamedResponse _response(http.BaseRequest request, String body) {
  final bytes = utf8.encode(body);
  return http.StreamedResponse(
    Stream.value(bytes),
    200,
    contentLength: bytes.length,
    headers: const {'content-type': 'application/json'},
    request: request,
  );
}

class _RecordedRequest {
  final String method;
  final Uri url;
  final Map<String, String> headers;
  final String body;

  const _RecordedRequest(this.method, this.url, this.headers, this.body);

  String? header(String name) {
    final target = name.toLowerCase();
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == target) return entry.value;
    }
    return null;
  }
}
