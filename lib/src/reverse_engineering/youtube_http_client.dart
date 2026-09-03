import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../exceptions/exceptions.dart';
import '../extensions/helpers_extension.dart';
import '../retry.dart';
import '../videos/streams/mixins/hls_stream_info.dart';
import '../videos/streams/streams.dart';
import 'hls_manifest.dart';

/// HTTP client wrapper for YouTube requests.
class YoutubeHttpClient extends http.BaseClient {
  final http.Client _httpClient;
  static final _logger = Logger('YoutubeExplode.HttpClient');

  bool _closed = false;

  bool get closed => _closed;

  static const Map<String, String> defaultHeaders = {
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.18 Safari/537.36',
    'cookie': 'CONSENT=YES+cb',
    'accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'accept-language': 'en-US,en;q=0.5',
  };

  /// Allows custom clients to override the default headers.
  Map<String, String> get headers => defaultHeaders;

  YoutubeHttpClient([http.Client? httpClient])
      : _httpClient = httpClient ?? http.Client();

  void _validateResponse(http.BaseResponse response, int statusCode) {
    if (_closed) return;

    final request = response.request;
    if (request != null &&
        request.url.host.endsWith('.google.com') &&
        request.url.path.startsWith('/sorry/')) {
      throw RequestLimitExceededException.httpRequest(response);
    }

    if (statusCode >= 500) {
      throw TransientFailureException.httpRequest(response);
    }

    if (statusCode == 429) {
      throw RequestLimitExceededException.httpRequest(response);
    }

    if (statusCode >= 400) {
      throw FatalFailureException.httpRequest(response);
    }
  }

  Future<String> getString(
    dynamic url, {
    Map<String, String> headers = const {},
    bool validate = true,
  }) async {
    final response =
        await get(url is String ? Uri.parse(url) : url, headers: headers);
    if (_closed) throw HttpClientClosedException();

    if (validate) {
      _validateResponse(response, response.statusCode);
    }

    return response.body;
  }

  @override
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers = const {},
    bool validate = false,
  }) async {
    final response = await super.get(url, headers: headers);
    if (_closed) throw HttpClientClosedException();

    if (validate) {
      _validateResponse(response, response.statusCode);
    }

    return response;
  }

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool validate = false,
  }) async {
    final response =
        await super.post(url, headers: headers, body: body, encoding: encoding);
    if (_closed) throw HttpClientClosedException();

    if (validate) {
      _validateResponse(response, response.statusCode);
    }
    return response;
  }

  Future<String> postString(
    dynamic url, {
    Map<String, dynamic>? body,
    Map<String, String> headers = const {},
    bool validate = true,
  }) async {
    assert(url is String || url is Uri);
    if (url is String) {
      url = Uri.parse(url);
    }
    final response = await post(url, headers: headers, body: json.encode(body));
    if (_closed) throw HttpClientClosedException();

    if (validate) {
      _validateResponse(response, response.statusCode);
    }

    return response.body;
  }

  /// Fetches a small, real media response to prove that [streamInfo] is
  /// accessible with [headers].
  ///
  /// This is intentionally stronger than a manifest parse or plain HEAD
  /// request. It validates the same range/fragment/HLS path used by download.
  Future<void> validateMediaStream(
    StreamInfo streamInfo, {
    Map<String, String> headers = const {},
    int probeBytes = 1024,
  }) async {
    if (probeBytes <= 0) {
      throw ArgumentError.value(probeBytes, 'probeBytes', 'Must be positive');
    }

    if (streamInfo.fragments.isNotEmpty) {
      final fragment = streamInfo.fragments.first;
      final response = await retry(
        this,
        () => get(
          Uri.parse(streamInfo.url.toString() + fragment.path),
          headers: headers,
          validate: true,
        ),
      );
      if (response.bodyBytes.isEmpty) {
        throw YoutubeExplodeException(
          'Stream ${streamInfo.tag} returned no media bytes.',
        );
      }
      return;
    }

    if (streamInfo is HlsStreamInfo) {
      try {
        final bytes = await _getHlsStream(
          streamInfo,
          headers: headers,
          validate: true,
        ).first;
        if (bytes.isEmpty) {
          throw YoutubeExplodeException(
            'HLS stream ${streamInfo.tag} returned no media bytes.',
          );
        }
      } on StateError {
        throw YoutubeExplodeException(
          'HLS stream ${streamInfo.tag} returned no media segments.',
        );
      }
      return;
    }

    final totalBytes = streamInfo.size.totalBytes;
    if (totalBytes <= 0) {
      throw YoutubeExplodeException(
        'Stream ${streamInfo.tag} has no valid content length.',
      );
    }

    final lastByte = totalBytes > probeBytes ? probeBytes - 1 : totalBytes - 1;
    final response = await retry(
      this,
      () => send(
        _createRangeRequest(
          streamInfo.url,
          0,
          lastByte,
          headers,
        ),
      ),
    );
    _validateResponse(response, response.statusCode);

    final firstChunk = await response.stream.firstWhere(
      (data) => data.isNotEmpty,
      orElse: () => const <int>[],
    );
    if (firstChunk.isEmpty) {
      throw YoutubeExplodeException(
        'Stream ${streamInfo.tag} returned no media bytes.',
      );
    }
  }

  Stream<List<int>> getStream(
    StreamInfo streamInfo, {
    Map<String, String> headers = const {},
    bool validate = true,
    int start = 0,
    int errorCount = 0,
    required StreamClient streamClient,
    Map<String, String> Function(StreamInfo streamInfo)? resolveHeaders,
  }) {
    if (streamInfo.fragments.isNotEmpty) {
      return _getFragmentedStream(
        streamInfo,
        headers: headers,
        validate: validate,
        start: start,
        errorCount: errorCount,
      );
    }
    if (streamInfo is HlsStreamInfo) {
      return _getHlsStream(
        streamInfo,
        headers: headers,
        validate: validate,
      );
    }
    return _getStream(
      streamInfo,
      streamClient: streamClient,
      headers: headers,
      validate: validate,
      start: start,
      errorCount: errorCount,
      resolveHeaders: resolveHeaders,
    );
  }

  Stream<List<int>> _getFragmentedStream(
    StreamInfo streamInfo, {
    Map<String, String> headers = const {},
    bool validate = true,
    int start = 0,
    int errorCount = 0,
  }) async* {
    final url = streamInfo.url;
    for (final fragment in streamInfo.fragments) {
      final response = await retry(
        this,
        () => get(
          Uri.parse(url.toString() + fragment.path),
          headers: headers,
          validate: validate,
        ),
      );
      yield response.bodyBytes;
    }
  }

  http.Request _createRangeRequest(
    Uri url,
    int from,
    int to,
    Map<String, String> headers,
  ) {
    late final http.Request request;
    if (url.queryParameters['c'] == 'ANDROID') {
      request = http.Request('GET', url);
      request.headers['Range'] = 'bytes=$from-$to';
    } else {
      request = http.Request('GET', url.setQueryParam('range', '$from-$to'));
    }
    request.headers.addAll(headers);
    return request;
  }

  Stream<List<int>> _getStream(
    StreamInfo streamInfo, {
    Map<String, String> headers = const {},
    bool validate = true,
    int start = 0,
    int errorCount = 0,
    int refreshCount = 0,
    required StreamClient streamClient,
    Map<String, String> Function(StreamInfo streamInfo)? resolveHeaders,
  }) async* {
    var url = streamInfo.url;
    var bytesCount = start;

    while (!_closed && bytesCount < streamInfo.size.totalBytes) {
      try {
        final response = await retry(this, () async {
          final from = bytesCount;
          final to = (streamInfo.isThrottled
                  ? bytesCount + 10379935
                  : streamInfo.size.totalBytes) -
              1;
          return send(_createRangeRequest(url, from, to, headers));
        });

        if (validate) {
          try {
            _validateResponse(response, response.statusCode);
          } on FatalFailureException {
            if (refreshCount >= 1) rethrow;

            final newManifest =
                await streamClient.getManifest(streamInfo.videoId);
            final replacement = newManifest.streams
                .firstWhereOrNull((stream) => stream.tag == streamInfo.tag);
            if (replacement == null) {
              _logger.severe(
                'Could not find stream ${streamInfo.tag} in the refreshed manifest.',
              );
              rethrow;
            }

            url = replacement.url;
            headers = resolveHeaders?.call(replacement) ?? headers;
            refreshCount++;
            continue;
          }
        }

        await for (final data in response.stream) {
          bytesCount += data.length;
          yield data;
        }
        errorCount = 0;
      } on HttpClientClosedException {
        break;
      } on RequestLimitExceededException {
        rethrow;
      } on FatalFailureException {
        rethrow;
      } on Exception {
        if (errorCount >= 5) rethrow;

        await Future.delayed(const Duration(milliseconds: 500));
        yield* _getStream(
          streamInfo,
          streamClient: streamClient,
          headers: headers,
          validate: validate,
          start: bytesCount,
          errorCount: errorCount + 1,
          refreshCount: refreshCount,
          resolveHeaders: resolveHeaders,
        );
        break;
      }
    }
  }

  Future<int?> getContentLength(
    dynamic url, {
    Map<String, String> headers = const {},
    bool validate = true,
  }) async {
    final response = await head(url, headers: headers);
    if (_closed) throw HttpClientClosedException();

    if (validate) {
      _validateResponse(response, response.statusCode);
    }

    return int.tryParse(response.headers['content-length'] ?? '');
  }

  Future<JsonMap> sendContinuation(
    String action,
    String token, {
    Map<String, String>? headers,
  }) async =>
      sendPost(action, {'continuation': token}, headers: headers);

  Future<JsonMap> sendPost(
    String action,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) {
    assert(action == 'next' || action == 'browse' || action == 'search');

    final url = Uri.parse(
      'https://www.youtube.com/youtubei/v1/$action?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8',
    );

    final body = {
      'context': const {
        'client': {
          'browserName': 'Chrome',
          'browserVersion': '105.0.0.0',
          'clientFormFactor': 'UNKNOWN_FORM_FACTOR',
          'clientName': 'WEB',
          'clientVersion': '2.20220921.00.00',
        },
      },
      ...data,
    };

    return retry<JsonMap>(this, () async {
      final raw = await post(url, body: json.encode(body), headers: headers);
      if (_closed) throw HttpClientClosedException();
      return json.decode(raw.body) as JsonMap;
    });
  }

  Stream<List<int>> _getHlsStream(
    HlsStreamInfo stream, {
    Map<String, String> headers = const {},
    bool validate = true,
  }) async* {
    final videoIndex = await getString(
      stream.url,
      headers: headers,
      validate: validate,
    );
    final video = HlsManifest.parseVideoSegments(videoIndex);
    for (final segment in video) {
      final data = await get(
        Uri.parse(segment.url),
        headers: headers,
        validate: validate,
      );
      yield data.bodyBytes;
    }
  }

  @override
  void close() {
    _closed = true;
    _httpClient.close();
  }

  String _safeRequestTarget(Uri url) => '${url.scheme}://${url.host}${url.path}';

  Map<String, String> _redactedHeaders(Map<String, String> input) {
    const sensitiveHeaders = {
      'authorization',
      'cookie',
      'set-cookie',
      'x-goog-visitor-id',
      'x-youtube-identity-token',
      'po-token',
    };

    return input.map((key, value) {
      final redacted = sensitiveHeaders.contains(key.toLowerCase());
      return MapEntry(key, redacted ? '[REDACTED]' : value);
    });
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_closed) throw HttpClientClosedException();

    headers.forEach((key, value) {
      if (!request.headers.containsKey(key)) {
        request.headers[key] = value;
      }
    });

    _logger.fine(
      'Sending ${request.method} request to ${_safeRequestTarget(request.url)}',
      null,
      StackTrace.current,
    );
    _logger.finer('Request headers: ${_redactedHeaders(request.headers)}');
    if (request is http.Request && request.body.isNotEmpty) {
      _logger.finer('Request body length: ${request.bodyBytes.length} bytes');
    }

    return _httpClient.send(request);
  }
}
